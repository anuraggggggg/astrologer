// ignore_for_file: must_be_immutable, avoid_print, deprecated_member_use

import 'dart:developer';
// REMOVED: import 'dart:io'; // Not needed anymore as Otpless is removed

import 'package:astrowaypartner/constants/messageConst.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_otp_controller.dart';
// REMOVED: import 'package:astrowaypartner/utils/config.dart'; // Check if still needed, likely not for OTP flow.
// REMOVED: import 'package:astrowaypartner/views/Authentication/OtpScreens/login_otp_screen.dart'; // Not needed
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// REMOVED: import 'package:otpless_flutter/otpless_flutter.dart'; // REMOVED THIS IMPORT
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

// REMOVED: import '../../../services/apiHelper.dart'; // Only used for commented Otpless logic, can be removed if not directly used elsewhere
import '../signup_screen.dart'; // Ensure this path is correct if SignupScreen is still relevant here

// These are general constants, keep them as is.
const borderColor = Color.fromRGBO(114, 178, 238, 1);
const errorColor = Color.fromRGBO(255, 234, 238, 1);
const fillColor = Color.fromRGBO(222, 231, 240, .57);
final defaultPinTheme = PinTheme(
  width: 65,
  height: 65,
  textStyle: const TextStyle(
    fontSize: 18,
    color: Color.fromRGBO(30, 60, 87, 1),
  ),
  decoration: BoxDecoration(
    color: fillColor,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey[400]!, width: 0.7),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
  borderRadius: BorderRadius.circular(8),
);

// Removed global pinEditingControllersignup - now a local state variable

class SignupOtpScreen extends StatefulWidget {
  String? mobileNumber;
  // REMOVED: String? verificationId; // No longer used, can be removed from constructor

  SignupOtpScreen({
    super.key,
    this.mobileNumber,
    // REMOVED: this.verificationId,
  });

  @override
  State<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends State<SignupOtpScreen> {
  final signupController = Get.find<SignupController>();
  final signupOtpController = Get.find<SignupOtpController>();
  // REMOVED: String phoneOrEmail = '';
  // REMOVED: String otp = '';
  // REMOVED: bool isInitIos = false;
  // REMOVED: final otplessFlutterPlugin = Otpless();
  // REMOVED: APIHelper apihelper = APIHelper();

  // Correctly define and initialize pinEditingControllersignup and FocusNode as state variables
  late TextEditingController pinEditingControllersignup;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    pinEditingControllersignup = TextEditingController(); // Initialize here
    signupOtpController.timer(); // Ensure timer starts for resend logic
  }

  @override
  void dispose() {
    pinEditingControllersignup.dispose(); // Dispose the controller
    focusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  // --- REMOVED ALL OTOLESS-RELATED FUNCTIONS ---
  // Future<void> verfiyHeadlesswithOtp(...) {}
  // void onHeadlessResultloginotp(...) {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: MyCustomAppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            ),
          ),
          height: 80,
          elevation: 0.5,
          appbarPadding: 0,
          title: const Text(
            MessageConstants.VERIFY_PHONE,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w300, fontSize: 19),
          ).tr(),
          backgroundColor: Colors.grey[100],
        ),
        body: Center(
          child: SizedBox(
            width: Get.width - Get.width * 0.1,
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                  Text(
                    'OTP Send to',
                    style: TextStyle(color: Colors.green, fontSize: 11.sp),
                  ).tr(args: [
                    signupOtpController.countryCode.toString(),
                    widget.mobileNumber.toString()
                  ]),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 6.h,
                    width: 90.w,
                    child: Pinput(
                      controller: pinEditingControllersignup, // Use instance controller
                      focusNode: focusNode,
                      defaultPinTheme: defaultPinTheme,
                      length: 6,
                      separatorBuilder: (index) => const SizedBox(width: 8),
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      onCompleted: (pin) {
                        // Directly verify OTP here, or set it to controller
                        // and let the button handle verification
                        log('OTP entered: $pin');
                      },
                      onChanged: (pin) {
                        // This updates `smsCode` in SignupController
                        // but verification happens on button press.
                        signupController.smsCode = pin; // Ensure smsCode is updated
                        signupController.update(); // Update relevant GetX listener
                        log('smscode from Pinput onChanged: ${signupController.smsCode}');
                      },
                      cursor: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 2,
                            height: 3.h,
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                      focusedPinTheme: focusedPinTheme,
                      errorPinTheme: defaultPinTheme.copyBorderWith(
                        border: Border.all(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        log('Verifying OTP: phone no is ${widget.mobileNumber} and country code is ${signupOtpController.countryCode} and otp is ${pinEditingControllersignup.text}');

                        // Call the verifySignupOtp method from SignupController
                        await signupController.verifySignupOtp(
                          pinEditingControllersignup.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side:
                          const BorderSide(width: 0.5, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: Get.theme.primaryColor,
                        textStyle:
                        const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      child: const Text(
                        MessageConstants.VERIFY_OTP,
                        style: TextStyle(color: Colors.black),
                      ).tr(),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GetBuilder<SignupOtpController>(builder: (c) {
                    return SizedBox(
                        child: signupOtpController.maxSecond != 0
                            ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Resend OTP Available in',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500),
                            ).tr(args: [
                              signupOtpController.maxSecond.toString()
                            ])
                          ],
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resend OTP Available',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500),
                            ).tr(),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    // Reset timer
                                    signupOtpController.maxSecond = 60;
                                    signupOtpController.second = 0;
                                    signupOtpController.timer();
                                    signupOtpController.update();

                                    log('Resend otp clicked mobile no is ${widget.mobileNumber} and country code is ${signupOtpController.countryCode}');

                                    // Call resendOtpForSignup from SignupController
                                    await signupController.resendOtpForSignup(
                                      widget.mobileNumber!,
                                      signupOtpController.countryCode,
                                    );
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                    ),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.only(
                                            left: 25, right: 25)),
                                    backgroundColor:
                                    MaterialStateProperty.all(
                                        Get.theme.primaryColor),
                                    textStyle:
                                    MaterialStateProperty.all(
                                        const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black)),
                                  ),
                                  child: const Text(
                                    'Resend OTP on SMS',
                                    style: TextStyle(color: Colors.black),
                                  ).tr(),
                                ),
                              ],
                            )
                          ],
                        ));
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}