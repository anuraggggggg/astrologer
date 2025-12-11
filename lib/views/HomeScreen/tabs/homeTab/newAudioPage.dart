// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astrowaypartner/fastApi/agora_service.dart';

class AudioCallPage extends StatefulWidget {
  final String astroId;
  final bool isAstrologer;

  final String? overrideRoomId;
  final String? overrideToken;
  final String? overrideAccount;
  final String? overrideAppId;

  const AudioCallPage({
    super.key,
    required this.astroId,
    required this.isAstrologer,
    this.overrideRoomId,
    this.overrideToken,
    this.overrideAccount,
    this.overrideAppId,
  });

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  RtcEngine? _engine;

  String _appId = '';
  String _roomId = '';
  String _token = '';
  String _account = '';

  int? _remoteUid;
  bool _joined = false;
  bool _loading = true;

  bool _micOn = true;
  bool _speakerOn = true;
  bool _earpieceOn = false;

  Timer? _callTimer;
  DateTime? _deadline;
  Duration _remaining = Duration.zero;
  static const maxDuration = Duration(minutes: 10);

  void log(String m) => debugPrint("🎧 [AUDIO] $m");

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
    }();
    super.dispose();
  }

  // --------------------------------------------------------
  // INIT
  // --------------------------------------------------------
  Future<void> _bootstrap() async {
    try {
      final mic = await Permission.microphone.request();
      if (mic != PermissionStatus.granted) throw "Microphone permission denied";

      if ((widget.overrideRoomId ?? "").isNotEmpty) {
        _roomId = widget.overrideRoomId!.trim();
        _token = widget.overrideToken?.trim() ?? "";
        _account = widget.overrideAccount?.trim() ?? "";
        _appId = widget.overrideAppId?.trim() ?? "";

        if (_appId.isEmpty || _token.isEmpty || _account.isEmpty) {
          final auth = await AgoraService.getTokens(widget.astroId);
          final join = AgoraService.buildJoinParams(
            auth: auth,
            isAstrologer: widget.isAstrologer,
          );

          _appId = _appId.isNotEmpty ? _appId : auth.appId;
          _roomId = _roomId.isNotEmpty ? _roomId : join.channel;
          _token = _token.isNotEmpty ? _token : join.token;
          _account = _account.isNotEmpty ? _account : join.account;
        }
      } else {
        final auth = await AgoraService.getTokens(widget.astroId);
        final join = AgoraService.buildJoinParams(
          auth: auth,
          isAstrologer: widget.isAstrologer,
        );
        _appId = join.appId;
        _roomId = join.channel;
        _token = join.token;
        _account = join.account;
      }

      final eng = createAgoraRtcEngine();
      await eng.initialize(RtcEngineContext(appId: _appId));
      _engine = eng;

      await eng
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await eng.enableAudio();
      await eng.disableVideo();
      await eng.setDefaultAudioRouteToSpeakerphone(true);

      eng.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (_, __) {
          setState(() => _joined = true);
        },
        onUserJoined: (_, uid, __) {
          _remoteUid = uid;
          _startCallTimer();
          if (mounted) setState(() {});
        },
        onUserOffline: (_, uid, __) {
          _remoteUid = null;
          if (mounted) setState(() {});
        },
      ));

      await eng.registerLocalUserAccount(appId: _appId, userAccount: _account);

      await eng.joinChannelWithUserAccount(
        token: _token,
        channelId: _roomId,
        userAccount: _account,
        options: const ChannelMediaOptions(
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --------------------------------------------------------
  // TIMER
  // --------------------------------------------------------
  void _startCallTimer() {
    _deadline = DateTime.now().add(maxDuration);
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final d = _deadline!.difference(DateTime.now());
      if (d <= Duration.zero) {
        _leave();
        return;
      }
      if (mounted) setState(() => _remaining = d);
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, "0");
    final s = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$m:$s";
  }

  Future<void> _leave() async {
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  // --------------------------------------------------------
  // BUTTON ACTIONS
  // --------------------------------------------------------
  Future<void> _toggleMic() async {
    _micOn = !_micOn;
    await _engine?.muteLocalAudioStream(!_micOn);
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _engine?.setEnableSpeakerphone(_speakerOn);
    if (_speakerOn) _earpieceOn = false;
    setState(() {});
  }

  Future<void> _toggleEarpiece() async {
    _earpieceOn = !_earpieceOn;
    if (_earpieceOn) {
      await _engine?.setEnableSpeakerphone(false);
      _speakerOn = false;
    }
    setState(() {});
  }

  // --------------------------------------------------------
  // UI
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Centered content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.call, size: 120, color: Colors.white60),
                const SizedBox(height: 14),
                Text(
                  _remoteUid == null ? "Connecting…" : "Connected",
                  style: const TextStyle(color: Colors.white70, fontSize: 20),
                ),
                const SizedBox(height: 10),
                if (_remoteUid != null)
                  Text(
                    _fmt(_remaining),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  icon: Icons.mic,
                  active: _micOn,
                  onTap: _toggleMic,
                ),
                _buildButton(
                  icon: Icons.hearing,
                  active: _earpieceOn,
                  onTap: _toggleEarpiece,
                ),
                _buildButton(
                  icon: Icons.volume_up,
                  active: _speakerOn,
                  onTap: _toggleSpeaker,
                ),
                _buildButton(
                  icon: Icons.call_end,
                  active: true,
                  color: Colors.red,
                  onTap: _leave,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    Color color = Colors.white24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: active ? color : Colors.grey.shade800,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}
