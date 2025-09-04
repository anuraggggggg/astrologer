// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VismshattariDasha extends StatelessWidget {
  const VismshattariDasha({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<KundliController>(builder: (kundliController) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Text('Mahadasha').tr(),
            Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 248, 242, 205),
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DataTable(
                columnSpacing: 20,
                dataTextStyle: Get.textTheme.bodyMedium!.copyWith(fontSize: 10),
                horizontalMargin: 10,
                headingRowHeight: 48,
                columns: [
                  DataColumn(
                    label: const Text('Planet', textAlign: TextAlign.center).tr(),
                  ),
                  DataColumn(label: const Text('Start Date', textAlign: TextAlign.center).tr()),
                  DataColumn(
                    label: const Text('End Date', textAlign: TextAlign.center).tr(),
                  ),
                ],
                border: const TableBorder(
                  verticalInside: BorderSide(color: Colors.grey),
                  horizontalInside: BorderSide(color: Colors.grey),
                ),
                rows: kundliController.listOfVishattari // Loops through dataColumnText, each iteration assigning the value to element
                    .map(
                      ((element) => DataRow(
                            color: WidgetStateProperty.all(Colors.white),
                            cells: <DataCell>[
                              DataCell(Center(child: Text(element["planet"]!))),
                              DataCell(Center(
                                  child: Text(
                                element["start"]!,
                              ))),
                              DataCell(Center(
                                  child: Row(
                                children: [
                                  Text(element["end"]!),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: Colors.grey,
                                  )
                                ],
                              ))),
                            ],
                          )),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        );
      }),
    );
  }
}
