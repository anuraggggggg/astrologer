// ignore_for_file: file_names

import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/global.dart';

class AgoraManager {
  static final AgoraManager _instance = AgoraManager._internal();
  factory AgoraManager() {
    return _instance;
  }

  AgoraManager._internal();

  Future<RtcEngine> initializeAgora(String appID) async {
    await [Permission.microphone, Permission.camera].request();
    //create an instance of the Agora engine
    RtcEngine agoraEngine = createAgoraRtcEngine();
    try {
      await agoraEngine.initialize(RtcEngineContext(appId: appID));
      log('init agora appID- $appID ');
    } catch (e) {
      log(e.toString());
    }
    return agoraEngine;
  }

  void joinChannel(
      String token, String channelName, RtcEngine agoraEngine) async {
    log('join-channel');
    ChannelMediaOptions options;
    // Set channel profile and client role ONE TO ONE VIDEO CALL
    options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine.startPreview();
    await agoraEngine.enableVideo();

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: 2,
      //UNIQUE for second user can be 1 or 0  canvas canvas: const VideoCanvas(0)
      //Put it same for both like 0 for both but dont use  0 then in hostscreen
    );
  }

  void leave(RtcEngine agoraEngine,
      {required void Function(bool isLiveEnded) onchannelLeaveCallback}) async {
    try {
      await agoraEngine.leaveChannel();
      await agoraEngine.release();
      //clear data for fututre
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_accepted', false);
      await prefs.setString('is_accepted_data', '');

      FutureBuilder(
        future: liveAstrologerController.endLiveSession(false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            debugPrint('Leaving error ${snapshot.error}');
            return const SizedBox();
          } else {
            return const SizedBox();
          }
        },
      );

      liveAstrologerController.isImInLive = false;
      liveAstrologerController.update();
      onchannelLeaveCallback(true);
    } on Exception catch (e) {
      log('Exception leaving channel-> $e.toString()');
      onchannelLeaveCallback(false);
    }
  }

  void muteVideoCall(
    bool flag,
    RtcEngine agoraEngine,
  ) async {
    try {
      agoraEngine.muteLocalAudioStream(flag);
    } catch (e) {
      log(e.toString());
    }
  }

  void onVolume(
    bool isSpeaker,
    RtcEngine agoraEngine,
  ) async {
    try {
      await agoraEngine.setEnableSpeakerphone(isSpeaker);
    } catch (e) {
      log(e.toString());
    }
  }
}
