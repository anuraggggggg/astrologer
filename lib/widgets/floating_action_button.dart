import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/dailyHoroscopeController.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/AstroBlog/astrology_blog_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/DailyHoroscope/dailyHoroscopeScreen.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/kundliScreen.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/KundliMatching/kundli_matching_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:sizer/sizer.dart';

import '../controllers/HomeController/astrology_blog_controller.dart';
import '../views/HomeScreen/FloatingButton/DailyHoroscope/dailyHoroscopeVedic.dart';

class FloatingActionButtonWidget extends StatefulWidget {
  const FloatingActionButtonWidget({super.key});

  @override
  State<FloatingActionButtonWidget> createState() =>
      _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState extends State<FloatingActionButtonWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;

  // SplashController splashController = Get.find<SplashController>();
  DailyHoroscopeController dailyhoroscopeController =
      Get.find<DailyHoroscopeController>();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      controller: controller,
      closedBackgroundColor: Colors.transparent,
      closedForegroundColor: Colors.indigoAccent,
      openBackgroundColor: Colors.transparent,
      openForegroundColor: Colors.orange,
      labelsStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      labelsBackgroundColor: COLORS().primaryColor,
      speedDialChildren: <SpeedDialChild>[
        SpeedDialChild(
          child: CircleAvatar(
            radius: 20,
            backgroundColor: COLORS().primaryColor,
            child: CircleAvatar(
              radius: 19,
              backgroundColor: COLORS().primaryColor,
              child: Image.asset(
                'assets/images/daily_horoscope.png',
              ),
            ),
          ),
          label: tr('Daily Horoscope'),
          onPressed: () async {
            dailyhoroscopeController.selectZodic(0);
            await dailyhoroscopeController.getHoroscopeList(
                horoscopeId: global.hororscopeSignList[0].id);

            //! GOTO SCREEN VEDIC OR ASTRO
            debugPrint('calltype ${dailyhoroscopeController.calltype}');
            if (dailyhoroscopeController.calltype == 2) {
              Get.to(() => const DailyHoroscopeScreen());
            } else if (dailyhoroscopeController.calltype == 3) {
              Get.to(() => const DailyHoroscopeVedic());
            }
          },
          closeSpeedDialOnPressed: true,
        ),
        SpeedDialChild(
          child: CircleAvatar(
            radius: 20,
            backgroundColor: COLORS().primaryColor,
            child: CircleAvatar(
              radius: 19,
              backgroundColor: COLORS().primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset('assets/images/free_kundli.png'),
              ),
            ),
          ),
          label: tr('Free kundli'),
          onPressed: () async {
            Get.to(() => const KundaliScreen());
          },
          closeSpeedDialOnPressed: true,
        ),
        SpeedDialChild(
          child: CircleAvatar(
            radius: 20,
            backgroundColor: COLORS().primaryColor,
            child: CircleAvatar(
              radius: 19,
              backgroundColor: COLORS().primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset('assets/images/kundli_matching.png'),
              ),
            ),
          ),
          label: tr('Kundli Matching'),
          onPressed: () async {
            Get.to(() => KundliMatchingScreen());
          },
          closeSpeedDialOnPressed: true,
        ),
        SpeedDialChild(
          child: CircleAvatar(
            radius: 20,
            backgroundColor: COLORS().primaryColor,
            child: CircleAvatar(
              backgroundColor: COLORS().primaryColor,
              radius: 19,
              child: Image.asset('assets/images/astrology_blog.png'),
            ),
          ),
          label: tr('Astrology Blog'),
          onPressed: () async {
            AstrologyBlogController blogController =
                Get.find<AstrologyBlogController>();
            global.showOnlyLoaderDialog();
            blogController.astrologyBlogs = [];
            blogController.astrologyBlogs.clear();
            blogController.isAllDataLoaded = false;
            blogController.update();
            await blogController.getAstrologyBlog("", false);
            global.hideLoader();
            Get.to(() => AstrologyBlogScreen());
          },
          closeSpeedDialOnPressed: true,
        ),
      ],
      child: GestureDetector(
        onTap: () async {
          debugPrint('clicked floatin button');
          if (controller!.isDismissed) {
            // global.hideLoader();  //Creating error going to login when uncomment it
            debugPrint('clicked isdismissed floatin button');

            controller!.forward();
          } else {
            controller!.reverse();
          }
        },
        child: CircleAvatar(
          backgroundColor: COLORS().primaryColor,
          radius: 28,
          child: CircleAvatar(
            radius: 23,
            backgroundColor: COLORS().primaryColor,
            child: Icon(
              FontAwesomeIcons.wandMagicSparkles,
              color: Colors.grey.shade900,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
