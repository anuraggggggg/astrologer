  import 'dart:async';
  import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/HostLiveRoomPage.dart';
  import 'package:flutter/material.dart';
  import 'package:clipboard/clipboard.dart';
  import 'package:astrowaypartner/fastApi/fastApiServices.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class GoLivePage extends StatefulWidget {
    const GoLivePage({super.key});

    @override
    State<GoLivePage> createState() => _GoLivePageState();
  }

  class _GoLivePageState extends State<GoLivePage> {
    final FastApiServices _api = FastApiServices();

    bool _starting = false;
    bool _ending = false;
    bool _live = false;

    String? _message;
    String? _channelName;
    String? _appId;

    int _ttlSeconds = 7200;
    String? _rtcToken;

    // 🚨 NEW: PERMISSION HANDLER
    Future<bool> _checkPermissions() async {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      bool cam = statuses[Permission.camera]!.isGranted;
      bool mic = statuses[Permission.microphone]!.isGranted;

      if (!cam || !mic) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Camera & Microphone permissions are required")),
        );
        return false;
      }
      return true;
    }

    // 🔴 Start live
    Future<void> _startLive() async {
      if (_starting) return;

      setState(() {
        _starting = true;
        _message = null;
      });

      try {
        // 🔹 Get astrologer_id dynamically
        final prefs = await SharedPreferences.getInstance();
        final astrologerId = prefs.getString('astro_id');

        if (astrologerId == null || astrologerId.isEmpty) {
          throw Exception('Astrologer ID not found in SharedPreferences');
        }

        // 🔹 Hit API
        final res = await _api.startAgoraLive(
          astrologerId: astrologerId,
          ttlSeconds: _ttlSeconds,
        );

        final payload = (res['data'] is Map) ? res['data'] : res;

        final status = (res['status'] == true);

        final channel = (payload['channelName'] ??
                payload['channel_name'] ??
                payload['channel'] ??
                payload['room'] ??
                '')
            .toString();

        final appId =
            (payload['appID'] ?? payload['appid'] ?? payload['app_id'] ?? '')
                .toString();

        final msg = (res['message'] ?? 'Live started').toString();

        final rtcToken =
            (payload['rtc_token'] ?? payload['token'] ?? '').toString();

        setState(() {
          _live = status && channel.isNotEmpty;
          _channelName = channel.isNotEmpty ? channel : null;
          _appId = appId.isNotEmpty ? appId : null;
          _rtcToken = rtcToken.isNotEmpty ? rtcToken : null;
          _message = msg;
        });

        // 🚨 ASK PERMISSIONS BEFORE ENTERING LIVE ROOM
        if (!await _checkPermissions()) {
          return;
        }

        // 🔹 Enter live room
        if (_rtcToken != null && _rtcToken!.isNotEmpty) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HostLiveRoomPage(
                appId: _appId!,
                channelName: _channelName!,
                rtcToken: _rtcToken!,
              ),
            ),
          );

          // Reset UI after returning
          if (mounted) {
            setState(() {
              _live = false;
              _starting = false;
              _ending = false;
              _message = "Session ended successfully";
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('RTC Token missing. Cannot start live session.')),
          );
        }
      } catch (e) {
        setState(() {
          _message = e.toString();
          _live = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to start live: $e')));
      } finally {
        if (mounted) setState(() => _starting = false);
      }
    }

    // 🔴 End live
    Future<void> _endLive() async {
      if (_ending) return;

      setState(() => _ending = true);

      try {
        final res = await _api.endAgoraLive();
        final msg = (res['message'] ?? 'Live ended').toString();

        setState(() {
          _live = false;
          _message = msg;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('End live failed: $e')));
      } finally {
        if (mounted) setState(() => _ending = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      final canStart = !_starting;

      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circle animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: _live ? 120 : 100,
                  height: _live ? 120 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _live
                          ? [Colors.redAccent, Colors.pinkAccent]
                          : [Colors.yellow.shade700, Colors.yellow.shade200],
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
                      size: 50,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  _live ? 'You’re Live Now 🎥' : 'Go Live Instantly!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _live ? Colors.redAccent : Colors.yellow.shade700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _live
                      ? 'Streaming live for your followers...'
                      : 'Tap below to start your live session.',
                  style: TextStyle(color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Start / End button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _live ? Colors.redAccent : Colors.yellow.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _live ? _endLive : (canStart ? _startLive : null),
                    icon: _starting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(_live ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      _starting
                          ? 'Starting…'
                          : _live
                              ? 'End Live'
                              : 'Start Live',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                if (_message != null)
                  Text(
                    _message!,
                    style: TextStyle(
                        color: _live ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
