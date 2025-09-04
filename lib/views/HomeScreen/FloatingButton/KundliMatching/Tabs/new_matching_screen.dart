// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:astrowaypartner/controllers/kundli_matchig_controller.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/KundliMatching/place_of_birth_screen.dart';
import 'package:astrowaypartner/widgets/common_padding_2.dart';
import 'package:astrowaypartner/widgets/common_small_%20textfield_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewMatchingScreen extends StatelessWidget {
  NewMatchingScreen({super.key});
  final kundliMatchingController = Get.find<KundliMatchingController>();

  @override
  Widget build(BuildContext context) {
    return CommonPadding2(
      child: GetBuilder<KundliMatchingController>(builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
//-------------------------------------------Boys Details -----------------------------------------
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CommonPadding2(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Boy's Details",
                          style: Get.theme.primaryTextTheme.displayMedium,
                        ).tr(),
                      ),
                      CommonSmallTextFieldWidget(
                        controller: controller.cBoysName,
                        titleText: "Name",
                        hintText: tr("Enter Name"),
                        keyboardType: TextInputType.text,
                        preFixIcon: Icons.person_outline,
                        maxLines: 1,
                        onFieldSubmitted: (p0) {},
                        onTap: () {},
                      ),
                      CommonSmallTextFieldWidget(
                        controller: controller.cBoysBirthDate,
                        titleText: "Birth Date",
                        hintText: tr("Select Your Birth Date"),
                        readOnly: true,
                        maxLines: 1,
                        preFixIcon: Icons.calendar_month,
                        onFieldSubmitted: (p0) {},
                        onTap: () {
                          _boySelectDate(context);
                        },
                      ),
                      CommonSmallTextFieldWidget(
                        controller: controller.cBoysBirthTime,
                        titleText: "Birth Time",
                        hintText: tr("Select Your Birth Time"),
                        readOnly: true,
                        maxLines: 1,
                        preFixIcon: Icons.schedule,
                        onFieldSubmitted: (p0) {},
                        onTap: () {
                          _boySelectBirthDateTime(context);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: CommonSmallTextFieldWidget(
                          controller: controller.cBoysBirthPlace,
                          titleText: "Birth Place",
                          hintText: tr("Select Your Birth Place"),
                          readOnly: true,
                          maxLines: 1,
                          preFixIcon: Icons.place,
                          onFieldSubmitted: (p0) {},
                          onTap: () {
                            Get.to(() => PlaceOfBirthSearchScreen(flagId: 1));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
//---------------------------------Girls Details--------------------------------------------------------
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CommonPadding2(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Girl's Details",
                          style: Get.theme.primaryTextTheme.displayMedium,
                        ).tr(),
                      ),
                      CommonSmallTextFieldWidget(
                        controller: controller.cGirlName,
                        titleText: "Name",
                        hintText: tr("Enter Name"),
                        keyboardType: TextInputType.text,
                        preFixIcon: Icons.person_outline,
                        maxLines: 1,
                        onFieldSubmitted: (p0) {},
                        onTap: () {},
                      ),
                      CommonSmallTextFieldWidget(
                        controller: controller.cGirlBirthDate,
                        titleText: "Birth Date",
                        hintText: tr("Select Your Birth Date"),
                        readOnly: true,
                        maxLines: 1,
                        preFixIcon: Icons.calendar_month,
                        onFieldSubmitted: (p0) {},
                        onTap: () {
                          _girlSelectDate(context);
                        },
                      ),
                      CommonSmallTextFieldWidget(
                        controller: controller.cGirlBirthTime,
                        titleText: "Birth Time",
                        hintText: tr("Select Your Birth Time"),
                        readOnly: true,
                        maxLines: 1,
                        preFixIcon: Icons.schedule,
                        onFieldSubmitted: (p0) {},
                        onTap: () {
                          _girlSelectBirthDateTime(context);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: CommonSmallTextFieldWidget(
                          controller: controller.cGirlBirthPlace,
                          titleText: "Birth Place",
                          hintText: tr("Select Your Birth Place"),
                          readOnly: true,
                          maxLines: 1,
                          preFixIcon: Icons.place,
                          onFieldSubmitted: (p0) {},
                          onTap: () {
                            Get.to(() => PlaceOfBirthSearchScreen(
                                  flagId: 2,
                                ));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  //Boys Date of Birth
  Future _boySelectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            textButtonTheme: TextButtonThemeData(
              style:
                  TextButton.styleFrom(foregroundColor: Get.theme.primaryColor),
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      kundliMatchingController.onBoyDateSelected(picked);
    }
  }

//Boy Select Birthdate Time
  Future _boySelectBirthDateTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            textButtonTheme: TextButtonThemeData(
              style:
                  TextButton.styleFrom(foregroundColor: Get.theme.primaryColor),
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      int hour = pickedTime.hour;
      String minute = pickedTime.minute.toString();
      if (pickedTime.minute <= 9) {
        minute = '0${pickedTime.minute}';
      }
      String serverTime = '$hour:$minute';
      String time = pickedTime.format(context);
      debugPrint('User time is $time');
      debugPrint('Server boy time is $serverTime');
      kundliMatchingController.onboyApiTime(serverTime);

      kundliMatchingController.cBoysBirthTime.text = serverTime;
      kundliMatchingController.update();
    } else {
      print("Time is not selected");
    }
  }

  //Girl Date of Birth
  Future _girlSelectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            textButtonTheme: TextButtonThemeData(
              style:
                  TextButton.styleFrom(foregroundColor: Get.theme.primaryColor),
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      kundliMatchingController.onGirlDateSelected(picked);
    }
  }

//Girl Select Birthdate Time
  Future _girlSelectBirthDateTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            textButtonTheme: TextButtonThemeData(
              style:
                  TextButton.styleFrom(foregroundColor: Get.theme.primaryColor),
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      print(pickedTime); //output 10:51 PM
      int hour = pickedTime.hour;
      String minute = pickedTime.minute.toString();
      if (pickedTime.minute <= 9) {
        minute = '0${pickedTime.minute}';
      }
      String serverTime = '$hour:$minute';
      String time = pickedTime.format(context);
      debugPrint('User time is $time');
      debugPrint('Server Girl time is $serverTime');
      kundliMatchingController.ongirlApiTIme(serverTime);
      kundliMatchingController.cGirlBirthTime.text = serverTime;

      kundliMatchingController.update();
    } else {
      print("Time is not selected");
    }
  }
}
