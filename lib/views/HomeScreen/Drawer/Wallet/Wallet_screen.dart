// ignore_for_file: file_names, must_be_immutable, avoid_print, prefer_interpolation_to_compose_strings, deprecated_member_use

import 'dart:developer';

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/constants/messageConst.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/Wallet/add_amount_screen.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:astrowaypartner/widgets/common_textfield_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:sizer/sizer.dart';

import '../../FloatingButton/KundliMatching/payment/AddmoneyToWallet.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});
  WalletController walletController = Get.find<WalletController>();
  SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MyCustomAppBar(
          height: 80,
          title: const Text("Wallet screen").tr(),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await walletController.getAmount();
                  Get.to(() => AddmoneyToWallet());
                })
          ],
          backgroundColor: COLORS().primaryColor,
        ),
        body: GetBuilder<WalletController>(
          builder: (walletController) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      child: Column(
                        children: [
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Get.theme.primaryColor),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: SizedBox(
                                      width: 11.h,
                                      height: 11.h,
                                      child: Image.asset(
                                        'assets/images/wallet.png',
                                      ),
                                    ),
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Center(
                                        child: Text(
                                          'Wallet Amount ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(fontSize: 14.sp),
                                        ).tr(),
                                      ),
                                    ),
                                    subtitle: SizedBox(
                                      height: 50,
                                      child: Card(
                                        shadowColor: COLORS().primaryColor,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ',
                                              style: Get
                                                  .theme.textTheme.bodyLarge!
                                                  .copyWith(fontSize: 14.sp),
                                            ),
                                            Text(
                                              walletController.withdraw
                                                          .walletAmount !=
                                                      null
                                                  ? walletController
                                                      .withdraw.walletAmount!
                                                      .toStringAsFixed(0)
                                                  : " 0",
                                              style: Get
                                                  .theme.textTheme.bodyLarge!
                                                  .copyWith(fontSize: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    trailing: walletController
                                                .withdraw.walletAmount !=
                                            null
                                        ? GestureDetector(
                                            onTap: () async {
                                              walletController.updateAmountId =
                                                  null;
                                              walletController.clearAmount();
                                              await walletController
                                                  .withdrawWalletAmount();
//! wallet api
                                              Get.to(() => AddAmountScreen());
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Get.theme.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w),
                                                child: Text(
                                                  'Withdraw',
                                                  style: Get.theme.textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          fontSize: 14.sp),
                                                ).tr(),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ),
                                Divider(
                                    color: Colors.grey.shade500, thickness: 1),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            'Pending\n Withdraw',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            textAlign: TextAlign.center,
                                          ).tr(),
                                          SizedBox(
                                            height: 50,
                                            child: Card(
                                              shadowColor:
                                                  COLORS().primaryColor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ',
                                                        style: Get
                                                            .theme
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                      Text(
                                                        walletController
                                                                    .withdraw
                                                                    .totalPending !=
                                                                null
                                                            ? walletController
                                                                .withdraw
                                                                .totalPending
                                                                .toString()
                                                            : "0",
                                                        style: Get
                                                            .theme
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Withdraw\nAmount',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            textAlign: TextAlign.center,
                                          ).tr(),
                                          SizedBox(
                                            height: 50,
                                            child: Card(
                                              shadowColor:
                                                  COLORS().primaryColor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ',
                                                        style: Get
                                                            .theme
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                      Text(
                                                        walletController
                                                                    .withdraw
                                                                    .withdrawAmount !=
                                                                null
                                                            ? walletController
                                                                .withdraw
                                                                .withdrawAmount!
                                                            : "0",
                                                        style: Get
                                                            .theme
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Total\nEarning',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            textAlign: TextAlign.center,
                                          ).tr(),
                                          SizedBox(
                                            height: 50,
                                            child: Card(
                                              shadowColor:
                                                  COLORS().primaryColor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ',
                                                        style: Get
                                                            .theme
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                      Text(
                                                        walletController
                                                                    .withdraw
                                                                    .totalEarning !=
                                                                null
                                                            ? walletController
                                                                .withdraw
                                                                .totalEarning
                                                                .toString()
                                                            : " 0",
                                                        style: Get
                                                            .theme
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: DefaultTabController(
                              initialIndex: 0,
                              length: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100.w,
                                    height: 40,
                                    margin:
                                        EdgeInsets.only(left: 2.w, right: 2.w),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: TabBar(
                                      dividerColor: Colors.transparent,
                                      tabAlignment: TabAlignment.start,
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp),
                                      labelColor: Colors.black,
                                      unselectedLabelColor: Colors.grey,
                                      isScrollable: true,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicatorColor: Get.theme.primaryColor,
                                      labelPadding: EdgeInsets.zero,
                                      indicator: BoxDecoration(
                                          color: COLORS().primaryColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20))),
                                      tabs: [
                                        SizedBox(
                                          width: 45.w,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Tab(
                                              text: tr('Withdraw History'),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 45.w,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Tab(
                                              text: tr('Wallet History'),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: SizedBox(
                                        height: Get.height * 0.53,
                                        child: TabBarView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            walletController.withdraw
                                                        .walletModel!.isEmpty &&
                                                    walletController.withdraw
                                                            .walletModel ==
                                                        null
                                                ? Center(
                                                    child: const Text(
                                                            "You don't have any withdraw history here!")
                                                        .tr(),
                                                  )
                                                : RefreshIndicator(
                                                    onRefresh: () async {
                                                      await walletController
                                                          .getAmountList();
                                                      walletController.update();
                                                    },
                                                    child: ListView.builder(
                                                      itemCount:
                                                          walletController
                                                              .withdraw
                                                              .walletModel!
                                                              .length,
                                                      shrinkWrap: true,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ',
                                                                            style:
                                                                                Get.theme.textTheme.bodyLarge,
                                                                          ),
                                                                          Text(
                                                                            walletController.withdraw.walletModel![index].withdrawAmount.toString(),
                                                                            style:
                                                                                Get.theme.textTheme.bodyLarge,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Icon(
                                                                              Icons.schedule,
                                                                              color: Colors.black,
                                                                              size: 12,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 4),
                                                                              child: Text(
                                                                                DateFormat('hh:mm a').format(DateTime.parse(walletController.withdraw.walletModel![index].createdAt.toString())),
                                                                                style: Get.theme.textTheme.bodyMedium,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          Text(
                                                                            DateFormat('dd-MM-yyyy').format(DateTime.parse(walletController.withdraw.walletModel![index].createdAt.toString())),
                                                                            style:
                                                                                Get.theme.textTheme.bodyMedium,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 5),
                                                                            child:
                                                                                Text(
                                                                              walletController.withdraw.walletModel![index].status!,
                                                                              style: Get.theme.textTheme.bodyMedium!.copyWith(
                                                                                color: walletController.withdraw.walletModel![index].status == 'Released' ? Colors.green : Colors.orange,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      walletController.withdraw.walletModel![index].status ==
                                                                              'Pending'
                                                                          ? Padding(
                                                                              padding: const EdgeInsets.only(left: 10),
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  walletController.fillAmount(walletController.withdraw.walletModel![index]);
                                                                                  walletController.updateAmountId = walletController.withdraw.walletModel![index].id;
                                                                                  Get.to(() => AddAmountScreen());

                                                                                  walletController.update();
                                                                                },
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: Get.theme.primaryColor,
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(10),
                                                                                    child: Text(
                                                                                      'Update',
                                                                                      style: Get.theme.textTheme.titleSmall,
                                                                                    ).tr(),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : const SizedBox(),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Divider(
                                                                height: 3.w,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                            walletController
                                                        .withdraw
                                                        .walletTransactionModel!
                                                        .isEmpty &&
                                                    walletController.withdraw
                                                            .walletTransactionModel ==
                                                        null
                                                ? Center(
                                                    child: const Text(
                                                            "You don't have any wallet transation history here!")
                                                        .tr(),
                                                  )
                                                : RefreshIndicator(
                                                    onRefresh: () async {
                                                      await walletController
                                                          .getAmountList();
                                                      walletController.update();
                                                    },
                                                    child: ListView.builder(
                                                      itemCount: walletController
                                                          .withdraw
                                                          .walletTransactionModel!
                                                          .length,
                                                      shrinkWrap: true,
                                                      itemBuilder:
                                                          (context, index) {
                                                        String transactiontype =
                                                            walletController
                                                                .withdraw
                                                                .walletTransactionModel![
                                                                    index]
                                                                .transactionType
                                                                .toString();
                                                        log('transaction-type-$transactiontype');

                                                        return Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            90.w,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Text(
                                                                                  'Amount',
                                                                                  style: Get.theme.textTheme.bodyLarge,
                                                                                ).tr(),
                                                                                Text(
                                                                                  '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${walletController.withdraw.walletTransactionModel![index].amount.toString()}',
                                                                                  style: Get.theme.textTheme.bodyMedium,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 5),
                                                                              child: Text(
                                                                                DateFormat('dd-MM-yyyy').format(DateTime.parse(walletController.withdraw.walletTransactionModel![index].createdAt.toString())),
                                                                                style: Get.theme.textTheme.bodyMedium,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            90.w,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Text(
                                                                                  'Transaction type',
                                                                                  style: Get.theme.textTheme.bodyLarge,
                                                                                ).tr(),
                                                                                transactiontype == 'recharge'
                                                                                    ? const Icon(
                                                                                        CupertinoIcons.bolt,
                                                                                        color: Colors.green,
                                                                                      )
                                                                                    : transactiontype == 'Gift'
                                                                                        ? const Icon(
                                                                                            CupertinoIcons.gift,
                                                                                            color: Colors.green,
                                                                                          )
                                                                                        : (transactiontype == 'Video Live Streaming')
                                                                                            ? const Icon(
                                                                                                CupertinoIcons.video_camera_solid,
                                                                                                color: Colors.red,
                                                                                              )
                                                                                            : (transactiontype == 'Audio Live Streaming')
                                                                                                ? const Icon(
                                                                                                    CupertinoIcons.speaker_3_fill,
                                                                                                    color: Colors.red,
                                                                                                  )
                                                                                                : (transactiontype == 'Call')
                                                                                                    ? const Icon(CupertinoIcons.phone)
                                                                                                    : (transactiontype == 'Chat')
                                                                                                        ? const Icon(CupertinoIcons.chat_bubble_2)
                                                                                                        : Image(
                                                                                                            height: 5.w,
                                                                                                            width: 5.w,
                                                                                                            image: const AssetImage('assets/images/report.png'),
                                                                                                          ),
                                                                              ],
                                                                            ),
                                                                            Text(
                                                                              walletController.withdraw.walletTransactionModel![index].paymentStatus != null ? '${walletController.withdraw.walletTransactionModel![index].paymentStatus?.toUpperCase().substring(0, 1) ?? ''}${walletController.withdraw.walletTransactionModel![index].paymentStatus?.substring(1) ?? ''}' : '',
                                                                              style: Get.theme.textTheme.bodyMedium!.copyWith(
                                                                                fontWeight: FontWeight.w800,
                                                                                color: walletController.withdraw.walletTransactionModel![index].paymentStatus == 'success' ? Colors.green : Colors.orange,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Divider(
                                                                height: 3.w,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  //Withdraw amount
  void withdrawAmount({int? index}) {
    try {
      Get.defaultDialog(
        title: walletController.updateAmountId != null
            ? tr('UPDATE AN AMOUNT')
            : tr('ADD AN AMOUNT'),
        titleStyle: Get.theme.textTheme.titleSmall,
        content: Column(
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 50,
              color: COLORS().blackColor,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CommonTextFieldWidget(
                textEditingController: walletController.cWithdrawAmount,
                hintText: "Add Amount",
                keyboardType: TextInputType.number,
                formatter: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                counterText: '',
                prefix: Icon(
                  Icons.currency_rupee_outlined,
                  color: Get.theme.primaryColor,
                  size: 25,
                ),
              ),
            )
          ],
        ),
        confirm: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ElevatedButton(
            onPressed: () {
              if (walletController.updateAmountId != null) {
                if (double.parse(walletController.cWithdrawAmount.text) <=
                    double.parse(
                        walletController.withdraw.walletAmount.toString())) {
                  walletController.updateAmount(
                      walletController.withdraw.walletModel![index!].id!);
                } else {
                  global.showToast(message: tr("Please enter a valid amount"));
                }
              } else {
                if (double.parse(walletController.cWithdrawAmount.text) <=
                    double.parse(
                        walletController.withdraw.walletAmount.toString())) {
                  walletController.addAmount();
                } else {
                  global.showToast(message: tr("Please enter a valid amount"));
                }
              }
              walletController.getAmountList();
              walletController.update();
            },
            child: const Text(MessageConstants.WITHDRAW).tr(),
          ),
        ),
      );
      walletController.update();
    } catch (e) {
      print('Exception :  Wallet_screen - withdrawAmount() :' + e.toString());
    }
  }
}
