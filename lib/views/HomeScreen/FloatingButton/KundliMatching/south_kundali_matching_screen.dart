// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:astrowaypartner/constants/imageConst.dart';
import 'package:astrowaypartner/controllers/kundli_matchig_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

class SouthKundliMatchingScreen extends StatefulWidget {
  const SouthKundliMatchingScreen({super.key});

  @override
  State<SouthKundliMatchingScreen> createState() =>
      _SouthKundliMatchingScreenState();
}

class _SouthKundliMatchingScreenState extends State<SouthKundliMatchingScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: GetBuilder<KundliMatchingController>(
              builder: (kundliMatchingController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2.4,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(IMAGECONST.sky),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Compatibility Score",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          kundliMatchingController.southkundliMatchDetailList!
                                      .recordList?.status ==
                                  200
                              ? kundliMatchingController
                                          .southkundliMatchDetailList!
                                          .recordList!
                                          .response ==
                                      null
                                  ? Center(
                                      child: Text(
                                        'No record Found',
                                        style: TextStyle(
                                            fontSize: 22.sp,
                                            color: Colors.white),
                                      ),
                                    )
                                  : kundliMatchingController
                                              .southkundliMatchDetailList!
                                              .recordList!
                                              .response!
                                              .score ==
                                          null
                                      ? const SizedBox()
                                      : SizedBox(
                                          height: 180,
                                          width: 230,
                                          child: SfRadialGauge(
                                            axes: <RadialAxis>[
                                              RadialAxis(
                                                showLabels: false,
                                                showAxisLine: false,
                                                showTicks: false,
                                                minimum: 0,
                                                maximum: double.parse(
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .botResponse
                                                        .toString()
                                                        .split("out of")[1]
                                                        .substring(0, 3)),
                                                ranges: <GaugeRange>[
                                                  GaugeRange(
                                                    startValue: 0,
                                                    endValue: 3.3,
                                                    color:
                                                        const Color(0xFFFE2A25),
                                                    label: '',
                                                    sizeUnit:
                                                        GaugeSizeUnit.factor,
                                                    labelStyle:
                                                        const GaugeTextStyle(
                                                            fontFamily: 'Times',
                                                            fontSize: 20),
                                                    startWidth: 0.50,
                                                    endWidth: 0.50,
                                                  ),
                                                  GaugeRange(
                                                    startValue: 3.3,
                                                    endValue: 6.6,
                                                    color:
                                                        const Color(0xFFFFBA00),
                                                    label: '',
                                                    startWidth: 0.50,
                                                    endWidth: 0.50,
                                                    sizeUnit:
                                                        GaugeSizeUnit.factor,
                                                  ),
                                                  GaugeRange(
                                                    startValue: 6.6,
                                                    endValue: 10,
                                                    color:
                                                        const Color(0xFF00AB47),
                                                    label: '',
                                                    sizeUnit:
                                                        GaugeSizeUnit.factor,
                                                    startWidth: 0.50,
                                                    endWidth: 0.50,
                                                  ),
                                                ],
                                                pointers: <GaugePointer>[
                                                  NeedlePointer(
                                                    value: kundliMatchingController
                                                                .southkundliMatchDetailList!
                                                                .recordList!
                                                                .response!
                                                                .score !=
                                                            null
                                                        ? double.parse(
                                                            kundliMatchingController
                                                                .southkundliMatchDetailList!
                                                                .recordList!
                                                                .response!
                                                                .score
                                                                .toString())
                                                        : 0.0,
                                                    needleStartWidth: 0,
                                                    needleEndWidth: 5,
                                                    needleColor:
                                                        const Color(0xFFDADADA),
                                                    enableAnimation: true,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ))
                              : const Center(
                                  child: Text(
                                    'No data Found Yet ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(
                          Platform.isIOS
                              ? Icons.arrow_back_ios
                              : Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(3),
                        width: 30,
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  insetPadding: EdgeInsets.zero,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage(IMAGECONST.sky),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                IMAGECONST.splashImage,
                                                height: 30,
                                                width: 30,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                global.getSystemFlagValue(global
                                                    .systemFlagNameList
                                                    .appName),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          kundliMatchingController
                                                      .isFemaleManglik ==
                                                  null
                                              ? const SizedBox()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            height: 70,
                                                            width: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .green,
                                                                width:
                                                                    3, /*strokeAlign: StrokeAlign.outside*/
                                                              ),
                                                              color: Get.theme
                                                                  .primaryColor,
                                                              image:
                                                                  const DecorationImage(
                                                                image:
                                                                    AssetImage(
                                                                  "assets/images/no_customer_image.png",
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 8.0),
                                                            child: Text(
                                                              kundliMatchingController
                                                                  .cBoysName
                                                                  .text,
                                                              style: Theme.of(
                                                                      context)
                                                                  .primaryTextTheme
                                                                  .titleMedium!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                          kundliMatchingController
                                                                      .isFemaleManglik ==
                                                                  null
                                                              ? const SizedBox()
                                                              : Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              6.0),
                                                                  child: Text(
                                                                    kundliMatchingController
                                                                            .isFemaleManglik!
                                                                        ? 'Non Manglik'
                                                                        : 'Manglik',
                                                                    style:
                                                                        TextStyle(
                                                                      color: kundliMatchingController.isFemaleManglik!
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                        ],
                                                      ),
                                                      Image.asset(
                                                        "assets/images/couple_ring_image.png",
                                                        scale: 8,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            height: 60,
                                                            width: 110,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .green,
                                                                width:
                                                                    3, /* strokeAlign: StrokeAlign.outside*/
                                                              ),
                                                              color: Get.theme
                                                                  .primaryColor,
                                                              image:
                                                                  const DecorationImage(
                                                                image:
                                                                    AssetImage(
                                                                  "assets/images/no_customer_image.png",
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 8.0),
                                                            child: Text(
                                                              kundliMatchingController
                                                                  .cGirlName
                                                                  .text,
                                                              style: Theme.of(
                                                                      context)
                                                                  .primaryTextTheme
                                                                  .titleMedium!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 9.0),
                                                            child: Text(
                                                              kundliMatchingController
                                                                      .isFemaleManglik!
                                                                  ? 'Non Manglik'
                                                                  : 'Manglik',
                                                              style: TextStyle(
                                                                color: kundliMatchingController
                                                                        .isFemaleManglik!
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Text(
                                              "Compatibility Score",
                                              style: TextStyle(
                                                color: Get.theme.primaryColor,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height: 180,
                                              width: 230,
                                              child: SfRadialGauge(
                                                axes: <RadialAxis>[
                                                  RadialAxis(
                                                    showLabels: false,
                                                    showAxisLine: false,
                                                    showTicks: false,
                                                    minimum: 0,
                                                    maximum: 36,
                                                    ranges: <GaugeRange>[
                                                      GaugeRange(
                                                        startValue: 0,
                                                        endValue: 12,
                                                        color: const Color(
                                                            0xFFFE2A25),
                                                        label: '',
                                                        sizeUnit: GaugeSizeUnit
                                                            .factor,
                                                        labelStyle:
                                                            const GaugeTextStyle(
                                                                fontFamily:
                                                                    'Times',
                                                                fontSize: 20),
                                                        startWidth: 0.50,
                                                        endWidth: 0.50,
                                                      ),
                                                      GaugeRange(
                                                        startValue: 12,
                                                        endValue: 24,
                                                        color: const Color(
                                                            0xFFFFBA00),
                                                        label: '',
                                                        startWidth: 0.50,
                                                        endWidth: 0.50,
                                                        sizeUnit: GaugeSizeUnit
                                                            .factor,
                                                      ),
                                                      GaugeRange(
                                                        startValue: 24,
                                                        endValue: 36,
                                                        color: const Color(
                                                            0xFF00AB47),
                                                        label: '',
                                                        sizeUnit: GaugeSizeUnit
                                                            .factor,
                                                        startWidth: 0.50,
                                                        endWidth: 0.50,
                                                      ),
                                                    ],
                                                    pointers: <GaugePointer>[
                                                      NeedlePointer(
                                                        value: kundliMatchingController
                                                            .southkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .score!,
                                                        needleStartWidth: 0,
                                                        needleEndWidth: 5,
                                                        needleColor:
                                                            const Color(
                                                                0xFFDADADA),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )),
                                          Container(
                                            height: 50,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.greenAccent),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Center(
                                                child: RichText(
                                              text: TextSpan(
                                                text:
                                                    '${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.score}/',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 24),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        '${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.score}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 22),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                top: 8, left: 8.0, right: 8.0),
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 20),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color:
                                                      Get.theme.primaryColor),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Get.theme.primaryColor,
                                                  Colors.white,
                                                ],
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "${global.getSystemFlagValue(global.systemFlagNameList.appName)} Conclusion",
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .titleMedium,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 10),
                                                  child: Text(
                                                    'The overall points of this couple ${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.score}',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    kundliMatchingController.southkundliMatchDetailList!
                                .recordList!.response ==
                            null
                        ? const SizedBox.shrink()
                        : kundliMatchingController.southkundliMatchDetailList!
                                    .recordList!.response?.score ==
                                null
                            ? const SizedBox()
                            : Positioned(
                                bottom: -25,
                                left: MediaQuery.of(context).size.width / 2.8,
                                child: Container(
                                  height: 50,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.greenAccent),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                      child: RichText(
                                    text: TextSpan(
                                      text:
                                          '${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.score}/',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 24),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: kundliMatchingController
                                              .southkundliMatchDetailList!
                                              .recordList!
                                              .response!
                                              .botResponse
                                              .toString()
                                              .split("out of")[1]
                                              .substring(0, 3),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 22),
                                        ),
                                      ],
                                    ),
                                  )),
                                ),
                              ),
                  ],
                ),
//----------------------Details-----------------------

                kundliMatchingController
                            .southkundliMatchDetailList!.recordList!.response ==
                        null
                    ? Center(
                        child: Text(
                          '',
                          style: TextStyle(fontSize: 22.sp),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            ///report
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 40.0,
                              ),
                              child: Center(
                                child: Text(
                                    "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.botResponse}",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18)),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20.0, bottom: 20),
                              child: Center(
                                child: Text("Details",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18)),
                              ),
                            ),
//------------------Card-------------------------------

                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.dina ==
                                    null
                                ? const SizedBox()
                                : Container(
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                        color: const Color(0xfffff6f1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey, width: 1)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  kundliMatchingController
                                                      .southkundliMatchDetailList!
                                                      .recordList!
                                                      .response!
                                                      .dina!
                                                      .name!
                                                      .toUpperCase(),
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .titleMedium,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0, right: 5),
                                                  child: Text(
                                                    "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.dina!.description}",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Girl",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                        Text(
                                                          "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.dina!.girlStar}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      width: 50,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Boy",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                        Text(
                                                          "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.dina!.boyStar}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 35.0,
                                            lineWidth: 5.0,
                                            percent: kundliMatchingController
                                                    .southkundliMatchDetailList!
                                                    .recordList!
                                                    .response!
                                                    .dina!
                                                    .dina!
                                                    .toDouble() /
                                                kundliMatchingController
                                                    .southkundliMatchDetailList!
                                                    .recordList!
                                                    .response!
                                                    .dina!
                                                    .fullScore!
                                                    .toDouble(),
                                            center: Text(
                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.dina!.dina}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.dina!.fullScore}",
                                              style: const TextStyle(
                                                  color: Color(0xfffca47c),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            progressColor:
                                                const Color(0xfffca47c),
                                          )
                                        ],
                                      ),
                                    )),

                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.gana ==
                                    null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: const Color(0xffeffaf4),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kundliMatchingController
                                                          .southkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .gana!
                                                          .name!
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              right: 5),
                                                      child: Text(
                                                        "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.gana!.description}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Girl",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.gana!.girlGana}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 50,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Boy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.gana!.boyGana}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                radius: 35.0,
                                                lineWidth: 5.0,
                                                percent: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .gana!
                                                        .gana!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .gana!
                                                        .fullScore!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.gana!.gana!}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.gana!.fullScore!}",
                                                  style: const TextStyle(
                                                      color: Color(0xfffca47c),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                progressColor:
                                                    const Color(0xfffca47c),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),

                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.mahendra ==
                                    null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: const Color(0xfffcf2fd),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kundliMatchingController
                                                          .southkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .mahendra!
                                                          .name!
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              right: 5),
                                                      child: Text(
                                                        "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.mahendra!.description}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Girl",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.mahendra!.girlStar}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 50,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Boy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.mahendra!.boyStar}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                radius: 35.0,
                                                lineWidth: 5.0,
                                                percent: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .mahendra!
                                                        .mahendra!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .mahendra!
                                                        .fullScore!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.mahendra!.mahendra!}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.mahendra!.fullScore!}",
                                                  style: const TextStyle(
                                                      color: Color(0xffba6ad9),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                progressColor:
                                                    const Color(0xffba6ad9),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),

                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.sthree ==
                                    null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: const Color(0xffeef7fe),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kundliMatchingController
                                                          .southkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .sthree!
                                                          .name!
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              right: 5),
                                                      child: Text(
                                                        "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.sthree!.description}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Girl",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.sthree!.girlStar}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 50,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Boy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.sthree!.boyStar}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                radius: 35.0,
                                                lineWidth: 5.0,
                                                percent: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .sthree!
                                                        .sthree!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .sthree!
                                                        .fullScore!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.sthree!.sthree!}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.sthree!.fullScore!}",
                                                  style: const TextStyle(
                                                      color: Color(0xff58a4f2),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                progressColor:
                                                    const Color(0xff58a4f2),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.yoni ==
                                    null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: const Color(0xfffff2f9),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kundliMatchingController
                                                          .southkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .yoni!
                                                          .name!
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              right: 5),
                                                      child: Text(
                                                        "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.yoni!.description}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Girl",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.yoni!.girlYoni}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 50,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Boy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.yoni!.boyYoni}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                radius: 35.0,
                                                lineWidth: 5.0,
                                                percent: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .yoni!
                                                        .yoni!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .yoni!
                                                        .fullScore!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.yoni!.yoni!}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.yoni!.fullScore!}",
                                                  style: const TextStyle(
                                                      color: Color(0xffff84bb),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                progressColor:
                                                    const Color(0xffff84bb),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),

                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.rasi ==
                                    null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: const Color(0xfffff6f1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kundliMatchingController
                                                          .southkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .rasi!
                                                          .name!
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              right: 5),
                                                      child: Text(
                                                        "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasi!.description}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Girl",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasi!.girlRasi}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 50,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Boy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasi!.boyRasi}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                radius: 35.0,
                                                lineWidth: 5.0,
                                                percent: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .rasi!
                                                        .rasi!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .rasi!
                                                        .fullScore!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasi!.rasi!}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasi!.fullScore!}",
                                                  style: const TextStyle(
                                                      color: Color(0xffffa37a),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                progressColor:
                                                    const Color(0xffffa37a),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),

                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.rasiathi ==
                                    null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: const Color(0xffeffaf4),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kundliMatchingController
                                                          .southkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .rasiathi!
                                                          .name!
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              right: 5),
                                                      child: Text(
                                                        "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasiathi!.description}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Girl",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasiathi!.girlLord}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 50,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Boy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasiathi!.boyLord}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                radius: 35.0,
                                                lineWidth: 5.0,
                                                percent: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .rasiathi!
                                                        .rasiathi!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .rasiathi!
                                                        .fullScore!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasiathi!.rasiathi}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rasiathi!.fullScore!}",
                                                  style: const TextStyle(
                                                      color: Color(
                                                        (0xff70ce99),
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                progressColor: const Color(
                                                  (0xff70ce99),
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                            //
                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.vasya ==
                                    null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: const Color(0xfffcf2fd),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kundliMatchingController
                                                          .southkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .vasya!
                                                          .name!
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              right: 5),
                                                      child: Text(
                                                        "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vasya!.description}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Girl",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vasya!.girlRasi}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 50,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Boy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vasya!.boyRasi}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                radius: 35.0,
                                                lineWidth: 5.0,
                                                percent: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .vasya!
                                                        .vasya!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .vasya!
                                                        .fullScore!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vasya!.vasya}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vasya!.fullScore!}",
                                                  style: const TextStyle(
                                                      color: Color(0xffbb6bda),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                progressColor:
                                                    const Color(0xffbb6bda),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),

                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.rajju ==
                                    null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: const Color(0xffeffaf4),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kundliMatchingController
                                                          .southkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .rajju!
                                                          .name!
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              right: 5),
                                                      child: Text(
                                                        "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rajju!.description}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Girl",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rajju!.girlRajju}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 50,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Boy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rajju!.boyRajju}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                radius: 35.0,
                                                lineWidth: 5.0,
                                                percent: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .rajju!
                                                        .rajju!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .rajju!
                                                        .fullScore!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rajju!.rajju}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.rajju!.fullScore!}",
                                                  style: const TextStyle(
                                                      color: Color(0xff70ce99),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                progressColor:
                                                    const Color(0xff70ce99),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),

                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.vedha ==
                                    null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                            color: const Color(0xfffcf2fd),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      kundliMatchingController
                                                          .southkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .vedha!
                                                          .name!
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .titleMedium,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              right: 5),
                                                      child: Text(
                                                        "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vedha!.description}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Girl",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vedha!.girlStar}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 50,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Boy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Text(
                                                              "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vedha!.boyStar}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              CircularPercentIndicator(
                                                radius: 35.0,
                                                lineWidth: 5.0,
                                                percent: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .vedha!
                                                        .vedha!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .vedha!
                                                        .fullScore!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vedha!.vedha}/${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.vedha!.fullScore!}",
                                                  style: const TextStyle(
                                                      color: Color(0xffbb6bda),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                progressColor:
                                                    const Color(0xffbb6bda),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),

//----------------------------------Manglik Report-------------------------------------
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                "Manglik Report",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.green,
                                          width:
                                              3, /*strokeAlign: StrokeAlign.outside*/
                                        ),
                                        color: Get.theme.primaryColor,
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            "assets/images/no_customer_image.png",
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        kundliMatchingController.cBoysName.text,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 9.0),
                                      child: Text(
                                        '${kundliMatchingController.southkundliMatchDetailList!.boyManaglikRpt!.response!.botResponse}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: kundliMatchingController
                                                        .southkundliMatchDetailList!
                                                        .boyManaglikRpt!
                                                        .response!
                                                        .score! >
                                                    50
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  "assets/images/couple_ring_image.png",
                                  scale: 8,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.green,
                                          width:
                                              3, /* strokeAlign: StrokeAlign.outside*/
                                        ),
                                        color: Get.theme.primaryColor,
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            "assets/images/no_customer_image.png",
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        kundliMatchingController.cGirlName.text,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 9.0),
                                      child: Text(
                                        '${kundliMatchingController.southkundliMatchDetailList!.girlMangalikRpt!.response!.botResponse}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: kundliMatchingController
                                                      .southkundliMatchDetailList!
                                                      .girlMangalikRpt!
                                                      .response!
                                                      .score! >
                                                  50
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
//--------------------------Conclusion-------------------------------------
                            kundliMatchingController.southkundliMatchDetailList!
                                        .recordList!.response!.score ==
                                    null
                                ? const SizedBox()
                                : Container(
                                    padding: const EdgeInsets.only(
                                        top: 8, left: 8.0, right: 8.0),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Get.theme.primaryColor),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Get.theme.primaryColor,
                                          Colors.white,
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "${global.getSystemFlagValue(global.systemFlagNameList.appName)} Conclusion",
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .titleMedium,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Text(
                                            'The overall points of this couple ${kundliMatchingController.southkundliMatchDetailList!.recordList!.response!.score}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          child: Image.asset(
                                            "assets/images/couple_image.png",
                                            scale: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                          ],
                        ),
                      ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
