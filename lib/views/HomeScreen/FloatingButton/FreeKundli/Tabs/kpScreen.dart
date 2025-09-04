// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KPScreen extends StatelessWidget {
  const KPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<KundliController>(builder: (kundliController) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Planets',
                style: Get.textTheme.titleMedium,
              ).tr(),
            ),
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
                    label:
                        const Text('Planet', textAlign: TextAlign.center).tr(),
                  ),
                  DataColumn(
                      label:
                          const Text('Cusp', textAlign: TextAlign.center).tr()),
                  DataColumn(
                    label: const Text('Sign', textAlign: TextAlign.center).tr(),
                  ),
                  DataColumn(
                      label:
                          const Text('Sign\nLord', textAlign: TextAlign.center)
                              .tr()),
                  DataColumn(
                      label:
                          const Text('Star\nLord', textAlign: TextAlign.center)
                              .tr()),
                  DataColumn(
                      label:
                          const Text('Sub\nLord', textAlign: TextAlign.center)
                              .tr()),
                ],
                border: const TableBorder(
                  verticalInside: BorderSide(color: Colors.grey),
                  horizontalInside: BorderSide(color: Colors.grey),
                ),
                rows: kundliController
                    .listOfPlanets // Loops through dataColumnText, each iteration assigning the value to element
                    .map(
                      ((element) => DataRow(
                            color: WidgetStateProperty.all(Colors.white),
                            cells: <DataCell>[
                              DataCell(Center(
                                  child: Text(
                                element["planet"]!,
                              ).tr())),
                              DataCell(Center(child: Text(element["cups"]!))),
                              DataCell(
                                  Center(child: Text(element["sign"]!).tr())),
                              DataCell(
                                  Center(child: Text(element["signLord"]!))),
                              DataCell(
                                  Center(child: Text(element["starLord"]!))),
                              DataCell(
                                  Center(child: Text(element["subLord"]!))),
                            ],
                          )),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
