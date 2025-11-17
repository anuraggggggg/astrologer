// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:astrowaypartner/fastApi/agora_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AudioCallPage extends StatefulWidget {
  final String astroId;

  const AudioCallPage({super.key, required this.astroId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  RtcEngine? _engine;

  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = '';

  bool _loading = true;
  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = true;

  int? _remoteUid;

  // === 10-minute call timer ===
  static const Duration _maxCallDuration = Duration(minutes: 10);
  DateTime? _callDeadline;
  Duration _remaining = Duration.zero;
  Timer? _callTimer;

  void _d(Object m) => debugPrint('🎧 [AudioVC] $m');

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    () async {
      try {
        await _engine?.leaveChannel();
    } catch (_) {}
    try {
    await _engine?.release();
    } catch (_) {}
    _engine = null;
    }();
    super.dispose();
  }

  // === Start the timer exactly like VIDEO PAGE ===
  void _startCallTimer() {
    _callTimer?.cancel();
    _callDeadline = DateTime.now().add(_maxCallDuration);
    _remaining = _maxCallDuration;

    _callTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      final deadline = _callDeadline;
      if (deadline == null) return;

      final rem = deadline.difference(DateTime.now());
      if (rem <= Duration.zero) {
        t.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Call ended (10 min limit reached)")),
          );
        }
        await _leave();
        return;
      }
      if (mounted) setState(() => _remaining = rem);
    });
  }

  String _formatRemaining(Duration d) {
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> _bootstrap() async {
    try {
      // Mic permission
      final statuses = await [Permission.microphone].request();
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Microphone permission denied';
      }

      // Token fetch
      final auth = await AgoraService.getVideoTokens(widget.astroId);
      final join = AgoraService.buildJoinParams(auth: auth, isAstrologer: true);

      _appId = join.appId;
      _channel = join.channel;
      _token = join.token;
      _account = join.account;

      if (_appId.isEmpty || _channel.isEmpty || _token.isEmpty || _account.isEmpty) {
        throw 'Missing join fields';
      }

      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(appId: _appId));
      _engine = engine;

      await engine.enableAudio();
      await engine.disableVideo();
      await engine.setDefaultAudioRouteToSpeakerphone(true);

      engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection conn, int elapsed) async {
          if (!mounted) return;
          setState(() => _joined = true);
          await Future.delayed(const Duration(milliseconds: 200));
          await engine.setEnableSpeakerphone(true);
        },

        onUserJoined: (RtcConnection c, int uid, int elapsed) {
          _remoteUid = uid;
          _startCallTimer();      // ⬅ START TIMER WHEN OTHER USER JOINS
          setState(() {});
        },

        onUserOffline: (RtcConnection c, int uid, UserOfflineReasonType r) {
          _remoteUid = null;
          setState(() {});
        },
      ));

      await engine.registerLocalUserAccount(appId: _appId, userAccount: _account);

      await engine.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
        ),
      );
    } catch (e) {
      _d("INIT FAILED: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Audio call failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleMute() async {
    _muted = !_muted;
    await _engine?.muteLocalAudioStream(_muted);
    if (mounted) setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _engine?.setEnableSpeakerphone(_speakerOn);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final showTimer = _remoteUid != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Audio Call"),
        backgroundColor: Colors.black,
        actions: [
          if (showTimer)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(
                  _formatRemaining(_remaining),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.call, size: 120, color: Colors.white70),
          const SizedBox(height: 12),
          Text(
            _remoteUid == null ? "Waiting for other user…" : "Connected",
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 40),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleBtn(
                icon: _muted ? Icons.mic_off : Icons.mic,
                color: _muted ? Colors.red : Colors.white,
                onTap: _toggleMute,
              ),
              const SizedBox(width: 30),
              _circleBtn(
                icon: _speakerOn ? Icons.volume_up : Icons.hearing,
                onTap: _toggleSpeaker,
              ),
              const SizedBox(width: 30),
              _circleBtn(
                icon: Icons.call_end,
                bg: Colors.red,
                onTap: _leave,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    Color color = Colors.white,
    Color bg = const Color(0x33FFFFFF),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
