// ignore_for_file: library_private_types_in_public_api, file_names

import 'dart:developer';

import 'package:astrowaypartner/controllers/HomeController/call_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../constants/colorConst.dart';
import '../../../controllers/networkController.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../../../main.dart';
import '../../../utils/config.dart';

class CallTab extends StatefulWidget {
  const CallTab({super.key});

  @override
  _CallTabState createState() => _CallTabState();
}

class _CallTabState extends State<CallTab> with AutomaticKeepAliveClientMixin {
  final callController = Get.find<CallController>();
  final networkController = Get.find<NetworkController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<CallController>(
      builder: (callController) {
        return callController.callList.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 10, bottom: 200),
                    child: ElevatedButton(
                      onPressed: () async {
                        var status = networkController.connectionStatus.value;

                        if (status <= 0) {
                          global.showToast(message: 'No internet');
                          return;
                        }
                        await callController.getCallList(false);
                        callController.update();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // global.warningDialog(context);
                        });
                      },
                      child: const Icon(
                        Icons.refresh_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Center(
                    child: const Text("You don't have call request yet!").tr(),
                  ),
                ],
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await callController.getCallList(true);
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: callController.callList.length,
                  controller: callController.scrollController,
                  physics: const ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Stack(
                                clipBehavior: Clip.none,
                                //make it overflowed
                                children: [
                                  CachedNetworkImage(
                                    imageUrl:
                                        '$imgBaseurl${callController.callList[index].profile}',
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      height: 75,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: Colors.black,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              "$imgBaseurl${callController.callList[index].profile}"),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 75,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: Get.theme.primaryColor,
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/no_customer_image.png"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.2.h,
                                    right: 2.w,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        callController
                                                    .callList[index].callType ==
                                                10
                                            ? Icons.call
                                            : Icons.video_call,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: COLORS().primaryColor,
                                          size: 20,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Text(
                                            callController
                                                        .callList[index].name ==
                                                    ""
                                                ? "User"
                                                : callController
                                                        .callList[index].name ??
                                                    'User',
                                            style: Get.theme.primaryTextTheme
                                                .displaySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_outlined,
                                            color: COLORS().primaryColor,
                                            size: 20,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Text(
                                              DateFormat('dd-MM-yyyy').format(
                                                  DateTime.parse(callController
                                                      .callList[index].birthDate
                                                      .toString())),
                                              style: Get.theme.primaryTextTheme
                                                  .titleSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    callController.callList[index].birthTime
                                            .isNotEmpty
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.schedule_outlined,
                                                  color: COLORS().primaryColor,
                                                  size: 20,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: Text(
                                                    callController
                                                        .callList[index]
                                                        .birthTime!,
                                                    style: Get
                                                        .theme
                                                        .primaryTextTheme
                                                        .titleSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 90,
                                  height: 30,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green,
                                      side:
                                          const BorderSide(color: Colors.green),
                                    ),
                                    onPressed: () async {
                                      log('hide call noti');

                                      FlutterCallkitIncoming
                                          .hideCallkitIncoming(CallKitParams(
                                              id: callController
                                                  .callList[index].callId
                                                  .toString()));
                                      FlutterCallkitIncoming.setCallConnected(
                                          callController.callList[index].callId
                                              .toString());

                                      Future.delayed(
                                              const Duration(milliseconds: 500))
                                          .then((value) async {
                                        await localNotifications.cancelAll();
                                      });

                                      log('calltype - ${callController.callList[index].callType}');

                                      if (callController
                                              .callList[index].callType ==
                                          10) {
                                        //! AUDIO UNCOMMENT
                                        global.showOnlyLoaderDialog();
                                        await callController.acceptCallRequest(
                                          callController.callList[index].callId,
                                          callController.callList[index]
                                                      .profile ==
                                                  ""
                                              ? "assets/images/no_customer_image.png"
                                              : callController
                                                  .callList[index].profile,
                                          callController.callList[index].name ??
                                              'User',
                                          callController.callList[index].id,
                                          callController
                                                  .callList[index].fcmToken ??
                                              '',
                                          callController
                                              .callList[index].callDuration
                                              .toString(),
                                        );
                                      } else if (callController
                                              .callList[index].callType ==
                                          11) {
                                        //!VIDEO WORKING
                                        log('on homescreen accept video audio ');

                                        global.showOnlyLoaderDialog();
                                        await callController
                                            .acceptVideoCallRequest(
                                          callController.callList[index].callId,
                                          callController.callList[index]
                                                      .profile ==
                                                  ""
                                              ? "assets/images/no_customer_image.png"
                                              : callController
                                                  .callList[index].profile,
                                          callController.callList[index].name ??
                                              'User',
                                          callController.callList[index].id,
                                          callController
                                                  .callList[index].fcmToken ??
                                              '',
                                          callController
                                              .callList[index].callDuration!
                                              .toString(),
                                        );
                                      } else {
                                        debugPrint(
                                            'for audio calltype 10 and 11 for video its neither of them');
                                      }
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "Accept",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400),
                                      ).tr(),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                SizedBox(
                                  width: 90,
                                  height: 30,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: COLORS().errorColor,
                                      side: BorderSide(
                                          color: COLORS().errorColor),
                                    ),
                                    onPressed: () async {
                                      await FlutterCallkitIncoming
                                          .endAllCalls();
                                      // Future.delayed(
                                      //         const Duration(milliseconds: 500))
                                      //     .then((value) async {
                                      //   await localNotifications.cancelAll();
                                      // });
                                      Get.dialog(
                                        AlertDialog(
                                          title: Text(
                                            "Are you sure you want remove customer?",
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400),
                                          ).tr(),
                                          content: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                child: const Text("No").tr(),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  // Optional delay before cancelling notifications
                                                  await Future.delayed(const Duration(milliseconds: 500));

                                                  // Cancel all local notifications
                                                  await localNotifications.cancelAll();

                                                  // Get the current callId
                                                  final callId = callController.callList[index].callId;

                                                  // Reject the call (API/backend update)
                                                  await callController.rejectCallRequest(callId);

                                                  // Remove the call from the local list
                                                  callController.callList.removeAt(index);

                                                  // Update the UI
                                                  callController.update();

                                                  // Close the dialog or screen
                                                  Get.back();
                                                },
                                                child: const Text("Yes").tr(),
                                              ),

                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "Reject",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400),
                                      ).tr(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
