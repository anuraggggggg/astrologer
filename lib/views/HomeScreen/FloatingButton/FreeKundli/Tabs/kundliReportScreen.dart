// ignore_for_file: file_names

import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/reportTabs/doshaReport.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/reportTabs/generalReportScreen.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/reportTabs/remediesKundli.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KundliReportScreen extends StatelessWidget {
  const KundliReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(indicatorColor: Get.theme.primaryColor, tabs: [
            Container(
                height: 35,
                alignment: Alignment.center,
                child:
                    const Text('General', style: TextStyle(fontSize: 13)).tr()),
            Container(
                height: 35,
                alignment: Alignment.center,
                child: const Text('Remedies', style: TextStyle(fontSize: 13))
                    .tr()),
            Container(
                height: 35,
                alignment: Alignment.center,
                child:
                    const Text('Dosha', style: TextStyle(fontSize: 13)).tr()),
          ]),
          SizedBox(
            height: Get.height - 180,
            child: TabBarView(
              children: [GeneralReport(), RemediesKundli(), DoshaReport()],
            ),
          )
        ],
      ),
    );
  }
}
