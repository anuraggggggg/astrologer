// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../../models/device_detail_model.dart';
import '../../services/apiHelper.dart';
import '../../views/Authentication/OtpScreens/login_otp_screen.dart';
import '../../views/Authentication/login_screen.dart';
import '../../views/HomeScreen/home_screen.dart';
import '../HomeController/call_controller.dart';
import '../HomeController/chat_controller.dart';
import '../HomeController/live_astrologer_controller.dart';
import '../HomeController/report_controller.dart';
import '../following_controller.dart';
import 'login_otp_controller.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  String screen = 'login_controller.dart';
  APIHelper apiHelper = APIHelper();

  ChatController chatController = Get.find<ChatController>();
  CallController callController = Get.find<CallController>();
  ReportController reportController = Get.find<ReportController>();
  FollowingController followingController = Get.find<FollowingController>();
  final liveAstrologerController = Get.find<LiveAstrologerController>();
  final loginOtpController = Get.put(LoginOtpController());

  String signupText = tr('By signin up you agree to our');
  String termsConditionText = tr('Terms of Services');
  String andText = tr('and');
  String privacyPolicyText = tr('Privacy Policy');
  String notaAccountText = tr("Don't have an account?");

  Map<String, dynamic>? dataResponse;

  String? sentOtp;

  @override
  void onInit() {
    super.onInit();
    signupText = tr('By signin up you agree to our');
    termsConditionText = tr('Terms of Services');
    andText = tr('and');
    privacyPolicyText = tr('Privacy Policy');
    notaAccountText = tr("Don't have an account?");
  }

  String generateOtp() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<void> sendOtpToPhone(String phoneNumber, String countryCode) async {
    final onlyDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (onlyDigits.length != 10) {
      global.showToast(message: "Enter a valid 10-digit phone number");
      return;
    }

    final otp = generateOtp(); // OTP generation logic
    sentOtp = otp;

    final message =
        "Your OTP for mobile application jyotishionline login is $otp jyotishi online";

    final url =
        "http://sms.messageindia.in/v2/sendSMS?username=sameerji&message=$message&sendername=JYTSHI&smstype=TRANS&numbers=$onlyDigits&apikey=242d4043-4734-4ae8-acb6-bcbb5b855bcc&peid=1701175032658751812&templateid=1707175048832142304";

    try {
      // Print debug info
      print('📲 Sending OTP to: $countryCode $onlyDigits');
      print('🔐 Generated OTP: $otp');
      print('📨 Message: $message');
      print('🌐 API URL: $url');

      global.showOnlyLoaderDialog();
      final response = await http.get(Uri.parse(url));
      global.hideLoader();

      final body = jsonDecode(response.body);

      // Log API response
      print('✅ API Response Body: $body');

      if (response.statusCode == 200 &&
          body is List &&
          body[0]['status'] == 'success') {
        print('🎉 OTP sent successfully to $onlyDigits');
        Get.to(() => LoginOtpScreen(
          mobileNumber: onlyDigits,
          countryCode: countryCode,
        ));
      } else {
        print('❌ Failed to send OTP - Status: ${body[0]['status']}');
        global.showToast(message: "Failed to send OTP. Try again.");
      }
    } catch (e) {
      global.hideLoader();
      print('❗ Exception while sending OTP: $e');
      global.showToast(message: "Network error while sending OTP");
    }
  }


  Future<void> verifyOtp({
    required String inputOtp,
    required String phoneNumber,
    required String countryCode,
  }) async {
    if (inputOtp == sentOtp) {
      await loginAstrologer(phoneNumber: phoneNumber);
    } else {
      global.showToast(message: "Invalid OTP");
    }
  }

  Future loginAstrologer({String? phoneNumber, String? email}) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          global.showOnlyLoaderDialog();
          await global.getDeviceData();

          DeviceInfoLoginModel deviceInfoLoginModel = DeviceInfoLoginModel(
            appId: "2",
            appVersion: global.appVersion,
            deviceId: global.deviceId,
            deviceManufacturer: global.deviceManufacturer,
            deviceModel: global.deviceModel,
            fcmToken: global.fcmToken,
            deviceLocation: "",
          );

          final response = await apiHelper.login(
            phoneNumber,
            email,
            deviceInfoLoginModel,
          );

          global.hideLoader();

          if (response.status == "200") {
            global.user = response.recordList;
            await global.sp!
                .setString('currentUser', json.encode(global.user.toJson()));

            await global.getCurrentUserId();
            await chatController.getChatList(false);
            await callController.getCallList(true);
            await reportController.getReportList(false);
            await followingController.followingList(false);

            Get.to(() => const HomeScreen());
          } else {
            global.showToast(message: response.message.toString());
            Get.offAll(() => const LoginScreen());
          }
        } else {
          global.showToast(message: 'No internet connection');
        }
      });
    } catch (e) {
      global.hideLoader();
      print("Login error: $e");
      global.showToast(message: "Something went wrong. Please try again.");
    }
  }
}