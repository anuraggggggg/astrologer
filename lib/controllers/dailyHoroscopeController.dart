// ignore_for_file: file_names, prefer_interpolation_to_compose_strings, avoid_print, non_constant_identifier_names

import 'package:astrowaypartner/models/dailyHoroscopeModel.dart';
import 'package:astrowaypartner/services/apiHelper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../models/dailyHororscopeModelVedic.dart';

class DailyHoroscopeController extends GetxController {
  APIHelper apiHelper = APIHelper();
  List zodiac = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricornus',
    'Aquarius',
    'Pisces'
  ];

  List dailyHoroscopeCate = ['Love', 'Career', 'Money', 'Health', 'Travel'];
  List borderColor = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple
  ];
  List containerColor = const [
    Color.fromARGB(255, 241, 223, 220),
    Color.fromARGB(255, 248, 233, 211),
    Color.fromARGB(255, 226, 248, 227),
    Color.fromARGB(255, 218, 234, 247),
    Color.fromARGB(255, 242, 227, 245)
  ];
  bool isToday = true;
  bool isYesterday = false;
  bool isTomorrow = false;
  bool isMonth = true;
  bool isWeek = false;
  bool isYear = false;
  int? signId;
  String SignName = "Pisces";
  int day = 2;
  DailyscopeModel? dailyList;
  VedicList? vedicdailyList;

  int zodiacindex = 0;
  Map<String, dynamic> dailyHororscopeData = {};

  updateDaily(int flag) {
    day = flag;
    update();
  }

  int calltype = 3;
  updatecalltype(int index) {
    calltype = index;
    update();
  }

  @override
  Future onInit() async {
    super.onInit();
    await getHororScopeSignData();
    await getDefaultDailyHororscope();
    if (global.hororscopeSignList.isNotEmpty) {
      debugPrint('horoscopeId-> ${global.hororscopeSignList[0].id}');

      await getHoroscopeList(horoscopeId: global.hororscopeSignList[0].id);
    }
  }

  updateTimely({bool? month, bool? year, bool? week}) {
    isMonth = month!;
    isWeek = week!;
    isYear = year!;
    update();
  }

  Future getDefaultDailyHororscope() async {
    try {
      if (global.hororscopeSignList.isNotEmpty) {
        global.hororscopeSignList[0].isSelected = true;
      }
    } catch (e) {
      print('Exception in getDefaultDailyHororscope():' + e.toString());
    }
  }

  selectZodic(int index) async {
    await getHororScopeSignData();
    global.hororscopeSignList.map((e) => e.isSelected = false).toList();
    global.hororscopeSignList[index].isSelected = true;
    zodiacindex = index;
    signId = global.hororscopeSignList[index].id;
    SignName = global.hororscopeSignList[index].name;
    update();
  }

  Future getHororScopeSignData() async {
    try {
      if (global.hororscopeSignList.isEmpty) {
        await global.checkBody().then((result) async {
          if (result) {
            await apiHelper.getHororscopeSign().then((result) {
              if (result.status == "200") {
                global.hororscopeSignList = result.recordList;
                update();
              } else {
                global.showToast(message: "No daily hororScope");
              }
            });
          }
        });
      }
    } catch (e) {
      print('Exception in getHororScopeSignData():' + e.toString());
    }
  }

  getHoroscopeList({int? horoscopeId}) async {
    try {
      dailyList = null;
      vedicdailyList = null;

      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .getHoroscope(horoscopeSignId: horoscopeId)
              .then((result) {
            if (result != null) {
              // debugPrint('respone result Horoscope-> $result');
              // debugPrint(
              //     'Global Calltype-> ${dailyhoroscopeController.calltype}');

              if (dailyhoroscopeController.calltype == 2) {
                Map<String, dynamic> map = result;
                dailyList = DailyscopeModel.fromJson(map);
              } else if (dailyhoroscopeController.calltype == 3) {
                // debugPrint(
                //     'inside calltype ${dailyhoroscopeController.calltype}');
                // debugPrint('result data $result');

                Map<String, dynamic> nmap = result;
                vedicdailyList = VedicList.fromJson(nmap);
              }

              update();
            } else {
              if (global.currentUserId != null) {
                global.showToast(message: 'Not show daily horoscope');
              }
            }
          });
        }
      });
    } catch (e) {
      print('Exception in getHoroscopeList():' + e.toString());
    }
  }
}
