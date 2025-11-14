  // ============================================
  // lib/views/HomeScreen/tabs/homeTab/HostLiveRoomPage.dart
  // Host goes LIVE (video) + comments overlay + End Live API call
  // NOTE: This version NEVER sends an RTC token (token: '').
  //       This will only work if your Agora project has App Certificate DISABLED.
  // ============================================
  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:agora_rtc_engine/agora_rtc_engine.dart';
  import 'package:astrowaypartner/fastApi/fastApiServices.dart'; // must expose endAgoraLive()

  class HostLiveRoomPage extends StatefulWidget {
    final String appId;
    final String channelName;
    final String? rtcToken; // kept for compatibility; NOT USED

    const HostLiveRoomPage({
      super.key,
      required this.appId,
      required this.channelName,
      this.rtcToken, // ignored
    });

    @override
    State<HostLiveRoomPage> createState() => _HostLiveRoomPageState();
  }

  class _HostLiveRoomPageState extends State<HostLiveRoomPage> {
    late final RtcEngine _engine;
    bool _joined = false;
    int _fps = 15;

    // Local-only MVP comments (replace with Firebase/RTM later for real sync)
    final List<_Comment> _comments = [];
    final TextEditingController _commentCtrl = TextEditingController();
    final ScrollController _commentScroll = ScrollController();

    // End live state
    bool _ending = false;

    @override
    void initState() {
      super.initState();
      _init();
    }

    Future<void> _init() async {
      _engine = createAgoraRtcEngine();

      await _engine.initialize(
        RtcEngineContext(appId: widget.appId),
      );

      await _engine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting,
      );

      await _engine.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );

      await _engine.enableVideo();
      await _engine.startPreview();

      await _engine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 720, height: 1280),
          frameRate: 15,
          bitrate: 1130,
          orientationMode: OrientationMode.orientationModeFixedPortrait,
        ),
      );

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            setState(() => _joined = true);
          },
          onError: (ErrorCodeType err, String msg) {
            if (!mounted) return;
            final text = err == ErrorCodeType.errInvalidToken
                ? 'Invalid/expired RTC token. This build always uses an EMPTY token. Make sure your Agora project has App Certificate DISABLED.'
                : 'Agora error $err: $msg';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(text)),
            );
          },
          onConnectionStateChanged: (
              RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason,
              ) {
            debugPrint(
                'agora: channel=${connection.channelId} state=$state reason=$reason');
          },
        ),
      );

      // If rtcToken is null, pass empty string (this matches your intention).
      final String tokenToUse = widget.rtcToken ?? '';

      debugPrint('Joining channel=${widget.channelName} tokenPresent=${widget.rtcToken != null}');

      await _engine.joinChannel(
        token: tokenToUse,
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: false,
          autoSubscribeVideo: false,
        ),
      );
    }


    Future<void> _endLive() async {
      if (_ending) return;
      setState(() => _ending = true);
      try {
        // hit your FastAPI endpoint
        final res = await FastApiServices().endAgoraLive();
        final msg = (res['message'] ?? 'Live ended').toString();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('End live failed: $e')),
          );
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

      // 🟣 Automatically end the live session when host leaves the page
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

    void _addComment(String text) {
      if (text.trim().isEmpty) return;
      setState(() {
        _comments.add(_Comment('Host', text.trim(), DateTime.now()));
      });
      _commentCtrl.clear();
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
                  Icons.stop_circle_outlined, // 🎯 change icon shape
                  color: Colors.redAccent, // 🔴 make icon red
                  size: 30, // a bit larger for better visibility
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
                            onSubmitted: _addComment,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () => _addComment(_commentCtrl.text),
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
