// lib/fastApi/agora_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// =============================================================
///                 UNIFIED AGORA TOKEN SYSTEM
///  BOTH AUDIO + VIDEO CALLS WILL USE THIS SAME MODEL + API
/// =============================================================

/// Agora token payload returned from GET /agora/token/video
/// We now use this SAME token for audio calls also.
class AgoraVideoAuth {
  final String appId;
  final String channelName;
  final String astroId;
  final String astroToken;
  final String currentUserId;
  final String currentUserToken;
  final int? expireIn;

  const AgoraVideoAuth({
    required this.appId,
    required this.channelName,
    required this.astroId,
    required this.astroToken,
    required this.currentUserId,
    required this.currentUserToken,
    this.expireIn,
  });

  factory AgoraVideoAuth.fromJson(Map<String, dynamic> j) {
    return AgoraVideoAuth(
      appId: (j['appID'] ?? j['appId'] ?? '').toString(),
      channelName: (j['channelName'] ?? j['channel_name'] ?? '').toString(),
      astroId: (j['astro_id'] ?? '').toString(),
      astroToken: (j['astro_token'] ?? '').toString(),
      currentUserId:
          (j['current_user_id'] ?? j['current_user'] ?? j['user'] ?? '').toString(),
      currentUserToken:
          (j['current_user_token'] ?? j['currentUserToken'] ?? '').toString(),
      expireIn: j['expireIn'] is int
          ? j['expireIn']
          : int.tryParse('${j['expireIn'] ?? ''}'),
    );
  }
}

/// Parameters needed to join the call.
/// Works for BOTH audio + video.
class AgoraJoinParams {
  final String appId;
  final String channel;
  final String token;
  final String account; 

  const AgoraJoinParams({
    required this.appId,
    required this.channel,
    required this.token,
    required this.account,
  });

  @override
  String toString() =>
      'AgoraJoin(appId:${appId.isNotEmpty}, channel:$channel, account:$account, token:${token.isNotEmpty})';
}

class AgoraService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  /// =============================================================
  ///              SINGLE SOURCE: GET VIDEO TOKENS
  ///   Audio call ALSO uses this — no more voice API.
  /// =============================================================
  static Future<AgoraVideoAuth> getTokens(String astroId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('access_token') ?? '';

    final uri = Uri.parse('$_base/agora/token/video')
        .replace(queryParameters: {'astro_id': astroId});

    final res = await http.get(uri, headers: {
      'accept': 'application/json',
      if (bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
    });

    if (res.statusCode != 200) {
      throw Exception(
          'Agora token fetch failed: ${res.statusCode} ${res.body}');
    }

    final json = jsonDecode(res.body);
    if (json is! Map<String, dynamic>) {
      throw Exception('Unexpected token payload: $json');
    }

    return AgoraVideoAuth.fromJson(json);
  }

  /// =============================================================
  ///          UNIFIED JOIN BUILDER FOR AUDIO + VIDEO
  /// =============================================================
  /// isAstrologer = true → use astro_token + astro_id  
  /// isAstrologer = false → use current_user_token + user_id
  static AgoraJoinParams buildJoinParams({
    required AgoraVideoAuth auth,
    required bool isAstrologer,
  }) {
    final token = isAstrologer ? auth.astroToken : auth.currentUserToken;
    final account = isAstrologer ? auth.astroId : auth.currentUserId;

    if (auth.appId.isEmpty ||
        auth.channelName.isEmpty ||
        token.isEmpty ||
        account.isEmpty) {
      throw StateError(
        'Missing join fields → '
        'appId=${auth.appId.isNotEmpty}, channel=${auth.channelName.isNotEmpty}, '
        'token=${token.isNotEmpty}, account=${account.isNotEmpty}',
      );
    }

    return AgoraJoinParams(
      appId: auth.appId,
      channel: auth.channelName,
      token: token,
      account: account,
    );
  }
}
