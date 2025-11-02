// lib/fastApi/agora_voice_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Model class for Agora Voice Authorization Response
class AgoraVoiceAuth {
  final String appId; // "appID" from API
  final String channelName; // "channelName"
  final String token; // "voice_token"
  final int expiresIn; // "timer"
  final String userId; // "user" (caller)

  AgoraVoiceAuth({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.expiresIn,
    required this.userId,
  });

  factory AgoraVoiceAuth.fromJson(Map<String, dynamic> j) {
    return AgoraVoiceAuth(
      appId: j['appID'] ?? '',
      channelName: j['channelName'] ?? '',
      token: j['voice_token'] ?? '',
      expiresIn: j['timer'] ?? 0,
      userId: j['user'] ?? '',
    );
  }
}

/// Handles Agora Voice Token Generation
class AgoraVoiceService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// Always pass ASTRO ID (not room_id)
  static Future<AgoraVoiceAuth> getVoiceTokenUsingAstroId(
      String astroId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('access_token') ?? '';

    debugPrint("🎧 [AgoraVoiceService] Starting token fetch...");
    debugPrint("🆔 Using astroId: $astroId");
    debugPrint("🔐 Access token present: ${bearer.isNotEmpty}");

    if (astroId.isEmpty) {
      throw Exception("❌ Astro ID is empty. Cannot generate voice token.");
    }

    final uri = Uri.parse('$_base/agora/token/voice')
        .replace(queryParameters: {'other_user_id': astroId});

    debugPrint("🌍 Final GET URL => $uri");

    final res = await http.get(
      uri,
      headers: {
        'accept': 'application/json',
        if (bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
      },
    );

    debugPrint("⬅️ [AgoraVoiceService] Response Code: ${res.statusCode}");
    debugPrint("⬅️ [AgoraVoiceService] Response Body: ${res.body}");

    if (res.statusCode == 200) {
      final parsed = jsonDecode(res.body);
      final auth = AgoraVoiceAuth.fromJson(parsed);

      debugPrint("✅ [AgoraVoiceService] Voice token fetched successfully!");
      debugPrint(
          "📦 Token: ${auth.token.substring(0, 20)}..."); // shortened for log
      debugPrint("📡 Channel: ${auth.channelName}");
      debugPrint("🕓 Validity (sec): ${auth.expiresIn}");
      return auth;
    }

    throw Exception(
        '❌ Voice token fetch failed: ${res.statusCode} ${res.body}');
  }
}
