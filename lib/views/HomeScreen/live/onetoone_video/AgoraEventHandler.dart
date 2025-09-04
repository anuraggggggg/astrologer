// agora_event_handler.dart

// ignore_for_file: file_names

import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class AgoraEventHandler {
  late Function(bool isImHost, int? localUid) onJoinChannelSuccessCallback;
  late Function(int remoteUid, bool? isJoined) onUserJoinedCallback;
  late Function(int remoteId3, bool? muted) onUserMutedCallback;
  late Function(int remoteUId, UserOfflineReasonType? reason)
      onUserOfflineCallback;

  late Function(RtcConnection con, RtcStats sc) onLeaveChannelCallback;
  late Function(String err, String msg) onAgoraError;

  AgoraEventHandler(
      {required this.onJoinChannelSuccessCallback,
      required this.onUserJoinedCallback,
      required this.onUserMutedCallback,
      required this.onUserOfflineCallback,
      required this.onLeaveChannelCallback,
      required this.onAgoraError});

  void handleEvent(
    RtcEngine agoraEngine,
  ) {
    agoraEngine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        log('onJoinChannelSuccess called');

        onJoinChannelSuccessCallback(true, connection.localUid);
      },
      onUserJoined: (RtcConnection connection, int remoteUid2, int elapsed) {
        log('onUserJoined called');

        onUserJoinedCallback(remoteUid2, true);
      },
      onUserMuteVideo: (RtcConnection conn, int remoteId3, bool muted) {
        log('onUserMuteVideo called');

        onUserMutedCallback(remoteId3, muted);
      },
      onUserOffline: (RtcConnection connection, int remoteUId,
          UserOfflineReasonType reason) {
        log('on User Offline called $reason');

        onUserOfflineCallback(remoteUId, reason);
      },
      onLeaveChannel: (RtcConnection con, RtcStats sc) {
        debugPrint("onLeaveChannel called${con.localUid}");
        onLeaveChannelCallback(con, sc);
      },
      onError: (err, msg) {
        log('error agora - $err  and msg is - $msg');
        onAgoraError(err.toString(), msg.toString());
      },
    ));
  }
}
