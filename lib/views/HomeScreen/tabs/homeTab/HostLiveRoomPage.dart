// lib/views/HomeScreen/tabs/homeTab/HostLiveRoomPage.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class HostLiveRoomPage extends StatefulWidget {
  final String appId;
  final String channelName;
  final String? rtcToken;

  const HostLiveRoomPage({
    super.key,
    required this.appId,
    required this.channelName,
    this.rtcToken,
  });

  @override
  State<HostLiveRoomPage> createState() => _HostLiveRoomPageState();
}

class _HostLiveRoomPageState extends State<HostLiveRoomPage>
    with WidgetsBindingObserver {
  late final RtcEngine _engine;
  bool _joined = false;
  int _fps = 15; 
  int? _dataStreamId;
  late final int _myUid;

  String _displayName =
      ''; // <-- will be replaced by real name if fetch succeeds

  final List<_Comment> _comments = [];
  final TextEditingController _commentCtrl = TextEditingController();
  final ScrollController _commentScroll = ScrollController();

  bool _ending = false;

  /// Message reassembly buffer
  final Map<String, List<String?>> _recvParts = {};
  final Map<String, int> _recvTotal = {};

  String _tag(String s) => '[HostLiveRoom] $s';
  void _log(String msg) =>
      debugPrint('$_tag ${DateTime.now().toIso8601String()} -> $msg');

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _endLive();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _myUid = Random().nextInt(900000) + 1000;
    _init();
  }

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------
  Future<void> _init() async {
    _log('INIT START (uid=$_myUid)');
    _engine = createAgoraRtcEngine();

    try {
      await _engine.initialize(RtcEngineContext(appId: widget.appId));
      _log('RtcEngine.initialize OK');
    } catch (e) {
      _log('RtcEngine.initialize FAILED: $e');
      rethrow;
    }

    // Register events
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
        _log(
            'onJoinChannelSuccess channel=${connection.channelId} uid=${connection.localUid}');
        if (!mounted) return;
        setState(() => _joined = true);

        // Try to fetch profile name (non-blocking)
        (() async {
          try {
            final api = FastApiServices();
            final fetched =
                await api.getAstrologerById(); // your existing method
            final name =
                (fetched?['name'] ?? fetched?['displayName'] ?? '').toString();
            if (name.isNotEmpty && mounted) {
              setState(() => _displayName = name);
              _log('Display name loaded: $_displayName');
            }
          } catch (e) {
            _log('Could not fetch profile name: $e');
          }
        })();
        try {
          final id = await _engine.createDataStream(
            const DataStreamConfig(syncWithAudio: false, ordered: true),
          );
          _dataStreamId = id;
          _log('createDataStream SUCCESS id=$_dataStreamId');
        } catch (e) {
          _log('createDataStream FAILED: $e');
        }
      },

      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        _log('onUserJoined uid=$remoteUid');
      },

      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        _log('onUserOffline uid=$remoteUid reason=$reason');
      },

      onError: (ErrorCodeType err, String msg) {
        _log('onError $err $msg');

        if (!mounted) return;
        final text = err == ErrorCodeType.errInvalidToken
            ? 'Invalid/expired RTC token.'
            : 'Agora error $err: $msg';

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(text)));
      },

      // -----------------------------------------------------------------------
      // RECEIVE STREAM MESSAGE (chunk-based)
      // -----------------------------------------------------------------------
      onStreamMessage: (RtcConnection connection, int uid, int streamId,
          Uint8List data, int offset, int length) {
        try {
          final trimmed = _trimNulls(Uint8List.fromList(data));
          final text = utf8.decode(trimmed);

          // Envelope decode
          final Map<String, dynamic> envelope = jsonDecode(text);
          final m = envelope['m'];
          final d = envelope['d'];
          if (m == null || d == null) {
            _log('Invalid envelope');
            return;
          }

          final id = m['id'].toString();
          final part = int.tryParse(m['part'].toString()) ?? 0;
          final total = int.tryParse(m['total'].toString()) ?? 1;

          _recvParts.putIfAbsent(id, () => List<String?>.filled(total, null));
          _recvTotal[id] = total;

          if (part < 0 || part >= total) {
            _log('Invalid part index');
            return;
          }

          _recvParts[id]![part] = d;

          // Check if all parts arrived
          final parts = _recvParts[id]!;
          if (!parts.every((p) => p != null)) {
            return;
          }

          // Assemble
          final combinedBytes = <int>[];
          for (final b64 in parts) {
            combinedBytes.addAll(base64.decode(b64!));
          }

          _recvParts.remove(id);
          _recvTotal.remove(id);

          final payload = utf8.decode(combinedBytes);
          _log('Assembled payload=$payload');

          final Map<String, dynamic> obj = jsonDecode(payload);
          final textMsg = obj['text']?.toString() ?? '';
          final user = obj['user']?.toString() ?? 'User';
          final ts = obj['ts']?.toString();

          DateTime at = DateTime.now();
          if (ts != null) {
            try {
              at = DateTime.parse(ts);
            } catch (_) {}
          }

          if (mounted) {
            setState(() => _comments.add(_Comment(user, textMsg, at)));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_commentScroll.hasClients) {
                _commentScroll.animateTo(
                  _commentScroll.position.maxScrollExtent + 80,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        } catch (e, st) {
          _log('onStreamMessage FAILED: $e\n$st');
        }
      },

      onConnectionStateChanged: (RtcConnection connection,
          ConnectionStateType state, ConnectionChangedReasonType reason) {
        _log('Connection changed state=$state reason=$reason');
      },
    ));

    // Video config
    await _engine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();

    await _engine.startPreview();

    await _engine.setVideoEncoderConfiguration(VideoEncoderConfiguration(
      dimensions: const VideoDimensions(width: 720, height: 1280),
      frameRate: _fps,
      bitrate: 1130,
      orientationMode: OrientationMode.orientationModeFixedPortrait,
    ));

    // Join channel
    try {
      await _engine.joinChannel(
        token: widget.rtcToken ?? '',
        channelId: widget.channelName,
        uid: _myUid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
      _log('joinChannel requested');
    } catch (e) {
      _log('join FAILED: $e');
    }

    _log('INIT END');
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Uint8List _trimNulls(Uint8List bytes) {
    int start = 0;
    int end = bytes.length;

    while (start < end && bytes[start] == 0) start++;
    while (end > start && bytes[end - 1] == 0) end--;

    return bytes.sublist(start, end);
  }

  // ---------------------------------------------------------------------------
  // SEND CHAT (Chunked)
  // ---------------------------------------------------------------------------
  Future<void> _sendChat(String text) async {
    if (text.trim().isEmpty) return;

    if (_dataStreamId == null) {
      try {
        _dataStreamId = await _engine.createDataStream(
          const DataStreamConfig(syncWithAudio: false, ordered: true),
        );
      } catch (_) {}
    }

    final payloadMap = {
      "type": "chat",
      "user": _displayName,
      "text": text.trim(),
      "ts": DateTime.now().toIso8601String(),
    };

    final payloadBytes = utf8.encode(jsonEncode(payloadMap));
    final id =
        '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

    const chunkSize = 900;
    final total = ((payloadBytes.length + chunkSize - 1) / chunkSize).floor();

    int sent = 0;
    int part = 0;

    try {
      while (sent < payloadBytes.length) {
        final take = min(chunkSize, payloadBytes.length - sent);
        final chunk = payloadBytes.sublist(sent, sent + take);

        final envelope = jsonEncode({
          "m": {"id": id, "part": part, "total": total},
          "d": base64.encode(chunk),
        });

        final bytesToSend = Uint8List.fromList(utf8.encode(envelope));

        if (_dataStreamId != null) {
          await _engine.sendStreamMessage(
            streamId: _dataStreamId!,
            data: bytesToSend,
            length: bytesToSend.length,
          );
        }

        sent += take;
        part++;
        await Future.delayed(const Duration(milliseconds: 6));
      }

      if (mounted) {
        setState(() => _comments
            .add(_Comment('$_displayName (You)', text.trim(), DateTime.now())));

        _commentCtrl.clear();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_commentScroll.hasClients) {
            _commentScroll.animateTo(
              _commentScroll.position.maxScrollExtent + 80,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      _log('sendStreamMessage failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // END LIVE
  // ---------------------------------------------------------------------------
  Future<void> _endLive({bool pop = true}) async {
    if (_ending) return;
    _ending = true;

    // stop live on server
    try {
      await FastApiServices().endAgoraLive();
    } catch (_) {}

    // cleanup agora
    try {
      await _engine.leaveChannel();
      await _engine.release();
    } catch (_) {}

    // pop screen only if requested and still mounted
    if (pop && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _commentCtrl.dispose();
    _commentScroll.dispose();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
    // WidgetsBinding.instance.removeObserver(this);
    // _endLive();
    // _commentCtrl.dispose();
    // _commentScroll.dispose();

    // () async {
    //   try {
    //     await FastApiServices().endAgoraLive();
    //   } catch (_) {}

    //   try {
    //     await _engine.leaveChannel();
    //     await _engine.release();
    //   } catch (_) {}
    // }();

    // super.dispose();
  }

  void _onSendPressed() => _sendChat(_commentCtrl.text);

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _endLive();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              decoration: BoxDecoration(
                // BLOCK COLOR
                borderRadius: BorderRadius.circular(10), // ROUND CORNERS
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _endLive,
              ),
            ),
          ),
          title: Text(_joined ? 'Live: ${_displayName}' : 'Connecting…'),
          actions: [
            // PopupMenuButton<int>(
            //   onSelected: (v) async {
            //     setState(() => _fps = v);
            //     await _engine.setVideoEncoderConfiguration(
            //       VideoEncoderConfiguration(
            //         dimensions: const VideoDimensions(width: 720, height: 1280),
            //         frameRate: v,
            //         bitrate: 1130,
            //         orientationMode: OrientationMode.orientationModeFixedPortrait,
            //       ),
            //     );
            //   },
            //   itemBuilder: (_) => const [
            //     PopupMenuItem(value: 15, child: Text('FPS: 15')),
            //     PopupMenuItem(value: 24, child: Text('FPS: 24')),
            //     PopupMenuItem(value: 30, child: Text('FPS: 30')),
            //   ],
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 12),
            //     child: Center(child: Text('$_fps FPS')),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ending
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.stop_circle_outlined,
                          color: Colors.redAccent, size: 30),
                      tooltip: 'End Live',
                      onPressed: _endLive,
                    ),
            ),
          ],
        ),

        // -----------------------------------------------------------------------
        // BODY
        // -----------------------------------------------------------------------
        body: Stack(
          children: [
            // VIDEO VIEW
            Positioned.fill(
              child: _joined
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),

            // COMMENTS + INPUT
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                minimum: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // COMMENT LIST
                    Container(
                      height: 160,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        controller: _commentScroll,
                        itemCount: _comments.length,
                        itemBuilder: (_, i) => _CommentTile(c: _comments[i]),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // INPUT FIELD
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Say something…',
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.35),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (_) => _onSendPressed(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _onSendPressed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// COMMENT OBJECT + TILE
// -----------------------------------------------------------------------------
class _Comment {
  final String user;
  final String text;
  final DateTime at;

  _Comment(this.user, this.text, this.at);
}

class _CommentTile extends StatelessWidget {
  final _Comment c;

  const _CommentTile({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 10,
            child: Icon(Icons.person, size: 12),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${c.user}: ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: c.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
