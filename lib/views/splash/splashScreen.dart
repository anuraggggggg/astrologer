// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/Provider/splashProvider.dart';
import 'package:astrowaypartner/views/Authentication/login_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import '../BaseRoute/baseRoute.dart';

class SplashScreen extends BaseRoute {
   SplashScreen({super.key, a, o});

  @override
  Widget build(BuildContext context) {
    // Provide NewSplashProvider to this screen
    return ChangeNotifierProvider<NewSplashProvider>(
      create: (_) => NewSplashProvider(),
      child: Consumer<NewSplashProvider>(
        builder: (context, provider, _) {
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
                      radius: 16.h,
                      backgroundImage: const AssetImage(
                          'assets/images/astrologer_splash.jpeg'),
                    ),
                    const SizedBox(height: 15),
                    global.appName != ""
                        ? Text(
                            global.appName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          )
                        : const SizedBox(),
                    const SizedBox(height: 20),
                    // Show loader if provider is loading
                    if (provider.isLoading)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
