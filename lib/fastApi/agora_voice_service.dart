// lib/fastApi/agora_voice_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgoraVoiceAuth {
  final String appId;        // "appID"
  final String channelName;  // "channelName"
  final String? token;       // "voice_token" (nullable/empty if no certificate)
  final String user;         // "user" (string userAccount for registerLocalUserAccount)
  final int expiresIn;       // "timer" seconds

  const AgoraVoiceAuth({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.user,
    required this.expiresIn,
  });

  factory AgoraVoiceAuth.fromJson(Map<String, dynamic> j) {
    String readStr(String k) => (j[k] ?? '').toString();

    int readInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final tok = j['voice_token']?.toString() ?? j['token']?.toString() ?? '';

    final auth = AgoraVoiceAuth(
      appId: readStr('appID').isNotEmpty ? readStr('appID') : readStr('appId'),
      channelName: readStr('channelName'),
      token: tok.isNotEmpty ? tok : null, // normalize empty -> null
      user: readStr('user'),
      expiresIn: readInt(j['timer'] ?? j['expireIn']),
    );

    if (auth.appId.isEmpty || auth.channelName.isEmpty) {
      throw const FormatException('Invalid voice auth: appID/channelName missing');
    }
    return auth;
  }

  @override
  String toString() =>
      'AgoraVoiceAuth(appId=$appId, channel=$channelName, hasToken=${token != null}, user=$user, ttl=$expiresIn)';
}

class AgoraVoiceService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// GET /agora/token/voice?other_user_id=<ASTRO_ID>
  static Future<AgoraVoiceAuth> getVoiceToken({
    required String otherUserId,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    print('🎧 [AgoraVoiceService] Fetch voice token for other_user_id=$otherUserId');

    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('access_token') ?? '';

    final uri = Uri.parse('$_base/agora/token/voice')
        .replace(queryParameters: {'other_user_id': otherUserId});
    final headers = <String, String>{
      'accept': 'application/json',
      if (bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
    };

    late http.Response res;
    try {
      res = await http.get(uri, headers: headers).timeout(timeout);
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    } on HttpException catch (e) {
      throw Exception('HTTP error: $e');
    } on FormatException {
      throw Exception('Bad response from server');
    } on TimeoutException {
      throw Exception('Server timed out while fetching voice token');
    }

    print('⬅️ [AgoraVoiceService] ${res.statusCode} ${res.body}');
    if (res.statusCode == 200) {
      return AgoraVoiceAuth.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    if (res.statusCode == 401) {
      throw Exception('Unauthorized (401). Please log in again.');
    }
    throw Exception('Voice token fetch failed: ${res.statusCode} ${res.body}');
  }
}
