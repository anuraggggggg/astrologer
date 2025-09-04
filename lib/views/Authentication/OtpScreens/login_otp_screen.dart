// ignore_for_file: must_be_immutable, avoid_print

import 'dart:developer';
// import 'dart:io'; // Not needed anymore as Otpless is removed

import 'package:astrowaypartner/services/apiHelper.dart'; // Still needed if APIHelper is used elsewhere, but not for direct Otpless calls here.
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

import '../../../constants/messageConst.dart';
import '../../../controllers/Authentication/login_controller.dart';
import '../../../controllers/Authentication/login_otp_controller.dart';
import '../../../controllers/Authentication/signup_controller.dart'; // If you're not using signupController, you can remove this too
// import '../../../utils/config.dart'; // Check if still needed, likely not for OTP flow.
import '../../../widgets/app_bar_widget.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../login_screen.dart';

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

// This global controller is problematic. It should be an instance variable in the state.
// final pinEditingController = TextEditingController(text: ''); // REMOVED GLOBAL

const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);

class LoginOtpScreen extends StatefulWidget {
  String? mobileNumber;
  // String? verificationId; // No longer used, can be removed from constructor
  String? countryCode;

  LoginOtpScreen({
    super.key,
    this.mobileNumber,
    // this.verificationId, // Removed
    this.countryCode,
  });

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final loginOtpController = Get.find<LoginOtpController>();
  final loginController = Get.find<LoginController>();
  // final signupController = Get.find<SignupController>(); // Not used, can remove
  // String phoneOrEmail = ''; // Not used, can remove
  // String otp = ''; // Not used, can remove
  // bool isInitIos = false; // Not needed after Otpless removal
  // APIHelper apihelper = APIHelper(); // Only used for commented Otpless logic, can be removed if not directly used elsewhere
  // bool? solidEnable = false; // Not used, can remove

  // Correctly define and initialize pinEditingController and FocusNode as state variables
  late TextEditingController pinEditingController;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    loginOtpController.timer();
    focusNode = FocusNode();
    pinEditingController = TextEditingController(); // Initialize here
  }

  @override
  void dispose() {
    pinEditingController.dispose(); // Dispose the controller
    focusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  // ALL OTOLESS-RELATED FUNCTIONS ARE REMOVED
  // Future<void> verfiyHeadlesswithOtp(...) {}
  // Future<void> startHeadlesswithOtp(...) {}
  // void onHeadlessResultloginotp(...) {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const LoginScreen());
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: MyCustomAppBar(
            leading: IconButton(
              onPressed: () {
                log('backpress to otpscreen');
                Get.offAll(() => const LoginScreen());
              },
              icon: Icon(
                Icons.arrow_back_ios,
                size: 18.sp,
                color: Colors.black,
              ),
            ),
            height: 10.h,
            elevation: 0.5,
            appbarPadding: 0,
            title: Text(
              MessageConstants.VERIFY_PHONE,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 14.sp),
            ).tr(),
            backgroundColor: Colors.grey[100],
          ),
          body: Center(
            child: SizedBox(
              width: 100.w,
              child: Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Column(
                  children: [
                    Text(
                      'OTP Send to',
                      style: TextStyle(color: Colors.green, fontSize: 11.sp),
                    ).tr(args: [
                      widget.countryCode.toString(),
                      widget.mobileNumber.toString()
                    ]),
                    SizedBox(
                      height: 3.h,
                    ),
                    SizedBox(
                      height: 6.h,
                      width: 90.w,
                      child: Pinput(
                        controller: pinEditingController, // Use instance controller
                        focusNode: focusNode,
                        defaultPinTheme: defaultPinTheme,
                        length: 6,
                        separatorBuilder: (index) => const SizedBox(width: 8),
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          // When OTP is completed, you can directly call verify here,
                          // or rely on the submit button.
                          loginOtpController.smsCode = pin;
                          loginOtpController.update();
                          log('smscode from Pinput onCompleted: ${loginOtpController.smsCode}');
                        },
                        onChanged: (pin) {
                          loginOtpController.smsCode = pin;
                          loginOtpController.update();
                          log('smscode from Pinput onChanged: ${loginOtpController.smsCode}');
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
                    SizedBox(
                      height: 5.h,
                    ),
                    SizedBox(
                      width: 90.w,
                      child: ElevatedButton(
                        onPressed: () async { // Make it async
                          // Removed global.showOnlyLoaderDialog() here
                          // because loginController.verifyOtp will handle it.

                          // Call verifyOtp from your LoginController
                          await loginController.verifyOtp(
                            inputOtp: pinEditingController.text, // Get the OTP from Pinput's controller
                            phoneNumber: widget.mobileNumber!,
                            countryCode: widget.countryCode!,
                          );
                          // The global.hideLoader() will be managed by loginController.verifyOtp
                          // upon completion of the loginAstrologer call, or if OTP is invalid.
                          // So, you don't need to explicitly call global.hideLoader() here.
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 0.5, color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Get.theme.primaryColor,
                          textStyle:
                          TextStyle(fontSize: 12.sp, color: Colors.black),
                        ),

                        // SUBMIT BUTTON
                        child: const Text(
                          MessageConstants.SUBMIT_CAPITAL,
                          style: TextStyle(color: Colors.black),
                        ).tr(),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    GetBuilder<LoginOtpController>(builder: (c) {
                      return loginOtpController.maxSecond != 0
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5.w),
                            child: Text(
                              'Resend OTP Available in',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp),
                            ).tr(args: [
                              loginOtpController.maxSecond.toString()
                            ]),
                          )
                        ],
                      )
                          : SizedBox(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 5.w),
                                  child: Text(
                                    'Resend OTP Available',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11.sp),
                                  ).tr(),
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: ElevatedButton(
                                        onPressed: () async { // Make it async
                                          String phoneNumber =
                                              widget.mobileNumber ?? ''; // Use widget.mobileNumber directly

                                          // global.showOnlyLoaderDialog(); // Removed from here
                                          //RESET TIMER
                                          loginOtpController.maxSecond = 0;
                                          loginOtpController.timer();

                                          if (phoneNumber.isNotEmpty) {
                                            await loginController.sendOtpToPhone(
                                              phoneNumber,
                                              widget.countryCode!, // Use widget.countryCode directly
                                            );
                                            // The global.hideLoader() will be managed by loginController.sendOtpToPhone
                                            // upon completion.
                                          } else {
                                            // global.hideLoader(); // Removed, handled by sendOtpToPhone
                                            global.showToast(
                                                message: tr(
                                                    'Please provide mobile number'));
                                          }
                                        },
                                        style: ButtonStyle(
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                          ),
                                          padding: WidgetStateProperty.all(
                                              const EdgeInsets.only(
                                                  left: 25, right: 25)),
                                          backgroundColor:
                                          WidgetStateProperty.all(
                                              Get.theme.primaryColor),
                                          textStyle: WidgetStateProperty.all(
                                              const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black)),
                                        ),
                                        child: Text(
                                          'Resend OTP on SMS',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 11.sp,
                                          ),
                                        ).tr(),
                                      ),
                                    ),
                                  ],
                                )
                              ]));
                    })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}