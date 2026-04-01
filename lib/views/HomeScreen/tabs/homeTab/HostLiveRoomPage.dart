
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class HostLiveRoomPage extends StatefulWidget {
  final String appId;
  final String channelName;
  final String? rtcToken;
  final bool initialMute;

  const HostLiveRoomPage({
    super.key,
    required this.appId,
    required this.channelName,
    this.rtcToken,
    required this.initialMute,
  });

  @override
  State<HostLiveRoomPage> createState() => _HostLiveRoomPageState();
}

class _HostLiveRoomPageState extends State<HostLiveRoomPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final RtcEngine _engine;
  bool _joined = false;
  int _fps = 15;
  int? _dataStreamId;
  late final int _myUid;
  Timer? _liveCountTimer;

  // Audio/Video states
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerEnabled = true;

  String _displayName = 'Host';

  final List<_Comment> _comments = [];
  final TextEditingController _commentCtrl = TextEditingController();
  final ScrollController _commentScroll = ScrollController();

  bool _ending = false;

  // 🔴 REAL VIEWER COUNT - Store from stats callback
  int _realViewerCount = 0;
  RtcStats? _latestStats; // Store latest stats for debugging

  Duration _streamDuration = Duration.zero;
  Timer? _durationTimer;

  // Animation controllers
  late AnimationController _pulseAnimation;
  late AnimationController _liveBadgeAnimation;

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

    // Set initial mute state from widget
    _isMuted = widget.initialMute;

    // Initialize animations
    _pulseAnimation = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _liveBadgeAnimation = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Start duration timer
    _startDurationTimer();

    _init();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _joined) {
        setState(() {
          _streamDuration = _streamDuration + const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
        _fetchLiveCount();
        _startLiveCountPolling();

        // Apply initial mute state if needed
        if (_isMuted) {
          await _engine.muteLocalAudioStream(true);
        }

        // Try to fetch profile name
        (() async {
          try {
            final api = FastApiServices();
            final fetched = await api.getAstrologerById();
            final name = (fetched?['name'] ?? fetched?['displayName'] ?? 'Host')
                .toString();
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

      // 🔴 NEW: Get stats every 2 seconds with real user count


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
  // AUDIO/VIDEO CONTROLS
  // ---------------------------------------------------------------------------
  Future<void> _fetchLiveCount() async {
    try {
      final sp = await SharedPreferences.getInstance();

      final astroId = sp.getString("astro_id");

      if (astroId == null || astroId.isEmpty) {
        print("❌ astro_id not found in SharedPreferences");
        return;
      }

      print("🚀 astro_id: $astroId");

      final api = FastApiServices();
      final count = await api.getLiveViewerCount(astroId);

      print("👁 Live Count: $count");

      if (mounted) {
        setState(() {
          _realViewerCount = count;
        });
      }

    } catch (e) {
      print("❌ Live count error: $e");
    }
  }

  void _startLiveCountPolling() {
    _liveCountTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      print("⏱ Polling live count...");
      _fetchLiveCount();
    });
  }


  Future<void> _toggleMute() async {
    _isMuted = !_isMuted;
    await _engine.muteLocalAudioStream(_isMuted);
    setState(() {});

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMuted ? 'Microphone muted' : 'Microphone unmuted'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isMuted ? Colors.orange : Colors.green,
      ),
    );
  }

  Future<void> _toggleVideo() async {
    _isVideoEnabled = !_isVideoEnabled;
    await _engine.muteLocalVideoStream(!_isVideoEnabled);
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _isSpeakerEnabled = !_isSpeakerEnabled;
    await _engine.setEnableSpeakerphone(_isSpeakerEnabled);
    setState(() {});
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
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

    // Stop timers
    _durationTimer?.cancel();

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
    _durationTimer?.cancel();
    _pulseAnimation.dispose();
    _liveBadgeAnimation.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _commentCtrl.dispose();
    _commentScroll.dispose();
    _engine.leaveChannel();
    _engine.release();
    _liveCountTimer?.cancel(); // 🔥 important

    super.dispose();
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
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // VIDEO VIEW
            Positioned.fill(
              child: _joined
                  ? (_isVideoEnabled
                  ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
                  : Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Camera is off',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
                  : const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              ),
            ),

            // 🔴 REAL VIEWER COUNT - Now gets real data from rtcStats callback

            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.remove_red_eye,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      '$_realViewerCount watching',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // Duration overlay
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(_streamDuration),
                      style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // COMMENTS + INPUT + CONTROLS
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
                        border: Border.all(color: Colors.white24),
                      ),
                      child: ListView.builder(
                        controller: _commentScroll,
                        itemCount: _comments.length,
                        itemBuilder: (_, i) => _CommentTile(c: _comments[i]),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // CONTROL BUTTONS
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: _isMuted ? Icons.mic_off : Icons.mic,
                            label: _isMuted ? 'Unmute' : 'Mute',
                            color: _isMuted ? Colors.orange : Colors.white,
                            onTap: _toggleMute,
                          ),
                          _buildControlButton(
                            icon: _isVideoEnabled
                                ? Icons.videocam
                                : Icons.videocam_off,
                            label:
                            _isVideoEnabled ? 'Stop Video' : 'Start Video',
                            color: _isVideoEnabled ? Colors.green : Colors.red,
                            onTap: _toggleVideo,
                          ),
                          _buildControlButton(
                            icon: Icons.cameraswitch,
                            label: 'Flip',
                            color: Colors.blue,
                            onTap: _switchCamera,
                          ),
                          _buildControlButton(
                            icon: _isSpeakerEnabled
                                ? Icons.volume_up
                                : Icons.volume_off,
                            label: _isSpeakerEnabled ? 'Speaker' : 'Mute',
                            color: _isSpeakerEnabled
                                ? Colors.purple
                                : Colors.orange,
                            onTap: _toggleSpeaker,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // INPUT FIELD
                    // INPUT FIELD - Replace your existing TextField with this
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Change to white background
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.purple.shade200),
                            ),
                            child: TextField(
                              controller: _commentCtrl,
                              style: const TextStyle(
                                  color:
                                  Colors.black87), // Black text for typing
                              decoration: InputDecoration(
                                hintText: 'Say something…',
                                hintStyle:
                                TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (_) => _onSendPressed(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.purple, Colors.purpleAccent],
                            ),
                          ),
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

            // Live badge (animated)
            if (_joined)
              Positioned(
                top: 70,
                left: 16,
                child: FadeTransition(
                  opacity: _liveBadgeAnimation,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _endLive,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _joined ? _displayName : 'Connecting…',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_joined)
            Text(
              widget.channelName.length > 20
                  ? '${widget.channelName.substring(0, 20)}...'
                  : widget.channelName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _ending
              ? const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
              : Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.stop_circle_outlined,
                  color: Colors.redAccent, size: 28),
              tooltip: 'End Live',
              onPressed: _endLive,
            ),
          ),
        ),
      ],
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
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.purple.shade300,
            child: Text(
              c.user.isNotEmpty ? c.user[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.user,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.text,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
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