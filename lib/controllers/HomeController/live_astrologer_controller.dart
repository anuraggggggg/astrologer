// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/live_users_model.dart';
import '../../models/user_model.dart';
import '../../models/wait_list_model.dart';
import '../../services/apiHelper.dart';
import '../../utils/global.dart';


class LiveAstrologerController extends GetxController {
  APIHelper apiHelper = APIHelper();
  bool isUserJoinAsChat = false;
  List<WaitList> waitList = [];

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;
  String? liveChatUserName;
  bool isOpenPersonalChatDialog = false;
  String? chatId;
  bool isChatDetailLoaded = false;
  bool isImInLive = false;
  String joinedUserProfile = "";
  String joinedUserName = "User";
  bool isUserJoinWaitList = false;
  late String chatuid;
  late String channelName;



  Stream<QuerySnapshot<Map<String, dynamic>>>? getChatMessages(
      String idUser, int globalId) {
    try {
      return FirebaseFirestore.instance
          .collection('chats2/$idUser/userschat')
          .doc(globalId.toString())
          .collection('messages')
          .orderBy("updatedAt", descending: true)
          .snapshots();
    } catch (err) {
      print("Exception - getChatMessages(): $err");
      return null;
    }
  }

  sendLiveToken(
      int id,
      String channelName,
      String token,
      String chatToken,
      ) async {
    try {
      if (await global.checkBody()) {
        final result = await apiHelper.sendLiveAstrologerToken(
          id,
          channelName,
          token,
          chatToken,
        );
        if (result.status == "200") {
          print('Live token sent: $token');
        } else {
          global.showToast(message: "Accept request failed");
        }
      }
      update();
    } catch (e) {
      print('Exception in sendLiveToken: $e');
    }
  }

  Future<dynamic> getWaitList(String channel) async {
    try {
      if (await global.checkBody()) {
        global.showOnlyLoaderDialog();
        final result = await apiHelper.getWaitList(channel);
        global.hideLoader();
        if (result.status == "200") {
          waitList = result.recordList;
          for (var i = 0; i < waitList.length; i++) {
            if (waitList[i].time != "") {
              waitList[i].endTime = DateTime.now().millisecondsSinceEpoch +
                  1000 * int.parse(waitList[i].time);
            }
          }
        } else {
          global.showToast(message: result.message);
        }
        update();
      }
    } catch (e) {
      print("Exception in getWaitList: $e");
    }
  }

  sendLiveChatToken(int id, String channelName, String token) async {
    try {
      if (await global.checkBody()) {
        final result = await apiHelper.sendLiveAstrologerChatToken(
          id,
          channelName,
          token,
        );
        if (result.status == "200") {
          print('Live chat token sent: $token');
        } else {
          global.showToast(message: "Accept chat request failed");
        }
      }
      update();
    } catch (e) {
      print('Exception in sendLiveChatToken: $e');
    }
  }

  endLiveSession(bool isFromDispose) async {
    try {
      if (await global.checkBody()) {
        global.sp = await SharedPreferences.getInstance();
        final userData = CurrentUser.fromJson(
          json.decode(global.sp!.getString("currentUser") ?? ""),
        );
        final result = await apiHelper.endLiveSession(userData.id ?? 0);
        if (result.status == "200") {
          if (!isFromDispose) {
            global.showToast(message: 'Live session ended!');
          }
        } else {
          global.showToast(
            message: "Problem fetching data from server.",
          );
        }
      }
      update();
    } catch (e) {
      print('Exception in endLiveSession: $e');
    }
  }

  var liveUsers = <LiveUserModel>[];
  Future<dynamic> getLiveuserData(String channel) async {
    try {
      if (await global.checkBody()) {
        final result = await apiHelper.getLiveUsers(channel);
        if (result.status == "200") {
          liveUsers = result.recordList;
          print('Live users found: ${liveUsers.length}');
        } else {
          global.showToast(
            message: '${result.status} failed to get live users',
          );
        }
        update();
      }
    } catch (e) {
      print("Exception in getLiveuserData: $e");
    }
  }

  Future<void> onlineOfflineUser() async {
    for (int i = 0; i < waitList.length; i++) {
      for (int j = 0; j < liveUsers.length; j++) {
        if (waitList[i].userId == liveUsers[j].userId) {
          waitList[i].isOnline = true;
        }
      }
    }
    update();
  }

  Future<dynamic> getRtmToken(
      String appId,
      String appCertificate,
      String chatId,
      String channelName,
      ) async {
    try {
      if (await global.checkBody()) {
        final result = await apiHelper.generateRtmToken(
          appId,
          appCertificate,
          chatId,
          channelName,
        );
        if (result.status == "200") {
          global.agoraChatToken = result.recordList['rtmToken'];
          print("RTM token received: ${global.agoraChatToken}");
        } else {
          global.showToast(
            message: '${result.status} failed to get RTM token',
          );
        }
      }
    } catch (e) {
      print("Exception in getRtmToken: $e");
    }
  }

  Future<void> generateChatToken() async {
    await liveAstrologerController.getRtmToken(
      global.agoraAppId,
      global.agoraAppCertificate,
      chatuid,
      channelName,
    );


  }



  Future<dynamic> getRitcToken(
      String appId,
      String appCertificate,
      String chatId,
      String channelName,
      ) async {
    try {
      if (await global.checkBody()) {
        final result = await apiHelper.generateRtcToken(
          appId,
          appCertificate,
          chatId,
          channelName,
        );
        if (result.status == "200") {
          global.agoraLiveToken = result.recordList['rtcToken'];
          print("RTC token received: ${global.agoraLiveToken}");
        } else {
          global.showToast(
            message: '${result.status} failed to get RTC token',
          );
        }
      }
    } catch (e) {
      print("Exception in getRitcToken: $e");
    }
  }
}
