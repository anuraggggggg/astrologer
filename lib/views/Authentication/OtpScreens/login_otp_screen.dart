import 'dart:developer';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:astrowaypartner/views/HomeScreen/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

import '../../../constants/messageConst.dart';
import '../../../widgets/app_bar_widget.dart';

const borderColor = Color.fromRGBO(114, 178, 238, 1);
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
    border: Border.all(color: Colors.grey, width: 0.7),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: borderColor),
  borderRadius: BorderRadius.circular(8),
);

class LoginOtpScreen extends StatefulWidget {
  final String mobileNumber;
  final String countryCode;

  const LoginOtpScreen({
    super.key,
    required this.mobileNumber,
    required this.countryCode,
  });

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  late TextEditingController pinEditingController;
  late FocusNode focusNode;
  final FastApiServices apiService = FastApiServices();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    pinEditingController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    pinEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = pinEditingController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 6-digit OTP"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await FastApiServices.verifyOtp(
        contactNo: widget.mobileNumber,
        countryCode: widget.countryCode,
        otp: otp,
      );

      log("✅ OTP Verified: $response");

      final token = response['access_token'];
      final userId = response['astro']?['id'];

      log("🔑 AccessToken: $token");
      log("👤 UserId: $userId");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP verified successfully"),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Navigate to home/dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      log("❌ OTP Verification Failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("OTP Verification Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: MyCustomAppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, size: 18.sp, color: Colors.black),
          ),
          height: 10.h,
          elevation: 0.5,
          appbarPadding: 0,
          title: Text(
            MessageConstants.VERIFY_PHONE,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: 14.sp,
            ),
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
                    'OTP sent to ${widget.countryCode}${widget.mobileNumber}',
                    style: TextStyle(color: Colors.green, fontSize: 11.sp),
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    height: 6.h,
                    width: 90.w,
                    child: Pinput(
                      controller: pinEditingController,
                      focusNode: focusNode,
                      defaultPinTheme: defaultPinTheme,
                      length: 6,
                      separatorBuilder: (index) => const SizedBox(width: 8),
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      onCompleted: (pin) {
                        log('OTP entered: $pin');
                      },
                    ),
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    width: 90.w,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              MessageConstants.SUBMIT_CAPITAL,
                              style: TextStyle(color: Colors.white),
                            ).tr(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
