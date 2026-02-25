// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astrowaypartner/fastApi/agora_service.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class AudioCallPage extends StatefulWidget {
  final String astroId;
  final bool isAstrologer;
  final int? requestId; // Add requestId for timer tracking

  final String? overrideRoomId;
  final String? overrideToken;
  final String? overrideAccount;
  final String? overrideAppId;

  const AudioCallPage({
    super.key,
    required this.astroId,
    required this.isAstrologer,
    this.requestId, // Make it optional for backward compatibility
    this.overrideRoomId,
    this.overrideToken,
    this.overrideAccount,
    this.overrideAppId,
  });

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage>
    with TickerProviderStateMixin {
  RtcEngine? _engine;

  String _appId = '';
  String _roomId = '';
  String _token = '';
  String _account = '';

  int? _remoteUid;
  bool _joined = false;
  bool _loading = true;
  bool _timerFetched = false; // Add flag to track if timer is fetched

  bool _micOn = true;
  bool _speakerOn = true;
  bool _earpieceOn = false;

  Timer? _callTimer;
  Timer? _serverSyncTimer; // Timer to sync with server
  DateTime? _deadline;
  Duration _remaining = Duration.zero;

  // Dynamic duration based on server response
  static const int _defaultMinutes = 10;
  int _totalMinutes = _defaultMinutes;
  bool _isSessionExpired = false; // Track if session is expired

  // Animation controllers for enhanced UI
  late AnimationController _pulseAnimation;
  late AnimationController _waveAnimation;
  late Animation<double> _pulseScale;
  late Animation<double> _waveOpacity;

  // Sound wave animation for active call
  late AnimationController _soundWaveController;
  late List<Animation<double>> _waveHeights;

  final FastApiServices _api = FastApiServices();

  void log(String m) => debugPrint("🎧 [AUDIO] $m");

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseAnimation = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseAnimation, curve: Curves.easeInOut),
    );

    _waveAnimation = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _waveOpacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _waveAnimation, curve: Curves.easeInOut),
    );

    // Initialize sound wave animations
    _soundWaveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    _waveHeights = List.generate(5, (index) {
      return Tween<double>(begin: 20, end: 50 + (index * 10)).animate(
        CurvedAnimation(
          parent: _soundWaveController,
          curve: Interval(index * 0.1, 0.5 + (index * 0.1),
              curve: Curves.easeInOut),
        ),
      );
    });

    _bootstrap();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _serverSyncTimer?.cancel();
    _pulseAnimation.dispose();
    _waveAnimation.dispose();
    _soundWaveController.dispose();

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
  // FETCH SERVER TIMER
  // --------------------------------------------------------
  Future<void> _fetchServerTimer() async {
    if (widget.requestId == null) {
      log("⚠️ No requestId provided, using default timer");
      setState(() {
        _timerFetched = true;
        _isSessionExpired = false;
      });
      return;
    }

    try {
      log("⏱ Fetching server timer for request: ${widget.requestId}");
      final timerData = await _api.checkSessionTimer(widget.requestId!);

      if (timerData != null && timerData['remaining_seconds'] != null) {
        final remainingSeconds = timerData['remaining_seconds'];

        setState(() {
          _remaining = Duration(seconds: remainingSeconds);
          _totalMinutes = (remainingSeconds / 60).ceil();
          _timerFetched = true;
        });

        // Set deadline based on remaining time
        _deadline = DateTime.now().add(_remaining);

        log("✅ Timer synced: ${_remaining.inMinutes} minutes remaining");

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
      log("🔥 Error fetching server timer: $e");
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
            'This audio call session has expired.',
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
      final mic = await Permission.microphone.request();
      if (mic != PermissionStatus.granted) throw "Microphone permission denied";

      // Fetch server timer first
      await _fetchServerTimer();

      // If session expired, don't proceed with Agora setup
      if (_isSessionExpired) {
        if (mounted) setState(() => _loading = false);
        return;
      }

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
          _startServerSync(); // Start server sync when user joins
          if (mounted) setState(() {});
        },
        onUserOffline: (_, uid, __) {
          _remoteUid = null;
          _showCallEndedDialog();
          if (mounted) setState(() {});
        },
        onConnectionStateChanged: (_, state, __) {
          if (state == ConnectionStateType.connectionStateReconnecting) {
            _showReconnectingDialog();
          }
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
    } catch (e) {
      log("🔥 Error: $e");
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --------------------------------------------------------
  // DIALOGS
  // --------------------------------------------------------
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
    if (_deadline == null) {
      // If no server timer, use default
      _deadline = DateTime.now().add(Duration(minutes: _totalMinutes));
    }

    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_deadline == null) return;

      final d = _deadline!.difference(DateTime.now());
      if (d <= Duration.zero) {
        _showTimeUpDialog();
        _leave();
        return;
      }
      if (mounted) setState(() => _remaining = d);
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
            'Your audio call session has ended.',
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

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, "0");
    final s = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$m:$s";
  }

  double _getProgress() {
    if (_deadline == null) return 0.0;
    final total = Duration(minutes: _totalMinutes).inSeconds;
    final remaining = _remaining.inSeconds;
    return total > 0 ? remaining / total : 0.0;
  }

  Future<void> _leave() async {
    _callTimer?.cancel();
    _serverSyncTimer?.cancel();
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
      body: _loading
          ? _buildLoadingScreen()
          : !_timerFetched
              ? _buildFetchingTimerScreen()
              : _isSessionExpired
                  ? _buildExpiredScreen()
                  : Stack(
                      children: [
                        // Background gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black,
                                Colors.grey.shade900,
                                Colors.black,
                              ],
                            ),
                          ),
                        ),

                        // Animated background waves
                        ..._buildBackgroundWaves(),

                        // Main content
                        SafeArea(
                          child: Column(
                            children: [
                              // Top bar with timer
                              _buildTopBar(),

                              Expanded(
                                child: _remoteUid == null
                                    ? _buildConnectingScreen()
                                    : _buildActiveCallScreen(),
                              ),

                              // Bottom Controls
                              _buildControls(),
                            ],
                          ),
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.timer,
                size: 60,
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
              letterSpacing: 1.2,
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.timer_off,
              size: 60,
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
            "This audio call session is no longer active",
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

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseScale,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.call,
                size: 60,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Initializing call...",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 1.2,
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

  Widget _buildConnectingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated phone icon
          ScaleTransition(
            scale: _pulseScale,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.withOpacity(0.3),
                    Colors.orange.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.phone_in_talk,
                size: 70,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Connecting to user...",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Please wait",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 40),
          // Sound wave animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _soundWaveController,
                builder: (context, child) {
                  return Container(
                    width: 8,
                    height: _waveHeights[index].value,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCallScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Call status with sound waves
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse
              FadeTransition(
                opacity: _waveOpacity,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                ),
              ),
              // Inner pulse
              ScaleTransition(
                scale: _pulseScale,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.green.withOpacity(0.3),
                        Colors.green.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Center icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: const Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Connected",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "You're on a call",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          // Live sound waves
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              return AnimatedBuilder(
                animation: _soundWaveController,
                builder: (context, child) {
                  return Container(
                    width: 6,
                    height: 30 + (index % 3) * 10,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.green.withOpacity(0.3),
                          Colors.green,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundWaves() {
    return List.generate(3, (index) {
      return Positioned(
        top: -100 + (index * 150),
        left: -50,
        right: -50,
        child: FadeTransition(
          opacity: _waveOpacity,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withOpacity(0.03 - (index * 0.01)),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopBar() {
    final progress = _getProgress();
    final isLowTime = progress < 0.2 && progress > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Room info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.meeting_room,
                  size: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  _roomId.length > 8
                      ? "Room: ${_roomId.substring(0, 8)}..."
                      : "Room: $_roomId",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Timer with progress
          if (_deadline != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isLowTime
                    ? Colors.red.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isLowTime
                      ? Colors.red.withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLowTime ? Colors.red : Colors.orange,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: isLowTime ? Colors.red : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _fmt(_remaining),
                    style: TextStyle(
                      color: isLowTime ? Colors.red : Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.mic,
            label: "Mic",
            active: _micOn,
            color: Colors.blue,
            onTap: _toggleMic,
          ),
          _buildControlButton(
            icon: Icons.hearing,
            label: "Earpiece",
            active: _earpieceOn,
            color: Colors.purple,
            onTap: _toggleEarpiece,
          ),
          _buildControlButton(
            icon: Icons.volume_up,
            label: "Speaker",
            active: _speakerOn,
            color: Colors.green,
            onTap: _toggleSpeaker,
          ),
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
            width: 60,
            height: 60,
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
