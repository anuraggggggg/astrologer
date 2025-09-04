// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:developer';

import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controllers/HomeController/wallet_controller.dart';
import '../../../../../controllers/splashController.dart';
import '../../../../../services/apiHelper.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import 'payment_screen.dart';

// ignore: must_be_immutable
class PaymentInformationScreen extends StatefulWidget {
  final double amount;
  final int? flag;
  final int? cashback;

  const PaymentInformationScreen(
      {super.key, required this.amount, this.flag, this.cashback});

  @override
  State<PaymentInformationScreen> createState() =>
      _PaymentInformationScreenState();
}

class _PaymentInformationScreenState extends State<PaymentInformationScreen> {
  final WalletController walletController = Get.find<WalletController>();

  SplashController splashController = Get.find<SplashController>();

  APIHelper apiHelper = APIHelper();

  int? paymentMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyCustomAppBar(
        height: 10.h,
        title: const Text('Payment Information'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GetBuilder<WalletController>(builder: (c) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment Details',
                                        style: Get.textTheme.titleMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15))
                                    .tr(),
                                const SizedBox(
                                  height: 5,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Amount').tr(),
                                    Text(
                                        '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${widget.amount}'),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('GST ${global.getSystemFlagValue(global.systemFlagNameList.gst)}%')
                                        .tr(),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            '${widget.amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100}'),
                                      ),
                                    )
                                  ],
                                ),
                                widget.cashback == 0
                                    ? const SizedBox()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Cashback',
                                                  style: Get
                                                      .textTheme.titleMedium!
                                                      .copyWith(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500))
                                              .tr(),
                                          Text(
                                              '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${widget.amount * int.parse(widget.cashback.toString()) / 100}',
                                              style: Get.textTheme.titleMedium!
                                                  .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                        ],
                                      ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Payable Amount',
                                            style: Get.textTheme.titleMedium!
                                                .copyWith(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500))
                                        .tr(),
                                    Text(
                                        '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${(widget.amount + widget.amount * double.parse(global.getSystemFlagValue(global.systemFlagNameList.gst)) / 100).toStringAsFixed(2)}',
                                        style: Get.textTheme.titleMedium!
                                            .copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ]);
          }),
        ),
      ),
      bottomSheet: SizedBox(
        height: 60,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () async {
              await apiHelper
                  .addAmountInWallet(
                amount: double.parse((widget.amount +
                        widget.amount *
                            double.parse(global.getSystemFlagValue(
                                global.systemFlagNameList.gst)) /
                            100)
                    .toStringAsFixed(2)),
                cashback: (widget.amount) *
                    (int.parse(widget.cashback.toString()) / 100),

                // cashback:
                //                     (int.parse(widget.amount.toString()) *
                //                             (int.parse(widget.cashback
                //                                     .toString()) /
                //                                 100))
                //                         .toInt(),
              )
                  .then((value) {
                if (value['status'] == 200) {
                  global.hideLoader();
                  log("jkasdjksa");
                  log("$value");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                                url: value['url'],
                              )));
                }
              });
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
              backgroundColor:
                  WidgetStateProperty.all(Get.theme.primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            child: Text('Proceed to Pay',
                    style: Get.textTheme.titleMedium!
                        .copyWith(fontSize: 12, color: Colors.white))
                .tr(),
          ),
        ),
      ),
    );
  }
}
