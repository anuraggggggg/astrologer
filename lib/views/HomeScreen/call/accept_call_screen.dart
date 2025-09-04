// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astrowaypartner/controllers/HomeController/call_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/home_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/callAvailability_controller.dart';
import '../../../controllers/chatAvailability_controller.dart';
import '../../../models/user_model.dart';
import '../../../services/apiHelper.dart';
import '../../../utils/config.dart';
import '../home_screen.dart';

class AcceptCallScreen extends StatefulWidget {
  final int id;
  final String name;
  final String profile;
  final int callId;
  final String fcmToken;
  final String callduration;
  const AcceptCallScreen(
      {super.key,
      required this.id,
      required this.fcmToken,
      required this.name,
      required this.profile,
      required this.callId,
      required this.callduration});

  @override
  State<AcceptCallScreen> createState() => _AcceptCallScreenState();
}

class _AcceptCallScreenState extends State<AcceptCallScreen> {
  int uid = 0;
  late RtcEngine agoraEngine;
  bool isCalling = true;
  ValueNotifier<bool> isMuted = ValueNotifier(false);
  ValueNotifier<bool> isSpeaker = ValueNotifier(false);
  int min = 0;
  int sec = 0;
  final chatControlleronline = Get.find<ChatAvailabilityController>();
  final walletController = Get.find<WalletController>();
  final callController = Get.find<CallController>();
  final homecontroller = Get.find<HomeController>();
  final kundlicontroller = Get.find<KundliController>();

  final callControlleronline = Get.find<CallAvailabilityController>();
  ValueNotifier<bool> isJoined = ValueNotifier(false);
  ValueNotifier<String> statusText = ValueNotifier('calling..');
  ValueNotifier<int?> remoteUid = ValueNotifier(null);
  final apiHelper = APIHelper();
  @override
  void initState() {
    super.initState();
    clearList();
    setupVoiceSDKEngine();
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('onDispose called accept');
    apiHelper.setAstrologerOnOffBusyline("Online");
    clearList();
  }

  Future generateToken() async {
    try {
      global.sp = await SharedPreferences.getInstance();
      CurrentUser userData = CurrentUser.fromJson(
          json.decode(global.sp!.getString("currentUser") ?? ""));
      int id = userData.id ?? 0;
      global.agoraChannelName = '${global.channelName}${id}_${widget.id}';
      log('channel name :- ${global.agoraChannelName}');
      await callController.getRtcToken(
          global.getSystemFlagValue(global.systemFlagNameList.agoraAppId),
          global.getSystemFlagValue(
              global.systemFlagNameList.agoraAppCertificate),
          "$uid",
          global.agoraChannelName);
      log("call token:-${global.agoraToken}");
      global.showOnlyLoaderDialog();
      await callController.sendCallToken(global.agoraToken,
          global.agoraChannelName, widget.callId); //audio call_type
      global.hideLoader();
      log("object");
    } catch (e) {
      // ignore: avoid_print
      debugPrint("Exception in gettting token: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        global.showToast(
            message: tr('Please leave the call by pressing leave button'));
        return false;
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
              color: Get.theme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.info),
                        onPressed: () async {
                          global.showOnlyLoaderDialog();
                          kundlicontroller.kundliChartModel = null;
                          kundlicontroller.update();
                          // await kundlicontroller
                          //     .kundliAddNewinfo(widget.id.toString());
                          await callController.getFormIntakeData(widget.id);
                          debugPrint('intakeData ${callController.intakeData}');
                          global.hideLoader();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  scrollable: true,
                                  content:
                                      Stack(clipBehavior: Clip.none, children: [
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ListTile(
                                          enabled: true,
                                          tileColor: Colors.white,
                                          title: Text(
                                            "Name",
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .displaySmall,
                                          ).tr(),
                                          trailing: SizedBox(
                                            width: 120,
                                            child: Text(
                                              callController
                                                      .intakeData[0].name ??
                                                  tr("User"),
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .titleMedium,
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          enabled: true,
                                          tileColor: Colors.white,
                                          title: Text(
                                            "Birth Date",
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .displaySmall,
                                          ).tr(),
                                          trailing: SizedBox(
                                            width: 120,
                                            child: Text(
                                              DateFormat('dd-MM-yyyy').format(
                                                  DateTime.parse(callController
                                                      .intakeData[0].birthDate
                                                      .toString())),
                                              textAlign: TextAlign.end,
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          enabled: true,
                                          tileColor: Colors.white,
                                          title: Text(
                                            "Birth Time",
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .displaySmall,
                                          ).tr(),
                                          trailing: Text(
                                            callController
                                                .intakeData[0].birthTime
                                                .toString(),
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        ListTile(
                                          enabled: true,
                                          tileColor: Colors.white,
                                          title: Text(
                                            "Birth Place",
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .displaySmall,
                                          ).tr(),
                                          trailing: SizedBox(
                                            width: 120,
                                            child: Text(
                                              callController
                                                  .intakeData[0].birthPlace
                                                  .toString(),
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .titleMedium,
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ),
                                        // ListTile(
                                        //   enabled: true,
                                        //   tileColor: Colors.white,
                                        //   title: Text(
                                        //     "Phone",
                                        //     style: Theme.of(context)
                                        //         .primaryTextTheme
                                        //         .displaySmall,
                                        //   ).tr(),
                                        //   trailing: Text(
                                        //     callController
                                        //         .intakeData[0].phoneNumber
                                        //         .toString(),
                                        //     style: Theme.of(context)
                                        //         .primaryTextTheme
                                        //         .titleMedium,
                                        //     textAlign: TextAlign.end,
                                        //   ),
                                        // ),
                                        ListTile(
                                          enabled: true,
                                          tileColor: Colors.white,
                                          title: Text(
                                            "Occupation",
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .displaySmall,
                                          ).tr(),
                                          trailing: SizedBox(
                                            width: 120,
                                            child: Text(
                                              callController
                                                  .intakeData[0].occupation
                                                  .toString(),
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .titleMedium,
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ),
                                        callController.intakeData[0]
                                                    .topicOfConcern ==
                                                ""
                                            ? const SizedBox()
                                            : ListTile(
                                                enabled: true,
                                                tileColor: Colors.white,
                                                title: Text(
                                                  "Topic",
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .displaySmall,
                                                ).tr(),
                                                trailing: SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    callController.intakeData[0]
                                                        .topicOfConcern
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium,
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                              ),
                                        callController.intakeData[0]
                                                        .partnerName !=
                                                    null &&
                                                callController.intakeData[0]
                                                        .partnerName !=
                                                    ''
                                            ? ListTile(
                                                enabled: true,
                                                tileColor: Colors.white,
                                                title: Text(
                                                  "Partner Name",
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .displaySmall,
                                                ).tr(),
                                                trailing: Text(
                                                  callController
                                                      .intakeData[0].partnerName
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .titleMedium,
                                                  textAlign: TextAlign.end,
                                                ),
                                              )
                                            : const SizedBox(),
                                        callController.intakeData[0]
                                                    .partnerBirthDate !=
                                                null
                                            ? ListTile(
                                                enabled: true,
                                                tileColor: Colors.white,
                                                title: Text(
                                                  "Partner Birth Date",
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .displaySmall,
                                                ).tr(),
                                                trailing: SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(DateTime.parse(
                                                            callController
                                                                .intakeData[0]
                                                                .partnerBirthDate
                                                                .toString())),
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium,
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        callController.intakeData[0]
                                                        .partnerBirthTime !=
                                                    null &&
                                                callController.intakeData[0]
                                                        .partnerBirthTime !=
                                                    ''
                                            ? ListTile(
                                                enabled: true,
                                                tileColor: Colors.white,
                                                title: Text(
                                                  "Partner Birth Time",
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .displaySmall,
                                                ).tr(),
                                                trailing: Text(
                                                  callController.intakeData[0]
                                                      .partnerBirthTime
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .titleMedium,
                                                ),
                                              )
                                            : const SizedBox(),
                                        callController.intakeData[0]
                                                        .partnerBirthPlace !=
                                                    null &&
                                                callController.intakeData[0]
                                                        .partnerBirthPlace !=
                                                    ''
                                            ? ListTile(
                                                enabled: true,
                                                tileColor: Colors.white,
                                                title: Text(
                                                  "Partner Birth Place",
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .displaySmall,
                                                ).tr(),
                                                trailing: SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    callController.intakeData[0]
                                                        .partnerBirthPlace
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .titleMedium,
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox()
                                      ],
                                    ),
                                    Positioned(
                                        top: -5,
                                        right: -5,
                                        child: GestureDetector(
                                            onTap: () {
                                              Get.back();
                                            },
                                            child: const Icon(Icons.close)))
                                  ]),
                                  actionsAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  actionsPadding: const EdgeInsets.only(
                                      bottom: 15, left: 15, right: 15),
                                );
                              });
                        },
                      )),
                  const SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.name == '' ? 'User' : widget.name,
                          style: Get.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                        ValueListenableBuilder(
                          valueListenable: isJoined,
                          builder: (context, isjoin, child) => SizedBox(
                            child: isjoin ? status() : const SizedBox(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  height: 120,
                  width: 120,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: Get.height * 0.1),
                  decoration: BoxDecoration(
                    border: Border.all(color: Get.theme.primaryColor),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 60,
                    // ignore: unnecessary_null_comparison
                    child: widget.profile == null || widget.profile == ""
                        ? Image.asset(
                            'assets/images/no_customer_image.png',
                            fit: BoxFit.contain,
                            height: 60,
                            width: 40,
                          )
                        : CachedNetworkImage(
                            imageUrl: '$imgBaseurl${widget.profile}',
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.transparent,
                              child: Image.network(
                                '$imgBaseurl${widget.profile}',
                                fit: BoxFit.contain,
                                height: 60,
                              ),
                            ),
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/no_customer_image.png',
                              fit: BoxFit.contain,
                              height: 60,
                              width: 40,
                            ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
        bottomSheet: Container(
          height: Get.height * 0.1,
          padding: const EdgeInsets.all(10),
          color: Get.theme.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  isSpeaker.value = !isSpeaker.value;
                  onVolume(isSpeaker.value);
                },
                child: ValueListenableBuilder(
                  valueListenable: isSpeaker,
                  builder: (context, value, child) => Icon(
                    value ? Icons.volume_up : Icons.volume_off,
                    color: Colors.black,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  debugPrint("ajsndkjbns");
                  debugPrint("ontab");

                  await global.sendNotification(
                    fcmToken: widget.fcmToken,
                    title: "Astrologer Leave call",
                    subtitle: "",
                  );

                  leave();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
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
              InkWell(
                onTap: () {
                  isMuted.value = !isMuted.value;
                  log('mute $isMuted');
                  onMute(isMuted.value);
                },
                child: ValueListenableBuilder(
                  valueListenable: isMuted,
                  builder: (context, ismute, child) => Icon(
                    ismute ? Icons.mic_off : Icons.mic,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();
    //createClient();
    //agoraEngine.startAudioRecording(config);
    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(
      appId: global.getSystemFlagValue(global.systemFlagNameList.agoraAppId),
    ));
    debugPrint('setup voice sdk engine');

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          // ignore: avoid_print
          debugPrint('host joined${connection.localUid}');
          remoteUid.value = null;
          debugPrint('audio joined engine');
        },
        onUserJoined: (RtcConnection connection, int rmoteID, int elapsed) {
          callController.callList
              .removeWhere((call) => call.callId == widget.callId);
          isJoined.value = true;
          remoteUid.value = rmoteID;
          callController.update();
          apiHelper.setAstrologerOnOffBusyline("Busy").then((value) {
            debugPrint("user also joined with RemoteId${remoteUid.value}");
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUId,
            UserOfflineReasonType reason) {
          isJoined.value = false;
          remoteUid.value = null;

          debugPrint('remote offline $reason');
          leave();
        },
        onRtcStats: (connection, stats) {},
      ),
    );
    await generateToken();
    agoraEngine
        .setDefaultAudioRouteToSpeakerphone(false); // default value for speaker

    join();
  }

  Widget status() {
    if (remoteUid.value == null) {
      statusText.value = 'Calling...';
      return ValueListenableBuilder(
        valueListenable: statusText,
        builder: (context, value, child) => Text(value).tr(),
      );
    } else {
      statusText.value = 'Calling in progress';
      return CountdownTimer(
        endTime: DateTime.now().millisecondsSinceEpoch +
            1000 * (int.parse(widget.callduration)),
        widgetBuilder: (_, CurrentRemainingTime? time) {
          if (time == null) {
            return const Text('');
          }
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: time.hours != null && time.hours != 0
                ? Text(
                    '${time.hours! <= 9 ? '0${time.hours}' : time.hours ?? '00'}:${time.min! <= 9 ? '0${time.min}' : time.min ?? '00'}:${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: Colors.black),
                  )
                : time.min != null
                    ? Text(
                        '${time.min! <= 9 ? '0${time.min}' : time.min ?? '00'}:${time.sec! <= 9 ? '0${time.sec}' : time.sec}',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: Colors.black),
                      )
                    : Text(
                        '${time.sec! <= 9 ? '0${time.sec}}' : time.sec}',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: Colors.black),
                      ),
          );
        },
        onEnd: () {
          if (remoteUid.value != null) {
            isJoined.value = false;
            debugPrint('on leave called');
            leave();
          }
        },
      );
    }
  }

  void join() async {
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine.joinChannel(
      token: global.agoraToken,
      channelId: global.agoraChannelName,
      options: options,
      uid: uid,
    );

    onMute(isMuted.value);
  }

  void onMute(bool mute) async {
    await agoraEngine.muteLocalAudioStream(mute);
  }

  void onVolume(bool isSpeaker) async {
    await agoraEngine.setEnableSpeakerphone(isSpeaker);
  }

  void leave() async {
    await walletController.getAmountList();
    walletController.update();

    debugPrint("ajsndkjbns");
    await apiHelper.setAstrologerOnOffBusyline("Online");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_accepted', false);
    await prefs.setString('is_accepted_data', '');
    debugPrint("leave");
    if (mounted) {
      remoteUid.value = null;
      isSpeaker.value = false;
    }

    agoraEngine.leaveChannel();
    agoraEngine.release(sync: true);
    debugPrint('back called');
    // Get.back();
    Get.offAll(() => const HomeScreen());
  }

  void clearList() async {
    callController.callList.removeWhere((call) => call.callId == widget.callId);
    callController.callList.clear();
    callController.update();
    await callController.getCallList(false);
  }
}
