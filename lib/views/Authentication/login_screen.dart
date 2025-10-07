// ignore_for_file: must_be_immutable, prefer_const_constructors, avoid_print

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/Authentication/login_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/login_otp_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/Provider/loginProvider.dart';
import 'package:astrowaypartner/models/time_availability_model.dart';
import 'package:astrowaypartner/models/week_model.dart';
import 'package:astrowaypartner/views/Authentication/OtpScreens/login_otp_screen.dart';
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
import 'package:provider/provider.dart';

final initialPhone = PhoneNumber(isoCode: "IN", phoneNumber: '');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final signupController = Get.put(SignupController());
  final loginController = Get.put(LoginController());
  final loginOtpController = Get.put(LoginOtpController());
  final _formKey = GlobalKey<FormState>();

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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                COLORS().primaryColor.withOpacity(0.1),
                COLORS().primaryColor.withOpacity(0.3),
              ],
            ),
          ),
          child: Column(
            children: [
              /// TOP SECTION
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 10.h,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('assets/images/astrologer_splash.jpeg'),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      global.appName,
                      style: Get.textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: COLORS().primaryColor,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              /// LOGIN FORM
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, -5),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Column(
                          children: [
                            SizedBox(height: 3.h),
                            Text(
                              'Login to continue',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2.h),

                            /// PHONE NUMBER FIELD
                            Form(
                              key: _formKey,
                              child:
                                  _buildPhoneNumberWidget(loginOtpController),
                            ),
                            SizedBox(height: 2.h),

                            /// SEND OTP BUTTON
                            GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  final authProvider =
                                      Provider.of<AuthProvider>(context,
                                          listen: false);

                                  String phoneNumber = loginOtpController
                                      .cMobileNumber.text
                                      .trim();
                                  String countryCode =
                                      loginOtpController.countryCode;

                                  bool success = await authProvider.requestOtp(
                                    contactNo: phoneNumber,
                                    countryCode: countryCode,
                                  );

                                  // Remove any old snackbars first
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar();

                                  // Show success or failure message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? "OTP sent successfully"
                                          : authProvider.errorMessage ??
                                              "Failed to send OTP"),
                                      backgroundColor:
                                          success ? Colors.green : Colors.red,
                                    ),
                                  );

                                  // Navigate to OTP screen if successful
                                  if (success) {
                                    // Use Future.microtask or WidgetsBinding to avoid context issues
                                    Future.microtask(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginOtpScreen(
                                            mobileNumber: phoneNumber,
                                            countryCode: countryCode,
                                          ),
                                        ),
                                      );
                                    });
                                  }
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 2.w),
                                height: 6.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      COLORS().primaryColor,
                                      COLORS().primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Consumer<AuthProvider>(
                                    builder: (_, authProvider, __) {
                                      return authProvider.isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'SEND_OTP',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ).tr(),
                                                const SizedBox(width: 10),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                  size: 18.sp,
                                                ),
                                              ],
                                            );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 3.h),
                          ],
                        ),
                      ),

                      /// SIGN UP FOOTER
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: InkWell(
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
                              signupController.week!.add(
                                Week(day: day, timeAvailabilityList: [
                                  TimeAvailabilityModel(
                                      fromTime: "", toTime: "")
                                ]),
                              );
                            }
                            signupController.clearAstrologer();
                            Get.to(() => AstrologerSignupPage(),
                                routeName: "Signup Screen");
                          },
                          child: GetBuilder<LoginController>(builder: (_) {
                            return Center(
                              child: RichText(
                                text: TextSpan(
                                  text: loginController.notaAccountText,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 11.sp),
                                  children: [
                                    TextSpan(
                                      text: " ${tr("signUp")}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: COLORS().primaryColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// PHONE NUMBER WIDGET
  Container _buildPhoneNumberWidget(LoginOtpController loginController) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: InternationalPhoneNumberInput(
        maxLength: 10,
        textFieldController: loginController.cMobileNumber,
        initialValue: initialPhone,
        formatInput: false,
        autoValidateMode: AutovalidateMode.onUserInteraction,
        autofillHints: [], // disables autofill
        inputDecoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter your phone number',
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 10, right: 5),
            child: Icon(
              Icons.phone_android,
              color: COLORS().primaryColor,
            ),
          ),
        ),
        selectorConfig: SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          setSelectorButtonAsPrefixIcon: true,
        ),
        onInputChanged: (PhoneNumber number) {
          loginController.updateCountryCode(number.dialCode);
        },
        onSaved: (PhoneNumber number) {
          loginController.updateCountryCode(number.dialCode);
        },
        validator: (value) {
          if (value == null || value.isEmpty)
            return 'Please enter your phone number';
          if (value.length < 10) return 'Please enter a valid phone number';
          return null;
        },
        keyboardType: TextInputType.number,
      ),
    );
  }
}
