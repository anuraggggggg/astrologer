// ignore_for_file: file_names, avoid_print, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'package:astrowaypartner/controllers/HomeController/home_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart'; // ✅ Added import

import '../models/systemFlagModel.dart';
import '../models/user_model.dart';
import '../services/apiHelper.dart';
import '../views/Authentication/login_screen.dart';
import '../views/HomeScreen/home_screen.dart';
import 'HomeController/call_controller.dart';
import 'HomeController/chat_controller.dart';
import 'HomeController/live_astrologer_controller.dart';
import 'HomeController/report_controller.dart';
import 'following_controller.dart';
import 'networkController.dart';

class SplashController extends GetxController {
  /// ✅ Set this to TRUE during testing to skip API calls
  final bool skipApiCalls = true;

  final networkController = Get.put(NetworkController());
  final chatController = Get.find<ChatController>();
  final callController = Get.find<CallController>();
  final reportController = Get.put(ReportController());
  final followingController = Get.put(FollowingController());
  final liveAstrologerController = Get.put(LiveAstrologerController());
  final homecontroller = Get.find<HomeController>();
  final walletController = Get.find<WalletController>();
  final apiHelper = APIHelper();

  String? appShareLinkForLiveSreaming;
  CurrentUser? currentUser;

  var systemFlag = <SystemFlag>[];
  RxBool isDataLoaded = false.obs;
  String? version;
  String currentLanguageCode = 'en';

  @override
  void onInit() async {
    super.onInit();

    ever(networkController.connectionStatus, (status) {
      debugPrint('Network status: $status');
      if (status > 0) {
        _init();
      } else {
        debugPrint('No Internet connection');
        Get.snackbar(
          "Warning",
          "No Internet Connection",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(Get.context!).primaryColor,
          colorText: Colors.white,
          duration: const Duration(days: 1),
          messageText: Row(
            children: [
              const Icon(Icons.signal_wifi_off, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(
                child: Text("No Internet Available"),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white),
                  height: 30,
                  width: 55,
                  child: Center(
                    child: Text(
                      "Retry",
                      style:
                          TextStyle(color: Theme.of(Get.context!).primaryColor),
                    ).tr(),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  // 🚀 Initialization function called when the app starts
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final astroId = prefs.getString("astro_id");

    /// ✅ Check if user already logged in
    if (token != null && astroId != null) {
      Get.off(() => const HomeScreen(), routeName: "HomeScreen");
    } else {
      Get.off(() => const LoginScreen(), routeName: "LoginScreen");
    }

    /// ✅ Normal API flow
    try {
      await global.checkBody().then((networkResult) async {
        if (networkResult) {
          if (networkController.connectionStatus.value != 0) {
            await performApiCalls();
          } else {
            global.showToast(message: "No Network Available");
          }
        } else {
          global.showToast(message: "No Network Available");
        }
      });
    } catch (err) {
      global.printException("SplashController", "_init", err);
    }

    // 🔥 Auto-register FCM token
    await _registerFcmToken();
  }

  /// ✅ Auto-register FCM token and save locally
  Future<void> _registerFcmToken() async {
    try {
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("📲 Current FCM Token: $fcmToken");
        await FastApiServices().autoRegisterAstrologerFcmToken(fcmToken);

        // 🔁 Also listen for future token refresh events (reinstall, update, etc.)
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          print("🔁 Firebase token refreshed: $newToken");
          await FastApiServices().autoRegisterAstrologerFcmToken(newToken);
        });
      } else {
        print("⚠️ No FCM token received from Firebase.");
      }
    } catch (e, st) {
      print("🔥 Error while registering FCM token: $e");
      print(st);
    }
  }

  Future<void> getSystemList() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getSystemFlag().then((result) {
            if (result.status == "200") {
              systemFlag = result.recordList;
              update();
            } else {
              if (global.currentUserId != null) {
                global.showToast(message: "System flag not found");
              }
            }
          });
        }
      });
    } catch (e) {
      print('Exception in getSystemList():$e');
    }
  }

  Future<void> performApiCalls() async {
    if (skipApiCalls) return;

    await apiHelper.getMasterTableData().then(
      (apiResult) async {
        if (apiResult.status == "200") {
          await global.getDeviceData();
          await getSystemList();
          global.appName =
              global.getSystemFlagValue(global.systemFlagNameList.appName);

          global.spLanguage = await SharedPreferences.getInstance();
          currentLanguageCode =
              global.spLanguage!.getString('currentLanguage') ?? 'en';
          update();

          global.getMasterTableDataModelList = apiResult.recordList;
          global.astrologerCategoryModelList =
              global.getMasterTableDataModelList.astrologerCategory;
          global.skillModelList = global.getMasterTableDataModelList.skill;
          global.allSkillModelList =
              global.getMasterTableDataModelList.allskill;
          global.languageModelList =
              global.getMasterTableDataModelList.language;
          global.assistantPrimarySkillModelList =
              global.getMasterTableDataModelList.assistantPrimarySkill;
          global.assistantAllSkillModelList =
              global.getMasterTableDataModelList.assistantAllSkill;
          global.assistantLanguageModelList =
              global.getMasterTableDataModelList.assistantLanguage;
          global.mainSourceBusinessModelList =
              global.getMasterTableDataModelList.mainSourceBusiness;
          global.highestQualificationModelList =
              global.getMasterTableDataModelList.highestQualification;
          global.degreeDiplomaList =
              global.getMasterTableDataModelList.qualifications;
          global.jobWorkingList = global.getMasterTableDataModelList.jobs;
        }
      },
    );

    global.sp = await SharedPreferences.getInstance();
    log('SharedPrefs currentUser: ${global.sp!.getString("currentUser")}');

    if (global.sp!.getString("currentUser") != null) {
      await apiHelper.validateSession().then((result) async {
        if (result.status == "200") {
          global.user = result.recordList;
          global.user.token = global.user.sessionToken!.split(" ")[1];
          await global.sp!
              .setString('currentUser', json.encode(global.user.toJson()));

          if (global.user.id != null) {
            global.showOnlyLoaderDialog();
            await global.getCurrentUserId();
            chatController.chatList.clear();
            callController.callList.clear();
            reportController.reportList.clear();
            followingController.followerList.clear();

            global.hideLoader();
            getInitialMsg();

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await Future.delayed(const Duration(seconds: 2));
              _loadSavedData();
            });
          } else {
            Get.off(() => const LoginScreen(), routeName: "LoginScreen");
          }
        } else {
          Get.off(() => const LoginScreen(), routeName: "LoginScreen");
        }
      });
    } else {
      Get.off(() => const LoginScreen(), routeName: "LoginScreen");
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isAcceptedCall = prefs.getBool('is_accepted');
    if (isAcceptedCall == true) {
      String? dataAccepted = prefs.getString('is_accepted_data');
      if (dataAccepted != null && dataAccepted.isNotEmpty) {
        await prefs.setBool('is_accepted', false);
        callAccept(jsonDecode(dataAccepted));
        await prefs.setString('is_accepted_data', '');
      }
    } else {
      await prefs.setBool('is_accepted', false);
      await prefs.setString('is_accepted_data', '');
    }

    bool? isRejectedCall = prefs.getBool('is_rejected');
    if (isRejectedCall == true) {
      await prefs.setBool('is_accepted', false);
      await prefs.setString('is_accepted_data', '');
    }
  }

  void getInitialMsg() async {
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null && message.data.isNotEmpty) {
        try {
          var messageData = json.decode((message.data['body']));
          if (messageData["notificationType"] == 2) {
            await walletController.getAmountList();
            walletController.update();
            callController.callList.clear();
            await callController.getCallList(false);
            homecontroller.homeTabIndex = 1;
            homecontroller.isSelectedBottomIcon = 1;
            homecontroller.tabController?.animateTo(1);
            homecontroller.update();
            Get.offAll(const HomeScreen());
          } else {
            Get.offAll(const HomeScreen());
          }
        } catch (_) {
          Get.offAll(const HomeScreen());
        }
      } else {
        Get.offAll(const HomeScreen());
      }
    });
  }
}

@pragma('vm:entry-point')
void callAccept(Map<String, dynamic> extraData) async {
  final callController = Get.find<CallController>();
  if (extraData["notificationType"] == 2) {
    callController.callList.clear();
    await callController.getCallList(false);
    if (extraData['call_type'] == 10) {
      callController.acceptCallRequest(
        extraData['callId'],
        extraData['profile'],
        extraData['name'],
        extraData['id'],
        extraData['fcmToken'],
        extraData['call_duration'].toString(),
      );
    } else if (extraData['call_type'] == 11) {
      callController.acceptVideoCallRequest(
        extraData['callId'],
        extraData['profile'],
        extraData['name'],
        extraData['id'],
        extraData['fcmToken'],
        extraData['call_duration'].toString(),
      );
    }
  }
}
