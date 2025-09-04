// ignore_for_file: avoid_print, must_be_immutable

import 'dart:developer';
import 'dart:io';

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/HomeController/call_detail_controller.dart';
import 'package:astrowaypartner/models/History/call_history_model.dart';
import 'package:astrowaypartner/views/HomeScreen/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:sizer/sizer.dart';

import '../../models/chat_message_model.dart';

class CallDetailScreen extends StatelessWidget {
  CallHistoryModel callHistorydata;
  CallDetailScreen({super.key, required this.callHistorydata});
  final callDetailController = Get.put(CallDetailController());

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        await callDetailController.disposeAudioPlayer();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: COLORS().greyBackgroundColor,
          appBar: AppBar(
            backgroundColor: COLORS().primaryColor,
            title: Text(
              callHistorydata.name != null && callHistorydata.name!.isNotEmpty
                  ? '${callHistorydata.name} detail\'s'
                  : tr("User detail's"),
            ),
            leading: IconButton(
              icon: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
              onPressed: () async {
                print('back press');
                await callDetailController.disposeAudioPlayer();
                Get.back();
              },
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Client Profile
              SizedBox(
                height: 25.h,
                width: width,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 12, top: 12, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Client Profile:",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ).tr(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Text(
                                "Name : ",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                              ).tr(),
                              Text(
                                callHistorydata.name != null &&
                                        callHistorydata.name!.isNotEmpty
                                    ? '${callHistorydata.name}'
                                    : tr("User"),
                                style: Get.theme.primaryTextTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Text(
                                "Mobile Number",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                              ).tr(),
                              Text(
                                '${callHistorydata.contactNo}',
                                style: Get.theme.primaryTextTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Text(
                                "Call status : ",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                              ).tr(),
                              Text(
                                '${callHistorydata.callStatus}',
                                style: Get.theme.primaryTextTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //Appointment Schedule
              SizedBox(
                height: 45.h,
                width: width,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 12, top: 12, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Appointment Schedule:",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ).tr(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Text(
                                "Expert Name : ",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                              ).tr(),
                              Text(
                                '${callHistorydata.astrologerName}',
                                style: Get.theme.primaryTextTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Text(
                                "Time : ",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                              ).tr(),
                              Text(
                                DateFormat('dd MMM yyyy , hh:mm a').format(
                                    DateTime.parse(
                                        callHistorydata.createdAt!.toString())),
                                style: Get.theme.primaryTextTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Text(
                                "Duration : ",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                              ).tr(),
                              Text(
                                callHistorydata.totalMin != null &&
                                        callHistorydata.totalMin!.isNotEmpty
                                    ? '${callHistorydata.totalMin} min'
                                    : "0 min",
                                style: Get.theme.primaryTextTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Text(
                                "Price : ",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                              ).tr(),
                              Text(
                                '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${callHistorydata.charge}',
                                style: Get.theme.primaryTextTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Text(
                                "Deduction : ",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                              ).tr(),
                              Text(
                                '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${callHistorydata.deduction}',
                                style: Get.theme.primaryTextTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              callHistorydata.chatId != ""
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 12,
                      ),
                      child: const Text(
                        'Live Client Chat History',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ).tr(),
                    )
                  : const SizedBox(),
              //Recording Audio
              callHistorydata.chatId != ""
                  ? Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 10,
                        child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                            stream: callDetailController.getChatMessages(
                                callHistorydata.chatId ?? "",
                                global.currentUserId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState.name == "waiting") {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else {
                                if (snapshot.hasError) {
                                  return Text(
                                      'snapShotError :- ${snapshot.error}');
                                } else {
                                  List<ChatMessageModel> messageList = [];
                                  for (var res in snapshot.data!.docs) {
                                    messageList.add(
                                        ChatMessageModel.fromJson(res.data()));
                                  }

                                  print(messageList.length);
                                  return ListView.builder(
                                      padding: const EdgeInsets.all(0),
                                      itemCount: messageList.length,
                                      //shrinkWrap: true,
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Get.theme.primaryColor,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(12),
                                                  bottomRight:
                                                      Radius.circular(0),
                                                ),
                                              ),
                                              width: 140,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 16),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    messageList[index].message!,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                  messageList[index]
                                                              .createdAt !=
                                                          null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                  DateFormat()
                                                                      .add_jm()
                                                                      .format(messageList[
                                                                              index]
                                                                          .createdAt!),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        9.5,
                                                                  )),
                                                            ],
                                                          ),
                                                        )
                                                      : const SizedBox()
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                }
                              }
                            }),
                      ),
                    )
                  : const SizedBox(),
              Container(
                width: 100.w,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                child: GestureDetector(
                  onTap: () {
                    String? ssID;
                    log("ssid 0 for audio is  ${callHistorydata.sId}");
                    log("ssid 1 for audio is  ${callHistorydata.sId1}");

                    if (callHistorydata.sId!.isEmpty ||
                        callHistorydata.sId == null) {
                      ssID = callHistorydata.sId1;
                    } else {
                      ssID = callHistorydata.sId;
                    }
                    log("ssid for audio is  $ssID");

                    Get.to(() => Player(
                          sid: ssID.toString(),
                          callHistorydata: callHistorydata,
                        ));
                  },
                  child: Container(
                    height: 6.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.h),
                      border: Border.all(color: Colors.pink, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        'Play',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleSmall!
                            .copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
