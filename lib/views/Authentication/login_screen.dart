// ignore_for_file: must_be_immutable, prefer_const_constructors, avoid_print

import 'dart:developer';
import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/constants/imageConst.dart';
import 'package:astrowaypartner/controllers/Authentication/login_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/login_otp_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/models/time_availability_model.dart';
import 'package:astrowaypartner/models/week_model.dart';
import 'package:astrowaypartner/views/Authentication/signup_screen.dart';
import 'package:astrowaypartner/views/FastApi/signUp.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/Setting/privacy_policy_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/Setting/term_and_condition_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sizer/sizer.dart';

final initialPhone = PhoneNumber(isoCode: "IN");

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final signupController = Get.put(SignupController());
  final loginController = Get.put(LoginController());
  final loginOtpController = Get.put(LoginOtpController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // global.warningDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        Get.back();
        SystemNavigator.pop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: 100.w,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 10.h,
                      backgroundImage:
                          AssetImage('assets/images/astrologer_splash.jpeg'),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      global.appName,
                      style: Get.textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                // color: COLORS().primaryColor,
                color: COLORS().primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      _buildphoneNumberWidget(loginOtpController),

                      /// ✅ SEND OTP BUTTON (Custom OTP API)
                      GestureDetector(
                        onTap: () {
                          bool isValid = loginOtpController.validedPhone();
                          if (isValid) {
                            String phoneNumber =
                                loginOtpController.cMobileNumber.text;
                            String countryCode = loginOtpController.countryCode;

                            loginController.sendOtpToPhone(
                                phoneNumber, countryCode);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Invalid Number"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                          child: Container(
                            height: 48,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SEND_OTP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                  ),
                                ).tr(),
                                SizedBox(width: 10),
                                Image.asset(
                                  IMAGECONST.arrowLeft,
                                  color: Colors.white,
                                  width: 7.w,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      /// 🔥 REMOVED: WhatsApp & Gmail Social Login UI

                      GetBuilder<LoginController>(builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: '${loginController.signupText} ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleMedium,
                              children: [
                                TextSpan(
                                  text: loginController.termsConditionText,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 11,
                                    color: Colors.blue,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => TermAndConditionScreen());
                                    },
                                ),
                                TextSpan(
                                  text: ' ${loginController.andText} ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                  ),
                                ),
                                TextSpan(
                                  text: loginController.privacyPolicyText,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 9.sp,
                                    color: Colors.blue,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => PrivacyPolicyScreen());
                                    },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ]),

                    /// SIGN UP BUTTON
                    InkWell(
                      onTap: () {
                        signupController.week = [];
                        for (var day in [
                          "Sunday",
                          "Monday",
                          "Tuesday",
                          "Wednesday",
                          "Thursday",
                          "Friday",
                          "Saturday"
                        ]) {
                          signupController.week!.add(Week(
                              day: day,
                              timeAvailabilityList: [
                                TimeAvailabilityModel(fromTime: "", toTime: "")
                              ]));
                        }
                        signupController.clearAstrologer();
                        // Get.to(() => SignupScreen(), routeName: "Signup Screen");
                        Get.to(() => AstrologerSignupPage(),
                            routeName: "Signup Screen");
                      },
                      child: GetBuilder<LoginController>(
                        builder: (_) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.0, left: 2),
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  text: loginController.notaAccountText,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleMedium,
                                  children: [
                                    TextSpan(
                                      text: " ${tr("signUp")}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// PHONE INPUT WIDGET
  Container _buildphoneNumberWidget(LoginOtpController loginController) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Theme(
          data: ThemeData(
            dialogTheme: DialogTheme(
              contentTextStyle: TextStyle(color: Colors.white),
              backgroundColor: Colors.grey[800],
              surfaceTintColor: Colors.grey[800],
            ),
          ),
          child: InternationalPhoneNumberInput(
            spaceBetweenSelectorAndTextField: 0,
            maxLength: 10,
            scrollPadding: EdgeInsets.zero,
            textFieldController: loginController.cMobileNumber,
            inputDecoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Phone number',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onInputValidated: (bool value) {
              // No need to set countryCode here
              // You already handle countryCode in `onInputChanged` and `onSaved`
              loginController.update();
            },
            selectorConfig: SelectorConfig(
              trailingSpace: false,
              leadingPadding: 2,
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle: TextStyle(color: Colors.black),
            searchBoxDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(2.w)),
              ),
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.black),
            ),
            initialValue: initialPhone,
            formatInput: false,
            keyboardType:
                TextInputType.numberWithOptions(signed: true, decimal: false),
            inputBorder: InputBorder.none,
            onSaved: (PhoneNumber number) {
              loginController.updateCountryCode(number.dialCode);
              loginOtpController.update();
            },
            onInputChanged: (PhoneNumber number) {
              loginController.updateCountryCode(number.dialCode);
              loginOtpController.update();
            },
            onSubmit: () {},
          ),
        ),
      ),
    );
  }
}
