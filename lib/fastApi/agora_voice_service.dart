// lib/fastApi/agora_voice_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'agora_service.dart'; // <-- we reuse AgoraService + AgoraJoinParams

/// Thin wrapper that reuses the *video* token API for AUDIO calls.
/// This guarantees both sides join the same channel with matching
/// userAccount + token pairs.
class AgoraVoiceService {
  /// Build AUDIO join params for either role using the video-token payload.
  ///
  /// - isAstrologer = true  → token = astro_token,     account = astro_id
  /// - isAstrologer = false → token = current_user_token, account = current_user_id
  static Future<AgoraJoinParams> getAudioJoinParams({
    required String astroId,
    required bool isAstrologer,
  }) async {
    debugPrint('🎧 [AgoraVoiceService] fetching video tokens for audio… astroId=$astroId, role=${isAstrologer ? 'ASTRO' : 'CUSTOMER'}');

    // 1) Fetch the standard video tokens (your stable endpoint)
    final auth = await AgoraService.getVideoTokens(astroId);

    // 2) Convert to the token+account pair required for this role
    final params = AgoraService.buildJoinParams(auth: auth, isAstrologer: isAstrologer);

    debugPrint('✅ [AgoraVoiceService] join params → $params');
    return params;
  }

  /// Convenience helpers if you prefer explicit methods.
  static Future<AgoraJoinParams> getCustomerAudioParams(String astroId) =>
      getAudioJoinParams(astroId: astroId, isAstrologer: false);

  static Future<AgoraJoinParams> getAstrologerAudioParams(String astroId) =>
      getAudioJoinParams(astroId: astroId, isAstrologer: true);
}
