// lib/call/video_call_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:astrowaypartner/fastApi/agora_service.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

/// Astrologer usage: VideoCallPage(astroId: astroId, isAstrologer: true)
/// Customer usage from FCM: VideoCallPage(astroId: astroId, isAstrologer: false,
///   overrideRoomId: channel, overrideToken: token, overrideAccount: account, overrideAppId: appId)
class VideoCallPage extends StatefulWidget {
  final String astroId;
  final bool isAstrologer;
  final int? requestId; // Add requestId for timer tracking

  // Optional overrides (when notification supplies Agora join info)
  final String? overrideRoomId; // aka agora_channel
  final String? overrideToken; // token for this role
  final String? overrideAccount; // userAccount to join as
  final String? overrideAppId; // optional appID from server

  const VideoCallPage({
    super.key,
    required this.astroId,
    required this.isAstrologer,
    this.requestId,
    this.overrideRoomId,
    this.overrideToken,
    this.overrideAccount,
    this.overrideAppId,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage>
    with TickerProviderStateMixin {
  RtcEngine? _engine;
  bool _engineReady = false;

  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = '';

  int? _remoteUid;
  bool _joined = false;
  bool _loading = true;
  bool _timerFetched = false;
  bool _isSessionExpired = false;

  bool _micOn = true;
  bool _camOn = true;

  Timer? _pulse;
  Timer? _callTimer;
  Timer? _serverSyncTimer;
  DateTime? _callDeadline;
  Duration _remaining = Duration.zero;

  // Dynamic duration based on server response
  static const int _defaultMinutes = 10;
  int _totalMinutes = _defaultMinutes;

  // Animation controllers
  late AnimationController _pulseAnimation;
  late AnimationController _flickerAnimation;
  late Animation<double> _pulseScale;
  late Animation<double> _flickerOpacity;

  final FastApiServices _api = FastApiServices();

  RtcEngine get _eng {
    final e = _engine;
    if (e == null) throw StateError('Agora engine not initialized');
    return e;
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseAnimation = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseAnimation, curve: Curves.easeInOut),
    );

    _flickerAnimation = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _flickerOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _flickerAnimation, curve: Curves.easeInOut),
    );

    _bootstrap();
  }

  @override
  void dispose() {
    _pulse?.cancel();
    _callTimer?.cancel();
    _serverSyncTimer?.cancel();
    _pulseAnimation.dispose();
    _flickerAnimation.dispose();

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

  // --------------------------------------------------------
  // FETCH SERVER TIMER
  // --------------------------------------------------------
  Future<void> _fetchServerTimer() async {
    if (widget.requestId == null) {
      debugPrint("⚠️ [VC] No requestId provided, using default timer");
      setState(() {
        _timerFetched = true;
        _isSessionExpired = false;
      });
      return;
    }

    try {
      debugPrint(
          "⏱ [VC] Fetching server timer for request: ${widget.requestId}");
      final timerData = await _api.checkSessionTimer(widget.requestId!);

      if (timerData != null && timerData['remaining_seconds'] != null) {
        final remainingSeconds = timerData['remaining_seconds'];

        setState(() {
          _remaining = Duration(seconds: remainingSeconds);
          _totalMinutes = (remainingSeconds / 60).ceil();
          _timerFetched = true;
        });

        // Set deadline based on remaining time
        _callDeadline = DateTime.now().add(_remaining);

        debugPrint(
            "✅ [VC] Timer synced: ${_remaining.inMinutes} minutes remaining");

        // Check if session is expired
        if (timerData['is_expired'] == true) {
          setState(() {
            _isSessionExpired = true;
          });
          _showSessionExpiredDialog();
        }
      } else {
        setState(() {
          _timerFetched = true;
          _isSessionExpired = false;
        });
      }
    } catch (e) {
      debugPrint("🔥 [VC] Error fetching server timer: $e");
      setState(() {
        _timerFetched = true;
        _isSessionExpired = false;
      });
    }
  }

  // --------------------------------------------------------
  // SYNC WITH SERVER PERIODICALLY
  // --------------------------------------------------------
  void _startServerSync() {
    if (widget.requestId == null) return;

    _serverSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchServerTimer();
    });
  }

  // --------------------------------------------------------
  // SHOW SESSION EXPIRED DIALOG
  // --------------------------------------------------------
  void _showSessionExpiredDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Column(
            children: [
              Icon(Icons.timer_off, color: Colors.red, size: 60),
              SizedBox(height: 16),
              Text(
                'Session Expired',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            'This video call session has expired.',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('OK',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------
  // INIT
  // --------------------------------------------------------
  Future<void> _bootstrap() async {
    try {
      // Fetch server timer first
      await _fetchServerTimer();

      // If session expired, don't proceed with Agora setup
      if (_isSessionExpired) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      // 1) Permissions
      final statuses =
          await [Permission.camera, Permission.microphone].request();
      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Camera/Microphone permission denied';
      }

      // 2) Decide join params: prefer overrides from notification/push if present
      if ((widget.overrideRoomId ?? '').isNotEmpty) {
        debugPrint(
            '🔑 [VC] Using overrides from notification: room=${widget.overrideRoomId}, tokenPresent=${(widget.overrideToken ?? '').isNotEmpty}, account=${widget.overrideAccount}');
        _channel = widget.overrideRoomId!.trim();
        _token = widget.overrideToken?.trim() ?? '';
        _account = widget.overrideAccount?.trim() ?? '';
        _appId = widget.overrideAppId?.trim() ?? '';

        // If appId or account or token missing, fetch minimal auth to fill gaps
        if (_appId.isEmpty || _account.isEmpty || _token.isEmpty) {
          debugPrint(
              '🔎 [VC] Overrides incomplete — fetching auth to fill missing fields.');
          final authResp = await AgoraService.getTokens(widget.astroId);
          final joinFromAuth = AgoraService.buildJoinParams(
            auth: authResp,
            isAstrologer: widget.isAstrologer,
          );

          _appId = _appId.isNotEmpty ? _appId : authResp.appId;
          _channel = _channel.isNotEmpty ? _channel : joinFromAuth.channel;
          _token = _token.isNotEmpty ? _token : joinFromAuth.token;
          _account = _account.isNotEmpty ? _account : joinFromAuth.account;
        }
      } else {
        // No overrides: fetch auth & build join params normally
        final authResp = await AgoraService.getTokens(widget.astroId);
        final join = AgoraService.buildJoinParams(
            auth: authResp, isAstrologer: widget.isAstrologer);

        _appId = join.appId;
        _token = join.token;
        _account = join.account;
        _channel = join.channel;
      }

      // helpful preview of token for logs
      final tokPreview = _token.length > 12
          ? '${_token.substring(0, 6)}…${_token.substring(_token.length - 6)}'
          : _token;

      debugPrint('🔑 [VC] role=${widget.isAstrologer ? 'ASTRO' : 'CUSTOMER'}');
      debugPrint('🔑 [VC] appId=$_appId');
      debugPrint('🔑 [VC] channel=$_channel');
      debugPrint('🔑 [VC] account=$_account');
      debugPrint('🔑 [VC] token=$tokPreview');

      // validate minimally
      if (_appId.isEmpty || _channel.isEmpty || _account.isEmpty) {
        throw 'Missing required join fields (appId/channel/account).';
      }
      if (_token.isEmpty) {
        debugPrint(
            '⚠️ [VC] Warning: token is empty — joining without token (ensure this is intended).');
      }

      // trim
      _appId = _appId.trim();
      _channel = _channel.trim();
      _account = _account.trim();
      _token = _token.trim();

      // init engine
      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(appId: _appId));
      _engine = engine;
      _engineReady = true;

      await _eng
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _eng.enableVideo();

      // event handlers
      _eng.registerEventHandler(RtcEngineEventHandler(
        onConnectionStateChanged: (RtcConnection conn,
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint(
              '🔎 [VC] onConnectionStateChanged state=$state reason=$reason ch=${conn.channelId}');
          if (state == ConnectionStateType.connectionStateReconnecting) {
            _showReconnectingDialog();
          }
        },
        onJoinChannelSuccess: (RtcConnection conn, int elapsed) {
          debugPrint(
              '🎉 [VC] onJoinChannelSuccess ch=${conn.channelId} elapsed=${elapsed}ms');
          if (mounted) setState(() => _joined = true);
        },
        onUserJoined: (RtcConnection conn, int remoteUid, int elapsed) {
          debugPrint(
              '👋 [VC] onUserJoined uid=$remoteUid elapsed=${elapsed}ms');
          if (mounted) setState(() => _remoteUid = remoteUid);
          _startCallTimer();
          _startServerSync();
        },
        onUserOffline:
            (RtcConnection conn, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('👋 [VC] onUserOffline uid=$remoteUid reason=$reason');
          if (mounted) setState(() => _remoteUid = null);
          _showCallEndedDialog();
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
        onTokenPrivilegeWillExpire: (RtcConnection conn, String token) {
          debugPrint(
              '⏰ [VC] Token expiring; refresh from server and call renewToken().');
        },
        onError: (ErrorCodeType code, String msg) {
          debugPrint('❗ [VC] Agora error: $code $msg');
          if (code == ErrorCodeType.errInvalidToken) {
            debugPrint(
                '🚨 [VC] INVALID TOKEN. Ensure userAccount matches token subject and channel matches token.');
          }
        },
      ));

      await _eng.startPreview();
      debugPrint('🎥 [VC] Local preview started');

      // join (debug print included)
      debugPrint(
          "ABOUT_TO_JOIN → channel='$_channel' tokenPresent=${_token.isNotEmpty} account=$_account");
      debugPrint(
          '➡️ [VC] joinChannelWithUserAccount(channel=$_channel, account=$_account, token=$tokPreview)');

      await _eng.joinChannelWithUserAccount(
        token: _token.isNotEmpty ? _token : '',
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

      _pulse = Timer.periodic(const Duration(seconds: 10), (Timer t) {
        debugPrint('💓 [VC] pulse joined=$_joined remoteUid=$_remoteUid');
      });
    } catch (e, st) {
      debugPrint('💥 [VC] init failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Video init failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --------------------------------------------------------
  // DIALOGS
  // --------------------------------------------------------
  void _showReconnectingDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
            const SizedBox(width: 16),
            const Expanded(child: Text('Reconnecting...')),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCallEndedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.call_end, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text('Call Ended', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('The other participant has left the call.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // TIMER
  // --------------------------------------------------------
  void _startCallTimer() {
    if (_callDeadline == null) {
      // If no server timer, use default
      _callDeadline = DateTime.now().add(Duration(minutes: _totalMinutes));
    }

    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      final deadline = _callDeadline;
      if (deadline == null) return;

      final now = DateTime.now();
      final rem = deadline.difference(now);
      if (rem <= Duration.zero) {
        t.cancel();
        _showTimeUpDialog();
        await _leave();
        return;
      }
      if (mounted) setState(() => _remaining = rem);
    });
  }

  void _showTimeUpDialog() {
    setState(() {
      _isSessionExpired = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(Icons.timer_off, color: Colors.orange, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Time\'s Up!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            'Your video call session has ended.',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('OK',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatRemaining(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double _getProgress() {
    if (_callDeadline == null) return 0.0;
    final total = Duration(minutes: _totalMinutes).inSeconds;
    final remaining = _remaining.inSeconds;
    return total > 0 ? remaining / total : 0.0;
  }

  bool _isLowTime() {
    final progress = _getProgress();
    return progress < 0.2 && progress > 0;
  }

  Future<void> _leave() async {
    debugPrint('↩️ [VC] Leaving channel…');
    try {
      _callTimer?.cancel();
      _serverSyncTimer?.cancel();
      if (_engineReady && _engine != null) {
        await _eng.leaveChannel();
        await _eng.stopPreview();
      }
    } catch (e) {
      debugPrint('⚠️ [VC] leave error: $e');
    }
    if (mounted) Navigator.pop(context);
  }

  // --------------------------------------------------------
  // BUTTON ACTIONS
  // --------------------------------------------------------
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

  // --------------------------------------------------------
  // UI
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final engineReadyLocal = _engineReady && _engine != null;
    final showCountdown = _joined && _callDeadline != null;
    final isLowTime = _isLowTime();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _leave(),
        ),
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _remoteUid != null ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _remoteUid != null ? 'Connected' : 'Connecting...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          if (showCountdown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isLowTime
                      ? Colors.red.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLowTime
                        ? Colors.red.withOpacity(0.5)
                        : Colors.white24,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: isLowTime ? Colors.red : Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatRemaining(_remaining),
                      style: TextStyle(
                        color: isLowTime ? Colors.red : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (widget.requestId != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.sync,
                        size: 12,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? _buildLoadingScreen()
          : !_timerFetched
              ? _buildFetchingTimerScreen()
              : _isSessionExpired
                  ? _buildExpiredScreen()
                  : Stack(
                      children: [
                        // Remote video (main)
                        Positioned.fill(
                          child: _remoteUid == null || !engineReadyLocal
                              ? _buildWaitingScreen()
                              : AgoraVideoView(
                                  controller: VideoViewController.remote(
                                    rtcEngine: _eng,
                                    canvas: VideoCanvas(uid: _remoteUid),
                                    connection:
                                        RtcConnection(channelId: _channel),
                                  ),
                                ),
                        ),

                        // Local video (picture-in-picture)
                        if (engineReadyLocal)
                          Positioned(
                            right: 16,
                            top: 16,
                            width: 120,
                            height: 180,
                            child: ScaleTransition(
                              scale: _pulseScale,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: _camOn
                                      ? AgoraVideoView(
                                          controller: VideoViewController(
                                            rtcEngine: _eng,
                                            canvas: const VideoCanvas(uid: 0),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.black87,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.videocam_off,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  size: 30,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Camera off',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.5),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),

                        // Animated overlay when remote user is not connected
                        if (_remoteUid == null)
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: FadeTransition(
                                    opacity: _flickerOpacity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.videocam_off,
                                          size: 80,
                                          color: Colors.white54,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _joined
                                              ? 'Waiting for customer to join...'
                                              : 'Connecting to call...',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Bottom controls
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 24,
                          child: _buildControls(),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseScale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.videocam,
                size: 50,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Initializing video call...",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(
            color: Colors.blue,
            strokeWidth: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFetchingTimerScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseScale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.timer,
                size: 50,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Fetching session details...",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(
            color: Colors.orange,
            strokeWidth: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.timer_off,
              size: 50,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Session Expired",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "This video call session is no longer active",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _flickerOpacity,
            child: const Icon(
              Icons.videocam_off,
              size: 80,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _joined ? 'Waiting for customer…' : 'Joining…',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: _micOn ? Icons.mic : Icons.mic_off,
            label: "Mic",
            active: _micOn,
            color: Colors.blue,
            onTap: _toggleMic,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: _camOn ? Icons.videocam : Icons.videocam_off,
            label: "Camera",
            active: _camOn,
            color: Colors.green,
            onTap: _toggleCam,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.cameraswitch,
            label: "Flip",
            active: true,
            color: Colors.purple,
            onTap: _switchCam,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.call_end,
            label: "End",
            active: true,
            color: Colors.red,
            onTap: _leave,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool active,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? (isDestructive ? color : color.withOpacity(0.2))
                  : Colors.grey.withOpacity(0.1),
              border: Border.all(
                color: active
                    ? (isDestructive ? color : color.withOpacity(0.5))
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: active && !isDestructive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color:
                  active ? (isDestructive ? Colors.white : color) : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active
                  ? (isDestructive ? Colors.white : Colors.white70)
                  : Colors.grey,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
