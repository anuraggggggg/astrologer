// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralReport extends StatelessWidget {
  GeneralReport({
    super.key,
  });
  final KundliController kundliController = Get.find<KundliController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 40,
          child: GetBuilder<KundliController>(builder: (c) {
            return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: kundliController.reportTab.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      kundliController.selectTab(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: kundliController.reportTab[index].isSelected
                                ? const Color.fromARGB(255, 247, 243, 213)
                                : Colors.transparent,
                            border: Border.all(
                                color:
                                    kundliController.reportTab[index].isSelected
                                        ? Get.theme.primaryColor
                                        : Colors.black),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(kundliController.reportTab[index].title,
                              style: const TextStyle(fontSize: 13))),
                    ),
                  );
                });
          }),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description',
                          style: Get.textTheme.titleMedium!
                              .copyWith(fontWeight: FontWeight.bold))
                      .tr(),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('${kundliController.generalDesc}',
                      style: Get.textTheme.titleMedium!.copyWith(fontSize: 14))
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
