// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/kundli_matchig_controller.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/KundliMatching/kundaliDialog.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/KundliMatching/Tabs/new_matching_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/KundliMatching/Tabs/open_kundli_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../controllers/free_kundli_controller.dart';

class KundliMatchingScreen extends StatelessWidget {
  KundliMatchingScreen({super.key});

  KundliController kundliController = Get.find<KundliController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<KundliMatchingController>(builder: (controller) {
        return Scaffold(
          appBar: MyCustomAppBar(
            height: 80,
            backgroundColor: COLORS().primaryColor,
            title: Text(
              "Kundli Matching",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ).tr(),
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage("assets/images/chat_background.jpg"),
              ),
            ),
            child: DefaultTabController(
                length: 2,
                initialIndex: controller.currentIndex,
                child: Column(
                  children: [
                    SizedBox(
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TabBar(
                            unselectedLabelColor: Colors.black,
                            labelColor: Colors.black,
                            indicatorWeight: 0.1,
                            indicatorColor: Colors.blue,
                            labelPadding: EdgeInsets.zero,
                            tabs: [
                              controller.homeTabIndex == 0
                                  ? Container(
                                      height: Get.height,
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: COLORS().primaryColor,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                          topLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Center(
                                          child:
                                              const Text('Open Kundli').tr()),
                                    )
                                  : Center(
                                      child: const Text('Open Kundli').tr(),
                                    ),
                              controller.homeTabIndex == 1
                                  ? Container(
                                      height: Get.height,
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: COLORS().primaryColor,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          topLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Center(
                                          child:
                                              const Text('New Matching').tr()),
                                    )
                                  : Center(
                                      child: const Text('New Matching').tr(),
                                    ),
                            ],
                            onTap: (index) {
                              controller.onHomeTabBarIndexChanged(index);
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: controller.homeTabIndex == 1
                          ?
//First Tabbar
                          NewMatchingScreen()
                          :
//Second Tabbar
                          OpenKundliScreen(),
                    )
                  ],
                )),
          ),
          bottomNavigationBar: controller.homeTabIndex == 1
              ? Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("assets/images/chat_background.jpg"),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: COLORS().primaryColor,
                        maximumSize:
                            Size(MediaQuery.of(context).size.width, 100),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width, 48),
                      ),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();

                        controller.addAllDataonList();
                        //ADD Form values in map to check if all values are present later

                        bool isvalid = controller.validateInputs();
                        if (isvalid) {
                          _showMyDialog(context);
                        } else {
                          log('all field requred');
                        }
                      },
                      child: const Text(
                        "Match Horoscope",
                        style: TextStyle(color: Colors.black),
                      ).tr(),
                    ),
                  ),
                )
              : const SizedBox(),
        );
      }),
    );
  }

  bool areAllValuesPresent(KundliMatchingController controller) {
    // Check if all values are not null
    return controller.userValidationData.values
        .every((value) => value != null && value.isNotEmpty);
  }
}

void _showMyDialog(BuildContext context) async {
  await showCupertinoDialog(
    context: context,
    builder: (context) {
      return const KundliDialog();
    },
  );
}
