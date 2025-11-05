import 'dart:async';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/HostLiveRoomPage.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
// ⬇️ import your HostLiveRoomPage

class GoLivePage extends StatefulWidget {
  const GoLivePage({super.key});

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> {
  final FastApiServices _api = FastApiServices();

  bool _starting = false;
  bool _live = false;
  String? _message;
  String? _channelName;
  String? _appId;
  String? _hostToken; // ⬅️ NEW: optional RTC token for host
  int _ttlSeconds = 7200;

  Future<void> _startLive() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _message = null;
    });

    try {
      final res = await _api.startAgoraLive(ttlSeconds: _ttlSeconds);

      final status = (res['status'] == true);
      final channel = (res['channelName'] ?? '').toString();
      final appId = (res['appID'] ?? '').toString();
      final msg = (res['message'] ?? 'Live started').toString();

      // Try common token keys your backend might return
      final token = (res['hostRtcToken'] ??
              res['hostToken'] ??
              res['rtcToken'] ??
              res['token'])
          ?.toString();

      setState(() {
        _live = status || channel.isNotEmpty;
        _channelName = channel.isNotEmpty ? channel : _channelName;
        _appId = appId.isNotEmpty ? appId : _appId;
        _hostToken = (token != null && token.isNotEmpty) ? token : _hostToken;
        _message = msg;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

  void _copy(String label, String value) {
    if (value.isEmpty) return;
    FlutterClipboard.copy(value);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label copied')));
  }

  void _enterLiveRoom() {
    if ((_appId ?? '').isEmpty || (_channelName ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing appId or channelName')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HostLiveRoomPage(
          appId: _appId!, // required
          channelName: _channelName!, // required
          rtcToken: _hostToken, // nullable; pass null if not provided
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
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'When you tap Start Live, the server issues/returns your live channel and host token (if configured).',
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
                  _InfoRow(
                    label: 'Host Token',
                    value: _hostToken ?? '(not required / not provided)',
                    onCopy: (_hostToken ?? '').isEmpty
                        ? null
                        : () => _copy('Host Token', _hostToken!),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Message', value: _message ?? '-'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 👉 Navigate to live room
          if (_live && (_channelName ?? '').isNotEmpty)
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
            child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis)),
        if (onCopy != null) ...[
          const SizedBox(width: 6),
          IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: onCopy,
              tooltip: 'Copy'),
        ],
      ],
    );
  }
}
