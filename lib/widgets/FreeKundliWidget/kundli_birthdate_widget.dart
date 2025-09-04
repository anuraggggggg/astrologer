import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:get/get.dart';

class KundliBrithDateWidget extends StatelessWidget {
  final KundliController kundliController;
  final void Function()? onPressed;
  const KundliBrithDateWidget(
      {super.key, required this.kundliController, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 250,
          child: DatePickerWidget(
            looping: false,
            dateFormat: "dd/MMMM/yyyy",
            onChange: (dateTime, selectedIndex) {
              kundliController.getselectedDate(dateTime);
            },
            initialDate: DateTime(1996),
            firstDate: DateTime(1960),
            lastDate: DateTime.now().subtract(const Duration(days: 1)),
            pickerTheme: const DateTimePickerTheme(
              backgroundColor: Colors.transparent,
            ),
          ),
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
