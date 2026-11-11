<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Http;
use Firebase\JWT\JWT;

class AppleAuthController extends Controller
{
    // ─── Configurações ────────────────────────────────────────────────────────

    private string $teamId;
    private string $keyId;
    private string $bundleId;
    private string $privateKey;

    private const APPLE_TOKEN_URL  = 'https://appleid.apple.com/auth/token';
    private const APPLE_REVOKE_URL = 'https://appleid.apple.com/auth/revoke';

    public function __construct()
    {
        $this->teamId     = config('apple.team_id');
        $this->keyId      = config('apple.key_id');
        $this->bundleId   = config('apple.bundle_id');
        $this->privateKey = config('apple.private_key');
    }


    // ─── Helpers ──────────────────────────────────────────────────────────────

    /**
     * Gera o JWT client_secret exigido pela Apple (válido por 3 minutos).
     */
    private function generateClientSecret(): string
    {
        $now = time();

        $payload = [
            'iss' => $this->teamId,
            'iat' => $now,
            'exp' => $now + 180,
            'aud' => 'https://appleid.apple.com',
            'sub' => $this->bundleId,
        ];

        return JWT::encode($payload, $this->privateKey, 'ES256', $this->keyId);
    }

    /**
     * Etapa 1: Troca o authorizationCode por um refresh_token.
     * O authorizationCode expira em 5-10 min, o refresh_token dura 180 dias.
     */
    private function exchangeCodeForRefreshToken(string $authorizationCode, string $clientSecret): string
    {
        $response = Http::asForm()->post(self::APPLE_TOKEN_URL, [
            'client_id'     => $this->bundleId,
            'client_secret' => $clientSecret,
            'code'          => $authorizationCode,
            'grant_type'    => 'authorization_code',
        ]);

        $data = $response->json();

        if (!isset($data['refresh_token'])) {
            $error = $data['error'] ?? 'Unknown error';
            throw new \Exception("Failed to exchange authorization code: {$error}");
        }

        return $data['refresh_token'];
    }

    /**
     * Etapa 2: Revoga o refresh_token na Apple.
     * Isso invalida completamente a sessão do usuário.
     */
    private function revokeRefreshToken(string $refreshToken, string $clientSecret): void
    {
        $response = Http::asForm()->post(self::APPLE_REVOKE_URL, [
            'client_id'       => $this->bundleId,
            'client_secret'   => $clientSecret,
            'token'           => $refreshToken,
            'token_type_hint' => 'refresh_token',
        ]);

        if ($response->status() !== 200) {
            throw new \Exception("Failed to revoke token: {$response->body()}");
        }
    }


    // ─── Endpoint ─────────────────────────────────────────────────────────────

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
    public function revoke(Request $request): JsonResponse
    {
        $request->validate([
            'authorization_code' => 'required|string',
        ]);

        try {
            // Gera o client_secret uma vez e reutiliza nas duas chamadas
            $clientSecret = $this->generateClientSecret();

            // Etapa 1: authorizationCode → refresh_token
            $refreshToken = $this->exchangeCodeForRefreshToken(
                $request->input('authorization_code'),
                $clientSecret
            );

            // Etapa 2: revoga o refresh_token
            $this->revokeRefreshToken($refreshToken, $clientSecret);

            return response()->json(['success' => true]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error'   => $e->getMessage(),
            ], 400);
        }
    }
}
