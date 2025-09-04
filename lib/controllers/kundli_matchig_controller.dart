// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:developer';

import 'package:astrowaypartner/models/kundli_add_model.dart';
import 'package:astrowaypartner/models/kundlimodelAdd.dart';
import 'package:astrowaypartner/models/north_kundli_model.dart';
import 'package:astrowaypartner/models/southKundliModel.dart';
import 'package:astrowaypartner/services/apiHelper.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/KundliMatching/north_kundli_match_result_screen.dart';
import 'package:date_format/date_format.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../models/kundliModel.dart';
import '../views/HomeScreen/FloatingButton/KundliMatching/south_kundali_matching_screen.dart';

class KundliMatchingController extends GetxController {
//Tab Manage
  final int currentIndex = 0;
  String? errorMessage;
  int? boykundliId;
  int? girlKundliId;
  int? minGirls;
  int? minBoy;
  int? hourGirl;
  double? lat;
  double? long;
  double? timeZone;
  int? hourBoy;
  bool? isFemaleManglik;
  bool? isMaleManglik;
  APIHelper apiHelper = APIHelper();
  NorthKundaliMatchingModel? northkundliMatchDetailList;
  SouthKundaliMatchingModel? southkundliMatchDetailList;
  KundliReceiveModel? recordList;

  TabController? kundliMatchingTabController;
  String selectedDirection = 'North';

  List<String> requiredKeys = [
    'boysName',
    'boysBirthDate',
    'boysBirthTime',
    'boysBirthPlace',
    'girlName',
    'girlBirthDate',
    'girlBirthTime',
    'girlBirthPlace',
  ];
  Map<String, String?> userValidationData = {};
  onValidation(String key, String? value) {
    debugPrint('adding key $key and value $value');
    userValidationData[key] = value;
    update();
  }

  double boy_lat = 0.0;
  double boylong = 0.0;
  double girl_lat = 0.0;
  double girl_long = 0.0;
  double boy_timezone = 0.0;
  double girl_timezone = 0.0;
  String? girlapiTime, boyapiTime;
  String? boyBirthTime, girlBirthTime;

  ongirlApiTIme(String value) {
    girlapiTime = value;
    debugPrint('girlapiTime is $girlapiTime');
    update();
  }

  void addAllDataonList() {
    onValidation('boysName', cBoysName.text);
    onValidation('boysBirthDate', cBoysBirthDate.text);
    onValidation('boysBirthTime', cBoysBirthTime.text);
    onValidation('boysBirthPlace', cBoysBirthPlace.text);

    onValidation('girlName', cGirlName.text);
    onValidation('girlBirthDate', cGirlBirthDate.text);
    onValidation('girlBirthTime', cGirlBirthTime.text);
    onValidation('girlBirthPlace', cGirlBirthPlace.text);
  }

  onboyApiTime(String value) {
    boyapiTime = value;
    debugPrint('boyapiTime is $boyapiTime');
    update();
  }

  onDireactionChanged(String value) {
    selectedDirection = value;
    debugPrint('direaction is $value');
    update();
  }

  int homeTabIndex = 0;
  onHomeTabBarIndexChanged(value) {
    homeTabIndex = value;
    update();
  }

//Boys Name
  final TextEditingController cBoysName = TextEditingController();
//Boys Birth Date
  final TextEditingController cBoysBirthDate = TextEditingController();
  DateTime? boySelectedDate;
  onBoyDateSelected(DateTime? picked) {
    if (picked != null && picked != boySelectedDate) {
      boySelectedDate = picked;

      cBoysBirthDate.text = boySelectedDate.toString();
      cBoysBirthDate.text =
          formatDate(boySelectedDate!, [dd, '-', mm, '-', yyyy]);
    }
    debugPrint('date is boy $boySelectedDate');
    update();
  }

  bool isValidData() {
    if (cBoysName.text == "") {
      errorMessage = "Please Input boy's detail";
      update();
      return false;
    } else if (cGirlName.text == "") {
      errorMessage = "Please Input Girl's detail";
      update();
      return false;
    } else {
      return true;
    }
  }

  int alreadycreatedmale = 1;
  int alreadycreatedfemale = 1;

//!
  openKundliData(List<KundliModel> kundliList, int index) {
    if (kundliList[index].gender == "Male") {
      boykundliId = kundliList[index].id;
      boy_timezone = kundliList[index].timezone!.toDouble();

      onBoyDateSelected(kundliList[index].birthDate);
      boylong = kundliList[index].longitude ?? 0.0;

      cBoysName.text = kundliList[index].name;
      alreadycreatedmale = 0;

      cBoysBirthDate.text =
          formatDate(kundliList[index].birthDate, [dd, '-', mm, '-', yyyy]);

      cBoysBirthTime.text = kundliList[index].birthTime.toString();

      cBoysBirthPlace.text = kundliList[index].birthPlace.toString();
      boy_lat = kundliList[index].latitude ?? 0.0;

      update();
    } else if (kundliList[index].gender == "Female") {
      girl_long = kundliList[index].longitude ?? 0.0;
      girlKundliId = kundliList[index].id;
      girl_timezone = kundliList[index].timezone!.toDouble();

      alreadycreatedfemale = 0;
      onGirlDateSelected(kundliList[index].birthDate);
      cGirlName.text = kundliList[index].name;
      cGirlBirthDate.text =
          formatDate(kundliList[index].birthDate, [dd, '-', mm, '-', yyyy]);
      cGirlBirthTime.text = kundliList[index].birthTime.toString();
      cGirlBirthPlace.text = kundliList[index].birthPlace.toString();
      girl_lat = kundliList[index].latitude ?? 0.0;

      update();
    }
  }

  addKundliMatchData(bool ismatching) async {
    global.showOnlyLoaderDialog();

    print('111 boy lat -> $boy_lat ');
    print('111 boy long -> $boylong ');
    print('111 boy boykundliId -> $boykundliId ');
    print('111 boy namet -> ${cBoysName.text} ');
    print('111 boy birthDate -> $boySelectedDate ');
    print('111 boy birthPlace -> ${cBoysBirthPlace.text} ');
    print('111 boy timezone -> $boy_timezone ');

    print('111 girllat -> $girl_lat ');
    print('111 girl long -> $girl_long ');
    print('111 girl  girlKundliId -> $girlKundliId ');
    print('111 girl name -> ${cGirlName.text} ');
    print('111 girl birthDate -> $girlSelectedDate ');
    print('111 girl birthPlace -> ${cGirlBirthPlace.text} ');
    print('111 girl girl_timezone -> $girl_timezone ');

    if (cBoysBirthTime.text.isNotEmpty) {
      List<String> parts = cBoysBirthTime.text.split(':');
      int hours = int.parse(parts[0]);

      if (hours <= 9) {
        parts[0] = '0$hours';
      }

      boyBirthTime = '${parts[0]}:${parts[1]}';
      print('111 birthTime -> $boyBirthTime ');
    }

    if (cGirlBirthTime.text.isNotEmpty) {
      List<String> parts = cGirlBirthTime.text.split(':');
      int hours = int.parse(parts[0]);

      if (hours <= 9) {
        parts[0] = '0$hours';
      }

      girlBirthTime = '${parts[0]}:${parts[1]}';
      print('111 girl birthTime -> $girlBirthTime ');
    }

    validateInputs();
    String lang = Get.locale!.languageCode;
    log('language code $lang');

    // ignore: unused_local_variable
    KundliModelAdd sendKundli;
    List<KundliModelAdd> kundliModel = [
      KundliModelAdd(
          language: lang,
          id: boykundliId,
          name: cBoysName.text,
          gender: 'Male',
          birthDate: boySelectedDate!,
          birthTime: boyBirthTime!,
          birthPlace: cBoysBirthPlace.text,
          pdf_type: 'small',
          latitude: boy_lat,
          longitude: boylong,
          match_type: selectedDirection,
          timezone: boy_timezone,
          forMatch: alreadycreatedmale), //1 not show 0 =show
      KundliModelAdd(
        language: lang,
        id: girlKundliId,
        name: cGirlName.text,
        gender: 'Female',
        birthDate: girlSelectedDate!,
        birthTime: girlBirthTime!,
        birthPlace: cGirlBirthPlace.text,
        pdf_type: 'small',
        latitude: girl_lat,
        longitude: girl_long,
        match_type: selectedDirection,
        timezone: girl_timezone,
        forMatch: alreadycreatedfemale,
      )
    ];

    // int ind = cBoysBirthTime.text.indexOf(":");
    // int ind2 = cGirlBirthTime.text.indexOf(":");
    // hourBoy = int.parse(cBoysBirthTime.text.substring(0, ind));
    // hourGirl = int.parse(cGirlBirthTime.text.substring(0, ind2));
    // minBoy = int.parse(cBoysBirthTime.text.substring(ind + 1, ind + 3));
    //minGirls = int.parse(cGirlBirthTime.text.substring(ind + 1, ind + 3));
    update();

    await global.checkBody().then((result) async {
      if (result) {
        await apiHelper
            .addKundli(kundliModel, ismatching, 0)
            .then((result) async {
          debugPrint('status is ${result.status}');
          if (result.status == "200") {
            List<dynamic> map = result.recordList;
            int boyId =
                map.firstWhere((person) => person['gender'] == 'Male')['id'];
            boykundliId = boyId;
            int girlId =
                map.firstWhere((person) => person['gender'] == 'Female')['id'];
            girlKundliId = girlId;

            update();

            getKundlMatchingiList(boyId, girlId);

            global.hideLoader();
          } else {
            global.hideLoader();
            global.showToast(
                message: "Failed to add kundli please try again later!");
          }
        });
      }
    });
  }

  getKundlMatchingiList(int boyid, int girlid) async {
    try {
      northkundliMatchDetailList = null;
      southkundliMatchDetailList = null;

      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getMatching(boyid, girlid).then((result) async {
            if (result != null) {
              print('selectedDirection $selectedDirection');
              print('boyid $boyid');
              print('girlid $girlid');

              if (selectedDirection == 'North') {
                Map<String, dynamic> map = result;
                northkundliMatchDetailList =
                    NorthKundaliMatchingModel.fromJson(map);
                global.showOnlyLoaderDialog();
                await Future.delayed(const Duration(milliseconds: 100));
                global.hideLoader();

                update();

                Get.to(() => const NorthKundliMatchingScreen());
              } else {
                Map<String, dynamic> map = result;
                southkundliMatchDetailList =
                    SouthKundaliMatchingModel.fromJson(map);
                await Future.delayed(const Duration(milliseconds: 100));

                update();

                Get.to(() => const SouthKundliMatchingScreen());
              }
            } else {}
          });
        }
      });
    } catch (e) {
      print('Exception in getKundliList():$e');
    }
  }

  getKundlMagllicList(DateTime kundliBoys, DateTime kundliGirls) async {
    try {
      northkundliMatchDetailList = null;
      southkundliMatchDetailList = null;
      DateTime datePanchang = kundliBoys;
      int formattedYear = int.parse(DateFormat('yyyy').format(datePanchang));
      int formattedDay = int.parse(DateFormat('dd').format(datePanchang));
      int formattedMonth = int.parse(DateFormat('MM').format(datePanchang));
      DateTime dateForGirl = kundliGirls;
      int yearGirl = int.parse(DateFormat('yyyy').format(dateForGirl));
      int dayGirl = int.parse(DateFormat('dd').format(dateForGirl));
      int monthGirl = int.parse(DateFormat('MM').format(dateForGirl));
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .getManglic(formattedDay, formattedMonth, formattedYear, hourBoy,
                  minBoy, dayGirl, monthGirl, yearGirl, hourGirl, minGirls)
              .then((result) {
            if (result != null) {
              isFemaleManglik = result['female']['is_present'];
              isMaleManglik = result['male']['is_present'];
              update();
            } else {}
          });
        }
      });
    } catch (e) {
      print('Exception in getKundliList():$e');
    }
  }

//Boys Birthdate Time
  final cBoysBirthTime = TextEditingController();
//Boys Birth Place
  final cBoysBirthPlace = TextEditingController();

//Girls Name
  final cGirlName = TextEditingController();
//Girls Birth Date
  final cGirlBirthDate = TextEditingController();
  DateTime? girlSelectedDate;
  onGirlDateSelected(DateTime? picked) {
    if (picked != null && picked != girlSelectedDate) {
      girlSelectedDate = picked;

      cGirlBirthDate.text = girlSelectedDate.toString();
      cGirlBirthDate.text =
          formatDate(girlSelectedDate!, [dd, '-', mm, '-', yyyy]);
    }
    update();
  }

//Girls Birthdate Time
  final TextEditingController cGirlBirthTime = TextEditingController();
//Girls Birth Place
  final TextEditingController cGirlBirthPlace = TextEditingController();
  // Validate input values
  bool validateInputs() {
    if (boy_lat == 0.0) {
      global.showToast(message: "Please enter boy's latitude");
      return false;
    }

    if (boylong == 0.0) {
      global.showToast(message: "Please enter boy's longitude");
      return false;
    }

    if (cBoysName.text.isEmpty) {
      global.showToast(message: "Please enter boy's name");
      return false;
    }

    if (boySelectedDate == null) {
      global.showToast(message: "Please select boy's birth date");
      return false;
    }

    if (cBoysBirthTime.text.isEmpty) {
      global.showToast(message: "Please enter boy's birth time");
      return false;
    }

    if (cBoysBirthPlace.text.isEmpty) {
      global.showToast(message: "Please enter boy's birth place");
      return false;
    }

    if (girl_lat == 0.0) {
      global.showToast(message: "Please enter girl's latitude");
      return false;
    }

    if (girl_long == 0.0) {
      global.showToast(message: "Please enter girl's longitude");
      return false;
    }

    if (cGirlName.text.isEmpty) {
      global.showToast(message: "Please enter girl's name");
      return false;
    }

    if (cGirlBirthTime.text.isEmpty) {
      global.showToast(message: "Please enter girl's birth time");
      return false;
    }

    if (girlSelectedDate == null) {
      global.showToast(message: "Please select girl's birth date");
      return false;
    }

    if (cGirlBirthPlace.text.isEmpty) {
      global.showToast(message: "Please enter girl's birth place");
      return false;
    }

    return true;
  }
}
