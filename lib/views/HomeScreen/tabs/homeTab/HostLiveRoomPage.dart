// lib/views/HomeScreen/tabs/homeTab/HostLiveRoomPage.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart'; // must expose endAgoraLive()

class HostLiveRoomPage extends StatefulWidget {
  final String appId;
  final String channelName;
  final String? rtcToken; // use if provided

  const HostLiveRoomPage({
    super.key,
    required this.appId,
    required this.channelName,
    this.rtcToken,
  });

  @override
  State<HostLiveRoomPage> createState() => _HostLiveRoomPageState();
}

class _HostLiveRoomPageState extends State<HostLiveRoomPage> {
  late final RtcEngine _engine;
  bool _joined = false;
  int _fps = 15;
  int? _dataStreamId;

  final List<_Comment> _comments = [];
  final TextEditingController _commentCtrl = TextEditingController();
  final ScrollController _commentScroll = ScrollController();

  bool _ending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  // place inside _HostLiveRoomPageState (near other members)
  String _tag(String s) => '[HostLiveRoom] $s';

  void _log(String msg) {
    final now = DateTime.now().toIso8601String();
    debugPrint('$_tag $now -> $msg');
  }

  Future<void> _init() async {
    _log('INIT START');

    try {
      _engine = createAgoraRtcEngine();
      _log('RtcEngine created');
    } catch (e) {
      _log('FAILED createAgoraRtcEngine: $e');
      rethrow;
    }

    try {
      await _engine.initialize(RtcEngineContext(appId: widget.appId));
      _log('RtcEngine.initialize SUCCESS (appId=${widget.appId})');
    } catch (e) {
      _log('RtcEngine.initialize FAILED: $e');
      rethrow;
    }

    try {
      await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
      _log('setChannelProfile -> channelProfileLiveBroadcasting');
    } catch (e) {
      _log('setChannelProfile FAILED: $e');
    }

    try {
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      _log('setClientRole -> Broadcaster');
    } catch (e) {
      _log('setClientRole FAILED: $e');
    }

    try {
      await _engine.enableVideo();
      await _engine.startPreview();
      _log('enableVideo + startPreview done');
    } catch (e) {
      _log('enableVideo/startPreview FAILED: $e');
    }

    try {
      await _engine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 720, height: 1280),
          frameRate: 15,
          bitrate: 1130,
          orientationMode: OrientationMode.orientationModeFixedPortrait,
        ),
      );
      _log('setVideoEncoderConfiguration set (720x1280, fps=15)');
    } catch (e) {
      _log('setVideoEncoderConfiguration FAILED: $e');
    }

    // Register detailed event handler with extra logging
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          _log('onJoinChannelSuccess channel=${connection.channelId} uid=${connection.localUid} elapsed=$elapsed');
          if (!mounted) return;
          setState(() => _joined = true);

          // (re)create data stream on every join to be safe
          try {
            final id = await _engine.createDataStream(
              const DataStreamConfig(syncWithAudio: false, ordered: true),
            );
            _dataStreamId = id;
            _log('createDataStream SUCCESS id=$_dataStreamId');
          } catch (e) {
            _dataStreamId = null;
            _log('createDataStream FAILED: $e');
          }
        },

        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _log('onUserJoined uid=$remoteUid channel=${connection.channelId} elapsed=$elapsed');
        },

        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          _log('onUserOffline uid=$remoteUid reason=$reason channel=${connection.channelId}');
        },

        onError: (ErrorCodeType err, String msg) {
          _log('onError err=$err msg=$msg');
          if (!mounted) return;
          final text = err == ErrorCodeType.errInvalidToken
              ? 'Invalid/expired RTC token. Make sure token is valid or App Certificate is disabled.'
              : 'Agora error $err: $msg';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
        },

        onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
          _log('onConnectionStateChanged channel=${connection.channelId} state=$state reason=$reason');
          // If reconnected, ensure dataStream exists (safety)
          if (state == ConnectionStateType.connectionStateConnected) {
            _log('Connection re-established on channel=${connection.channelId}');
            // optional: recreate data stream if missing
            if (_dataStreamId == null) {
              _log('Data stream missing after reconnect — attempting to create');
              () async {
                try {
                  final id = await _engine.createDataStream(const DataStreamConfig(syncWithAudio: false, ordered: true));
                  _dataStreamId = id;
                  _log('createDataStream after reconnect SUCCESS id=$_dataStreamId');
                } catch (e) {
                  _log('createDataStream after reconnect FAILED: $e');
                }
              }();
            }
          }
        },

        onStreamMessage: (RtcConnection connection, int uid, int streamId, Uint8List data, int offset, int length) {
          try {
            final bytes = data.sublist(offset, offset + length);
            final payload = utf8.decode(bytes);
            _log('onStreamMessage received streamId=$streamId from uid=$uid length=$length payload=$payload');

            // parse safely
            try {
              final obj = jsonDecode(payload) as Map<String, dynamic>;
              final user = obj['user']?.toString() ?? 'User';
              final text = obj['text']?.toString() ?? '';
              final ts = obj['ts']?.toString();
              DateTime at = DateTime.now();
              if (ts != null) {
                try {
                  at = DateTime.parse(ts);
                } catch (_) {}
              }

              if (mounted) {
                setState(() {
                  _comments.add(_Comment(user, text, at));
                });
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
              _log('onStreamMessage json parse FAILED: $e payload=$payload');
            }
          } catch (e) {
            _log('onStreamMessage processing FAILED: $e');
          }
        },

        onStreamMessageError: (RtcConnection connection, int uid, int streamId, ErrorCodeType error, int missed, int cached) {
          _log('onStreamMessageError uid=$uid streamId=$streamId error=$error missed=$missed cached=$cached');
        },

        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          _log('onLeaveChannel channel=${connection.channelId}');
//        if (mounted) setState(() => _joined = false);
        },
      ),
    );

    final String tokenToUse = widget.rtcToken ?? '';
    _log('About to join channel=${widget.channelName} tokenPresent=${widget.rtcToken != null}');

    try {
      await _engine.joinChannel(
        token: tokenToUse,
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
      _log('joinChannel call completed (await returned)');
    } catch (e) {
      _log('joinChannel FAILED: $e');
    }

    _log('INIT END');
  }


  Future<void> _endLive() async {
    if (_ending) return;
    setState(() => _ending = true);
    try {
      final res = await FastApiServices().endAgoraLive();
      final msg = (res['message'] ?? 'Live ended').toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('End live failed: $e')));
      }
    } finally {
      try {
        await _engine.leaveChannel();
        await _engine.release();
      } catch (_) {}
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentScroll.dispose();

    // cleanup & auto end (fire-and-forget)
    () async {
      try {
        await FastApiServices().endAgoraLive();
      } catch (e) {
        debugPrint('Auto end live failed: $e');
      }
      try {
        await _engine.leaveChannel();
        await _engine.release();
      } catch (e) {
        debugPrint('Agora cleanup failed: $e');
      }
    }();

    super.dispose();
  }

  // send message using new sendStreamMessage named params
  Future<void> _sendChatViaDataStream(String text) async {
    if (text.trim().isEmpty) return;

    if (_dataStreamId == null) {
      try {
        final id = await _engine.createDataStream(
          const DataStreamConfig(syncWithAudio: false, ordered: true),
        );
        debugPrint('Created data stream on-demand id=$id');
        _dataStreamId = id;
      } catch (e) {
        debugPrint('Failed to create data stream on-demand: $e');
      }
    }

    final payload = jsonEncode({
      "type": "chat",
      "user": "Host", // replace with real name/uid if available
      "text": text.trim(),
      "ts": DateTime.now().toIso8601String(),
    });

    final bytes = Uint8List.fromList(utf8.encode(payload));

    try {
      if (_dataStreamId != null) {
        await _engine.sendStreamMessage(streamId: _dataStreamId!, data: bytes, length: bytes.length);
      } else {
        debugPrint('No data stream id available, added locally only');
      }

      // local UI update
      setState(() {
        _comments.add(_Comment('Host', text.trim(), DateTime.now()));
      });
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
    } catch (e) {
      debugPrint('sendStreamMessage failed: $e');
      setState(() {
        _comments.add(_Comment('Host', text.trim(), DateTime.now()));
      });
      _commentCtrl.clear();
    }
  }

  void _addCommentFromInput(String text) {
    _sendChatViaDataStream(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_joined ? 'Live: ${widget.channelName}' : 'Connecting…'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (v) async {
              setState(() => _fps = v);
              await _engine.setVideoEncoderConfiguration(
                VideoEncoderConfiguration(
                  dimensions: const VideoDimensions(width: 720, height: 1280),
                  frameRate: v,
                  bitrate: 1130,
                  orientationMode: OrientationMode.orientationModeFixedPortrait,
                ),
              );
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 15, child: Text('FPS: 15')),
              PopupMenuItem(value: 24, child: Text('FPS: 24')),
              PopupMenuItem(value: 30, child: Text('FPS: 30')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text('$_fps FPS')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _ending
                ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : IconButton(
              icon: const Icon(
                Icons.stop_circle_outlined,
                color: Colors.redAccent,
                size: 30,
              ),
              tooltip: 'End Live Session',
              onPressed: _endLive,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
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

          // Comments overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: _addCommentFromInput,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () => _addCommentFromInput(_commentCtrl.text),
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
    );
  }
}

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
          const CircleAvatar(radius: 10, child: Icon(Icons.person, size: 12)),
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
