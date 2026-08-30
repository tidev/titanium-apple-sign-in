<?php

// config/apple.php
// Adicione as variáveis correspondentes no seu .env

return [
    'team_id'     => env('APPLE_TEAM_ID'),
    'key_id'      => env('APPLE_KEY_ID'),
    'bundle_id'   => env('APPLE_BUNDLE_ID'),

    // Conteúdo do arquivo .p8 — no .env use \n para quebras de linha:
    // APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIGH...\n-----END PRIVATE KEY-----"
    'private_key' => str_replace('\\n', "\n", env('APPLE_PRIVATE_KEY', '')),
];
