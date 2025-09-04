import 'package:astrowaypartner/controllers/dailyHoroscopeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore_for_file: file_names, avoid_print

import 'dart:io';

import 'package:astrowaypartner/controllers/splashController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import 'package:sizer/sizer.dart';

import '../../../../utils/config.dart';

// ignore: must_be_immutable
class DailyHoroscopeVedic extends StatefulWidget {
  const DailyHoroscopeVedic({super.key});

  @override
  State<DailyHoroscopeVedic> createState() => _DailyHoroscopeVedicState();
}

class _DailyHoroscopeVedicState extends State<DailyHoroscopeVedic> {
  SplashController splashController = Get.find<SplashController>();

  int selectHoroscope = 1;
  int zodiacIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.primaryColor,
        title: Text(
          'Daily Horoscope vedic',
          style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
            fontSize: 13.sp,
          ),
        ).tr(),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            color: Get.theme.iconTheme.color,
          ),
        ),
        // actions: [
        //   // GestureDetector(
        //   //   onTap: () {
        //   //     global.createAndShareLinkForDailyHorscope(screenshotController);
        //   //   },
        //   //   child: Padding(
        //   //     padding: const EdgeInsets.all(12.0),
        //   //     child: Container(
        //   //       decoration: BoxDecoration(
        //   //         border: Border.all(color: Colors.black),
        //   //         borderRadius: BorderRadius.circular(5),
        //   //       ),
        //   //       child: Row(
        //   //         children: [
        //   //           Padding(
        //   //             padding: const EdgeInsets.only(left: 8.0),
        //   //             child: Image.asset(
        //   //               IMAGECONST.whatsapp,
        //   //               height: 20,
        //   //               width: 20,
        //   //             ),
        //   //           ),
        //   //           Padding(
        //   //             padding: const EdgeInsets.all(4.0),
        //   //             child: Text(
        //   //               'Share',
        //   //               style: Get.textTheme.titleMedium!
        //   //                   .copyWith(fontSize: 11.sp),
        //   //             ).tr(),
        //   //           )
        //   //         ],
        //   //       ),
        //   //     ),
        //   //   ),
        //   // )
        // ]
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GetBuilder<DailyHoroscopeController>(
              builder: (dailyHoroscopeController) {
            return dailyHoroscopeController.vedicdailyList == null
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///rashi listing
                      (global.hororscopeSignList.isNotEmpty)
                          ? SizedBox(
                              height: 120,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: global.hororscopeSignList.length,
                                  itemBuilder: (context, index) {
                                    debugPrint(
                                        'image url $imgBaseurl${global.hororscopeSignList[index].image}');

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              setState(() {});
                                              global.showOnlyLoaderDialog();
                                              await dailyHoroscopeController
                                                  .selectZodic(index);
                                              await dailyHoroscopeController
                                                  .getHoroscopeList(
                                                      horoscopeId:
                                                          dailyHoroscopeController
                                                              .signId);
                                              global.hideLoader();
                                            },
                                            child: Container(
                                              width: global
                                                      .hororscopeSignList[index]
                                                      .isSelected
                                                  ? 68.0
                                                  : 54.0,
                                              height: global
                                                      .hororscopeSignList[index]
                                                      .isSelected
                                                  ? 68.0
                                                  : 54.0,
                                              padding: const EdgeInsets.all(0),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(7)),
                                                border: Border.all(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '$imgBaseurl${global.hororscopeSignList[index].image}',
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(
                                                            Icons.no_accounts,
                                                            size: 20),
                                              ),
                                            ),
                                          ),
                                          Text(
                                              global.hororscopeSignList[index]
                                                  .name,
                                              textAlign: TextAlign.center,
                                              style: Get.textTheme.titleMedium!
                                                  .copyWith(fontSize: 10))
                                        ],
                                      ),
                                    );
                                  }),
                            )
                          : const SizedBox(),

                      ///daily,yearly,monthly
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectHoroscope = 0;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 8, 18, 8),
                                decoration: BoxDecoration(
                                  color: selectHoroscope == 0
                                      ? const Color.fromARGB(255, 247, 243, 214)
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: selectHoroscope == 0
                                          ? Get.theme.primaryColor
                                          : Colors.grey),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0)),
                                ),
                                child: Text(
                                  '''Today\nHoroscope''',
                                  textAlign: TextAlign.center,
                                  style: Get.textTheme.titleMedium!
                                      .copyWith(fontSize: 12.sp),
                                ).tr(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectHoroscope = 1;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 8, 18, 8),
                                decoration: BoxDecoration(
                                  color: selectHoroscope == 1
                                      ? const Color.fromARGB(255, 247, 243, 214)
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: selectHoroscope == 1
                                          ? Get.theme.primaryColor
                                          : Colors.grey),
                                ),
                                child: Text('''Weekly\nHoroscope''',
                                        textAlign: TextAlign.center,
                                        style: Get.textTheme.titleMedium!
                                            .copyWith(fontSize: 12.sp))
                                    .tr(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectHoroscope = 2;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 8, 18, 8),
                                decoration: BoxDecoration(
                                  color: selectHoroscope == 2
                                      ? const Color.fromARGB(255, 247, 243, 214)
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: selectHoroscope == 2
                                          ? Get.theme.primaryColor
                                          : Colors.grey),
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0)),
                                ),
                                child: Text('''Yearly\nHoroscope''',
                                        textAlign: TextAlign.center,
                                        style: Get.textTheme.titleMedium!
                                            .copyWith(fontSize: 12.sp))
                                    .tr(),
                              ),
                            ),
                          )
                        ],
                      ),

                      ///lucky number and color banner

                      selectHoroscope == 0
                          ? dailyHoroscopeController
                                  .vedicdailyList!.todayHoroscope!.isNotEmpty
                              ? Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: Get.width * 0.03,
                                          vertical: Get.height * 0.02),
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.centerRight,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    dailyHoroscopeController
                                                            .vedicdailyList
                                                            ?.todayHoroscope![
                                                                zodiacIndex]
                                                            .date
                                                            .toString()
                                                            .split(" ")
                                                            .first ??
                                                        "",
                                                    style: Get
                                                        .textTheme.titleMedium!
                                                        .copyWith(
                                                            fontSize: 12.sp,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Today Horoscope",
                                                  style: Get
                                                      .textTheme.titleMedium!
                                                      .copyWith(
                                                    fontSize: 13.sp,
                                                    color: Colors.white,
                                                  ),
                                                ).tr(),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Lucky Color",
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ).tr(),
                                                      CircleAvatar(
                                                        radius: 7,
                                                        backgroundColor: Color(
                                                          int.parse(dailyHoroscopeController
                                                                  .vedicdailyList!
                                                                  .todayHoroscope![
                                                                      zodiacIndex]
                                                                  .colorCode ??
                                                              '0xff000000'),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Lucky Number",
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ).tr(),
                                                      Text(
                                                        dailyHoroscopeController
                                                                .vedicdailyList!
                                                                .todayHoroscope![
                                                                    zodiacIndex]
                                                                .luckyNumber
                                                                ?.toString()
                                                                .replaceAll(
                                                                    '[', '')
                                                                .replaceAll(
                                                                    ']', '') ??
                                                            "[]",
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),

                                    Text(
                                      "Today Horoscope",
                                      style: Get.textTheme.titleMedium!
                                          .copyWith(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ).tr(),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${dailyHoroscopeController.vedicdailyList?.todayHoroscope![zodiacIndex].botResponse}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),

                                    ///daily horoscope list
                                    SizedBox(
                                      height: 8.h,
                                      width: 100.w,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Today Horoscope of',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600),
                                        ).tr(args: [
                                          dailyHoroscopeController.SignName
                                        ]),
                                      ),
                                    ),

                                    GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2.5,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: 9,
                                      itemBuilder: (context, index) {
                                        switch (index) {
                                          case 0:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Physique",
                                                Icons.sports_gymnastics,
                                                dailyHoroscopeController
                                                    .vedicdailyList!
                                                    .todayHoroscope![
                                                        zodiacIndex]
                                                    .physique);
                                          case 1:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Finances",
                                                Icons.monetization_on_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.todayHoroscope![
                                                        zodiacIndex]
                                                    .finances);
                                          case 2:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Relationships",
                                                Icons.handshake_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.todayHoroscope![
                                                        zodiacIndex]
                                                    .relationship);
                                          case 3:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Career",
                                                Icons.book_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.todayHoroscope![
                                                        zodiacIndex]
                                                    .career);

                                          case 4:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Travel",
                                                Icons.travel_explore,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.todayHoroscope![
                                                        zodiacIndex]
                                                    .travel);

                                          case 5:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Family',
                                                Icons.people_alt_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.todayHoroscope![
                                                        zodiacIndex]
                                                    .family);

                                          case 6:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Friends',
                                                Icons.people_alt_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.todayHoroscope![
                                                        zodiacIndex]
                                                    .friends);

                                          case 7:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Health',
                                                Icons
                                                    .health_and_safety_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.todayHoroscope![
                                                        zodiacIndex]
                                                    .health);

                                          case 8:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Status',
                                                Icons
                                                    .photo_size_select_actual_sharp,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.todayHoroscope![
                                                        zodiacIndex]
                                                    .status);

                                          default:
                                            return const SizedBox.shrink();
                                        }
                                      },
                                    )
                                  ],
                                )
                              : SizedBox(
                                  child: Center(
                                    child: Text(
                                      'No Data Found Yet',
                                      style: TextStyle(fontSize: 12.sp),
                                    ).tr(),
                                  ),
                                )
                          : const SizedBox(),

                      selectHoroscope == 1
                          ? dailyHoroscopeController.vedicdailyList!
                                      .weeklyHoroScope!.isNotEmpty &&
                                  zodiacIndex <
                                      dailyHoroscopeController.vedicdailyList!
                                          .weeklyHoroScope!.length
                              ? Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: Get.width * 0.03,
                                          vertical: Get.height * 0.02),
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.centerRight,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    dailyHoroscopeController
                                                        .vedicdailyList!
                                                        .weeklyHoroScope![
                                                            zodiacIndex]
                                                        .date
                                                        .toString()
                                                        .split(" ")
                                                        .first,
                                                    style: Get
                                                        .textTheme.titleMedium!
                                                        .copyWith(
                                                            fontSize: 12.sp,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Weekly Horoscrope",
                                                  style: Get
                                                      .textTheme.titleMedium!
                                                      .copyWith(
                                                    fontSize: 13.sp,
                                                    color: Colors.white,
                                                  ),
                                                ).tr(),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Lucky Color",
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                      ).tr(),
                                                      CircleAvatar(
                                                        radius: 7,
                                                        backgroundColor: Color(
                                                          int.parse(dailyHoroscopeController
                                                                  .vedicdailyList!
                                                                  .weeklyHoroScope![
                                                                      zodiacIndex]
                                                                  .colorCode ??
                                                              '0xff000000'),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Lucky Number",
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ).tr(),
                                                      Text(
                                                        dailyHoroscopeController
                                                                .vedicdailyList!
                                                                .weeklyHoroScope![
                                                                    zodiacIndex]
                                                                .luckyNumber
                                                                ?.toString()
                                                                .replaceAll(
                                                                    '[', '')
                                                                .replaceAll(
                                                                    ']', '') ??
                                                            "[]",
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          // CircleAvatar(
                                          //   radius: 40,
                                          //   backgroundColor: Colors.white,
                                          // )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      "Weekly Horoscrope",
                                      style: Get.textTheme.titleMedium!
                                          .copyWith(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ).tr(),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${dailyHoroscopeController.vedicdailyList?.weeklyHoroScope![zodiacIndex].botResponse}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ),

                                    ///weekly horoscope list
                                    SizedBox(
                                      height: 8.h,
                                      width: 100.w,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Weekly Horoscope of',
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600),
                                        ).tr(args: [
                                          dailyHoroscopeController.SignName
                                        ]),
                                      ),
                                    ),

                                    ///weekly horoscope list
                                    GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2.5,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: 9,
                                      itemBuilder: (context, index) {
                                        switch (index) {
                                          case 0:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Physique",
                                                Icons.sports_gymnastics,
                                                dailyHoroscopeController
                                                    .vedicdailyList!
                                                    .weeklyHoroScope![
                                                        zodiacIndex]
                                                    .physique);
                                          case 1:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Finances",
                                                Icons.monetization_on_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.weeklyHoroScope![
                                                        zodiacIndex]
                                                    .finances);
                                          case 2:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Relationships",
                                                Icons.handshake_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.weeklyHoroScope![
                                                        zodiacIndex]
                                                    .relationship);
                                          case 3:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Career",
                                                Icons.book_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.weeklyHoroScope![
                                                        zodiacIndex]
                                                    .career);

                                          case 4:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Travel",
                                                Icons.travel_explore,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.weeklyHoroScope![
                                                        zodiacIndex]
                                                    .travel);

                                          case 5:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Family',
                                                Icons.people_alt_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.weeklyHoroScope![
                                                        zodiacIndex]
                                                    .family);

                                          case 6:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Friends',
                                                Icons.people_alt_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.weeklyHoroScope![
                                                        zodiacIndex]
                                                    .friends);

                                          case 7:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Health',
                                                Icons
                                                    .health_and_safety_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.weeklyHoroScope![
                                                        zodiacIndex]
                                                    .health);

                                          case 8:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Status',
                                                Icons
                                                    .photo_size_select_actual_sharp,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.weeklyHoroScope![
                                                        zodiacIndex]
                                                    .status);

                                          default:
                                            return const SizedBox.shrink();
                                        }
                                      },
                                    ),

                                    const SizedBox(
                                      height: 60,
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  child: Center(
                                    child: Text(
                                      'No Data Found Yet',
                                      style: TextStyle(fontSize: 12.sp),
                                    ).tr(),
                                  ),
                                )
                          : const SizedBox(),

                      selectHoroscope == 2
                          ? dailyHoroscopeController.vedicdailyList!
                                      .yearlyHoroScope!.isNotEmpty &&
                                  zodiacIndex <
                                      dailyHoroscopeController.vedicdailyList!
                                          .yearlyHoroScope!.length
                              ? Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: Get.width * 0.03,
                                          vertical: Get.height * 0.02),
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.centerRight,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    dailyHoroscopeController
                                                        .vedicdailyList!
                                                        .yearlyHoroScope![
                                                            zodiacIndex]
                                                        .date
                                                        .toString()
                                                        .split(" ")
                                                        .first,
                                                    style: Get
                                                        .textTheme.titleMedium!
                                                        .copyWith(
                                                            fontSize: 12.sp,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Yearly Horoscope",
                                                  style: Get
                                                      .textTheme.titleMedium!
                                                      .copyWith(
                                                          fontSize: 12.sp,
                                                          color: Colors.white),
                                                ).tr(),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  //! HOW TO GET 1 to 12 zodiac
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Lucky Color",
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                      ).tr(),
                                                      CircleAvatar(
                                                        radius: 7,
                                                        backgroundColor: Color(int.tryParse(dailyHoroscopeController
                                                                    .vedicdailyList!
                                                                    .yearlyHoroScope![
                                                                        zodiacIndex]
                                                                    .colorCode ??
                                                                '0x00000000') ??
                                                            0x00000000),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Lucky Number",
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ).tr(),
                                                      Text(
                                                        dailyHoroscopeController
                                                                .vedicdailyList!
                                                                .yearlyHoroScope![
                                                                    zodiacIndex]
                                                                .luckyNumber
                                                                ?.toString()
                                                                .replaceAll(
                                                                    '[', '')
                                                                .replaceAll(
                                                                    ']', '') ??
                                                            "[]",
                                                        style: Get.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 12.sp,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      "Yearly Horoscope",
                                      style: Get.textTheme.titleMedium!
                                          .copyWith(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ).tr(),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${dailyHoroscopeController.vedicdailyList?.yearlyHoroScope![zodiacIndex].botResponse}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ),

                                    ///yearly horoscope list
                                    SizedBox(
                                      height: 8.h,
                                      width: 100.w,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Yearly Horoscope of',
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600),
                                        ).tr(args: [
                                          dailyHoroscopeController.SignName
                                        ]),
                                      ),
                                    ),

                                    ///yearly horoscope list
                                    GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2.5,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: 9,
                                      itemBuilder: (context, index) {
                                        switch (index) {
                                          case 0:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Physique",
                                                Icons.sports_gymnastics,
                                                dailyHoroscopeController
                                                    .vedicdailyList!
                                                    .yearlyHoroScope![
                                                        zodiacIndex]
                                                    .physique);
                                          case 1:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Finances",
                                                Icons.monetization_on_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.yearlyHoroScope![
                                                        zodiacIndex]
                                                    .finances);
                                          case 2:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Relationships",
                                                Icons.handshake_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.yearlyHoroScope![
                                                        zodiacIndex]
                                                    .relationship);
                                          case 3:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Career",
                                                Icons.book_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.yearlyHoroScope![
                                                        zodiacIndex]
                                                    .career);

                                          case 4:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                "Travel",
                                                Icons.travel_explore,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.yearlyHoroScope![
                                                        zodiacIndex]
                                                    .travel);

                                          case 5:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Family',
                                                Icons.people_alt_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.yearlyHoroScope![
                                                        zodiacIndex]
                                                    .family);

                                          case 6:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Friends',
                                                Icons.people_alt_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.yearlyHoroScope![
                                                        zodiacIndex]
                                                    .friends);

                                          case 7:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Health',
                                                Icons
                                                    .health_and_safety_outlined,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.yearlyHoroScope![
                                                        zodiacIndex]
                                                    .health);

                                          case 8:
                                            return HoroscopeWidget(
                                                dailyHoroscopeController,
                                                'Status',
                                                Icons
                                                    .photo_size_select_actual_sharp,
                                                dailyHoroscopeController
                                                    .vedicdailyList
                                                    ?.yearlyHoroScope![
                                                        zodiacIndex]
                                                    .status);

                                          default:
                                            return const SizedBox.shrink();
                                        }
                                      },
                                    ),

                                    const SizedBox(
                                      height: 60,
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  child: Center(
                                    child: Text(
                                      'No Data Found Yet',
                                      style: TextStyle(fontSize: 12.sp),
                                    ).tr(),
                                  ),
                                )
                          : const SizedBox(),
                    ],
                  );
          }),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container HoroscopeWidget(DailyHoroscopeController dailyHoroscopeController,
      String title, IconData preicon, int? percentage) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      margin: EdgeInsets.symmetric(vertical: Get.height * 0.005),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(10),
          color: Colors.red.shade50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, //
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    preicon,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: Get.width * 0.02,
                  ),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    title,
                    style: Get.textTheme.titleMedium!
                        .copyWith(fontSize: 10.sp, fontWeight: FontWeight.w400),
                  ).tr(),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "$percentage% ",
                    style: Get.theme.primaryTextTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 10.sp,
                      letterSpacing: -0.2,
                      wordSpacing: 0,
                    ),
                  ),
                  // Circular Progress Indicator
                  SizedBox(
                    height: 5.h,
                    width: 5.h,
                    child: CircularProgressIndicator(
                      value: (percentage ?? 0) / 100.0,
                      strokeWidth: 2.0,
                      backgroundColor: Colors.grey.shade400,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
