import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/constants/imageConst.dart';
import 'package:astrowaypartner/constants/messageConst.dart';
import 'package:astrowaypartner/controllers/Authentication/login_controller.dart';
import 'package:astrowaypartner/views/Authentication/login_screen.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/config.dart';

class SuccessRegistrationScreen extends StatelessWidget {
  const SuccessRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          height: 80,
          appbarPadding: 0,
          backgroundColor: COLORS().primaryColor,
          leading: IconButton(
            onPressed: () {
              Get.delete<LoginController>();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(IMAGECONST.thankYouImage),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 15, right: 15),
              child: Center(
                child: Text(
                  "Thank you for submitting your details with Us. Our team shall reach out to you for an interview within 5-7 business days if your profile gets shortlisted. For more info, write to us at BhavishyaAstro108@gmail.com",
                  style: Theme.of(context).primaryTextTheme.titleMedium,
                ).tr(args: [
                  contactsupportEmail,
                ]),
              ),
            )
          ],
        ),
        bottomNavigationBar: Container(
          height: 48,
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: COLORS().primaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextButton(
            onPressed: () {
              Get.delete<LoginController>();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false);
            },
            child: const Text(
              MessageConstants.LOGIN,
              style: TextStyle(color: Colors.black),
            ).tr(),
          ),
        ),
      ),
    );
  }
}
