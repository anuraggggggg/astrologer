import 'dart:async';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/HostLiveRoomPage.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
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

  // We are NOT using any RTC token here.
  // intensionally removed _hostToken and any token handling.

  int _ttlSeconds = 7200;
  String? _rtcToken;


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

      // 🔹 Now call API
      final res = await _api.startAgoraLive(
        astrologerId: astrologerId,
        ttlSeconds: _ttlSeconds,
      );

      debugPrint('startAgoraLive response: $res');

      // Some backends wrap data under 'data' key.
      final payload = (res['data'] is Map) ? res['data'] : res;

      final status = (res['status'] == true);
      final channel = (payload['channelName'] ??
          payload['channel_name'] ??
          payload['channel'] ??
          payload['room'] ??
          payload['room_name'] ??
          '')
          .toString();

      final appId = (payload['appID'] ??
          payload['app_id'] ??
          payload['appId'] ??
          payload['appid'] ??
          '')
          .toString();

      final msg = (res['message'] ??
          payload['message'] ??
          'Live started')
          .toString();

      final rtcToken = (payload['rtc_token'] ??
          payload['rtcToken'] ??
          payload['token'] ??
          '')
          .toString();

      setState(() {
        _live = (status && channel.isNotEmpty) || channel.isNotEmpty;
        if (channel.isNotEmpty) _channelName = channel;
        if (appId.isNotEmpty) _appId = appId;
        _rtcToken = rtcToken.isNotEmpty ? rtcToken : null;
        _message = msg;
      });

      // ✅ If token received, navigate to live page
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

// 🟢 When host ends and returns, reset UI
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
            content: Text('RTC token missing in response. Cannot go live.'),
          ),
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


  Future<void> _endLive() async {
    if (_ending) return;
    setState(() => _ending = true);
    try {
      final res = await _api.endAgoraLive();
      final msg = (res['message'] ?? 'Live ended').toString();
      setState(() {
        _live = false;
        // Keep channel/appId for reference if backend returns the same channel
        // You can also clear them if you prefer:
        // _channelName = null;
        // _appId = null;
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

  void _copy(String label, String value) {
    if (value.isEmpty) return;
    FlutterClipboard.copy(value);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label copied')));
  }

  void _enterLiveRoom() {
    final appId = _appId ?? '';
    final channel = _channelName ?? '';

    // debug logs + short snackbar for quick feedback
    debugPrint(
        'Attempt enterLiveRoom -> appId: "$appId", channel: "$channel", rtcTokenPresent: ${_rtcToken !=
            null}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('appId: ${appId.isEmpty
            ? "<empty>"
            : "present"}  •  channel: ${channel.isEmpty
            ? "<empty>"
            : "present"}'),
        duration: const Duration(seconds: 2),
      ),
    );

    if (appId.isEmpty || channel.isEmpty) {
      // keep the original error message for user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing appId or channelName')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            HostLiveRoomPage(
              appId: appId,
              channelName: channel,
              rtcToken: _rtcToken, // pass nullable token
            ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final canStart = !_starting;

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text('Go Live'),
      //   backgroundColor: Colors.deepPurple,
        // actions: [
        //   if (_live)
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 8),
        //       child: _ending
        //           ? const Center(
        //         child: SizedBox(
        //           width: 20,
        //           height: 20,
        //           child: CircularProgressIndicator(
        //               strokeWidth: 2, color: Colors.white),
        //         ),
        //       )
        //           : TextButton.icon(
        //         style: TextButton.styleFrom(
        //           foregroundColor: Colors.white,
        //           backgroundColor: Colors.redAccent,
        //         ),
        //         onPressed: _endLive,
        //         icon: const Icon(Icons.stop_circle_outlined),
        //         label: const Text('End Live'),
        //       ),
        //     ),
        // ],
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Live indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: _live ? 120 : 100,
                height: _live ? 120 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _live
                        ? [Colors.redAccent, Colors.pinkAccent]
                        : [Colors.yellow.shade700, Colors.yellow.shade200,],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _live ? Colors.redAccent.withOpacity(0.5) : Colors
                          .yellow.withOpacity(0.4),
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
                    backgroundColor: _live ? Colors.redAccent : Colors.yellow.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _live
                      ? _endLive
                      : (canStart ? _startLive : null),
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