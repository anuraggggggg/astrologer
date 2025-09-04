// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:astrowaypartner/controllers/kundli_matchig_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../../../../constants/imageConst.dart';
import '../../../../models/north_kundli_model.dart';

class NorthKundliMatchingScreen extends StatefulWidget {
  const NorthKundliMatchingScreen({
    super.key,
  });

  @override
  State<NorthKundliMatchingScreen> createState() =>
      _NorthKundliMatchingScreenState();
}

class _NorthKundliMatchingScreenState extends State<NorthKundliMatchingScreen> {
  RecordList? matchingresponse;
  final kundliMatchingController = Get.find<KundliMatchingController>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: GetBuilder<KundliMatchingController>(
              init: kundliMatchingController,
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
                              kundliMatchingController
                                          .northkundliMatchDetailList!
                                          .recordList!
                                          .status ==
                                      200
                                  ? kundliMatchingController
                                              .northkundliMatchDetailList!
                                              .recordList!
                                              .response ==
                                          null
                                      ? Center(
                                          child: Text(
                                            'No record Founds',
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                                color: Colors.white),
                                          ),
                                        )
                                      : kundliMatchingController
                                                  .northkundliMatchDetailList!
                                                  .recordList!
                                                  .response!
                                                  .score ==
                                              null
                                          ? Center(
                                              child: Text(
                                                'No record Founds',
                                                style: TextStyle(
                                                    fontSize: 18.sp,
                                                    color: Colors.black),
                                              ),
                                            )
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
                                                                    .northkundliMatchDetailList!
                                                                    .recordList!
                                                                    .response!
                                                                    .score !=
                                                                null
                                                            ? double.parse(
                                                                kundliMatchingController
                                                                    .northkundliMatchDetailList!
                                                                    .recordList!
                                                                    .response!
                                                                    .score
                                                                    .toString())
                                                            : 0.0,
                                                        needleStartWidth: 0,
                                                        needleEndWidth: 5,
                                                        needleColor:
                                                            const Color(
                                                                0xFFDADADA),
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
                          // title: const Text(
                          //   "Kundli Matching",
                          //   style: TextStyle(
                          //       color: Colors.white,
                          //       fontSize: 14,
                          //       fontWeight: FontWeight.bold),
                          // ),
                          // trailing: Container(
                          //   padding: const EdgeInsets.all(3),
                          //   width: 100,
                          //   decoration: BoxDecoration(
                          //     color: Get.theme.primaryColor,
                          //     borderRadius: BorderRadius.circular(50),
                          //   ),
                          //   child: GestureDetector(
                          //     onTap: () async {
                          //       showDialog(
                          //         context: context,
                          //         builder: (context) {
                          //           return Dialog(
                          //             insetPadding: EdgeInsets.zero,
                          //             child: Container(
                          //               width:
                          //                   MediaQuery.of(context).size.width,
                          //               decoration: const BoxDecoration(
                          //                 image: DecorationImage(
                          //                   fit: BoxFit.fill,
                          //                   image: AssetImage(IMAGECONST.sky),
                          //                 ),
                          //               ),
                          //               child: Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Column(
                          //                   children: [
                          //                     Row(
                          //                       mainAxisAlignment:
                          //                           MainAxisAlignment.center,
                          //                       children: [
                          //                         Image.asset(
                          //                           IMAGECONST.splashImage,
                          //                           height: 30,
                          //                           width: 30,
                          //                         ),
                          //                         const SizedBox(
                          //                           width: 10,
                          //                         ),
                          //                         Text(
                          //                           global.getSystemFlagValue(
                          //                               global
                          //                                   .systemFlagNameList
                          //                                   .appName),
                          //                           style: const TextStyle(
                          //                               color: Colors.white),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                     kundliMatchingController
                          //                                 .isFemaleManglik ==
                          //                             null
                          //                         ? const SizedBox()
                          //                         : Padding(
                          //                             padding:
                          //                                 const EdgeInsets.all(
                          //                                     8.0),
                          //                             child: Row(
                          //                               mainAxisAlignment:
                          //                                   MainAxisAlignment
                          //                                       .spaceEvenly,
                          //                               children: [
                          //                                 Column(
                          //                                   children: [
                          //                                     Container(
                          //                                       height: 70,
                          //                                       width: 100,
                          //                                       decoration:
                          //                                           BoxDecoration(
                          //                                         shape: BoxShape
                          //                                             .circle,
                          //                                         border: Border
                          //                                             .all(
                          //                                           color: Colors
                          //                                               .green,
                          //                                           width:
                          //                                               3, /*strokeAlign: StrokeAlign.outside*/
                          //                                         ),
                          //                                         color: Get
                          //                                             .theme
                          //                                             .primaryColor,
                          //                                         image:
                          //                                             const DecorationImage(
                          //                                           image:
                          //                                               AssetImage(
                          //                                             "assets/images/no_customer_image.png",
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                     Padding(
                          //                                       padding:
                          //                                           const EdgeInsets
                          //                                               .only(
                          //                                               top:
                          //                                                   8.0),
                          //                                       child: Text(
                          //                                         kundliMatchingController
                          //                                             .cBoysName
                          //                                             .text,
                          //                                         style: Theme.of(
                          //                                                 context)
                          //                                             .primaryTextTheme
                          //                                             .titleMedium!
                          //                                             .copyWith(
                          //                                                 color:
                          //                                                     Colors.white),
                          //                                       ),
                          //                                     ),
                          //                                     kundliMatchingController
                          //                                                 .isFemaleManglik ==
                          //                                             null
                          //                                         ? const SizedBox()
                          //                                         : Padding(
                          //                                             padding: const EdgeInsets
                          //                                                 .only(
                          //                                                 top:
                          //                                                     6.0),
                          //                                             child:
                          //                                                 Text(
                          //                                               kundliMatchingController.isFemaleManglik!
                          //                                                   ? 'Non Manglik'
                          //                                                   : 'Manglik',
                          //                                               style:
                          //                                                   TextStyle(
                          //                                                 color: kundliMatchingController.isFemaleManglik!
                          //                                                     ? Colors.green
                          //                                                     : Colors.red,
                          //                                               ),
                          //                                             ),
                          //                                           ),
                          //                                   ],
                          //                                 ),
                          //                                 Image.asset(
                          //                                   "assets/images/couple_ring_image.png",
                          //                                   scale: 8,
                          //                                 ),
                          //                                 Column(
                          //                                   children: [
                          //                                     Container(
                          //                                       height: 60,
                          //                                       width: 110,
                          //                                       decoration:
                          //                                           BoxDecoration(
                          //                                         shape: BoxShape
                          //                                             .circle,
                          //                                         border: Border
                          //                                             .all(
                          //                                           color: Colors
                          //                                               .green,
                          //                                           width:
                          //                                               3, /* strokeAlign: StrokeAlign.outside*/
                          //                                         ),
                          //                                         color: Get
                          //                                             .theme
                          //                                             .primaryColor,
                          //                                         image:
                          //                                             const DecorationImage(
                          //                                           image:
                          //                                               AssetImage(
                          //                                             "assets/images/no_customer_image.png",
                          //                                           ),
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                     Padding(
                          //                                       padding:
                          //                                           const EdgeInsets
                          //                                               .only(
                          //                                               top:
                          //                                                   8.0),
                          //                                       child: Text(
                          //                                         kundliMatchingController
                          //                                             .cGirlName
                          //                                             .text,
                          //                                         style: Theme.of(
                          //                                                 context)
                          //                                             .primaryTextTheme
                          //                                             .titleMedium!
                          //                                             .copyWith(
                          //                                                 color:
                          //                                                     Colors.white),
                          //                                       ),
                          //                                     ),
                          //                                     Padding(
                          //                                       padding:
                          //                                           const EdgeInsets
                          //                                               .only(
                          //                                               top:
                          //                                                   9.0),
                          //                                       child: Text(
                          //                                         kundliMatchingController
                          //                                                 .isFemaleManglik!
                          //                                             ? 'Non Manglik'
                          //                                             : 'Manglik',
                          //                                         style:
                          //                                             TextStyle(
                          //                                           color: kundliMatchingController.isFemaleManglik!
                          //                                               ? Colors
                          //                                                   .green
                          //                                               : Colors
                          //                                                   .red,
                          //                                         ),
                          //                                       ),
                          //                                     ),
                          //                                   ],
                          //                                 ),
                          //                               ],
                          //                             ),
                          //                           ),
                          //                     Padding(
                          //                       padding: const EdgeInsets.only(
                          //                           bottom: 10),
                          //                       child: Text(
                          //                         "Compatibility Score",
                          //                         style: TextStyle(
                          //                           color:
                          //                               Get.theme.primaryColor,
                          //                           fontSize: 18,
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //             ),
                          //           );
                          //         },
                          //       );
                          //     },
                          //   ),
                          // ),
                        ),
                        kundliMatchingController.northkundliMatchDetailList!
                                    .recordList!.response ==
                                null
                            ? const SizedBox.shrink()
                            : kundliMatchingController
                                        .northkundliMatchDetailList!
                                        .recordList!
                                        .response!
                                        .score ==
                                    null
                                ? const SizedBox()
                                : Positioned(
                                    bottom: -25,
                                    left:
                                        MediaQuery.of(context).size.width / 2.8,
                                    child: Container(
                                      height: 50,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.greenAccent),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                          child: RichText(
                                        text: TextSpan(
                                          text:
                                              '${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.score}/',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 24),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: kundliMatchingController
                                                  .northkundliMatchDetailList!
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

                    kundliMatchingController.northkundliMatchDetailList!
                                .recordList!.response ==
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
                                        "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.botResponse}",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .titleMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18)),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, bottom: 20),
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

                                kundliMatchingController
                                            .northkundliMatchDetailList!
                                            .recordList!
                                            .response!
                                            .tara ==
                                        null
                                    ? const SizedBox()
                                    : Container(
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
                                                          .northkundliMatchDetailList!
                                                          .recordList!
                                                          .response!
                                                          .tara!
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
                                                        "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.tara!.description}",
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
                                                              "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.tara!.girlTara}",
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
                                                              "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.tara!.boyTara}",
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
                                                        .northkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .tara!
                                                        .tara!
                                                        .toDouble() /
                                                    kundliMatchingController
                                                        .northkundliMatchDetailList!
                                                        .recordList!
                                                        .response!
                                                        .tara!
                                                        .tara!
                                                        .toDouble(),
                                                center: Text(
                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.tara!.tara}/${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.tara!.fullScore}",
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

                                kundliMatchingController
                                            .northkundliMatchDetailList!
                                            .recordList!
                                            .response!
                                            .gana ==
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
                                                    color: Colors.grey,
                                                    width: 1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          kundliMatchingController
                                                              .northkundliMatchDetailList!
                                                              .recordList!
                                                              .response!
                                                              .gana!
                                                              .name!
                                                              .toUpperCase(),
                                                          style: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .titleMedium,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0,
                                                                  right: 5),
                                                          child: Text(
                                                            "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.gana!.description}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                            textAlign: TextAlign
                                                                .justify,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.gana!.girlGana}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.gana!.boyGana}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .gana!
                                                            .gana!
                                                            .toDouble() /
                                                        kundliMatchingController
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .gana!
                                                            .fullScore!
                                                            .toDouble(),
                                                    center: Text(
                                                      "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.gana!.gana!}/${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.gana!.fullScore!}",
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xfffca47c),
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

                                kundliMatchingController
                                            .northkundliMatchDetailList!
                                            .recordList!
                                            .response!
                                            .yoni ==
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
                                                    color: Colors.grey,
                                                    width: 1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          kundliMatchingController
                                                              .northkundliMatchDetailList!
                                                              .recordList!
                                                              .response!
                                                              .yoni!
                                                              .name!
                                                              .toUpperCase(),
                                                          style: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .titleMedium,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0,
                                                                  right: 5),
                                                          child: Text(
                                                            "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.yoni!.description}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                            textAlign: TextAlign
                                                                .justify,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.yoni!.girlYoni}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.yoni!.boyYoni}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .yoni!
                                                            .yoni!
                                                            .toDouble() /
                                                        kundliMatchingController
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .yoni!
                                                            .fullScore!
                                                            .toDouble(),
                                                    center: Text(
                                                      "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.yoni!.yoni!}/${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.yoni!.fullScore!}",
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xffba6ad9),
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

                                kundliMatchingController
                                            .northkundliMatchDetailList!
                                            .recordList!
                                            .response!
                                            .bhakoot ==
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
                                                    color: Colors.grey,
                                                    width: 1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          kundliMatchingController
                                                              .northkundliMatchDetailList!
                                                              .recordList!
                                                              .response!
                                                              .bhakoot!
                                                              .name!
                                                              .toUpperCase(),
                                                          style: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .titleMedium,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0,
                                                                  right: 5),
                                                          child: Text(
                                                            "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.bhakoot!.description}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                            textAlign: TextAlign
                                                                .justify,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.bhakoot!.girlRasiName}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.bhakoot!.boyRasiName}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .bhakoot!
                                                            .bhakoot!
                                                            .toDouble() /
                                                        kundliMatchingController
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .bhakoot!
                                                            .fullScore!
                                                            .toDouble(),
                                                    center: Text(
                                                      "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.bhakoot!.bhakoot!}/${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.bhakoot!.fullScore!}",
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xff58a4f2),
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
                                kundliMatchingController
                                            .northkundliMatchDetailList!
                                            .recordList!
                                            .response!
                                            .grahamaitri ==
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
                                                    color: Colors.grey,
                                                    width: 1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          kundliMatchingController
                                                              .northkundliMatchDetailList!
                                                              .recordList!
                                                              .response!
                                                              .grahamaitri!
                                                              .name!
                                                              .toUpperCase(),
                                                          style: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .titleMedium,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0,
                                                                  right: 5),
                                                          child: Text(
                                                            "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.grahamaitri!.description}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                            textAlign: TextAlign
                                                                .justify,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.grahamaitri!.girlLord}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.grahamaitri!.boyLord}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .grahamaitri!
                                                            .grahamaitri!
                                                            .toDouble() /
                                                        kundliMatchingController
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .grahamaitri!
                                                            .fullScore!
                                                            .toDouble(),
                                                    center: Text(
                                                      "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.grahamaitri!.grahamaitri!}/${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.grahamaitri!.fullScore!}",
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xffff84bb),
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

                                kundliMatchingController
                                            .northkundliMatchDetailList!
                                            .recordList!
                                            .response!
                                            .vasya ==
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
                                                    color: Colors.grey,
                                                    width: 1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          kundliMatchingController
                                                              .northkundliMatchDetailList!
                                                              .recordList!
                                                              .response!
                                                              .vasya!
                                                              .name!
                                                              .toUpperCase(),
                                                          style: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .titleMedium,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0,
                                                                  right: 5),
                                                          child: Text(
                                                            "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.vasya!.description}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                            textAlign: TextAlign
                                                                .justify,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.vasya!.girlVasya}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.vasya!.boyVasya}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .vasya!
                                                            .vasya!
                                                            .toDouble() /
                                                        kundliMatchingController
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .vasya!
                                                            .fullScore!
                                                            .toDouble(),
                                                    center: Text(
                                                      "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.vasya!.vasya!}/${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.vasya!.fullScore!}",
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xffffa37a),
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

                                kundliMatchingController
                                            .northkundliMatchDetailList!
                                            .recordList!
                                            .response!
                                            .nadi ==
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
                                                    color: Colors.grey,
                                                    width: 1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          kundliMatchingController
                                                              .northkundliMatchDetailList!
                                                              .recordList!
                                                              .response!
                                                              .nadi!
                                                              .name!
                                                              .toUpperCase(),
                                                          style: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .titleMedium,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0,
                                                                  right: 5),
                                                          child: Text(
                                                            "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.nadi!.description}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                            textAlign: TextAlign
                                                                .justify,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.nadi!.girlNadi}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.nadi!.boyNadi}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .nadi!
                                                            .nadi!
                                                            .toDouble() /
                                                        kundliMatchingController
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .nadi!
                                                            .fullScore!
                                                            .toDouble(),
                                                    center: Text(
                                                      "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.nadi!.nadi!}/${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.nadi!.fullScore!}",
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
                                kundliMatchingController
                                            .northkundliMatchDetailList!
                                            .recordList!
                                            .response!
                                            .varna ==
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
                                                    color: Colors.grey,
                                                    width: 1)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          kundliMatchingController
                                                              .northkundliMatchDetailList!
                                                              .recordList!
                                                              .response!
                                                              .varna!
                                                              .name!
                                                              .toUpperCase(),
                                                          style: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .titleMedium,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0,
                                                                  right: 5),
                                                          child: Text(
                                                            "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.varna!.description}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                            textAlign: TextAlign
                                                                .justify,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.varna!.girlVarna}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                                      fontSize:
                                                                          12,
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
                                                                  "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.varna!.boyVarna}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
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
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .varna!
                                                            .varna!
                                                            .toDouble() /
                                                        kundliMatchingController
                                                            .northkundliMatchDetailList!
                                                            .recordList!
                                                            .response!
                                                            .varna!
                                                            .fullScore!
                                                            .toDouble(),
                                                    center: Text(
                                                      "${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.varna!.varna!}/${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.varna!.fullScore!}",
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xffbb6bda),
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Text(
                                    "Manglik Report",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleMedium,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                              width: 3,
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
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: Text(
                                            kundliMatchingController
                                                .cBoysName.text,
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: Text(
                                            '${kundliMatchingController.northkundliMatchDetailList!.boyManaglikRpt!.response!.botResponse}',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: kundliMatchingController
                                                            .northkundliMatchDetailList!
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
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            kundliMatchingController
                                                .cGirlName.text,
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 9.0),
                                          child: Text(
                                            '${kundliMatchingController.northkundliMatchDetailList!.girlMangalikRpt!.response!.botResponse}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: kundliMatchingController
                                                          .northkundliMatchDetailList!
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
                                kundliMatchingController
                                            .northkundliMatchDetailList!
                                            .recordList!
                                            .response!
                                            .score ==
                                        null
                                    ? const SizedBox()
                                    : Container(
                                        padding: const EdgeInsets.only(
                                            top: 8, left: 8.0, right: 8.0),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                              padding: const EdgeInsets.only(
                                                  top: 10.0),
                                              child: Text(
                                                'The overall points of this couple ${kundliMatchingController.northkundliMatchDetailList!.recordList!.response!.score}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
