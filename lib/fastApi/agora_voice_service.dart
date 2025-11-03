// lib/fastApi/agora_voice_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgoraVoiceAuth {
  final String appId;
  final String channelName;
  final String token;
  final String user; // string userAccount from server
  final int expiresIn;

  AgoraVoiceAuth({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.user,
    required this.expiresIn,
  });

  factory AgoraVoiceAuth.fromJson(Map<String, dynamic> j) {
    return AgoraVoiceAuth(
      appId: j['appID'] ?? j['appId'] ?? '',
      channelName: j['channelName'] ?? '',
      token: j['voice_token'] ?? j['token'] ?? '',
      user: j['user']?.toString() ?? '',
      expiresIn: (j['timer'] ?? j['expireIn'] ?? 0) as int,
    );
  }
}

class AgoraVoiceService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// GET /agora/token/voice?other_user_id=<ASTRO_ID>
  static Future<AgoraVoiceAuth> getVoiceToken({required String otherUserId}) async {
    print('🎧 [AgoraVoiceService] Starting token fetch...');
    print('🆔 Using astroId: $otherUserId');

    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('access_token') ?? '';
    print('🔐 Access token present: ${access.isNotEmpty}');

    final uri = Uri.parse('$_base/agora/token/voice')
        .replace(queryParameters: {'other_user_id': otherUserId});
    print('🌍 Final GET URL => $uri');

    final res = await http.get(
      uri,
      headers: {
        'accept': 'application/json',
        if (access.isNotEmpty) 'Authorization': 'Bearer $access',
      },
    );

    print('⬅️ [AgoraVoiceService] Response Code: ${res.statusCode}');
    print('⬅️ [AgoraVoiceService] Response Body: ${res.body}');

    if (res.statusCode == 200) {
      print('✅ [AgoraVoiceService] Voice token fetched successfully!');
      final data = AgoraVoiceAuth.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      print('📦 Token: ${data.token.substring(0, 20)}...');
      print('📡 Channel: ${data.channelName}');
      print('🕓 Validity (sec): ${data.expiresIn}');
      return data;
    }
    throw Exception('Voice token fetch failed: ${res.statusCode} ${res.body}');
  }
}
