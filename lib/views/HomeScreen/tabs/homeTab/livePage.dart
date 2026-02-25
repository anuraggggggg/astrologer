// lib/views/HomeScreen/tabs/homeTab/GoLivePage.dart

import 'dart:async';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/HostLiveRoomPage.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class GoLivePage extends StatefulWidget {
  const GoLivePage({super.key});

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> with TickerProviderStateMixin {
  final FastApiServices _api = FastApiServices();

  bool _starting = false;
  bool _ending = false;
  bool _live = false;
  bool _micMuted = false;

  String? _message;
  String? _channelName;
  String? _appId;

  int _ttlSeconds = 7200;
  String? _rtcToken;

  // Animation controllers
  late AnimationController _pulseAnimation;
  late AnimationController _glowAnimation;
  late Animation<double> _pulseScale;
  late Animation<double> _glowOpacity;

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

    _glowAnimation = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowAnimation, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseAnimation.dispose();
    _glowAnimation.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  // 🚨 PERMISSION HANDLER
  Future<bool> _checkPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    bool cam = statuses[Permission.camera]!.isGranted;
    bool mic = statuses[Permission.microphone]!.isGranted;

    if (!cam || !mic) {
      _showPermissionDialog();
      return false;
    }
    return true;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permissions Required'),
          ],
        ),
        content: const Text(
          'Camera and microphone permissions are needed to go live. '
          'Please grant them in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => openAppSettings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // 🔴 Start live
  Future<void> _startLive() async {
    if (_starting) return;

    setState(() {
      _starting = true;
      _message = null;
    });

    try {
      // 🔹 Get astrologer_id
      final prefs = await SharedPreferences.getInstance();
      final astrologerId = prefs.getString('astro_id');

      if (astrologerId == null || astrologerId.isEmpty) {
        throw Exception('Astrologer ID not found');
      }

      // 🔹 Ask permissions BEFORE live
      if (!await _checkPermissions()) {
        setState(() => _starting = false);
        return;
      }

      // 🔹 Call API to start live
      final res = await _api.startAgoraLive(
        astrologerId: astrologerId,
        ttlSeconds: _ttlSeconds,
      );

      final payload = (res['data'] is Map) ? res['data'] : res;
      final bool status = res['status'] == true;

      final String channel = (payload['channelName'] ??
              payload['channel_name'] ??
              payload['channel'] ??
              payload['room'] ??
              '')
          .toString();

      final String appId =
          (payload['appID'] ?? payload['appid'] ?? payload['app_id'] ?? '')
              .toString();

      final String rtcToken =
          (payload['rtc_token'] ?? payload['token'] ?? '').toString();

      final String msg = (res['message'] ?? 'Live started').toString();

      if (!status || channel.isEmpty || appId.isEmpty || rtcToken.isEmpty) {
        throw Exception('Invalid live session data received');
      }

      // 🔒 KEEP SCREEN AWAKE DURING LIVE
      await WakelockPlus.enable();

      // 🔹 Update UI state
      if (!mounted) return;
      setState(() {
        _live = true;
        _channelName = channel;
        _appId = appId;
        _rtcToken = rtcToken;
        _message = msg;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You are now live! 🎥'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // 🔹 Enter Live Room
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HostLiveRoomPage(
            appId: _appId!,
            channelName: _channelName!,
            rtcToken: _rtcToken!,
            initialMute: _micMuted,
          ),
        ),
      );

      // 🔓 Live ended → release wakelock
      await WakelockPlus.disable();

      if (!mounted) return;
      setState(() {
        _live = false;
        _starting = false;
        _ending = false;
        _message = "Session ended successfully";
      });
    } catch (e) {
      // 🔓 Safety: always release wakelock on error
      await WakelockPlus.disable();

      if (!mounted) return;
      setState(() {
        _live = false;
        _message = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start live: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _starting = false;
        });
      }
    }
  }

  // 🔴 End live
  Future<void> _endLive() async {
    if (_ending) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Live Session?'),
        content: const Text('Are you sure you want to end your live stream?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Live'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _ending = true);

    try {
      final res = await _api.endAgoraLive();
      final msg = (res['message'] ?? 'Live ended').toString();

      setState(() {
        _live = false;
        _message = msg;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End live failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _ending = false);
    }
  }

  // Toggle microphone mute
  void _toggleMute() {
    setState(() {
      _micMuted = !_micMuted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_micMuted ? 'Microphone muted' : 'Microphone unmuted'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _micMuted ? Colors.orange : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canStart = !_starting && !_ending;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Live Stream',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // 🔴 FIX: Make content scrollable
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated live indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow
                    if (_live)
                      FadeTransition(
                        opacity: _glowOpacity,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.red.withOpacity(0.3),
                                Colors.red.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Main circle
                    ScaleTransition(
                      scale: _live
                          ? _pulseScale
                          : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: _live ? 140 : 120,
                        height: _live ? 140 : 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _live
                                ? [Colors.redAccent, Colors.pinkAccent]
                                : [
                                    Colors.yellow.shade700,
                                    Colors.orange.shade300
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _live
                                  ? Colors.redAccent.withOpacity(0.5)
                                  : Colors.yellow.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _live ? Icons.videocam : Icons.videocam_outlined,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ),

                    // Live badge
                    if (_live)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fiber_manual_record,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // Status text
                Text(
                  _live ? 'You\'re Live Now' : 'Ready to Go Live',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _live ? Colors.redAccent : Colors.yellow.shade700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _live
                      ? 'Streaming to your followers...'
                      : 'Connect with your audience in real-time',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (_live && _channelName != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.live_tv,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Channel: ${_channelName!.substring(0, 8)}...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Live controls card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Mute toggle (only when live)
                      if (_live) ...[
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _micMuted
                                  ? Colors.orange.shade50
                                  : Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _micMuted ? Icons.mic_off : Icons.mic,
                              color: _micMuted ? Colors.orange : Colors.green,
                            ),
                          ),
                          title: Text(
                            _micMuted
                                ? 'Microphone Muted'
                                : 'Microphone Active',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            _micMuted
                                ? 'Audience cannot hear you'
                                : 'Audience can hear you',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                          trailing: Switch(
                            value: !_micMuted,
                            onChanged: (_) => _toggleMute(),
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.orange,
                          ),
                        ),
                        const Divider(height: 24),
                      ],

                      // Main action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _live
                                ? Colors.redAccent
                                : Colors.yellow.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          onPressed:
                              _live ? _endLive : (canStart ? _startLive : null),
                          icon: _starting || _ending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(_live ? Icons.stop : Icons.play_arrow),
                          label: Text(
                            _starting
                                ? 'Starting...'
                                : _ending
                                    ? 'Ending...'
                                    : _live
                                        ? 'End Live Stream'
                                        : 'Start Live Stream',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      if (_message != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _live
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _live ? Icons.check_circle : Icons.info,
                                color: _live ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _message!,
                                  style: TextStyle(
                                    color: _live ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tips section
                if (!_live)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Tips',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Ensure good lighting\n'
                                '• Stable internet connection\n'
                                '• You can mute anytime during live',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // 🔴 ADDED: Extra bottom padding to ensure no overflow
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
