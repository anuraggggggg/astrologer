// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/splashController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:astrowaypartner'
    '/utils/global.dart' as global;
import 'package:sizer/sizer.dart';
import '../BaseRoute/baseRoute.dart';

class SplashScreen extends BaseRoute {
  //a - analytics
  //o - observer
  SplashScreen({super.key, a, o});

  final customerController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 100.h,
        width: 100.w,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/images/splash_background.jpg"),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                //Get.theme.primaryColor,
                radius: 20.h,
                backgroundImage:
                    const AssetImage('assets/images/astrologer_splash.jpeg'),
              ),
              const SizedBox(
                height: 15,
              ),
              global.appName != ""
                  ? Text(
                      global.appName,
                      style: Get.textTheme.headlineSmall,
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
