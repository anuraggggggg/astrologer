// lib/fastApi/agora_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Video token payload (GET /agora/token/video)
class AgoraVideoAuth {
  final String appId;              // from appID
  final String channelName;        // from channelName
  final String astroId;            // from astro_id
  final String astroToken;         // from astro_token
  final String currentUserId;      // from current_user_id
  final String currentUserToken;   // from current_user_token
  final int? expireIn;             // from expireIn (seconds), optional

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
      currentUserId: (j['current_user_id'] ?? j['current_user'] ?? j['user'] ?? '').toString(),
      currentUserToken: (j['current_user_token'] ?? j['currentUserToken'] ?? '').toString(),
      expireIn: j['expireIn'] is int ? j['expireIn'] as int : int.tryParse('${j['expireIn'] ?? ''}'),
    );
  }
}

/// Voice token payload (GET /agora/token/voice)
class AgoraVoiceAuth {
  final String appId;         // appID
  final String channelName;   // channelName
  final String voiceToken;    // voice_token
  final String userAccount;   // user
  final int? timer;           // timer (seconds)
  final String? userType;     // userType (optional)

  const AgoraVoiceAuth({
    required this.appId,
    required this.channelName,
    required this.voiceToken,
    required this.userAccount,
    this.timer,
    this.userType,
  });

  factory AgoraVoiceAuth.fromJson(Map<String, dynamic> j) {
    return AgoraVoiceAuth(
      appId: (j['appID'] ?? j['appId'] ?? '').toString(),
      channelName: (j['channelName'] ?? j['channel_name'] ?? '').toString(),
      voiceToken: (j['voice_token'] ?? j['voiceToken'] ?? '').toString(),
      userAccount: (j['user'] ?? j['user_account'] ?? j['userAccount'] ?? '').toString(),
      timer: j['timer'] is int ? j['timer'] as int : int.tryParse('${j['timer'] ?? ''}'),
      userType: j['userType']?.toString(),
    );
  }
}

/// Simple container for whatever you must pass to Agora join.
class AgoraJoinParams {
  final String appId;
  final String channel;
  final String token;
  final String account; // userAccount for joinChannelWithUserAccount

  const AgoraJoinParams({
    required this.appId,
    required this.channel,
    required this.token,
    required this.account,
  });

  @override
  String toString() =>
      'AgoraJoinParams(appId: ${appId.isNotEmpty}, channel: $channel, account: $account, token: ${token.isNotEmpty ? '*' : '(empty)'})';
}

class AgoraService {
  static const String _base = 'https://fastapi.jyotishionline.com';

  // ---------------- Video token (existing) ----------------
  /// Call: GET /agora/token/video?astro_id=...
  static Future<AgoraVideoAuth> getVideoTokens(String astroId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('access_token') ?? '';

    final uri = Uri.parse('$_base/agora/token/video')
        .replace(queryParameters: {'astro_id': astroId});

    final res = await http.get(
      uri,
      headers: {
        'accept': 'application/json',
        if (bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Agora token fetch failed: ${res.statusCode} ${res.body}');
    }

    final json = jsonDecode(res.body);
    if (json is! Map<String, dynamic>) {
      throw Exception('Unexpected token payload (not a JSON object): $json');
    }

    return AgoraVideoAuth.fromJson(json);
  }

  /// Convenience: pick the right token/account based on the role for video.
  /// isAstrologer == true  → account=astro_id,     token=astro_token
  /// isAstrologer == false → account=current_user_id, token=current_user_token
  static AgoraJoinParams buildJoinParams({
    required AgoraVideoAuth auth,
    required bool isAstrologer,
  }) {
    final token   = isAstrologer ? auth.astroToken       : auth.currentUserToken;
    final account = isAstrologer ? auth.astroId          : auth.currentUserId;
    final appId   = auth.appId;
    final channel = auth.channelName;

    if (appId.isEmpty || channel.isEmpty || token.isEmpty || account.isEmpty) {
      throw StateError(
        'Missing required join fields. '
        'appId=${appId.isNotEmpty}, channel=${channel.isNotEmpty}, '
        'token=${token.isNotEmpty}, account=${account.isNotEmpty}',
      );
    }

    return AgoraJoinParams(appId: appId, channel: channel, token: token, account: account);
  }

  // ---------------- Voice token (NEW) ----------------
  /// Call: GET /agora/token/voice?other_user_id=...
  /// Use this when backend exposes dedicated voice endpoint.
  static Future<AgoraVoiceAuth> getVoiceToken(String otherUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('access_token') ?? '';

    final uri = Uri.parse('$_base/agora/token/voice')
        .replace(queryParameters: {'other_user_id': otherUserId});

    final res = await http.get(
      uri,
      headers: {
        'accept': 'application/json',
        if (bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Agora voice token fetch failed: ${res.statusCode} ${res.body}');
    }

    final json = jsonDecode(res.body);
    if (json is! Map<String, dynamic>) {
      throw Exception('Unexpected voice token payload (not a JSON object): $json');
    }

    return AgoraVoiceAuth.fromJson(json);
  }

  /// Convert voice payload -> AgoraJoinParams
  static AgoraJoinParams buildVoiceJoinParams({
    required AgoraVoiceAuth auth,
  }) {
    final appId = auth.appId;
    final channel = auth.channelName;
    final token = auth.voiceToken;
    final account = auth.userAccount;

    if (appId.isEmpty || channel.isEmpty || token.isEmpty || account.isEmpty) {
      throw StateError(
        'Missing required voice join fields. '
        'appId=${appId.isNotEmpty}, channel=${channel.isNotEmpty}, '
        'token=${token.isNotEmpty}, account=${account.isNotEmpty}',
      );
    }

    return AgoraJoinParams(appId: appId, channel: channel, token: token, account: account);
  }
}