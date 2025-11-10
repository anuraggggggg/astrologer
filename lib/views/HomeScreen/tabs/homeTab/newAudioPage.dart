// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:astrowaypartner/fastApi/agora_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// ⬇️ We reuse your VIDEO token service for audio-only joining

class AudioCallPage extends StatefulWidget {
  /// Pass the ASTROLOGER ID here (this is the id your /agora/token/video expects)
  final String astroId;

  const AudioCallPage({super.key, required this.astroId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  RtcEngine? _engine;

  // From token API (via AgoraService)
  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = ''; // userAccount for joinChannelWithUserAccount

  bool _loading = true;
  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = true;

  void _d(Object m) => debugPrint('🎧 [AstroVC] $m');

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    () async {
      try {
        await _engine?.leaveChannel();
      } catch (_) {}
      try {
        await _engine?.release();
      } catch (_) {}
      _engine = null;
    }();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final incoming = widget.astroId.trim();
      _d('Bootstrapping with astroId="$incoming"');
      if (incoming.isEmpty || incoming.toLowerCase() == 'null') {
        throw 'Invalid astrologer id';
      }

      // 1) Mic permission only (audio call)
      final statuses = await [Permission.microphone].request();
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Microphone permission denied';
      }

      // 2) Fetch tokens using VIDEO API and pick ASTRO credentials
      _d('Fetching video tokens for astroId=$incoming …');
      final auth = await AgoraService.getVideoTokens(incoming);
      final join = AgoraService.buildJoinParams(auth: auth, isAstrologer: true);

      _appId = join.appId;
      _channel = join.channel;
      _token = join.token;
      _account = join.account;

      if (_appId.isEmpty ||
          _channel.isEmpty ||
          _token.isEmpty ||
          _account.isEmpty) {
        throw 'Missing required join fields (appId/channel/token/account).';
      }
      _d('Auth OK → appId=$_appId | channel=$_channel | account=$_account');

      // 3) Init engine (audio-only)
      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(appId: _appId));
      _engine = engine;

      await engine
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await engine.enableAudio();
      await engine.disableVideo(); // ensure audio-only
      _d('ChannelProfile=Communication, audio ✅, video ❌');

      // Hint route to speaker BEFORE join
      try {
        await engine.setDefaultAudioRouteToSpeakerphone(true);
        _d('Default audio route → speaker (pre-join)');
      } catch (e) {
        _d('setDefaultAudioRouteToSpeakerphone error: $e');
      }

      // 4) Events
      engine.registerEventHandler(
        RtcEngineEventHandler(
          onError: (ErrorCodeType code, String msg) {
            _d('ERROR $code $msg');
          },
          onConnectionStateChanged: (RtcConnection c, ConnectionStateType s,
              ConnectionChangedReasonType r) {
            _d('ConnState=$s reason=$r');
          },
          onJoinChannelSuccess: (RtcConnection conn, int elapsed) async {
            _d('Joined ${conn.channelId} in ${elapsed}ms');
            if (!mounted) return;
            setState(() => _joined = true);

            // Flip speaker AFTER join to avoid -3
            try {
              await Future.delayed(const Duration(milliseconds: 150));
              await engine.setEnableSpeakerphone(true);
              _speakerOn = true;
              _d('Speakerphone ON ✅');
            } catch (e) {
              _d('setEnableSpeakerphone post-join error: $e');
            }
          },
          onUserJoined: (RtcConnection c, int uid, int elapsed) {
            _d('Remote JOINED uid=$uid (elapsed=${elapsed}ms)');
          },
          onUserOffline:
              (RtcConnection c, int uid, UserOfflineReasonType reason) {
            _d('Remote OFFLINE uid=$uid reason=$reason');
          },
          onLeaveChannel: (RtcConnection c, RtcStats stats) {
            _d('Left channel. stats=${stats.toJson()}');
            if (mounted) setState(() => _joined = false);
          },
          onTokenPrivilegeWillExpire: (RtcConnection c, String oldToken) {
            _d('Token will expire soon → (optional) refresh + renew');
            // If needed:
            // final fresh = await AgoraService.getVideoTokens(widget.astroId);
            // final freshJoin = AgoraService.buildJoinParams(auth: fresh, isAstrologer: true);
            // await _engine?.renewToken(freshJoin.token);
          },
          onAudioVolumeIndication: (
            RtcConnection c,
            List<AudioVolumeInfo> speakers,
            int speakerNumber,
            int totalVolume,
          ) {
            for (final s in speakers) {
              _d('VOLUME uid=${s.uid} vol=${s.volume} vad=${s.vad}');
            }
          },
        ),
      );

      // 5) Join via userAccount (MUST match token’s subject)
      await engine.registerLocalUserAccount(
          appId: _appId, userAccount: _account);
      _d('registerLocalUserAccount($_account) → OK');

      final tokPreview = _token.length > 12
          ? '${_token.substring(0, 6)}…${_token.substring(_token.length - 6)}'
          : _token;
      _d('Joining "$_channel" with account="$_account", token=$tokPreview');

      await engine.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
        ),
      );
      _d('joinChannelWithUserAccount() sent');
    } catch (e) {
      _d('INIT FAILED: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio init failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    _d('Leaving…');
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleMute() async {
    _muted = !_muted;
    try {
      await _engine?.muteLocalAudioStream(_muted);
      _d('muteLocalAudioStream($_muted)');
    } catch (e) {
      _d('muteLocalAudioStream error: $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _setSpeaker(bool on) async {
    _speakerOn = on;
    try {
      await _engine?.setEnableSpeakerphone(_speakerOn);
      _d('Speaker ${_speakerOn ? 'ON' : 'OFF'}');
    } catch (e) {
      _d('setEnableSpeakerphone error: $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleSpeaker() => _setSpeaker(!_speakerOn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Call (Astrologer)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_in_talk, size: 80),
                const SizedBox(height: 12),
                Text(_joined ? 'Connected • $_channel' : 'Connecting…'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_muted ? Icons.mic_off : Icons.mic),
                      onPressed: _toggleMute,
                      tooltip: _muted ? 'Unmute' : 'Mute',
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: Icon(_speakerOn ? Icons.volume_up : Icons.hearing),
                      onPressed: _toggleSpeaker,
                      tooltip: _speakerOn ? 'Speaker off' : 'Speaker on',
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.red),
                      onPressed: _leave,
                      tooltip: 'Hang up',
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
