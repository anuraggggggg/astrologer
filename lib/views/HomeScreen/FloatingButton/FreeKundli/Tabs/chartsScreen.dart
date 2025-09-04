// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child:
                    GetBuilder<KundliController>(builder: (kundliController) {
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                        child: Text(
                          'Planets',
                          style: Get.textTheme.bodyMedium,
                        ).tr(),
                      ),
                      SizedBox(
                        height: 30,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: kundliController.planetTab.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  kundliController.selectPlanetTab(index);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    decoration: BoxDecoration(
                                      color: kundliController
                                              .planetTab[index].isSelected
                                          ? const Color.fromARGB(
                                              255, 247, 243, 213)
                                          : Colors.transparent,
                                      border: Border.all(
                                          color: kundliController
                                                  .planetTab[index].isSelected
                                              ? Get.theme.primaryColor
                                              : Colors.black),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      kundliController.planetTab[index].title,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                      kundliController.planetTab[0].isSelected
                          ? Container(
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 248, 242, 205),
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: DataTable(
                                columnSpacing: 20,
                                dataTextStyle: Get.textTheme.bodyMedium!
                                    .copyWith(fontSize: 10),
                                horizontalMargin: 10,
                                headingRowHeight: 48,
                                columns: [
                                  DataColumn(
                                    label: const Text('Planet',
                                            textAlign: TextAlign.center)
                                        .tr(),
                                  ),
                                  DataColumn(
                                      label: const Text('Sign',
                                              textAlign: TextAlign.center)
                                          .tr()),
                                  DataColumn(
                                    label: const Text('Sign\nLord',
                                            textAlign: TextAlign.center)
                                        .tr(),
                                  ),
                                  DataColumn(
                                      label: const Text('Degree',
                                              textAlign: TextAlign.center)
                                          .tr()),
                                  DataColumn(
                                      label: const Text('House',
                                              textAlign: TextAlign.center)
                                          .tr()),
                                ],
                                border: const TableBorder(
                                  verticalInside:
                                      BorderSide(color: Colors.grey),
                                  horizontalInside:
                                      BorderSide(color: Colors.grey),
                                ),
                                rows: [
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.ascendantDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.ascendantDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.ascendantDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .ascendantDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.ascendantDetails.house}'))),
                                    ],
                                  ),
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.sunDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.sunDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.sunDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .sunDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.sunDetails.house}'))),
                                    ],
                                  ),
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.moonDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.moonDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.moonDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .moonDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.moonDetails.house}'))),
                                    ],
                                  ),
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.mercuryDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.mercuryDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.mercuryDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .mercuryDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.mercuryDetails.house}'))),
                                    ],
                                  ),
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.venusDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.venusDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.venusDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .venusDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.venusDetails.house}'))),
                                    ],
                                  ),
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.marsDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.marsDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.marsDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .marsDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.marsDetails.house}'))),
                                    ],
                                  ),
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.jupiterDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.jupiterDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.jupiterDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .jupiterDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.jupiterDetails.house}'))),
                                    ],
                                  ),
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.saturnDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.saturnDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.saturnDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .saturnDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.saturnDetails.house}'))),
                                    ],
                                  ),
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.rahuDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.rahuDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.rahuDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .rahuDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.rahuDetails.house}'))),
                                    ],
                                  ),
                                  DataRow(
                                    color: WidgetStateColor.resolveWith(
                                      (states) {
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.ketuDetails.name}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.ketuDetails.sign}'))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.ketuDetails.signLord}'))),
                                      DataCell(Center(
                                          child: Text(kundliController
                                              .ketuDetails.fullDegree!
                                              .toStringAsFixed(2)))),
                                      DataCell(Center(
                                          child: Text(
                                              '${kundliController.ketuDetails.house}'))),
                                    ],
                                  )
                                ],
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 248, 242, 205),
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: DataTable(
                                  columnSpacing: 20,
                                  dataTextStyle: Get.textTheme.bodyMedium!
                                      .copyWith(fontSize: 10),
                                  horizontalMargin: 10,
                                  headingRowHeight: 48,
                                  columns: [
                                    DataColumn(
                                      label: const Text('Planet',
                                              textAlign: TextAlign.center)
                                          .tr(),
                                    ),
                                    DataColumn(
                                        label: const Text('Nakshatra',
                                                textAlign: TextAlign.center)
                                            .tr()),
                                    DataColumn(
                                      label: const Text('Nakshatra\nLord',
                                              textAlign: TextAlign.center)
                                          .tr(),
                                    ),
                                    DataColumn(
                                        label: const Text('House',
                                                textAlign: TextAlign.center)
                                            .tr()),
                                  ],
                                  border: const TableBorder(
                                    verticalInside:
                                        BorderSide(color: Colors.grey),
                                    horizontalInside:
                                        BorderSide(color: Colors.grey),
                                  ),
                                  rows: [
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.ascendantDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.ascendantDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.ascendantDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.ascendantDetails.house}'))),
                                      ],
                                    ),
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.sunDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.sunDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.sunDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.sunDetails.house}'))),
                                      ],
                                    ),
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.moonDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.moonDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.moonDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.moonDetails.house}'))),
                                      ],
                                    ),
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.mercuryDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.mercuryDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.mercuryDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.mercuryDetails.house}'))),
                                      ],
                                    ),
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.venusDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.venusDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.venusDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.venusDetails.house}'))),
                                      ],
                                    ),
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.marsDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.marsDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.marsDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.marsDetails.house}'))),
                                      ],
                                    ),
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.jupiterDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.jupiterDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.jupiterDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.jupiterDetails.house}'))),
                                      ],
                                    ),
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.saturnDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.saturnDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.saturnDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.saturnDetails.house}'))),
                                      ],
                                    ),
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.rahuDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.rahuDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.rahuDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.rahuDetails.house}'))),
                                      ],
                                    ),
                                    DataRow(
                                      color: WidgetStateColor.resolveWith(
                                        (states) {
                                          return Colors.white;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.ketuDetails.name}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.ketuDetails.nakshatra}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.ketuDetails.nakshatraLord}'))),
                                        DataCell(Center(
                                            child: Text(
                                                '${kundliController.ketuDetails.house}'))),
                                      ],
                                    )
                                  ]),
                            ),
                    ],
                  );
                }),
              )
            ],
          ),
        ));
  }
}
