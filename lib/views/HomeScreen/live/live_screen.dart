// ignore_for_file: deprecated_member_use, unnecessary_null_comparison, non_constant_identifier_names, avoid_init_to_null

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:astrowaypartner/controllers/HomeController/chat_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/live_astrologer_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/main.dart';
import 'package:astrowaypartner/services/apiHelper.dart';
import 'package:astrowaypartner/views/HomeScreen/home_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../constants/messageConst.dart';
import '../../../controllers/HomeController/home_controller.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../utils/config.dart';
import '../../../utils/global.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  late RtcEngine agoraEngine;
  final homeController = Get.find<HomeController>();
  final apiHelper = APIHelper();
  final liveAstrologerController = Get.find<LiveAstrologerController>();
  final messageController = TextEditingController();
  final chatcontroller = Get.find<ChatController>();
  String? reqType, username;
  String chatuid = "";
  String peerUserId = "";
  int uid = 0; // current user id
  int? remoteUid;
  late RtmClient client;
  int? newUserindex = 0;
  int? currentUserId;
  Map<String, dynamic> map = {};
  bool isSetConn = false;
  String userName = "";
  String currenUserName = "";
  bool isAlreadyTaking = false;
  String channel_name = '';
  final walletController = Get.find<WalletController>();
  ValueNotifier<String> currentUserProfile = ValueNotifier<String>('');
  ValueNotifier<bool> isJoined = ValueNotifier<bool>(false);
  ValueNotifier<int> conneId = ValueNotifier<int>(0);
  ValueNotifier<bool> isImHost = ValueNotifier<bool>(false);
  ValueNotifier<int> myviewerCount = ValueNotifier<int>(1);
  ValueNotifier<List<MessageModel>> reverseMessage = ValueNotifier([]);
  final List<MessageModel> messageList = [];

  Widget buildText(String text) =>
      Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, color: Colors.black),
        ),
      );

  //GET CHAT MSG USING FIREBASE HERE
  personalChatDialog({String? userName}) {
    BuildContext context = Get.context!;
    showDialog(
      context: context,
      // barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                height: 300,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        userName != null
                            ? tr("Live chat with $userName")
                            : tr("Live chat with User"),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ).tr(),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -5,
                right: -5,
                child: GestureDetector(
                  onTap: () {
                    if (liveAstrologerController.isOpenPersonalChatDialog) {
                      liveAstrologerController.isOpenPersonalChatDialog = false;
                    }
                    Get.back();
                  },
                  child: const Icon(Icons.close),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.only(
            bottom: 15,
            left: 15,
            right: 15,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    final userId = global.user.id ?? 0;

    chatuid = "AgoraLiveUser_$userId";
    channelName = "liveAstrologer_$userId";

    initRTM();
    onInit();
  }

  onInit() async {
    await setupVideoSDKEngine();
    await createClient();
    getWaitList();
  }

  getOnlineUserList() async {
    try {
      var (status, response) = await client.getPresence().getOnlineUsers(
        channel_name,
        RtmChannelType.message,
        includeUserId: true,
        includeState: true,
      );

      // ignore: unrelated_type_equality_checks
      if (status.error == true) {
        log('${status.operation} failed, errorCode: ${status
            .errorCode}, due to ${status.reason}');
      } else {
        // var nextPage = response!.nextPage;
        var count = response!.count;
        myviewerCount.value = count;
        log('There are $count occupants in $channel_name channel');
      }
    } catch (e) {
      log('something went wrong: $e');
    }
  }

  Future<void> getWaitList() async {
    if (global.agoraLiveChannelName != "") {
      await liveAstrologerController.getWaitList(global.agoraLiveChannelName);
    }
  }

  // Function to Send a Message with Debug Logs
  sendMessage(String messageText) async {
    try {
      // Construct local message object
      final newUserMessage = MessageModel(
        message: messageText,
        userName: currenUserName,
        profile: '', // removed to avoid redirect error
        isMe: true,
        gift: null,
        createdAt: DateTime.now(),
      );

      // Message data to be sent
      final messageData = {
        'userName': currenUserName,
        'message': messageText,
        'profile': '', // removed profile URL
        'isMe': false,
        'gift': '',
      };

      final jsonMessage = jsonEncode(messageData);

      log('🟡 Sending message...');
      log('🔹 userName: $currenUserName');
      log('🔹 message: $messageText');
      log('🔹 Final JSON: $jsonMessage');

      var (status, response) = await client.publish(
        channel_name,
        jsonMessage,
        channelType: RtmChannelType.message,
        customType: 'PlainText',
      );

      if (status.error == true) {
        log('❌ Message publish failed');
        log('🔻 Operation: ${status.operation}');
        log('🔻 Error Code: ${status.errorCode}');
      } else {
        log('✅ Message published successfully');
        messageList.add(newUserMessage);
        reverseMessage.value = messageList.reversed.toList();
      }
    } catch (e, stackTrace) {
      log('🚨 Exception while sending message: $e');
      log('🧾 Stack Trace: $stackTrace');
    }
  }






  Future<void> createClient() async {
    try {
      // Step 1 : GENERATE CHAT TOKEN
      await generateChatToken();
      log('chat token is ${global.agoraChatToken} and chat uid is $chatuid');

      // Step 2 : CREATE RTM CLIENT
      final (status, mclient) = await RTM(
        global.getSystemFlagValue(global.systemFlagNameList.agoraAppId),
        chatuid,
      );

      if (status.error == true) {
        debugPrint('${status.operation} failed due to ${status.reason}}');
      } else {
        client = mclient;

        debugPrint('Initialize success!');
      }

      // add events listner
      client.addListener(
        message: (event) {
          try {
            log('📥 Message event from ${event.publisher}');
            String messageText = utf8.decode(event.message!);
            log('🔓 Decoded message: $messageText');

            final decoded = jsonDecode(messageText);

            final newUserMessage = MessageModel(
              message: decoded['message'],
              userName: decoded['userName'],
              profile: '', // Removed to avoid invalid image crash
              isMe: false,
              gift: decoded['gift'],
              createdAt: DateTime.now(),
            );

            if (mounted) {
              messageList.add(newUserMessage);
              reverseMessage.value = messageList.reversed.toList();
              log('✅ Message added to list');
              getOnlineUserList();
            }
          } catch (e, st) {
            log('❌ Error in listener: $e');
            log('🧾 StackTrace: $st');
          }
        },
        linkState: (event) {
          log('[Link State] ${event.previousState} → ${event.currentState}');
          log('[Reason] ${event.reason}, [Operation] ${event.operation}');
        },
        presence: (event) {
          log('📡 Presence event: ${event.snapshot?.userStateList?.length ?? 0}');
        },
        token: (event) {
          log('🔐 Token event: ${event.channelName}');
        },
      );


    } catch (e) {
      log('Initialize falid!:$e');
    }

    try {
      var (status, response) = await client.login(global.agoraChatToken);
      if (status.error == true) {
        log('failed due to ${status.reason}, error code: ${status.errorCode}');
      } else {
        log('login RTM success!');
      }
    } catch (e) {
      log('Failed to login: $e');
    }
    try {
      var (status, response) = await client.subscribe(channel_name);
      if (status.error == true) {
        debugPrint(
          '${status.operation} failed due to ${status
              .reason}, error code: ${status.errorCode}',
        );
      } else {
        debugPrint('subscribe channel: $channel_name success!');
      }
    } catch (e) {
      debugPrint('Failed to subscribe channel: $e');
    }
  }

  Future<void> wailtListDialog() {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              Container(
                height: 50.h,
                width: 100.w,
                margin: EdgeInsets.all(3.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 100.w,
                        child: Stack(
                          children: [
                            Center(
                              child: const Text(
                                "Waitlist",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ).tr(),
                            ),
                            Positioned(
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: const Icon(Icons.close),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 3.w),
                        child: Text(
                          "Customers who missed the call & were marked offline will get priority as per the list, if they come online.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.sp,
                          ),
                          textAlign: TextAlign.center,
                        ).tr(),
                      ),
                      SizedBox(
                        height: 25.h,
                        // ignore: prefer_is_empty
                        child: liveAstrologerController.waitList.isNotEmpty
                            ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: liveAstrologerController.waitList.length,
                          itemBuilder: (BuildContext context,
                              int index,) {
                            return Container(
                              padding: EdgeInsets.all(3.w),
                              width: 100.w,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      liveAstrologerController.waitList[index]
                                          .userProfile !=
                                          ""
                                          ? CircleAvatar(
                                        radius: 15,
                                        backgroundColor:
                                        Get.theme.primaryColor,
                                        child:
                                        Image.network(
                                          "$imgBaseurl${liveAstrologerController
                                              .waitList[index].userProfile}",
                                          height: 18,
                                        ),
                                      )
                                          : CircleAvatar(
                                        radius: 15,
                                        backgroundColor:
                                        Get.theme.primaryColor,
                                        child: Image.asset(
                                          "assets/images/no_customer_image.png",
                                          height: 18,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 3.w,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              liveAstrologerController
                                                  .waitList[index].userName,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              liveAstrologerController
                                                  .waitList[index]
                                                  .isOnline
                                                  ? 'Online'
                                                  : 'Offline',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ).tr(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor:
                                        Get.theme.primaryColor,
                                        child: Icon(
                                          liveAstrologerController
                                              .waitList[index]
                                              .requestType ==
                                              "Video"
                                              ? Icons.video_call
                                              : liveAstrologerController
                                              .waitList[index]
                                              .requestType ==
                                              "Audio"
                                              ? Icons.call
                                              : Icons.chat,
                                          color: Colors.black,
                                          size: 13,
                                        ),
                                      ),
                                      liveAstrologerController
                                          .waitList[index].status ==
                                          "Pending"
                                          ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: Text(
                                          "${liveAstrologerController
                                              .waitList[index].time} sec",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                          : CountdownTimer(
                                        endTime:
                                        liveAstrologerController
                                            .endTime,
                                        widgetBuilder: (_,
                                            CurrentRemainingTime? time,) {
                                          if (time == null) {
                                            return Text(
                                              '00:00:00',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight:
                                                FontWeight.w500,
                                              ),
                                            );
                                          }
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              left: 2.w,
                                            ),
                                            child: time.hours != null &&
                                                time.hours != 0
                                                ? Text(
                                              '${time.hours}:${time.min}:${time
                                                  .sec} sec',
                                              style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .w400,
                                                fontSize: 11.sp,
                                              ),
                                            )
                                                : time.min != null
                                                ? Text(
                                              '${time.min} min ${time.sec} sec',
                                              style:
                                              TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .w400,
                                                fontSize:
                                                11.sp,
                                              ),
                                            )
                                                : Text(
                                              '${time.sec} sec',
                                              style:
                                              TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .w400,
                                                fontSize:
                                                11.sp,
                                              ),
                                            ),
                                            // child: time.min != null
                                            //     ? Text(
                                            //         '${time.min} min ${time.sec} sec',
                                            //         style: TextStyle(
                                            //             fontSize:
                                            //                 11.sp,
                                            //             fontWeight:
                                            //                 FontWeight
                                            //                     .w500))
                                            //     : Text(
                                            //         '${time.sec} sec',
                                            //         style: TextStyle(
                                            //             fontSize:
                                            //                 11.sp,
                                            //             fontWeight:
                                            //                 FontWeight
                                            //                     .w500),
                                            //       ),
                                          );
                                        },
                                        onEnd: () {
                                          //call the disconnect method from requested customer
                                        },
                                      ),
                                      liveAstrologerController
                                          .waitList[index].isOnline
                                          ? Container(
                                        margin: EdgeInsets.only(
                                          left: 3.w,
                                        ),
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color:
                                          liveAstrologerController
                                              .waitList[index]
                                              .isOnline
                                              ? Get.theme
                                              .primaryColor
                                              : Colors.grey,
                                        ),
                                        child: ElevatedButton(
                                          //! WAITING LIST
                                          onPressed: () async {
                                            Future.delayed(
                                              const Duration(
                                                milliseconds: 500,
                                              ),
                                            ).then((value) async {
                                              await localNotifications
                                                  .cancelAll();
                                            });
                                            log(
                                              'alreay running $isAlreadyTaking',
                                            );

                                            if (isAlreadyTaking ==
                                                true) {
                                              global.showToast(
                                                message:
                                                "already running",
                                              );

                                              return;
                                            } else {
                                              log(
                                                'no live chat carry on jatta',
                                              );
                                            }
                                            Get.back();
                                            List<String> list = [];
                                            for (var i = 0;
                                            i <
                                                liveAstrologerController
                                                    .waitList
                                                    .length;
                                            i++) {
                                              log(
                                                "STATUS 1 ${liveAstrologerController
                                                    .waitList[i].status}",
                                              );

                                              if (liveAstrologerController
                                                  .waitList[i]
                                                  .status ==
                                                  "Pending") {
                                                list.add("value");

                                                setState(
                                                      () =>
                                                  isAlreadyTaking =
                                                  true,
                                                );
                                              }
                                            }
                                            debugPrint("marker1");
                                            debugPrint(
                                              '${list.isEmpty}',
                                            );
                                            debugPrint('$list');

                                            if (list.isNotEmpty) {
                                              //! connect other user by desconnecting current user
                                              log(
                                                "statu Already is in chat",
                                              );

                                              CurrentUser userData =
                                              CurrentUser.fromJson(
                                                json.decode(
                                                  global.sp!.getString(
                                                    "currentUser",
                                                  ) ??
                                                      "",
                                                ),
                                              );
                                              String id = userData.id
                                                  .toString();
                                              String? fcmToken =
                                              await FirebaseMessaging
                                                  .instance
                                                  .getToken();

                                              setState(() {
                                                reqType =
                                                    liveAstrologerController
                                                        .waitList[index]
                                                        .requestType;
                                                log(
                                                  'req type $reqType',
                                                );
                                                username =
                                                    liveAstrologerController
                                                        .waitList[index]
                                                        .userName;
                                              });
                                              global.sendNotification(
                                                fcmToken:
                                                liveAstrologerController
                                                    .waitList[index]
                                                    .userFcmToken,
                                                title:
                                                "For Live accept/reject",
                                                subtitle:
                                                "For Live accept/reject",
                                                astroname: (global.user
                                                    .name !=
                                                    null &&
                                                    global.user
                                                        .name !=
                                                        "")
                                                    ? global.user.name
                                                    : "Astrologer",
                                                channelname: global
                                                    .agoraLiveChannelName,
                                                token: global
                                                    .agoraLiveToken,
                                                astroId: id.toString(),
                                                requestType:
                                                liveAstrologerController
                                                    .waitList[index]
                                                    .requestType,
                                                id: liveAstrologerController
                                                    .waitList[index].id
                                                    .toString(),
                                                charge: global
                                                    .user.charges
                                                    .toString(),
                                                nfcmToken: fcmToken,
                                                astroProfile: global
                                                    .user
                                                    .imagePath ??
                                                    "",
                                                videoCallCharge: global
                                                    .user.videoCallRate
                                                    .toString(),
                                              );

                                              liveAstrologerController
                                                  .endTime = DateTime
                                                  .now()
                                                  .millisecondsSinceEpoch +
                                                  1000 *
                                                      int.parse(
                                                        liveAstrologerController
                                                            .waitList[
                                                        index]
                                                            .time,
                                                      );
                                            } else {
                                              global.showToast(
                                                message:
                                                "Once running session complete, you will be able to start new session",
                                              );
                                            }
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                            liveAstrologerController
                                                .waitList[index]
                                                .isOnline
                                                ? MaterialStateProperty
                                                .all(
                                              Get.theme
                                                  .primaryColor,
                                            )
                                                : MaterialStateProperty
                                                .all(
                                              Colors.grey,
                                            ),
                                          ),
                                          child: Center(
                                            child: const Text(
                                              "Start",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ).tr(),
                                          ),
                                        ),
                                      )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                            : Center(
                          child: const Text(
                            "No members available",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ).tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (liveAstrologerController.isOpenPersonalChatDialog) {
            liveAstrologerController.isOpenPersonalChatDialog = false;
            liveAstrologerController.update();
            return false; // Prevent back navigation
          }

          bool shouldLeave = await showExitConfirmationDialog();
          return shouldLeave;
        },
        child: Scaffold(
          body: ListView(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: Get.height * 0.9,
                    child: ValueListenableBuilder(
                      valueListenable: isImHost,
                      builder: (context, isHost, child) =>
                          Stack(
                            children: [
                              ValueListenableBuilder(
                                valueListenable: isJoined,
                                builder: (context, isJoin, child) {
                                  log('isJoined --> $isJoin');
                                  return SizedBox(
                                    height: isHost
                                        ? Get.height * 0.5
                                        : Get.height * 0.9,
                                    width: Get.width,
                                    child: isJoin
                                        ? videoPanel()
                                        : Center(
                                      child: const Text('joining..').tr(),
                                    ),
                                  );
                                },
                              ),
                              isHost
                                  ? Container(
                                margin: EdgeInsets.only(
                                  top: Get.height * 0.46,
                                ),
                                height: isHost ? Get.height * 0.5 : 0,
                                width: isHost ? Get.width : 0,
                                child: _videoPanelForCoHost(),
                              )
                                  : const SizedBox(),
                            ],
                          ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 8,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Future.delayed(
                              const Duration(milliseconds: 500),
                            ).then((value) async {
                              await localNotifications.cancelAll();
                            });
                            await liveAstrologerController.getWaitList(
                              global.agoraLiveChannelName,
                            );
                            await liveAstrologerController.getLiveuserData(
                              global.agoraLiveChannelName,
                            );
                            await liveAstrologerController.onlineOfflineUser();
                            liveAstrologerController.isUserJoinWaitList = false;
                            liveAstrologerController.update();
                            wailtListDialog();
                          },
                          child: GetBuilder<LiveAstrologerController>(
                            builder: (liveController) {
                              return Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    margin: const EdgeInsets.only(
                                      right: 20,
                                      bottom: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      FontAwesomeIcons.hourglassEnd,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  liveController.isUserJoinWaitList
                                      ? const Positioned(
                                    right: 20,
                                    top: 0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 6,
                                    ),
                                  )
                                      : const SizedBox(),
                                ],
                              );
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text(
                                  "Are you sure you want Leave live stream?",
                                ).tr(),
                                content: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: const Text(
                                          MessageConstants.No,
                                        ).tr(),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          homeController.getOnlineAstro(0);
                                          await walletController
                                              .getAmountList();
                                          walletController.update();
                                          leave();
                                          //added this line for not to wait
                                          await liveAstrologerController.endLiveSession(false);
                                          Get.offAll(() => const HomeScreen());
                                        },
                                        child: const Text(
                                          MessageConstants.YES,
                                        ).tr(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ValueListenableBuilder<List<MessageModel>>(
                            valueListenable: reverseMessage,
                            builder: (context, messages, child) =>
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    messages.isEmpty
                                        ? const SizedBox()
                                        : SizedBox(
                                      height: Get.height * 0.4,
                                      width: Get.width * 0.74,
                                      child: ListView.builder(
                                        itemCount: messages.length,
                                        reverse: true,
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        itemBuilder: (context, index) {
                                          debugPrint(
                                            'revrese profile ${messages[index]
                                                .profile}',
                                          );

                                          return messages[index]
                                              .message
                                              .toString() ==
                                              ''
                                              ? const SizedBox()
                                              : Row(
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(
                                                  4.0,
                                                ),
                                                child: CircleAvatar(
                                                  backgroundColor: Get
                                                      .theme
                                                      .primaryColor,
                                                  child: messages[index]
                                                      .profile ==
                                                      ""
                                                      ? Image.asset(
                                                    'assets/images/no_customer_image.png',
                                                    height: 40,
                                                    width: 30,
                                                  )
                                                      : CachedNetworkImage(
                                                    imageUrl:
                                                    '${messages[index]
                                                        .profile}',
                                                    imageBuilder: (context,
                                                        imageProvider,) =>
                                                        CircleAvatar(
                                                          backgroundImage:
                                                          NetworkImage(
                                                            '${messages[index]
                                                                .profile}',
                                                          ),
                                                        ),
                                                    placeholder: (context,
                                                        url,) =>
                                                    const Center(
                                                      child:
                                                      CircularProgressIndicator(),
                                                    ),
                                                    errorWidget: (context,
                                                        url,
                                                        error,) =>
                                                        Image
                                                            .asset(
                                                          'assets/images/no_customer_image.png',
                                                          height: 40,
                                                          width: 30,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              SizedBox(
                                                width: Get.width * 0.55,
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      messages[index]
                                                          .userName ??
                                                          "User",
                                                      style: Get
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                        color: Colors
                                                            .white,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                      MainAxisSize
                                                          .min,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            messages.isNotEmpty
                                                                ? messages[index]
                                                                .message!
                                                                : '',
                                                            style: Get
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                              color: Colors
                                                                  .white,
                                                            ),
                                                          ),
                                                        ),
                                                        messages[index].gift !=
                                                            null &&
                                                            messages[index]
                                                                .gift !=
                                                                'null'
                                                            ? CachedNetworkImage(
                                                          height:
                                                          30,
                                                          width:
                                                          30,
                                                          imageUrl:
                                                          '$imgBaseurl${messages[index]
                                                              .gift}',
                                                        )
                                                            : const SizedBox(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: Get.width * 0.4,
                                          child: TextFormField(
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                            controller: messageController,
                                            keyboardType: TextInputType.text,
                                            cursorColor: Colors.white,
                                            decoration: InputDecoration(
                                              fillColor: Colors.black38,
                                              filled: true,
                                              hintStyle: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                              helperStyle: TextStyle(
                                                color: Get.theme.primaryColor,
                                              ),
                                              contentPadding: const EdgeInsets
                                                  .all(
                                                10.0,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                                borderRadius: BorderRadius
                                                    .circular(
                                                  20,
                                                ),
                                              ),
                                              focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                                borderRadius: BorderRadius
                                                    .circular(
                                                  20,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                                borderRadius: BorderRadius
                                                    .circular(
                                                  20,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                                borderRadius: BorderRadius
                                                    .circular(
                                                  20,
                                                ),
                                              ),
                                              hintText: tr("Say hi..."),
                                              prefixIcon: const Icon(
                                                Icons.chat,
                                                color: Colors.white,
                                                size: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        InkWell(
                                          onTap: () {
                                            if (messageController.text != "") {
                                              sendMessage(
                                                  messageController.text);
                                              messageController.clear();
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.only(
                                                top: 8),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.black38,
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.send,
                                              color: Colors.white,
                                              size: 15,
                                            ),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: remoteUid != null ? 10 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                children: [
                                  remoteUid != null
                                      ? Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 13.0,
                                        child:
                                        currentUserProfile.value == ""
                                            ? CircleAvatar(
                                          backgroundColor: Get
                                              .theme
                                              .primaryColor,
                                          backgroundImage:
                                          const AssetImage(
                                            "assets/images/no_customer_image.png",
                                          ),
                                          radius: 10.0,
                                        )
                                            : CircleAvatar(
                                          backgroundImage:
                                          NetworkImage(
                                            currentUserProfile
                                                .value,
                                          ),
                                          radius: 10.0,
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 13.0,
                                          child: liveAstrologerController
                                              .joinedUserProfile ==
                                              ""
                                              ? CircleAvatar(
                                            backgroundColor: Get
                                                .theme.primaryColor,
                                            backgroundImage:
                                            const AssetImage(
                                              "assets/images/no_customer_image.png",
                                            ),
                                            radius: 10.0,
                                          )
                                              : CircleAvatar(
                                            backgroundImage:
                                            NetworkImage(
                                              "$imgBaseurl${liveAstrologerController
                                                  .joinedUserProfile}",
                                            ),
                                            radius: 10.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                      : CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 18.0,
                                    child: (currentUserProfile.value !=
                                        "")
                                        ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        currentUserProfile.value,
                                      ),
                                      radius: 15.0,
                                    )
                                        : CircleAvatar(
                                      backgroundColor:
                                      Get.theme.primaryColor,
                                      backgroundImage:
                                      const AssetImage(
                                        "assets/images/no_customer_image.png",
                                      ),
                                      radius: 15.0,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currenUserName,
                                        style: Get.textTheme.bodySmall!
                                            .copyWith(color: Colors.white),
                                      ),
                                      remoteUid != null
                                          ? username != ""
                                          ? Text(
                                        "&$username",
                                        style: Get
                                            .textTheme.bodySmall!
                                            .copyWith(
                                          color: Colors.white,
                                        ),
                                      )
                                          : const SizedBox()
                                          : const SizedBox(),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  remoteUid != null
                                      ? Image.asset(
                                    'assets/images/voice.gif',
                                    height: 30,
                                    width: 30,
                                  )
                                      : const SizedBox(),
                                  liveAstrologerController.isUserJoinAsChat
                                      ? Image.asset(
                                    'assets/images/voice.gif',
                                    height: 30,
                                    width: 30,
                                  )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                remoteUid != null
                                    ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(right: 8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: CountdownTimer(
                                    endTime:
                                    liveAstrologerController.endTime,
                                    widgetBuilder: (_,
                                        CurrentRemainingTime? time,) {
                                      if (time == null) {
                                        return Text(
                                          '00:00:00',
                                          style: Get.textTheme.bodySmall!
                                              .copyWith(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        );
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: time.hours != null &&
                                            time.hours != 0
                                            ? Text(
                                          '${time.hours}:${time.min}:${time
                                              .sec} sec',
                                          style: const TextStyle(
                                            fontWeight:
                                            FontWeight.w400,
                                            fontSize: 10,
                                            color: Colors.black,
                                          ),
                                        )
                                            : time.min != null
                                            ? Text(
                                          '${time.min} min ${time.sec} sec',
                                          style:
                                          const TextStyle(
                                            fontWeight:
                                            FontWeight.w400,
                                            fontSize: 10,
                                            color: Colors.black,
                                          ),
                                        )
                                            : Text(
                                          '${time.sec} sec',
                                          style:
                                          const TextStyle(
                                            fontWeight:
                                            FontWeight.w400,
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                    onEnd: () {
                                      //call the disconnect method from requested customer
                                    },
                                  ),
                                )
                                    : const SizedBox(),
                                GetBuilder<LiveAstrologerController>(
                                  builder: (c) {
                                    return liveAstrologerController
                                        .isUserJoinAsChat
                                        ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(
                                        right: 8,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius:
                                        BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: CountdownTimer(
                                        endTime: liveAstrologerController
                                            .endTime,
                                        widgetBuilder: (_,
                                            CurrentRemainingTime? time,) {
                                          if (time == null) {
                                            return Text(
                                              '00 min 00 sec',
                                              style: Get
                                                  .textTheme.bodySmall!
                                                  .copyWith(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            );
                                          }
                                          return Padding(
                                            padding:
                                            const EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: time.min != null
                                                ? Text(
                                              '${time.min} min ${time.sec} sec',
                                              style: Get.textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            )
                                                : Text(
                                              '${time.sec} sec',
                                              style: Get.textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                        onEnd: () {
                                          //call the disconnect method from requested customer
                                        },
                                      ),
                                    )
                                        : const SizedBox();
                                  },
                                ),
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ValueListenableBuilder(
                                        valueListenable: myviewerCount,
                                        builder: (context, value, child) =>
                                            Text(
                                              value.toString(),
                                              style:
                                              Get.textTheme.bodySmall!.copyWith(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                      ),
                                    ),
                                    GetBuilder<LiveAstrologerController>(
                                      builder: (liveAstrologerController) {
                                        return liveAstrologerController
                                            .isUserJoinAsChat ==
                                            true
                                            ? GestureDetector(
                                          onTap: () {
                                            liveAstrologerController
                                                .isOpenPersonalChatDialog =
                                            true;
                                            liveAstrologerController
                                                .update();
                                            personalChatDialog(
                                              userName:
                                              "${liveAstrologerController
                                                  .liveChatUserName}",
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              top: 5,
                                              right: 5,
                                            ),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundColor: Colors
                                                  .black
                                                  .withOpacity(0.3),
                                              child: const Icon(
                                                Icons.message,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        )
                                            : const SizedBox();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> showExitConfirmationDialog() async {
    return await Get.dialog(
      AlertDialog(
        title: const Text(
          "Are you sure you want to leave the live stream?",
        ).tr(),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(
                    result: false,
                  ); // Return false when "No" is clicked
                },
                child: const Text(MessageConstants.No).tr(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () async {
                  homeController.getOnlineAstro(0); // No live
                  await walletController.getAmountList();
                  walletController.update();
                  leave();
                  Get.offAll(() => const HomeScreen());
                  Get.back(result: true);
                  // Return true when "YES" is clicked
                },
                child: const Text(MessageConstants.YES).tr(),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible:
      false, // Prevents dialog from closing on tap outside
    ) ??
        false; // Ensure a default value in case of null
  }

  Future generateChatToken() async {
    try {
      global.sp = await SharedPreferences.getInstance();
      CurrentUser userData = CurrentUser.fromJson(
        json.decode(global.sp!.getString("currentUser") ?? ""),
      );
      int? id = userData.id;
      chatuid = "AgoraLiveUser_$id";
      channel_name = "liveAstrologer_$id"; //astrowayGuruLive_155
      log('channel name is for both partner and user is - $chatuid');
      setState(() {});
      await liveAstrologerController.getRtmToken(
        global.getSystemFlagValue(global.systemFlagNameList.agoraAppId),
        global.getSystemFlagValue(
          global.systemFlagNameList.agoraAppCertificate,
        ),
        chatuid,
        channel_name,
      );
      log("token chat genrated:-${global.agoraChatToken}");
    } catch (e) {
      debugPrint("Exception in gettting token: ${e.toString()}");
    }
  }

  Future generateToken() async {
    try {
      global.sp = await SharedPreferences.getInstance();
      CurrentUser userData = CurrentUser.fromJson(
        json.decode(global.sp!.getString("currentUser") ?? ""),
      );
      int id = userData.id ?? 0;
      log('channel user id - $id');

      global.agoraLiveChannelName = '${global.liveChannelName}_$id';
      log('channel name agora - ${global.agoraLiveChannelName}');
      await liveAstrologerController.getRtmToken(
        global.getSystemFlagValue(global.systemFlagNameList.agoraAppId),
        global.getSystemFlagValue(
          global.systemFlagNameList.agoraAppCertificate,
        ),
        "$uid",
        global.agoraLiveChannelName,
      );
      await liveAstrologerController.getRitcToken(
        global.getSystemFlagValue(global.systemFlagNameList.agoraAppId),
        global.getSystemFlagValue(
          global.systemFlagNameList.agoraAppCertificate,
        ),
        "$uid",
        global.agoraLiveChannelName,
      );
      FutureBuilder(
        future: sendTokenToApi(
          id,
          global.agoraLiveChannelName,
          global.agoraLiveToken,
          "",
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (snapshot.hasError) {
                global.showToast(message: 'Error: ${snapshot.error}');
                return const SizedBox();
              } else {
                global.showToast(message: "Token Generated");

                return const SizedBox();
              }
            }
          }

          return const SizedBox();
        },
      );
    } catch (e) {
      debugPrint("Exception in getting token: ${e.toString()}");
    }
  }

  Future<void> setupVideoSDKEngine() async {
    await [Permission.microphone, Permission.camera].request();
    agoraEngine = createAgoraRtcEngine();
    await generateToken();
    try {
      await agoraEngine.initialize(
        RtcEngineContext(
          appId: global.getSystemFlagValue(
            global.systemFlagNameList.agoraAppId,
          ),
        ),
      );
      // ✅ Set low video quality here BEFORE join
      await agoraEngine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions:
          VideoDimensions(width: 320, height: 240),
          // Lower resolution
          frameRate: 15,
          // FPS
          bitrate: 200,
          // kbps
          orientationMode: OrientationMode.orientationModeAdaptive,
          degradationPreference: DegradationPreference.maintainQuality,
        ),
      );
      log('init agora ${global.getSystemFlagValue(
          global.systemFlagNameList.agoraAppId)}');
    } catch (e) {
      log('agora catched error $e');
    }
    join();
    await agoraEngine.enableVideo();

    sp = await SharedPreferences.getInstance();
    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          isJoined.value = true;
          liveAstrologerController.isImInLive = true;

          conneId.value = connection.localUid!;
          debugPrint("local uid 5555-:${connection.localUid}");
          apiHelper.setAstrologerOnOffBusyline('Busy');
          homeController.getOnlineAstro(1);
        },
        onUserJoined: (RtcConnection connection, int remoteUid2, int elapsed) {
          isImHost.value = true;
          setState(() {
            remoteUid = remoteUid2;
            isAlreadyTaking = true;
          });
          homeController.getOnlineAstro(remoteUid2);

          log('customer joined:---- ${isImHost.value}');
          log('Connection local Id: ${connection.localUid}');
          log('RemoteId from onUserJoinded- $remoteUid');

          apiHelper.setAstrologerOnOffBusyline('Busy');
        },
        onUserMuteVideo: (RtcConnection conn, int remoteId3, bool muted) {
          debugPrint("Muted remoteId:$remoteId3");
          debugPrint("muted or not$muted");
          if (remoteUid == remoteId3) {
            if (muted == true) {
              isImHost.value = true;
              debugPrint('isimHost in onUserMuteVideo muted ${isImHost.value}');
            } else {
              isImHost.value = true;
              debugPrint(
                'isimHost in onUserMuteVideo mutede else ${isImHost.value}',
              );
            }
          }
        },
        onUserOffline: (RtcConnection connection,
            int remoteUId,
            UserOfflineReasonType reason,) {
          apiHelper.setAstrologerOnOffBusyline('Online');
          isImHost.value = false;
          homeController.getOnlineAstro(0); //no live

          setState(() {
            remoteUid = null;
            isAlreadyTaking = false;
          });
          debugPrint('user offline $reason');
        },
        onLeaveChannel: (RtcConnection con, RtcStats sc) {
          debugPrint("onLeaveChannel called${con.localUid}");
          apiHelper.setAstrologerOnOffBusyline('Online');
          liveAstrologerController.isImInLive = false;
          homeController.getOnlineAstro(0);

          setState(() {
            remoteUid = null;

            isAlreadyTaking = false;
          });
          liveAstrologerController.update();
        },
      ),
    );

    CurrentUser userData = CurrentUser.fromJson(
      json.decode(sp!.getString("currentUser") ?? ""),
    );
    setState(() {
      currentUserId = userData.id ?? 0;
      currenUserName = userData.name ?? "User";
      log('user name $currenUserName');
    });
    currentUserProfile.value =
    userData.imagePath != "" ? "$imgBaseurl${userData.imagePath}" : "";
    debugPrint('user profile is after $imgBaseurl${userData.imagePath}');
  }

  Widget _videoPanelForCoHost() {
    log('cohost request type $reqType');
    if (remoteUid != null) {
      debugPrint('remote id from _videoPanelForCoHost:- $remoteUid');
      if (reqType == 'Audio') {
        return Stack(
          children: [
            Container(
              color: const Color(0xff22292f),
              child: Lottie.asset('assets/animation/audio_call_anim.json'),
            ),
            Positioned(
              top: 60,
              left: 90,
              child: Text(
                'Call with $username ongoing',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        );
      } else {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: agoraEngine,
            canvas: VideoCanvas(uid: remoteUid),
            connection: RtcConnection(channelId: global.agoraLiveChannelName),
          ),
        );
      }
    } else {
      return const SizedBox();
    }
  }

  Widget videoPanel() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine,
        canvas: VideoCanvas(
          uid: uid, //Can be 0 for local ID
        ),
      ),
    );
  }

  void join() async {
    debugPrint("agora live token - ${global.agoraLiveToken}");
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine.startPreview();
    global.showOnlyLoaderDialog();
    await agoraEngine.joinChannel(
      token: global.agoraLiveToken,
      channelId: global.agoraLiveChannelName,
      options: options,
      uid: 0,
    );
    global.hideLoader();

    isJoined.value = true;
    homeController.getOnlineAstro(1);

    log('in join method');
  }

  void leave() async {
    if (mounted) {
      isJoined.value = false;
      homeController.getOnlineAstro(0);
      await apiHelper.setAstrologerOnOffBusyline('Online');
      await liveAstrologerController.endLiveSession(false);
      client.removeListener();
      reverseMessage.value.clear();
      try {
        // Log out of Signaling​
        var (status, response) = await client.logout();
        if (status.error == true) {
          log('${status.operation} failed ${status.reason}, error code: ${status
              .errorCode}');
        } else {
          log('logout RTM success!');
        }
      } catch (e) {
        log('something went wrong with logout: $e');
      }
    }

    homeController.isSelectedBottomIcon = 1;
    homeController.update();
    await agoraEngine.leaveChannel();
    await agoraEngine.release();
    liveAstrologerController.isImInLive = false;
    liveAstrologerController.update();
    remoteUid = null;
    log('astrologer leave in method');
  }

  @override
  void dispose() async {
    client.removeListener();
    reverseMessage.value.clear();
    await apiHelper.setAstrologerOnOffBusyline('Online');
    await liveAstrologerController.endLiveSession(true);
    if (agoraEngine != null) {
      await agoraEngine.leaveChannel();
      await agoraEngine.release();
      liveAstrologerController.isImInLive = false;
      liveAstrologerController.update();
      WakelockPlus.disable();


    }
    super.dispose();
  }

  void initRTM() async {
    await liveAstrologerController.getRtmToken(
      global.agoraAppId,
      global.agoraAppCertificate,
      chatuid,
      channelName,
    );

    // await liveAstrologerController.enableRTM(
    //   global.agoraAppId,
    //   chatuid,
    //   global.agoraChatToken,
    //   channelName,
    // );
  }
}

