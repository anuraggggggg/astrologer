// lib/call/video_call_page.dart
import 'dart:async';
import 'package:astrowaypartner/fastApi/agora_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

/// Use `isAstrologer=true` in the astrologer app; false in the customer app.
class VideoCallPage extends StatefulWidget {
  final String astroId; // the astrologer id
  final bool
      isAstrologer; // true => astro_token & astro_id; false => current_user_token & current_user_id

  const VideoCallPage({
    super.key,
    required this.astroId,
    required this.isAstrologer,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  RtcEngine? _engine; // nullable
  bool _engineReady = false;

  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = ''; // userAccount for joinChannelWithUserAccount

  int? _remoteUid;
  bool _joined = false;
  bool _loading = true;

  bool _micOn = true;
  bool _camOn = true;

  Timer? _pulse;

  // === 10-minute call timer ===
  static const Duration _maxCallDuration = Duration(minutes: 10);
  DateTime? _callDeadline;
  Duration _remaining = Duration.zero;
  Timer? _callTimer;

  // Safe getter after init
  RtcEngine get _eng {
    final e = _engine;
    if (e == null) {
      throw StateError('Agora engine not initialized');
    }
    return e;
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _pulse?.cancel();
    _callTimer?.cancel();
    () async {
      try {
        await _engine?.leaveChannel();
      } catch (_) {}
      try {
        await _engine?.stopPreview();
      } catch (_) {}
      try {
        await _engine?.release();
      } catch (_) {}
      _engine = null;
    }();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      // 1) Permissions
      final statuses =
          await [Permission.camera, Permission.microphone].request();
      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Camera/Microphone permission denied';
      }

      // 2) Fetch tokens + ids from your API
      final authResp = await AgoraService.getVideoTokens(widget.astroId);
      final join = AgoraService.buildJoinParams(
        auth: authResp,
        isAstrologer: widget.isAstrologer,
      );

      _appId = join.appId;
      _channel = join.channel;
      _token = join.token;
      _account = join.account;

      final tokPreview = _token.length > 12
          ? '${_token.substring(0, 6)}…${_token.substring(_token.length - 6)}'
          : _token;

      debugPrint('🔑 [VC] role=${widget.isAstrologer ? 'ASTRO' : 'CUSTOMER'}');
      debugPrint('🔑 [VC] appId=$_appId');
      debugPrint('🔑 [VC] channel=$_channel');
      debugPrint('🔑 [VC] account=$_account');
      debugPrint('🔑 [VC] token=$tokPreview');

      // Validate BEFORE touching engine
      if (_appId.isEmpty ||
          _channel.isEmpty ||
          _token.isEmpty ||
          _account.isEmpty) {
        throw 'Missing required join fields (appId/channel/token/account).';
      }

      // 3) Init engine
      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(appId: _appId));
      _engine = engine;
      _engineReady = true;

      await _eng
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _eng.enableVideo();

      // 4) Events
      _eng.registerEventHandler(RtcEngineEventHandler(
        onConnectionStateChanged: (RtcConnection conn,
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint(
              '🔎 [VC] onConnectionStateChanged state=$state reason=$reason ch=${conn.channelId}');
        },
        onJoinChannelSuccess: (RtcConnection conn, int elapsed) {
          debugPrint(
              '🎉 [VC] onJoinChannelSuccess ch=${conn.channelId} elapsed=${elapsed}ms');
          if (mounted) {
            setState(() => _joined = true);
            _startCallTimer(); // ⬅️ start 10-minute timer on successful join
          }
        },
        onUserJoined: (RtcConnection conn, int remoteUid, int elapsed) {
          debugPrint(
              '👋 [VC] onUserJoined uid=$remoteUid elapsed=${elapsed}ms');
          if (mounted) setState(() => _remoteUid = remoteUid);
        },
        onUserOffline:
            (RtcConnection conn, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('👋 [VC] onUserOffline uid=$remoteUid reason=$reason');
          if (mounted) setState(() => _remoteUid = null);
        },
        onLeaveChannel: (RtcConnection conn, RtcStats stats) {
          debugPrint('👋 [VC] onLeaveChannel duration=${stats.duration}');
          if (mounted) {
            setState(() {
              _joined = false;
              _remoteUid = null;
            });
          }
        },
        onTokenPrivilegeWillExpire: (RtcConnection conn, String token) async {
          debugPrint(
              '⏰ [VC] Token expiring; refresh from server and call renewToken().');
          // NOTE: We intentionally keep the hard 10-min cutoff regardless of renewal.
        },
        onError: (ErrorCodeType code, String msg) {
          debugPrint('❗ [VC] Agora error: $code $msg');
          if (code == ErrorCodeType.errInvalidToken) {
            debugPrint('🚨 [VC] INVALID TOKEN. Ensure:');
            debugPrint('   • Using joinChannelWithUserAccount');
            debugPrint('   • userAccount="$_account" matches token subject');
            debugPrint('   • channelName="$_channel" matches token channel');
            debugPrint('   • Device time is correct');
          }
        },
      ));

      await _eng.startPreview();
      debugPrint('🎥 [VC] Local preview started');

      // 5) JOIN BY ACCOUNT
      debugPrint(
          '➡️ [VC] joinChannelWithUserAccount(channel=$_channel, account=$_account, token=$tokPreview)');
      await _eng.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      _pulse = Timer.periodic(const Duration(seconds: 10), (_) {
        debugPrint('💓 [VC] pulse joined=$_joined remoteUid=$_remoteUid');
      });
    } catch (e) {
      debugPrint('💥 [VC] init failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video init failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // === 10-minute countdown logic ===
  void _startCallTimer() {
    _callTimer?.cancel();
    _callDeadline = DateTime.now().add(_maxCallDuration);
    _remaining = _maxCallDuration;

    _callTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      final deadline = _callDeadline;
      if (deadline == null) return;

      final now = DateTime.now();
      final rem = deadline.difference(now);
      if (rem <= Duration.zero) {
        t.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Call ended: 10 minutes limit reached')),
          );
        }
        await _leave(); // auto-leave
        return;
      }
      if (mounted) {
        setState(() => _remaining = rem);
      }
    });
  }

  String _formatRemaining(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _leave() async {
    debugPrint('↩️ [VC] Leaving channel…');
    try {
      _callTimer?.cancel(); // stop countdown when leaving
      if (_engineReady && _engine != null) {
        await _eng.leaveChannel();
        await _eng.stopPreview();
      }
    } catch (e) {
      debugPrint('⚠️ [VC] leave error: $e');
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleMic() async {
    if (_engine == null) return;
    _micOn = !_micOn;
    await _eng.muteLocalAudioStream(!_micOn);
    debugPrint('🎙 [VC] micOn=$_micOn');
    if (mounted) setState(() {});
  }

  Future<void> _toggleCam() async {
    if (_engine == null) return;
    _camOn = !_camOn;
    await _eng.muteLocalVideoStream(!_camOn);
    debugPrint('📷 [VC] camOn=$_camOn');
    if (mounted) setState(() {});
  }

  Future<void> _switchCam() async {
    if (_engine == null) return;
    await _eng.switchCamera();
    debugPrint('🔁 [VC] switchCamera()');
  }

  @override
  Widget build(BuildContext context) {
    final engineReadyLocal = _engineReady && _engine != null;
    final showCountdown = _joined && _callDeadline != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Video Call (${widget.isAstrologer ? 'Astrologer' : 'Customer'})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (showCountdown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  _formatRemaining(_remaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Remote (full screen)
                Positioned.fill(
                  child: _remoteUid == null || !engineReadyLocal
                      ? Center(
                          child: Text(
                            _joined
                                ? (widget.isAstrologer
                                    ? 'Waiting for customer…'
                                    : 'Waiting for astrologer…')
                                : 'Joining…',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      : AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: _eng,
                            canvas: VideoCanvas(uid: _remoteUid),
                            connection: RtcConnection(channelId: _channel),
                          ),
                        ),
                ),

                // Local PiP
                if (engineReadyLocal)
                  Positioned(
                    right: 12,
                    top: 12,
                    width: 120,
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.black54,
                        child: AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _eng,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _roundBtn(
                        icon: _micOn ? Icons.mic : Icons.mic_off,
                        color: _micOn ? Colors.white : Colors.redAccent,
                        onTap: _toggleMic,
                      ),
                      const SizedBox(width: 16),
                      _roundBtn(
                        icon: _camOn ? Icons.videocam : Icons.videocam_off,
                        color: _camOn ? Colors.white : Colors.redAccent,
                        onTap: _toggleCam,
                      ),
                      const SizedBox(width: 16),
                      _roundBtn(
                        icon: Icons.cameraswitch,
                        onTap: _switchCam,
                      ),
                      const SizedBox(width: 16),
                      _roundBtn(
                        icon: Icons.call_end,
                        color: Colors.white,
                        bg: Colors.redAccent,
                        onTap: _leave,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _roundBtn({
    required IconData icon,
    Color color = Colors.white,
    Color bg = const Color(0x44000000),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
    );
  }
}
