// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:astrowaypartner/fastApi/agora_voice_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AudioCallPage extends StatefulWidget {
  /// Pass the ASTROLOGER ID here (sent to backend as other_user_id)
  final String astroId;

  const AudioCallPage({super.key, required this.astroId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  late RtcEngine _engine;

  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = ''; // server "user" for userAccount APIs

  bool _loading = true;
  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = true;

  void _d(Object m) => debugPrint('🎧 [AstroVC] $m');

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final incoming = widget.astroId.trim();
      _d('Bootstrapping with astroId="$incoming"');
      if (incoming.isEmpty || incoming.toLowerCase() == 'null') {
        throw 'Invalid astrologer id';
      }
      if (incoming.toLowerCase().startsWith('room_')) {
        throw 'Expected astrologer id, received room_id';
      }

      // 1) Mic permission
      final statuses = await [Permission.microphone].request();
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Microphone permission denied';
      }

      // 2) Fetch voice token/appId/channel/user
      _d('Fetching voice token for other_user_id=$incoming …');
      final auth = await AgoraVoiceService.getVoiceToken(otherUserId: incoming);
      _appId = auth.appId;
      _channel = auth.channelName;
      _token = auth.token ?? "";
      _account = auth.user;

      if (_appId.isEmpty || _channel.isEmpty || _token.isEmpty || _account.isEmpty) {
        throw 'Missing voice auth (appId/channel/token/account)';
      }
      _d('Auth OK → appId=$_appId, channel=$_channel, account=$_account');

      // 3) Init engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      _d('Engine initialized');

      await _engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine.enableAudio();
      await _engine.disableVideo();
      _d('ChannelProfile=Communication, audio ✅, video ❌');

      // Safe pre-join: route default to speaker
      // (This just hints the default route; actual enable happens post-join)
      try {
        await _engine.setDefaultAudioRouteToSpeakerphone(true);
      } catch (e) {
        _d('setDefaultAudioRouteToSpeakerphone error: $e');
      }

      // 4) Events
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onError: (ErrorCodeType code, String msg) {
            _d('ERROR $code $msg');
          },
          onConnectionStateChanged: (RtcConnection c, ConnectionStateType s, ConnectionChangedReasonType r) {
            _d('ConnState=$s reason=$r');
          },
          onJoinChannelSuccess: (RtcConnection conn, int elapsed) async {
            _d('Joined ${conn.channelId} in ${elapsed}ms');
            setState(() => _joined = true);

            // 🔊 IMPORTANT: force loudspeaker only after join (avoids -3)
            try {
              await Future.delayed(const Duration(milliseconds: 150));
              await _engine.setEnableSpeakerphone(true);
              _speakerOn = true;
              _d('Speakerphone ON ✅');
            } catch (e) {
              _d('setEnableSpeakerphone post-join error: $e');
            }
          },
          onUserJoined: (RtcConnection c, int uid, int elapsed) {
            _d('Remote JOINED uid=$uid (elapsed=${elapsed}ms)');
          },
          onUserOffline: (RtcConnection c, int uid, UserOfflineReasonType reason) {
            _d('Remote OFFLINE uid=$uid reason=$reason');
          },
          onLeaveChannel: (RtcConnection c, RtcStats stats) {
            _d('Left channel. stats=${stats.toJson()}');
            setState(() => _joined = false);
          },
          onTokenPrivilegeWillExpire: (RtcConnection c, String token) {
            _d('Token will expire soon → refresh & renew if needed');
          },
          onAudioVolumeIndication: (RtcConnection c, List<AudioVolumeInfo> speakers, int speakerNumber, int totalVolume) {
            for (final s in speakers) {
              _d('VOLUME uid=${s.uid} vol=${s.volume} vad=${s.vad}');
            }
          },
        ),
      );

      // 5) Join with userAccount (matches server token)
      await _engine.registerLocalUserAccount(appId: _appId, userAccount: _account);
      _d('registerLocalUserAccount($_account) → OK');

      await _engine.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
        ),
      );
      _d('joinChannelWithUserAccount() sent');
    } catch (e) {
      _d('INIT FAILED: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio init failed: $e')),
      );
      if (e.toString().toLowerCase().contains('room_id')) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    try {
      await _engine.leaveChannel();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    () async {
      try { await _engine.leaveChannel(); } catch (_) {}
      try { await _engine.release(); } catch (_) {}
    }();
    super.dispose();
  }

  Future<void> _toggleMute() async {
    _muted = !_muted;
    await _engine.muteLocalAudioStream(_muted);
    _d('muteLocalAudioStream($_muted)');
    setState(() {});
  }

  Future<void> _setSpeaker(bool on) async {
    _speakerOn = on;
    try {
      await _engine.setEnableSpeakerphone(_speakerOn);
      _d('Speaker ${_speakerOn ? 'ON' : 'OFF'}');
    } catch (e) {
      _d('setEnableSpeakerphone error: $e');
    }
    setState(() {});
  }

  Future<void> _toggleSpeaker() => _setSpeaker(!_speakerOn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Call')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_in_talk, size: 80),
          const SizedBox(height: 12),
          Text(_joined ? 'Connected • $_channel' : 'Connecting…'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_muted ? Icons.mic_off : Icons.mic),
                onPressed: _toggleMute,
                tooltip: _muted ? 'Unmute' : 'Mute',
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: Icon(_speakerOn ? Icons.volume_up : Icons.hearing),
                onPressed: _toggleSpeaker,
                tooltip: _speakerOn ? 'Speaker off' : 'Speaker on',
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: _leave,
                tooltip: 'Hang up',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
