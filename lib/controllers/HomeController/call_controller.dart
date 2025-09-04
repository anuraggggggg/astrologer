// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, non_constant_identifier_names

import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astrowaypartner/models/call_model.dart';
import 'package:astrowaypartner/services/apiHelper.dart';
import 'package:astrowaypartner/views/HomeScreen/live/onetoone_video/onetooneVideo.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import '../../models/intake_model.dart';
import '../../views/HomeScreen/call/accept_call_screen.dart';

class CallController extends GetxController {
  String screen = 'call_controller.dart';
  APIHelper apiHelper = APIHelper();
  List<CallModel> callList = [];
  var intakeData = <IntakeModel>[];
  bool newIsStartTimer = false;
  late RtcEngine agoraEngine;

  ScrollController scrollController = ScrollController();
  int fetchRecord = 5;
  int startIndex = 0;
  bool isDataLoaded = false;
  bool isAllDataLoaded = false;
  bool isMoreDataAvailable = false;
  bool isRejectCall = false;
  AudioPlayer player = AudioPlayer();
  @override
  // ignore: unnecessary_overrides
  void onInit() async {
    super.onInit();
  }
  // Handle Camera Flip Here
  void switchCamera() {
    agoraEngine.switchCamera();
  }

//Get a call AUDIO AND VIDEO  list
  Future getCallList(bool isLazyLoading, {int? isLoading = 1}) async {
    try {
      startIndex = 0;
      if (callList.isNotEmpty) {
        startIndex = callList.length;
      }
      if (!isLazyLoading) {
        log('Lazy loading ${!isLazyLoading}');
        isDataLoaded = false;
      }
      await global.checkBody().then(
        (result) async {
          if (result) {
            log('Lazy loading insde body $isLazyLoading');

            isLoading == 0 ? '' : global.showOnlyLoaderDialog();
            int id = global.user.id ?? 0;
            log('userid $id');

            await apiHelper.getCallRequest(id, startIndex, fetchRecord).then(
              (result) {
                isLoading == 0 ? '' : global.hideLoader();
                if (result.status == "200") {
                  // // callList.clear(); dont use it will not add new user else in list
                  if (!isLazyLoading) {
                    callList.clear();
                    update();
                  }
                  callList.addAll(result.recordList);
                  update();
                  if (result.recordList.length == 0) {
                    isMoreDataAvailable = false;
                    isAllDataLoaded = true;
                  }
                  update();
                } else {
                  // global.showToast(message: "No call list is here");
                  debugPrint('No call list is here');
                }
                update();
              },
            );
          }
        },
      );
    } catch (e) {
      print('Exception: $screen - getCallList(): ' + e.toString());
    }
  }

  acceptCallRequest(int callId, String? profile, String name, int id,
      String fcmToken, String callduration) async {
    print(
        'accept call request- callduration $callduration callid -$callId, name - $name, profile - $profile, CustomerID - $id, fcmToken - $fcmToken');
    try {
      await apiHelper.acceptCallRequest(callId).then(
        (result) async {
          if (result.status == "200") {
            global.hideLoader();
            isRejectCall = false;
            update();
            Get.to(() => AcceptCallScreen(
                name: name,
                profile: profile ?? '',
                id: id,
                callId: callId,
                fcmToken: fcmToken,
                callduration: callduration.toString()));

            callList.clear();
            isAllDataLoaded = false;

            await getCallList(false);
            update();
          } else {
            global.showToast(message: "accept request${result.status}");
          }
        },
      );

      update();
    } catch (e) {
      print('Exception: $screen - acceptCallRequest(): ' + e.toString());
    }
  }

  acceptVideoCallRequest(
      int callId,
      String? profile,
      String name,
      int id,
      String fcmToken,
      String? call_duration,
      ) async {
    log('[📞] Accepting video call...');
    log('   ├─ callId     : $callId');
    log('   ├─ name       : $name');
    log('   ├─ id         : $id');
    log('   ├─ profile    : $profile');
    log('   └─ fcmToken   : $fcmToken');

    try {
      bool isBodyValid = await global.checkBody();

      if (!isBodyValid) {
        log('[❌] Request body validation failed.');
        return;
      }

      log('[✅] Request body validated. Sending call acceptance to backend...');
      final result = await apiHelper.acceptCallRequest(callId);

      if (result.status == "200") {
        log('[✅] Backend confirmed call acceptance.');

        global.hideLoader();
        isRejectCall = false;
        update();

        log('[🚀] Navigating to OneToOneLiveScreen...');
        Get.to(
              () => OneToOneLiveScreen(
            name: name,
            profile: profile ?? '',
            id: id,
            callId: callId,
            fcmToken: fcmToken,
            call_duration: call_duration.toString(),
          ),
        );

        callList.clear();
        isAllDataLoaded = false;
        await getCallList(false);
        update();
      } else {
        log('[❌] Backend rejected the call. Status: ${result.status}');
        global.showToast(message: "Accept request failed: ${result.status}");
      }
    } catch (e) {
      log('[💥] Exception in acceptVideoCallRequest: $e');
    }
  }



  sendCallToken(String token, String channelName, int callId) async {
    try {
      await global.checkBody().then(
        (result) async {
          if (result) {
            await apiHelper.addCallToken(token, channelName, callId).then(
              (result) {
                if (result.status == "200") {
                  //callList = result.recordList;
                  print('call token sent :- $token');
                } else {
                  global.showToast(message: "accept Request ");
                }
              },
            );
          }
        },
      );
      update();
    } catch (e) {
      print('Exception: $screen - sendCallToken(): ' + e.toString());
    }
  }

  rejectCallRequest(int callId) async {
    try {
      await global.checkBody().then(
        (result) async {
          if (result) {
            await apiHelper.rejectCallRequest(callId).then(
              (result) async {
                if (result.status == "200") {
                  global.showToast(message: "Reject call request Successfully");
                  callList.clear();
                  isAllDataLoaded = false;
                  update();
                  await getCallList(false);
                  Get.back();
                } else {
                  global.showToast(
                      message: "Reject Request failed please try again later!");
                }
              },
            );
          }
        },
      );
      update();
    } catch (e) {
      print('Exception: $screen - rejectCallRequest(): ' + e.toString());
    }
  }

  Future<dynamic> getRtcToken(String appId, String appCertificate,
      String chatId, String channelName) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .generateRtcToken(appId, appCertificate, chatId, channelName)
              .then((result) {
            if (result.status == "200") {
              global.agoraToken = result.recordList['rtcToken'];
            } else {
              global.showToast(
                  message: '${result.status} failed to get live RTC Token');
            }
          });
        }
      });
    } catch (e) {
      print("Exception in getRtcToken :-$e");
    }
  }

  getFormIntakeData(int userId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getIntakedata(userId).then((result) {
            if (result.status == "200") {
              intakeData = result.recordList;
              if (intakeData.isNotEmpty) {}
              update();
            } else {
              if (global.currentUserId != null) {
                global.showToast(
                  message: 'Fail to get get Intake data',
                );
              }
            }
          });
        }
      });
    } catch (e) {
      print('Exception in getFormIntakeData():' + e.toString());
    }
  }

  rejectDialog() {
    showDialog(
        context: Get.context!,
        // barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            content: SizedBox(
              height: 150,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: const Text(
                      "Call Rejected!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).tr(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: const Text(
                      "The call was declined/cancelled by the user. Please decline the call.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ).tr(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                          child: const Text(
                            "Ok",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ).tr(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding:
                const EdgeInsets.only(bottom: 15, left: 15, right: 15),
          );
        });
  }
}
