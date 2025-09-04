// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/HomeController/home_controller.dart';
import '../../../controllers/splashController.dart';

void showLanguageBottomSheet(
    BuildContext context, HomeController homeController) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16.0),
        child: GetBuilder<HomeController>(
          builder: (homeController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ),
                Text(
                  'Choose your app language',
                  style: Get.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ).tr(),
                Expanded(
                  child: ListView.builder(
                    itemCount: homeController.lan.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          homeController.updateLan(index);
                          Get.back();
                          Future.delayed(const Duration(milliseconds: 100),
                              () async {
                            await updateLocale(index, homeController, context);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    homeController.lan[index].isSelected
                                        ? Get.theme.primaryColor
                                        : Colors.grey,
                                    homeController.lan[index].isSelected
                                        ? Get.theme.primaryColor
                                            .withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [0.0, 1.0],
                                  tileMode: TileMode.clamp),
                              color: homeController.lan[index].isSelected
                                  ? Get.theme.primaryColor.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: index,
                                groupValue: homeController.selectedIndex,
                                onChanged: (value) {
                                  homeController.updateLan(index);
                                  Get.back();
                                  Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () async {
                                    await updateLocale(
                                        index, homeController, context);
                                  });
                                },
                                activeColor: Get.theme.primaryColor,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      homeController.lan[index].title,
                                      style: Get.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      homeController.lan[index].subTitle,
                                      style: Get.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                "assets/images/languageimg.png",
                                color: homeController.lan[index].isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                width: 90,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Future<void> updateLocale(
    int index, HomeController homeController, BuildContext context) async {
  Locale newLocale;
  switch (index) {
    case 0:
      newLocale = const Locale('en', 'US'); // ENGLISH
      break;
    case 1:
      newLocale = const Locale('gu', 'IN'); // GUJARATI
      break;
    case 2:
      newLocale = const Locale('hi', 'IN'); // HINDI
      break;
    case 3:
      newLocale = const Locale('es', 'ES'); // SPANISH
      break;
    case 4:
      newLocale = const Locale('mr', 'IN'); // MARATHI
      break;
    case 5:
      newLocale = const Locale('sa', 'IN'); // SANSKRIT
      break;
    case 6:
      newLocale = const Locale('bn', 'IN'); // BENGALI
      break;
    case 7:
      newLocale = const Locale('kn', 'IN'); // KANNADA
      break;
    case 8:
      newLocale = const Locale('ml', 'IN'); // MALAYALAM
      break;
    case 9:
      newLocale = const Locale('ta', 'IN'); // TAMIL
      break;
    case 10:
      newLocale = const Locale('te', 'IN'); // TELUGU
      break;
    default:
      newLocale = const Locale('en', 'US'); // Default to English
  }

  context.setLocale(newLocale);
  Get.updateLocale(newLocale);

  // Await the async refreshIt function
  await refreshIt(homeController);
}

Future<void> refreshIt(HomeController homeController) async {
  final splashController = Get.find<SplashController>();
  splashController.currentLanguageCode =
      homeController.lan[homeController.selectedIndex].lanCode;
  splashController.update();
  global.spLanguage = await SharedPreferences.getInstance();
  await global.spLanguage!
      .setString('currentLanguage', splashController.currentLanguageCode);
  log('language code is  :- ${global.spLanguage}');
  homeController.update();
  // Get.back();
}
