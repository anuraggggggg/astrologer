// lib/fastApi/agora_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgoraVideoAuth {
  final String appId;
  final String channelName;
  final String currentUserToken;
  final String astroToken;

  AgoraVideoAuth({
    required this.appId,
    required this.channelName,
    required this.currentUserToken,
    required this.astroToken,
  });

  factory AgoraVideoAuth.fromJson(Map<String, dynamic> j) {
    return AgoraVideoAuth(
      appId: j['appID'] ?? j['appId'] ?? '',
      channelName: j['channelName'] ?? '',
      currentUserToken: j['current_user_token'] ?? '',
      astroToken: j['astro_token'] ?? '',
    );
  }
}

class AgoraService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// Call: GET /agora/token/video?astro_id=...
  static Future<AgoraVideoAuth> getVideoTokens(String astroId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final uri = Uri.parse('$_base/agora/token/video').replace(
      queryParameters: {'astro_id': astroId},
    );

    final res = await http.get(
      uri,
      headers: {
        'accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return AgoraVideoAuth.fromJson(jsonDecode(res.body));
    }
    throw Exception('Agora token fetch failed: ${res.statusCode} ${res.body}');
  }
}
