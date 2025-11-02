// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:astrowaypartner/fastApi/agora_voice_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AudioCallPage extends StatefulWidget {
  /// Pass the ASTROLOGER ID here
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

  bool _loading = true;
  bool _joined = false;
  final Set<int> _remoteUids = {};

  bool _micOn = true;
  bool _speakerOn = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    debugPrint(
        '🎧 [AudioVC] Bootstrapping call with astroId="${widget.astroId}"');

    try {
      // Permissions
      final statuses = await [Permission.microphone].request();
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Microphone permission denied';
      }

      // Fetch Agora voice token using ASTRO ID
      final auth =
          await AgoraVoiceService.getVoiceTokenUsingAstroId(widget.astroId);
      _appId = auth.appId;
      _channel = auth.channelName;
      _token = auth.token;

      debugPrint('✅ [AudioVC] Token fetched for astroId=${widget.astroId}');
      debugPrint('🧩 appId=$_appId');
      debugPrint('🛰 channel=$_channel');
      debugPrint('🧑 user=${auth.userId}');
      debugPrint('🕓 expiresIn=${auth.expiresIn}s');

      // Initialize Agora engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      debugPrint('⚙️ [AudioVC] Agora engine initialized');

      await _engine
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine.enableAudio();
      await _engine.disableVideo();
      debugPrint('🎛️ [AudioVC] Audio enabled, video disabled');

      // Register event handlers
      _engine.registerEventHandler(RtcEngineEventHandler(
        onConnectionStateChanged: (RtcConnection conn,
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint('🔎 [AudioVC] connState=$state reason=$reason');
        },
        onJoinChannelSuccess: (RtcConnection conn, int elapsed) async {
          debugPrint(
              '🎉 [AudioVC] Join OK ch=${conn.channelId} after ${elapsed}ms');
          try {
            await _engine.setEnableSpeakerphone(true);
            debugPrint('🔊 [AudioVC] Speaker enabled after join');
          } catch (e) {
            debugPrint('⚠️ [AudioVC] Speaker enable failed after join: $e');
          }
          setState(() => _joined = true);
        },
        onUserJoined: (RtcConnection conn, int uid, int elapsed) {
          debugPrint('👋 [AudioVC] Remote joined: $uid after ${elapsed}ms');
          setState(() => _remoteUids.add(uid));
        },
        onUserOffline:
            (RtcConnection conn, int uid, UserOfflineReasonType reason) {
          debugPrint('👋 [AudioVC] Remote left: $uid reason=$reason');
          setState(() => _remoteUids.remove(uid));
        },
        onTokenPrivilegeWillExpire: (RtcConnection conn, String token) async {
          debugPrint('⏳ [AudioVC] Token will expire soon');
          // Optionally refresh token here
        },
        onError: (ErrorCodeType code, String msg) {
          debugPrint('💥 [AudioVC] Agora error: $code $msg');
        },
      ));

      // Join Agora channel
      await _engine.joinChannel(
        token: _token,
        channelId: _channel,
        uid: auth.userId.hashCode, // use same ID (converted to int)
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
        ),
      );

      debugPrint('📞 [AudioVC] joinChannel() called');
    } catch (e) {
      debugPrint('💥 [AudioVC] Initialization failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio init failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleMic() async {
    _micOn = !_micOn;
    await _engine.muteLocalAudioStream(!_micOn);
    debugPrint('🎙️ [AudioVC] Mic -> ${_micOn ? 'ON' : 'OFF'}');
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _engine.setEnableSpeakerphone(_speakerOn);
    debugPrint('🔊 [AudioVC] Speaker -> ${_speakerOn ? 'ON' : 'OFF'}');
    setState(() {});
  }

  Future<void> _leave() async {
    try {
      await _engine.leaveChannel();
      debugPrint('👋 [AudioVC] Left channel');
    } catch (e) {
      debugPrint('⚠️ [AudioVC] Leave channel failed: $e');
    }
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
      debugPrint('🧹 [AudioVC] Engine released');
    }();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Call')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    _joined ? 'Connected to $_channel' : 'Joining $_channel …'),
                const SizedBox(height: 8),
                Text('Remote users: ${_remoteUids.join(', ')}'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _btn(
                        icon: _micOn ? Icons.mic : Icons.mic_off,
                        onTap: _toggleMic),
                    const SizedBox(width: 16),
                    _btn(
                        icon: _speakerOn ? Icons.volume_up : Icons.hearing,
                        onTap: _toggleSpeaker),
                    const SizedBox(width: 16),
                    _btn(
                        icon: Icons.call_end,
                        bg: Colors.redAccent,
                        onTap: _leave),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _btn(
      {required IconData icon,
      required VoidCallback onTap,
      Color bg = const Color(0xFF2C2C2C)}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
