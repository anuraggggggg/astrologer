// lib/views/HomeScreen/tabs/homeTab/HostLiveRoomPage.dart
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class HostLiveRoomPage extends StatefulWidget {
  final String appId;
  final String channelName;
  final String? rtcToken; // nullable

  const HostLiveRoomPage({
    super.key,
    required this.appId,
    required this.channelName,
    this.rtcToken, // can be null when App Certificate is disabled
  });

  @override
  State<HostLiveRoomPage> createState() => _HostLiveRoomPageState();
}

class _HostLiveRoomPageState extends State<HostLiveRoomPage> {
  late final RtcEngine _engine;
  bool _joined = false;

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

    // For audio-only live; for video, also call enableVideo() and set up preview
    await _engine.enableAudio();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _joined = true);
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Agora error: $err $msg');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Agora error $err: $msg')),
            );
          }
        },
        onConnectionStateChanged: (
          RtcConnection connection,
          ConnectionStateType state,
          ConnectionChangedReasonType reason,
        ) {
          debugPrint(
              'Agora connection=${connection.channelId} state=$state reason=$reason');
        },
      ),
    );

    // IMPORTANT: pass an empty string if you don't have a token
    final tokenOrEmpty =
        (widget.rtcToken != null && widget.rtcToken!.isNotEmpty)
            ? widget.rtcToken!
            : '';

    await _engine.joinChannel(
      token: tokenOrEmpty,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        // For audio-only publishing; enable these if needed:
        // publishMicrophoneTrack: true,
        // publishCameraTrack: false,
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_joined ? 'Live: ${widget.channelName}' : 'Connecting…'),
      ),
      body: Center(
        child: _joined
            ? const Text('Broadcasting… (audio live)')
            : const CircularProgressIndicator(),
      ),
    );
  }
}
