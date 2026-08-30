import os
import jwt
import time
import requests
from flask import Blueprint, request, jsonify

bp = Blueprint('apple_auth', __name__)

# ─── Configurações ────────────────────────────────────────────────────────────
APPLE_TEAM_ID      = os.getenv('APPLE_TEAM_ID')
APPLE_KEY_ID       = os.getenv('APPLE_KEY_ID')
APPLE_BUNDLE_ID    = os.getenv('APPLE_BUNDLE_ID')
APPLE_PRIVATE_KEY  = os.getenv('APPLE_PRIVATE_KEY')

APPLE_TOKEN_URL    = 'https://appleid.apple.com/auth/token'
APPLE_REVOKE_URL   = 'https://appleid.apple.com/auth/revoke'


# ─── Helpers ──────────────────────────────────────────────────────────────────

def generate_apple_client_secret():
    """Gera o JWT client_secret exigido pela Apple (válido por 3 minutos)."""
    now = int(time.time())
    payload = {
        'iss': APPLE_TEAM_ID,
        'iat': now,
        'exp': now + 180,
        'aud': 'https://appleid.apple.com',
        'sub': APPLE_BUNDLE_ID,
    }
    return jwt.encode(
        payload,
        APPLE_PRIVATE_KEY,
        algorithm='ES256',
        headers={'kid': APPLE_KEY_ID}
    )


def exchange_code_for_refresh_token(authorization_code, client_secret):
    """
    Etapa 1: Troca o authorizationCode por um refresh_token.
    O authorizationCode expira em 5-10 min, o refresh_token dura 180 dias.
    """
    response = requests.post(
        APPLE_TOKEN_URL,
        data={
            'client_id':     APPLE_BUNDLE_ID,
            'client_secret': client_secret,
            'code':          authorization_code,
            'grant_type':    'authorization_code',
        },
        headers={'Content-Type': 'application/x-www-form-urlencoded'},
        timeout=10
    )

    data = response.json()

    if response.status_code != 200 or 'refresh_token' not in data:
        error = data.get('error', 'Unknown error')
        raise ValueError(f'Failed to exchange authorization code: {error}')

    return data['refresh_token']


def revoke_refresh_token(refresh_token, client_secret):
    """
    Etapa 2: Revoga o refresh_token na Apple.
    Isso invalida completamente a sessão do usuário.
    """
    response = requests.post(
        APPLE_REVOKE_URL,
        data={
            'client_id':        APPLE_BUNDLE_ID,
            'client_secret':    client_secret,
            'token':            refresh_token,
            'token_type_hint':  'refresh_token',
        },
        headers={'Content-Type': 'application/x-www-form-urlencoded'},
        timeout=10
    )

    # Apple retorna 200 com body vazio em caso de sucesso
    if response.status_code != 200:
        raise ValueError(f'Failed to revoke token: {response.text}')


# ─── Endpoint ─────────────────────────────────────────────────────────────────

@bp.route('/apple/revoke', methods=['POST'])
def apple_revoke():
    """
    Recebe o authorizationCode do app e executa o fluxo completo de revogação:
      1. Gera client_secret JWT
      2. Troca authorizationCode por refresh_token  (/auth/token)
      3. Revoga o refresh_token                     (/auth/revoke)
    """
    data = request.get_json()

    if not data or 'authorization_code' not in data:
        return jsonify({'success': False, 'error': 'Missing authorization_code'}), 400

    authorization_code = data['authorization_code']

    try:
        # Gera o client_secret uma vez e reutiliza nas duas chamadas
        client_secret = generate_apple_client_secret()

        # Etapa 1: authorizationCode → refresh_token
        refresh_token = exchange_code_for_refresh_token(authorization_code, client_secret)

        # Etapa 2: revoga o refresh_token
        revoke_refresh_token(refresh_token, client_secret)

        return jsonify({'success': True})

    except ValueError as e:
        return jsonify({'success': False, 'error': str(e)}), 400

    except requests.RequestException as e:
        return jsonify({'success': False, 'error': f'Network error: {str(e)}'}), 500

    except Exception as e:
        return jsonify({'success': False, 'error': f'Unexpected error: {str(e)}'}), 500