<?php

// routes/api.php — adicione esta linha ao seu arquivo de rotas existente

use App\Http\Controllers\AppleAuthController;

Route::post('/apple/revoke', [AppleAuthController::class, 'revoke']);
