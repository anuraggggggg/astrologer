// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/apiHelper.dart';
import '../../utils/global.dart' as global;
import '../Authentication/signup_controller.dart';
import '../Authentication/login_controller.dart';

class LoginOtpController extends GetxController {
  SignupController signupController = Get.find<SignupController>();
  final TextEditingController cMobileNumber = TextEditingController();
  APIHelper apiHelper = APIHelper();

  String? phonenois;
  String? countrycodeis;
  String countryCode = "+91";
  String? sentOtp; // Store the OTP sent to the user
  String smsCode = ''; // OTP entered by user
  int maxSecond = 60;
  Timer? time;

  bool countryValidator = false;

  /// Updates the country code
  void updateCountryCode(String? value) {
    countryCode = value ?? "+91";
    log('Updated countryCode: $countryCode');
    update();
  }

  /// Starts the OTP resend countdown
  void timer() {
    maxSecond = 60;
    time?.cancel();
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (maxSecond > 0) {
        maxSecond--;
        update();
      } else {
        time?.cancel();
        update();
      }
    });
  }

  /// Validates the entered mobile number
  bool validedPhone() {
    String phone = cMobileNumber.text.trim();
    String onlyDigits = phone.replaceAll(RegExp(r'\D'), '');
    if (onlyDigits.length == 10) {
      countryValidator = true;
      return true;
    } else {
      countryValidator = false;
      return false;
    }
  }

  /// Store the OTP received from API
  void storeOtp(String otp) {
    sentOtp = otp;
    log("OTP stored: $otp");
   timer();
  }

  /// Compare user-entered OTP with stored OTP
  Future<void> verifyOtpWithManualCheck(BuildContext context) async {
    final loginController = Get.put(LoginController());
    final phone = phonenois ?? cMobileNumber.text.trim();

    log("Verifying OTP — entered: $smsCode | expected: $sentOtp");

    if (smsCode.trim() == sentOtp?.trim()) {
      global.showOnlyLoaderDialog();
      await loginController.loginAstrologer(phoneNumber: phone, email: '');
    } else {
      global.hideLoader();
      global.showToast(message: "Invalid OTP");
    }
  }

  @override
  void onClose() {
    time?.cancel();
    super.onClose();
  }
}
