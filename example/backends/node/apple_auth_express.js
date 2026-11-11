const express = require('express');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const qs = require('qs');

const router = express.Router();

// ─── Configurações ────────────────────────────────────────────────────────────
const APPLE_TEAM_ID     = process.env.APPLE_TEAM_ID;
const APPLE_KEY_ID      = process.env.APPLE_KEY_ID;
const APPLE_BUNDLE_ID   = process.env.APPLE_BUNDLE_ID;
const APPLE_PRIVATE_KEY = process.env.APPLE_PRIVATE_KEY.replace(/\\n/g, '\n');

const APPLE_TOKEN_URL   = 'https://appleid.apple.com/auth/token';
const APPLE_REVOKE_URL  = 'https://appleid.apple.com/auth/revoke';


// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Gera o JWT client_secret exigido pela Apple (válido por 3 minutos).
 */
function generateAppleClientSecret() {
  const now = Math.floor(Date.now() / 1000);
  return jwt.sign(
    {
      iss: APPLE_TEAM_ID,
      iat: now,
      exp: now + 180,
      aud: 'https://appleid.apple.com',
      sub: APPLE_BUNDLE_ID,
    },
    APPLE_PRIVATE_KEY,
    {
      algorithm: 'ES256',
      keyid: APPLE_KEY_ID,
    }
  );
}

/**
 * Etapa 1: Troca o authorizationCode por um refresh_token.
 * O authorizationCode expira em 5-10 min, o refresh_token dura 180 dias.
 */
async function exchangeCodeForRefreshToken(authorizationCode, clientSecret) {
  const response = await axios.post(
    APPLE_TOKEN_URL,
    qs.stringify({
      client_id:     APPLE_BUNDLE_ID,
      client_secret: clientSecret,
      code:          authorizationCode,
      grant_type:    'authorization_code',
    }),
    { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
  );

  if (!response.data.refresh_token) {
    throw new Error(`Failed to exchange authorization code: ${response.data.error || 'Unknown error'}`);
  }

  return response.data.refresh_token;
}

/**
 * Etapa 2: Revoga o refresh_token na Apple.
 * Isso invalida completamente a sessão do usuário.
 */
async function revokeRefreshToken(refreshToken, clientSecret) {
  const response = await axios.post(
    APPLE_REVOKE_URL,
    qs.stringify({
      client_id:       APPLE_BUNDLE_ID,
      client_secret:   clientSecret,
      token:           refreshToken,
      token_type_hint: 'refresh_token',
    }),
    { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
  );

  if (response.status !== 200) {
    throw new Error(`Failed to revoke token: ${response.data}`);
  }
}


// ─── Endpoint ─────────────────────────────────────────────────────────────────

/**
 * POST /apple/revoke
 *
 * Body: { "authorization_code": "..." }
 *
 * Executa o fluxo completo de revogação:
 *   1. Gera client_secret JWT
 *   2. Troca authorizationCode por refresh_token  (/auth/token)
 *   3. Revoga o refresh_token                     (/auth/revoke)
 */
router.post('/apple/revoke', async (req, res) => {
  const { authorization_code } = req.body;

  if (!authorization_code) {
    return res.status(400).json({ success: false, error: 'Missing authorization_code' });
  }

  try {
    // Gera o client_secret uma vez e reutiliza nas duas chamadas
    const clientSecret = generateAppleClientSecret();

    // Etapa 1: authorizationCode → refresh_token
    const refreshToken = await exchangeCodeForRefreshToken(authorization_code, clientSecret);

    // Etapa 2: revoga o refresh_token
    await revokeRefreshToken(refreshToken, clientSecret);

    return res.json({ success: true });

  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
});

module.exports = router;
