// ignore_for_file: must_be_immutable, prefer_const_constructors, avoid_print

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/Authentication/login_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/login_otp_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/Provider/loginProvider.dart';
import 'package:astrowaypartner/views/Authentication/OtpScreens/login_otp_screen.dart';
import 'package:astrowaypartner/views/FastApi/signUp.dart';
import 'package:easy_localization/easy_localization.dart';
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
        SystemNavigator.pop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 🔥 IMPORTANT
        body: Stack(
          children: [
            /// BACKGROUND
            Container(
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
            ),

            /// CONTENT
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    /// TOP SECTION
                    SizedBox(
                      height: 40.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/astrologer_splash.jpeg',
                              width: 23.h,
                              height: 23.h,
                              fit: BoxFit.contain,
                            ),
                          ),

                          // SizedBox(height: 1.h),
                          Text(
                            global.appName,
                            style: Get.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: COLORS().primaryColor,
                            ),
                          ),
                          // SizedBox(height: 1.h),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// LOGIN FORM
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 3.h),
                          Text(
                            'Login to continue',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),

                          /// PHONE FIELD
                          Form(
                            key: _formKey,
                            child:
                            _buildPhoneNumberWidget(loginOtpController),
                          ),

                          SizedBox(height: 2.h),

                          /// SEND OTP BUTTON
                          _sendOtpButton(),

                          SizedBox(height: 3.h),
                          Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),



                          /// SIGN UP
                          InkWell(
                            onTap: () {
                              signupController.clearAstrologer();
                              Get.to(() => AstrologerSignupPage());
                            },
                            child: RichText(
                              text: TextSpan(
                                text: loginController.notaAccountText,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                                children: [

                                  TextSpan(
                                    text: " ${tr("Sign Up")}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: COLORS().primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SEND OTP BUTTON
  Widget _sendOtpButton() {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();

        final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

        if (authProvider.isLoading) return;

        if (_formKey.currentState!.validate()) {
          final phone =
          loginOtpController.cMobileNumber.text.trim();
          final code = loginOtpController.countryCode;

          final success = await authProvider.requestOtp(
            contactNo: phone,
            countryCode: code,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? "OTP sent successfully"
                      : authProvider.errorMessage ??
                      "Failed to send OTP",
                ),
                backgroundColor:
                success ? Colors.green : Colors.red,
              ),
            );

          if (success) {
            Get.to(
                  () => LoginOtpScreen(
                mobileNumber: phone,
                countryCode: code,
              ),
            );
          }
        }
      },
      child: Container(
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
            builder: (_, auth, __) {
              return auth.isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SEND_OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ).tr(),
                  SizedBox(width: 10),
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
    );
  }

  /// PHONE INPUT
  Widget _buildPhoneNumberWidget(LoginOtpController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
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
        textFieldController: controller.cMobileNumber,
        initialValue: initialPhone,
        formatInput: false,
        autoValidateMode: AutovalidateMode.onUserInteraction,
        inputDecoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter your phone number',
          contentPadding:
          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          prefixIcon: Icon(
            Icons.phone_android,
            color: COLORS().primaryColor,
          ),
        ),
        selectorConfig: SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          setSelectorButtonAsPrefixIcon: true,
        ),
        onInputChanged: (PhoneNumber number) {
          controller.updateCountryCode(number.dialCode);
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your phone number';
          }
          if (value.length < 10) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
        keyboardType: TextInputType.number,
      ),
    );
  }
}
