// ignore_for_file: file_names

import 'dart:developer';

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:astrowaypartner/widgets/FreeKundliWidget/create_kundli_title_widget.dart';
import 'package:astrowaypartner/widgets/FreeKundliWidget/kundli_birth_time_widget.dart';
import 'package:astrowaypartner/widgets/FreeKundliWidget/kundli_birthdate_widget.dart';
import 'package:astrowaypartner/widgets/FreeKundliWidget/kundli_born_place_widget.dart';
import 'package:astrowaypartner/widgets/FreeKundliWidget/kundli_gender_widget.dart';
import 'package:astrowaypartner/widgets/FreeKundliWidget/kundli_name_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../KundliMatching/payment/PaymentInformationScreen.dart';

class CreateNewKundki extends StatefulWidget {
  const CreateNewKundki({super.key});

  @override
  State<CreateNewKundki> createState() => _CreateNewKundkiState();
}

class _CreateNewKundkiState extends State<CreateNewKundki> {
  final KundliController kundliController = Get.find<KundliController>();

  final WalletController walletcontroller = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        width: double.infinity,
        height: Get.height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topLeft,
              colors: [
                Get.theme.primaryColor,
                Colors.white,
              ]),
        ),
        child: SingleChildScrollView(
          child: GetBuilder<KundliController>(builder: (c) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                        onTap: () => Get.back(),
                        child: const Icon(
                          Icons.arrow_back_ios,
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('Kundli',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium)
                        .tr()
                  ],
                ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 5,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: kundliController.listIcon[index].isSelected!
                            ? CircleAvatar(
                                radius: 13,
                                backgroundColor: COLORS().primaryColor,
                                child: Icon(
                                  kundliController
                                      .listIcon[kundliController.initialIndex]
                                      .icon,
                                  size: 15,
                                  color: Colors.black,
                                ),
                              )
                            : kundliController.initialIndex >= index
                                ? GestureDetector(
                                    onTap: () {
                                      kundliController
                                          .backStepForCreateKundli(index);
                                      kundliController.updateIcon(
                                          kundliController.initialIndex);
                                    },
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: COLORS().primaryColor,
                                    ),
                                  )
                                : const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.grey,
                                  ),
                      );
                    },
                  ),
                ),
                CreateKundliTitleWidget(
                  title: kundliController.initialIndex == 0
                      ? kundliController.kundliTitle[0]
                      : kundliController.initialIndex == 1
                          ? kundliController.kundliTitle[1]
                          : kundliController.initialIndex == 2
                              ? kundliController.kundliTitle[2]
                              : kundliController.initialIndex == 3
                                  ? kundliController.kundliTitle[3]
                                  : kundliController.kundliTitle[4],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (kundliController.initialIndex == 0)
                  KundliNameWidget(
                    kundliController: kundliController,
                    onPressed: () {
                      if (!kundliController.isDisable) {
                        kundliController.updateInitialIndex();
                        kundliController
                            .updateIcon(kundliController.initialIndex);
                      }
                    },
                  ),
                if (kundliController.initialIndex == 1)
                  KundliGenderWidget(
                    kundliController: kundliController,
                  ),
                if (kundliController.initialIndex == 2)
                  KundliBrithDateWidget(
                    kundliController: kundliController,
                    onPressed: () {
                      kundliController.updateInitialIndex();
                      kundliController
                          .updateIcon(kundliController.initialIndex);
                    },
                  ),
                if (kundliController.initialIndex == 3)
                  KundliBirthTimeWidget(
                    kundliController: kundliController,
                    onPressed: () {
                      kundliController.updateInitialIndex();
                      kundliController
                          .updateIcon(kundliController.initialIndex);
                    },
                  ),
                if (kundliController.initialIndex == 4)
                  KundliBornPlaceWidget(
                    kundliController: kundliController,
                    onPresseds: () async {
                      log('kundli type is ${kundliController.kundaliType}');
                      log('kundli wallet amount is ${walletcontroller.withdraw.walletAmount}');

                      if (kundliController.kundaliType == "small"
                          ? (kundliController.pdfPriceData!.isFreeSession ==
                                  true
                              ? false
                              : walletcontroller.withdraw.walletAmount! <
                                  int.parse(kundliController
                                      .pdfPriceData!.recordList!.small
                                      .toString()))
                          : kundliController.kundaliType == "medium"
                              ? (walletcontroller.withdraw.walletAmount! <
                                  int.parse(kundliController
                                      .pdfPriceData!.recordList!.medium
                                      .toString()))
                              : kundliController.kundaliType == "large"
                                  ? (walletcontroller.withdraw.walletAmount! <
                                      int.parse(kundliController
                                          .pdfPriceData!.recordList!.large
                                          .toString()))
                                  : false) {
                        openBottomSheetRechrage(
                            context, walletcontroller.minBalance);
                      } else {
                        if (kundliController.birthKundliPlaceController.text ==
                            "") {
                          global.showToast(
                            message: 'Please select birth place',
                          );
                        } else {
                          kundliController
                              .updateIcon(kundliController.initialIndex);
                          global.showOnlyLoaderDialog();
                          await kundliController.addKundliData(
                            false,
                            kundliController.kundaliType.toString() == "large"
                                ? int.parse(kundliController
                                    .pdfPriceData!.recordList!.large
                                    .toString())
                                : (kundliController.kundaliType.toString() ==
                                        "medium"
                                    ? int.parse(kundliController
                                        .pdfPriceData!.recordList!.medium
                                        .toString())
                                    : (kundliController.kundaliType
                                                .toString() ==
                                            "small"
                                        ? int.parse(kundliController
                                            .pdfPriceData!.recordList!.small
                                            .toString())
                                        : 0)),
                            Get.locale!.languageCode, //language code
                          );
                          await kundliController.getKundliList();
                          kundliController.initialIndex = 0;
                          global.hideLoader();
                          Get.back();
                        }
                      }
                      // if (kundliController.birthKundliPlaceController.text ==
                      //     "") {
                      //   global.showToast(
                      //       message: tr('Please select birth place'));
                      // } else {
                      //   kundliController
                      //       .updateIcon(kundliController.initialIndex);
                      //   await kundliController.addKundliData(false);
                      //   await kundliController.getKundliList();
                      //   kundliController.initialIndex = 0;
                      //   Get.back();
                      // }
                    },
                  )
              ],
            );
          }),
        ),
      ),
    ));
  }

  void openBottomSheetRechrage(
    BuildContext context,
    int minBalance,
  ) {
    Get.bottomSheet(
      SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.85,
                                  child: minBalance != 0
                                      ? Text('Minimum balance (${global.getSystemFlagValue(global.systemFlagNameList.currency)} $minBalance) is required to Create Kundali',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.red))
                                          .tr()
                                      : const SizedBox(),
                                ),
                                GestureDetector(
                                  child: Padding(
                                    padding: minBalance == 0
                                        ? const EdgeInsets.only(top: 8)
                                        : const EdgeInsets.only(top: 0),
                                    child: const Icon(Icons.close, size: 18),
                                  ),
                                  onTap: () {
                                    Get.back();
                                  },
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 5),
                              child: const Text('Recharge Now',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))
                                  .tr(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Icon(Icons.lightbulb_rounded,
                                      color: Get.theme.primaryColor, size: 13),
                                ),
                                Expanded(
                                    child: Text(
                                            'Minimum balance required ${global.getSystemFlagValue(global.systemFlagNameList.currency)} $minBalance',
                                            style:
                                                const TextStyle(fontSize: 12))
                                        .tr())
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 3.8 / 2.3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: walletcontroller.rechrage.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => PaymentInformationScreen(
                              flag: 0,
                              amount: double.parse(
                                  walletcontroller.payment[index])));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                                child: Text(
                              '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${walletcontroller.rechrage[index]}',
                              style: const TextStyle(fontSize: 13),
                            )),
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.8),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }
}
