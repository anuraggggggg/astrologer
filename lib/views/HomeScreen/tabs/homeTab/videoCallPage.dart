// lib/call/video_call_page.dart
import 'dart:async';
import 'package:astrowaypartner/fastApi/agora_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

/// Use `isAstrologer=true` in the astrologer app; false in the customer app.
class VideoCallPage extends StatefulWidget {
  final String astroId; // the astrologer id
  final bool
      isAstrologer; // true => use astro_token & astro_id; false => current_user_token & current_user_id

  const VideoCallPage({
    super.key,
    required this.astroId,
    required this.isAstrologer,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late final RtcEngine _engine;
  bool _engineReady = false;

  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = ''; // <-- IMPORTANT: join with this

  int? _remoteUid;
  bool _joined = false;
  bool _loading = true;

  bool _micOn = true;
  bool _camOn = true;

  Timer? _pulse;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _pulse?.cancel();
    () async {
      try {
        await _engine.leaveChannel();
      } catch (_) {}
      try {
        await _engine.stopPreview();
      } catch (_) {}
      try {
        await _engine.release();
      } catch (_) {}
    }();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      // 1) Permissions
      final statuses =
          await [Permission.camera, Permission.microphone].request();
      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Camera/Microphone permission denied';
      }

      // 2) Fetch tokens + ids
      final auth = await AgoraService.getVideoTokens(widget.astroId);
      _appId = auth.appId;
      _channel = auth.channelName;

      // if (widget.isAstrologer) {
      //   _token = auth.astroToken;
      //   _account =
      //       auth.astroId; // MUST equal the account used when token was minted
      // } else {
      //   _token = auth.currentUserToken;
      //   _account = auth
      //       .currentUserId; // MUST equal the account used when token was minted
      // }

      final tokPreview = _token.length > 12
          ? '${_token.substring(0, 6)}…${_token.substring(_token.length - 6)}'
          : _token;

      debugPrint('🔑 [VC] role=${widget.isAstrologer ? 'ASTRO' : 'CUSTOMER'}');
      debugPrint('🔑 [VC] appId=$_appId');
      debugPrint('🔑 [VC] channel=$_channel');
      debugPrint('🔑 [VC] account=$_account');
      debugPrint('🔑 [VC] token=$tokPreview');

      if (_appId.isEmpty ||
          _channel.isEmpty ||
          _token.isEmpty ||
          _account.isEmpty) {
        throw 'Missing required join fields (appId/channel/token/account). Check API.';
      }

      // 3) Init engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      _engineReady = true;

      await _engine
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine.enableVideo();

      // 4) Events (use v6 signatures)
      _engine.registerEventHandler(RtcEngineEventHandler(
        onConnectionStateChanged: (RtcConnection conn,
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint(
              '🔎 [VC] onConnectionStateChanged state=$state reason=$reason ch=${conn.channelId}');
        },
        onJoinChannelSuccess: (RtcConnection conn, int elapsed) {
          debugPrint(
              '🎉 [VC] onJoinChannelSuccess ch=${conn.channelId} elapsed=${elapsed}ms');
          setState(() => _joined = true);
        },
        onUserJoined: (RtcConnection conn, int remoteUid, int elapsed) {
          debugPrint(
              '👋 [VC] onUserJoined uid=$remoteUid elapsed=${elapsed}ms');
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline:
            (RtcConnection conn, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('👋 [VC] onUserOffline uid=$remoteUid reason=$reason');
          setState(() => _remoteUid = null);
        },
        onLeaveChannel: (RtcConnection conn, RtcStats stats) {
          debugPrint('👋 [VC] onLeaveChannel duration=${stats.duration}');
          setState(() {
            _joined = false;
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection conn, String token) async {
          debugPrint(
              '⏰ [VC] Token expiring soon; consider refreshing from server and calling renewToken().');
        },
        onError: (ErrorCodeType code, String msg) {
          debugPrint('❗ [VC] Agora error: $code $msg');
          if (code == ErrorCodeType.errInvalidToken) {
            debugPrint('🚨 [VC] INVALID TOKEN. Ensure:');
            debugPrint('   • Using joinChannelWithUserAccount');
            debugPrint('   • userAccount="${_account}" matches token’s user');
            debugPrint('   • Same channelName on both sides: "$_channel"');
            debugPrint('   • Device time is correct (tokens expire in ~900s)');
          }
        },
      ));

      await _engine.startPreview();
      debugPrint('🎥 [VC] Local preview started');

      // 5) JOIN **BY ACCOUNT**
      debugPrint(
          '➡️ [VC] joinChannelWithUserAccount(channel=$_channel, account=$_account, token=$tokPreview)');
      await _engine.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      _pulse = Timer.periodic(const Duration(seconds: 10), (_) {
        debugPrint('💓 [VC] pulse joined=$_joined remoteUid=$_remoteUid');
      });
    } catch (e) {
      debugPrint('💥 [VC] init failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video init failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    debugPrint('↩️ [VC] Leaving channel…');
    try {
      if (_engineReady) {
        await _engine.leaveChannel();
        await _engine.stopPreview();
      }
    } catch (e) {
      debugPrint('⚠️ [VC] leave error: $e');
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleMic() async {
    _micOn = !_micOn;
    await _engine.muteLocalAudioStream(!_micOn);
    debugPrint('🎙 [VC] micOn=$_micOn');
    setState(() {});
  }

  Future<void> _toggleCam() async {
    _camOn = !_camOn;
    await _engine.muteLocalVideoStream(!_camOn);
    debugPrint('📷 [VC] camOn=$_camOn');
    setState(() {});
  }

  Future<void> _switchCam() async {
    await _engine.switchCamera();
    debugPrint('🔁 [VC] switchCamera()');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Video Call (${widget.isAstrologer ? 'Astrologer' : 'Customer'})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Remote (full screen)
                Positioned.fill(
                  child: _remoteUid == null
                      ? Center(
                          child: Text(
                            _joined
                                ? (widget.isAstrologer
                                    ? 'Waiting for customer…'
                                    : 'Waiting for astrologer…')
                                : 'Joining…',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      : AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: _engine,
                            canvas: VideoCanvas(uid: _remoteUid),
                            connection: RtcConnection(channelId: _channel),
                          ),
                        ),
                ),

                // Local PiP
                Positioned(
                  right: 12,
                  top: 12,
                  width: 120,
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black54,
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                    ),
                  ),
                ),

                // Controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _roundBtn(
                        icon: _micOn ? Icons.mic : Icons.mic_off,
                        color: _micOn ? Colors.white : Colors.redAccent,
                        onTap: _toggleMic,
                      ),
                      const SizedBox(width: 16),
                      _roundBtn(
                        icon: _camOn ? Icons.videocam : Icons.videocam_off,
                        color: _camOn ? Colors.white : Colors.redAccent,
                        onTap: _toggleCam,
                      ),
                      const SizedBox(width: 16),
                      _roundBtn(
                        icon: Icons.cameraswitch,
                        onTap: _switchCam,
                      ),
                      const SizedBox(width: 16),
                      _roundBtn(
                        icon: Icons.call_end,
                        color: Colors.white,
                        bg: Colors.redAccent,
                        onTap: _leave,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _roundBtn({
    required IconData icon,
    Color color = Colors.white,
    Color bg = const Color(0x44000000),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
    );
  }
}
