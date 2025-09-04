// ignore_for_file: non_constant_identifier_names, must_be_immutable, import_of_legacy_library_into_null_safe

import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';

class KundliBirthTimeWidget extends StatelessWidget {
  final KundliController kundliController;
  final void Function()? onPressed;
  const KundliBirthTimeWidget(
      {super.key, required this.kundliController, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TimePickerSpinner(
          onTimeChange: (date) {
            kundliController.getSelectedTime(date);
          },
          is24HourMode: false,
          normalTextStyle: const TextStyle(fontSize: 15, color: Colors.black),
          highlightedTextStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
                value: kundliController.isTimeOfBirthKnow,
                activeColor: Colors.black,
                onChanged: (bool? value) {
                  kundliController.updateCheck(value);
                }),
            Text(
              'Dont\'t know my exact time of birth',
              style: Get.textTheme.titleMedium!
                  .copyWith(fontSize: 12, color: Colors.black),
            ).tr()
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          child: Text(
            'Note:Without time of birth,we can still achive upto 80% accurate predictions',
            style: Get.textTheme.titleMedium!
                .copyWith(fontSize: 12, color: Colors.grey),
          ).tr(),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
              backgroundColor:
                  WidgetStateProperty.all(Get.theme.primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.grey)),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              'Next',
              textAlign: TextAlign.center,
              style: Get.theme.primaryTextTheme.titleMedium,
            ).tr(),
          ),
        ),
      ],
    );
  }
}
