import 'dart:async';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/HostLiveRoomPage.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

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
      final res = await _api.startAgoraLive(
        astrologerId: "fea423d4-3f23-43a9-9ecb-a5cd4d0d5247",
        ttlSeconds: _ttlSeconds,
      );

      // === DEBUG: print the whole response so you can inspect keys ===
      debugPrint('startAgoraLive response: $res');

      // Some backends wrap data under 'data' key. try to normalize:
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
        // only mark live when we have a valid channel OR status true & channel present
        _live = (status && channel.isNotEmpty) || channel.isNotEmpty;
        if (channel.isNotEmpty) _channelName = channel;
        if (appId.isNotEmpty) _appId = appId;
        _rtcToken = rtcToken.isNotEmpty ? rtcToken : null;
        _message = msg;
      });
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
    debugPrint('Attempt enterLiveRoom -> appId: "$appId", channel: "$channel", rtcTokenPresent: ${_rtcToken != null}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('appId: ${appId.isEmpty ? "<empty>" : "present"}  •  channel: ${channel.isEmpty ? "<empty>" : "present"}'),
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
        builder: (_) => HostLiveRoomPage(
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
      appBar: AppBar(
        title: const Text('Go Live'),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_live)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _ending
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: _endLive,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('End Live'),
                    ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _live ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _live ? 'LIVE' : 'Offline',
                style: TextStyle(
                  color: _live ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              const Chip(
                label: Text('Token: not used'),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap Start Live to get channel & appId. We are NOT passing any RTC token to the host (requires App Certificate to be DISABLED in Agora project).',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),

          // TTL selector
          Row(
            children: [
              const Text('Session TTL:'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _ttlSeconds,
                items: const [
                  DropdownMenuItem(value: 1800, child: Text('30 min')),
                  DropdownMenuItem(value: 3600, child: Text('1 hour')),
                  DropdownMenuItem(value: 7200, child: Text('2 hours')),
                  DropdownMenuItem(value: 14400, child: Text('4 hours')),
                ],
                onChanged: canStart
                    ? (v) => setState(() => _ttlSeconds = v ?? 7200)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Start / Refresh
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: canStart ? _startLive : null,
              icon: _starting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(_starting
                  ? 'Starting…'
                  : (_live ? 'Refresh / Resume' : 'Start Live')),
            ),
          ),

          const SizedBox(height: 24),

          // Result panel
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Live Details',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Channel Name',
                    value: _channelName ?? '-',
                    onCopy: (_channelName ?? '').isEmpty
                        ? null
                        : () => _copy('Channel name', _channelName!),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'App ID',
                    value: _appId ?? '-',
                    onCopy: (_appId ?? '').isEmpty
                        ? null
                        : () => _copy('App ID', _appId!),
                  ),
                  const SizedBox(height: 8),
                  const _InfoRow(
                    label: 'Host Token',
                    value:
                        '(not used – join with empty token; App Certificate must be DISABLED)',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Message', value: _message ?? '-'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 👉 Navigate to live room
          // 👉 Navigate to live room (only when BOTH appId & channelName are available)
          if (_live &&
              (_channelName ?? '').isNotEmpty &&
              (_appId ?? '').isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _enterLiveRoom,
                icon: const Icon(Icons.video_call),
                label: const Text('Enter Live Room'),
              ),
            ),

        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.onCopy});

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onCopy != null) ...[
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: onCopy,
            tooltip: 'Copy',
          ),
        ],
      ],
    );
  }
}
