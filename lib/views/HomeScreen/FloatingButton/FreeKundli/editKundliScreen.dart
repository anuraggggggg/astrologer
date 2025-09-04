// ignore_for_file: file_names

import 'package:astrowaypartner/views/HomeScreen/FloatingButton/KundliMatching/place_of_birth_screen.dart';
import 'package:astrowaypartner/widgets/common_small_%20textfield_widget.dart';
import 'package:date_format/date_format.dart';
import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

class EditKundliScreen extends StatelessWidget {
  final int id;
  const EditKundliScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: Get.width,
          height: Get.height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topLeft,
              colors: [Get.theme.primaryColor, Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            child: GetBuilder<KundliController>(builder: (kundliController) {
              return Column(
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
                      Text('Edit Kundli', style: Get.textTheme.titleMedium).tr()
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        CommonSmallTextFieldWidget(
                          controller: kundliController.editNameController,
                          titleText: "",
                          hintText: tr("Enter Name"),
                          keyboardType: TextInputType.text,
                          preFixIcon: Icons.person_outline,
                          maxLines: 1,
                          onFieldSubmitted: (p0) {},
                          onTap: () {},
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.transgender,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 2,
                                child: DropdownButton(
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    icon: const SizedBox(),
                                    alignment: Alignment.bottomLeft,
                                    value: kundliController.innitialValue(
                                        1, ['Male', 'Female', 'Other']),
                                    hint: const Text('hint').tr(),
                                    items: ['Male', 'Female', 'Other']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                          value: value,
                                          child: Center(
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                value,
                                                style: Get.theme
                                                    .primaryTextTheme.bodyLarge,
                                                textAlign: TextAlign.start,
                                              ).tr(),
                                            ),
                                          ));
                                    }).toList(),
                                    onChanged: (value) {
                                      kundliController.genderChoose(value!);
                                    }),
                              ),
                            ],
                          ),
                        ),
                        CommonSmallTextFieldWidget(
                          controller: kundliController.editBirthDateController,
                          titleText: "",
                          hintText: "Select Your Birth Date",
                          readOnly: true,
                          maxLines: 1,
                          preFixIcon: Icons.calendar_month,
                          onFieldSubmitted: (p0) {},
                          onTap: () {
                            _selectDate(context, kundliController);
                          },
                        ),
                        CommonSmallTextFieldWidget(
                          controller: kundliController.editBirthTimeController,
                          titleText: "",
                          hintText: "Select Your Birth Time",
                          readOnly: true,
                          maxLines: 1,
                          preFixIcon: Icons.schedule,
                          onFieldSubmitted: (p0) {},
                          onTap: () {
                            _boySelectBirthDateTime(context, kundliController);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: CommonSmallTextFieldWidget(
                            controller:
                                kundliController.editBirthPlaceController,
                            titleText: "",
                            hintText: "Select Your Birth Place",
                            readOnly: true,
                            maxLines: 1,
                            preFixIcon: Icons.place,
                            onFieldSubmitted: (p0) {},
                            onTap: () {
                              Get.to(() => PlaceOfBirthSearchScreen());
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.all(0)),
                              backgroundColor: WidgetStateProperty.all(
                                  Get.theme.primaryColor),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: const BorderSide(color: Colors.grey)),
                              ),
                            ),
                            onPressed: () async {
                              global.showOnlyLoaderDialog();
                              await kundliController.updateKundliData(id);
                              global.hideLoader();
                              await kundliController.getKundliList();
                              // Get.to(() => KundliDetailsScreen());
                              Get.back();
                            },
                            child: Text(
                              'Update',
                              textAlign: TextAlign.center,
                              style: Get.theme.primaryTextTheme.titleMedium!
                                  .copyWith(),
                            ).tr(),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Future _selectDate(
      BuildContext context, KundliController kundliController) async {
    // ignore: unused_local_variable
    var datePicked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: DateTime(1994),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      dateFormat: "dd-MM-yyyy",
      itemTextStyle: Get.theme.textTheme.titleMedium!.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        wordSpacing: 2,
        //  color: Colors.blue,
        //   leadingDistribution:
      ),
      titleText: tr('Select Birth Date'),
    );
    if (datePicked != null) {
      kundliController.editBirthDateController.text =
          formatDate(datePicked, [dd, '-', mm, '-', yyyy]);
      kundliController.pickedDate = datePicked;
      kundliController.update();
    }
  }

  Future _boySelectBirthDateTime(
      BuildContext context, KundliController kundliController) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  backgroundColor: Get.theme.primaryColor,
                  foregroundColor: Colors.black),
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              onSurface: Colors.white,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (pickedTime != null) {
      // ignore: use_build_context_synchronously
      String pictime = pickedTime.format(context);
      kundliController.editBirthTimeController.text = pictime;
    } else {}
    debugPrint(
        'time is setting ${kundliController.editBirthTimeController.text}');
  }
}
