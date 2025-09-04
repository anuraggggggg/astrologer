//ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../services/apiHelper.dart';
import 'signup_controller.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

class SignupOtpController extends GetxController {
  String screen = 'signup_otp_controller.dart';

  final signupController = Get.find<SignupController>();
  double second = 0;
  int maxSecond = 60;
  Timer? time;
  APIHelper apiHelper = APIHelper();
  RxBool isLoading = false.obs;
  String countryCode = "+91";
  String? otpSent;

  timer() {
    maxSecond = 60;
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (maxSecond > 0) {
        maxSecond--;
        update();
      } else {
        time?.cancel();
      }
    });
  }

  updateCountryCode(String? value) {
    countryCode = value!;
    log('country code is \$countryCode');
    update();
  }

  Future<void> sendOtpToPhone(String phoneNumber, String countryCode) async {
    if (phoneNumber.length != 10) {
      global.showToast(message: "Enter a valid 10-digit phone number");
      return;
    }

    final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    otpSent = otp;

    final message = "Your OTP for mobile application jyotishionline login is \$otp jyotishi online";

    final url =
        "http://sms.messageindia.in/v2/sendSMS?username=sameerji&message=\$message&sendername=JYTSHI&smstype=TRANS&numbers=\$phoneNumber&apikey=242d4043-4734-4ae8-acb6-bcbb5b855bcc&peid=1701175032658751812&templateid=1707175048832142304";

    try {
      global.showOnlyLoaderDialog();
      final response = await http.get(Uri.parse(url));
      global.hideLoader();

      final responseBody = jsonDecode(response.body);

      if (responseBody != null &&
          responseBody is List &&
          responseBody.isNotEmpty &&
          responseBody[0]['status'] == 'success') {
        log("🎉 OTP sent successfully to \$phoneNumber");
      } else {
        global.showToast(message: "Failed to send OTP. Try again.");
      }
    } catch (e) {
      global.hideLoader();
      log("OTP Error: \$e");
      global.showToast(message: "Network error while sending OTP");
    }
  }
}
