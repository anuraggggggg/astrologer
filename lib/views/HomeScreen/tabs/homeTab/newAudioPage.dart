// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:astrowaypartner/fastApi/agora_voice_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AudioCallPage extends StatefulWidget {
  /// Pass the ASTROLOGER ID here (this will be sent as `other_user_id` to your API).
  final String astroId;

  const AudioCallPage({super.key, required this.astroId, required String otherUserId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  late RtcEngine _engine;

  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account =
      ''; // server returns a string "user" — we use userAccount APIs

  bool _loading = true;
  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // ── Basic param sanity ───────────────────────────────────────────────────
      final incoming = widget.astroId.trim();
      debugPrint('🎧 [AudioVC] Bootstrapping with astroId="$incoming"');

      if (incoming.isEmpty || incoming.toLowerCase() == 'null') {
        throw 'Invalid astrologer id';
      }
      if (incoming.toLowerCase().startsWith('room_')) {
        // Hard stop: this page must get ASTRO ID, not a room id
        throw 'Got room_id but expected astrologer id (astroId)';
      }

      // ── Permissions ──────────────────────────────────────────────────────────
      final statuses = await [Permission.microphone].request();
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Microphone permission denied';
      }

      // ── Fetch voice token (uses other_user_id = astroId) ────────────────────
      debugPrint(
          '🌐 [AudioVC] Fetching voice token for other_user_id=$incoming');
      final auth = await AgoraVoiceService.getVoiceToken(otherUserId: incoming);

      _appId = auth.appId;
      _channel = auth.channelName;
      _token = auth.token;
      _account = auth.user; // IMPORTANT: join with userAccount

      debugPrint('✅ [AudioVC] Voice token OK:');
      debugPrint('   • appId   = $_appId');
      debugPrint('   • channel = $_channel');
      debugPrint('   • account = $_account');
      debugPrint('   • ttl     = ${auth.expiresIn}s');

      if (_appId.isEmpty ||
          _channel.isEmpty ||
          _token.isEmpty ||
          _account.isEmpty) {
        throw 'Missing required voice auth fields (appId/channel/token/account)';
      }

      // ── Init engine ──────────────────────────────────────────────────────────
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      debugPrint('⚙️ [AudioVC] Agora engine initialized');

      await _engine
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine.enableAudio();
      await _engine.disableVideo();
      debugPrint('🎛️ [AudioVC] Audio enabled, video disabled');

      // ── Events ───────────────────────────────────────────────────────────────
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onError: (ErrorCodeType code, String msg) {
            debugPrint('💥 [AudioVC] Agora error: $code $msg');
          },
          onConnectionStateChanged: (RtcConnection conn,
              ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint('🔎 [AudioVC] connState=$state reason=$reason');
          },
          // v6 signature: (RtcConnection, int elapsed)
          onJoinChannelSuccess: (RtcConnection conn, int elapsed) {
            debugPrint(
                '🎉 [AudioVC] onJoinChannelSuccess ch=${conn.channelId} elapsed=${elapsed}ms');
            setState(() => _joined = true);
            // Route audio to speaker by default (ignore result code)
            _setSpeaker(true);
          },
          // v6 signature: (RtcConnection, int uid, int elapsed)
          onUserJoined: (RtcConnection conn, int uid, int elapsed) {
            debugPrint(
                '👋 [AudioVC] remote user joined uid=$uid elapsed=${elapsed}ms');
          },
          onUserOffline:
              (RtcConnection conn, int uid, UserOfflineReasonType r) {
            debugPrint('👋 [AudioVC] remote user left uid=$uid reason=$r');
          },
          onLeaveChannel: (RtcConnection conn, RtcStats stats) {
            debugPrint('👋 [AudioVC] left channel stats=$stats');
            setState(() => _joined = false);
          },
          onTokenPrivilegeWillExpire: (RtcConnection conn, String token) async {
            debugPrint(
                '⌛ [AudioVC] token will expire soon → refresh + renew if needed');
            // Example:
            // final refreshed = await AgoraVoiceService.getVoiceToken(otherUserId: widget.astroId);
            // await _engine.renewToken(refreshed.token);
          },
        ),
      );

      // ── Join using USER ACCOUNT (string) — matches your token ────────────────
      await _engine.registerLocalUserAccount(
          appId: _appId, userAccount: _account);
      debugPrint('🪪 [AudioVC] registerLocalUserAccount($_account) → OK');

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
      debugPrint('📞 [AudioVC] joinChannelWithUserAccount() called');
    } catch (e) {
      debugPrint('💥 [AudioVC] init failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio init failed: $e')),
        );
        // If bad param (room_id passed), leave immediately
        if (e.toString().toLowerCase().contains('room_id')) {
          Navigator.of(context).pop();
        }
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
      try {
        await _engine.leaveChannel();
      } catch (_) {}
      try {
        await _engine.release();
      } catch (_) {}
    }();
    super.dispose();
  }

  Future<void> _toggleMute() async {
    _muted = !_muted;
    await _engine.muteLocalAudioStream(_muted);
    debugPrint('🎙️ [AudioVC] muteLocalAudioStream($_muted) done');
    setState(() {});
  }

  Future<void> _setSpeaker(bool on) async {
    _speakerOn = on;
    await _engine.setEnableSpeakerphone(_speakerOn);
    debugPrint('🔊 [AudioVC] setEnableSpeakerphone($_speakerOn) done');
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
