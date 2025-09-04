// ignore_for_file: file_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controllers/HomeController/wallet_controller.dart';
import '../../../../../controllers/splashController.dart';
import '../../../../BaseRoute/baseRoute.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import 'PaymentInformationScreen.dart';

class AddmoneyToWallet extends BaseRoute {
  AddmoneyToWallet({super.key, super.a, super.o})
      : super(r: 'AddMoneyToWallet');
  final WalletController walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(
            title: const Text('Add money to wallet'),
          )),
      body: SingleChildScrollView(
        child: GetBuilder<SplashController>(builder: (splash) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Recharge Your Wallet Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ).tr(),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                const Text(
                  'Available Balance',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ).tr(),
                Text(
                    '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${walletController.withdraw.walletAmount != null ? walletController.withdraw.walletAmount!.toStringAsFixed(0) : " 0"}',
                    style: Get.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                GetBuilder<WalletController>(builder: (c) {
                  return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 1.5,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: walletController.paymentAmount.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Get.delete<RazorPayController>();
                            Get.to(() => PaymentInformationScreen(
                                amount: double.parse(walletController
                                    .paymentAmount[index].amount
                                    .toString()),
                                cashback: walletController
                                    .paymentAmount[index].cashback));
                          },
                          child: Container(
                            height: 20.h,
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${walletController.paymentAmount[index].amount}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                        color: Get.theme.primaryColor,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                        )),
                                    // padding: EdgeInsets.symmetric(
                                    //     vertical: 3
                                    // ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Get ${walletController.paymentAmount[index].cashback.toString()} Extra",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )),
                          ),
                        );
                      });
                })
              ],
            ),
          );
        }),
      ),
    );
  }
}
