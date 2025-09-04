// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:astrowaypartner/utils/global.dart' as global;

import '../models/dailyHoroscopeModel.dart';

class TimeWiseHoroscopeWidget extends StatelessWidget {
  final DailyscopeModel dailyHoroscopeModel;
  const TimeWiseHoroscopeWidget({super.key, required this.dailyHoroscopeModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('Yearly Horoscope',
                  style: Get.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.black))
              .tr(),
          const SizedBox(
            height: 3,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Expanded(
                child: Divider(
                  color: Colors.black,
                  height: 10,
                  indent: 200,
                  endIndent: 10,
                ),
              ),
              Text(DateFormat('yyy').format(DateTime.now()),
                  style: Get.textTheme.titleMedium!
                      .copyWith(fontSize: 13, color: Colors.grey)),
              const Expanded(
                child: Divider(
                  color: Colors.black,
                  height: 10,
                  indent: 200,
                  endIndent: 10,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          dailyHoroscopeModel.yearlyHoroScope == null
              ? const SizedBox()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dailyHoroscopeModel.yearlyHoroScope!.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dailyHoroscopeModel.yearlyHoroScope![index].title!,
                          style: Get.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FutureBuilder(
                          future: global.showHtml(
                            html: dailyHoroscopeModel
                                    .yearlyHoroScope![index].description ??
                                '',
                          ),
                          builder: (context, snapshot) {
                            return snapshot.data ?? const SizedBox();
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  })
        ],
      ),
    );
  }
}
