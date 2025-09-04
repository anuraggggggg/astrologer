// ignore_for_file: must_be_immutable

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:astrowaypartner/widgets/common_textfield_widget.dart';
import 'package:astrowaypartner/widgets/primary_text_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:sizer/sizer.dart';

class AddAmountScreen extends StatelessWidget {
  AddAmountScreen({super.key});
  WalletController walletController = Get.find<WalletController>();
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MyCustomAppBar(
          height: 80,
          title: const Text("Withdraw screen").tr(),
          backgroundColor: COLORS().primaryColor,
        ),
        body: GetBuilder<WalletController>(
          builder: (walletController) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: PrimaryTextWidget(text: "Enter Amount"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: CommonTextFieldWidget(
                        textEditingController: walletController.cWithdrawAmount,
                        hintText: tr("Add Amount"),
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
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      child: DottedBorder(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            'Choose a Bank account or UPI ID',
                            style: Get.theme.primaryTextTheme.headlineMedium!
                                .copyWith(fontSize: 18.sp),
                          ).tr(),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: walletController.withdrawList.length,
                      itemBuilder: (context, index) {
                        final walletItem = walletController.withdrawList[index];

                        return walletItem.isActive == 1
                            ? Row(
                                children: [
                                  Radio(
                                    activeColor: COLORS().primaryColor,
                                    value: walletItem.methodId ?? 0,
                                    groupValue: walletController.wallet,
                                    onChanged: (value) {
                                      walletController.changeAccount(value);
                                      walletController.update();
                                    },
                                  ),
                                  Text(
                                    walletItem.methodName ?? 'N/A',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontSize: 14.sp,
                                        ),
                                  ).tr(),
                                ],
                              )
                            : const SizedBox.shrink();
                      },
                    )

                    // Wrap(
                    //   children: walletController.withdrawList.map((walletItem) {
                    //     return Flexible(
                    //       child: Row(
                    //         children: [
                    //           Radio(
                    //             activeColor: COLORS().primaryColor,
                    //             value: walletItem.methodId,
                    //             groupValue: walletController.wallet,
                    //             onChanged: (value) {
                    //               walletController.changeAccount(value);
                    //               walletController.update();
                    //             },
                    //           ),
                    //           Text(
                    //             walletItem.methodName ?? '',
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .titleSmall!
                    //                 .copyWith(
                    //                   fontSize: 14.sp,
                    //                 ),
                    //           ).tr(),
                    //         ],
                    //       ),
                    //     );
                    //   }).toList(),
                    // ),
                    ,
                    walletController.wallet == 1
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child:
                                      PrimaryTextWidget(text: "Account number"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: CommonTextFieldWidget(
                                    hintText: tr("Account number"),
                                    textEditingController:
                                        walletController.cBankNumber,
                                    keyboardType: TextInputType.number,
                                    formatter: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    maxLength: 16,
                                    counterText: '',
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: PrimaryTextWidget(text: "IFSC number"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: CommonTextFieldWidget(
                                    hintText: "IFSC number",
                                    textEditingController:
                                        walletController.cIfscCode,
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: PrimaryTextWidget(text: "Holder name"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5.0, bottom: 20),
                                  child: CommonTextFieldWidget(
                                    hintText: tr("Holder name"),
                                    textEditingController:
                                        walletController.cAccountHolder,
                                    keyboardType: TextInputType.text,
                                    formatter: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[a-zA-Z ]"))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : walletController.wallet == 2
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: PrimaryTextWidget(text: "UPI ID"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: CommonTextFieldWidget(
                                        hintText: "UPI ID",
                                        textEditingController:
                                            walletController.cUPI,
                                        keyboardType: TextInputType.text,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(10),
                              ),
                    //SUBMIT BUTTON
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            if (walletController.updateAmountId != null) {
                              if (walletController.cWithdrawAmount.text != "" &&
                                  double.parse(walletController
                                          .cWithdrawAmount.text) <=
                                      double.parse(walletController
                                          .withdraw.walletAmount
                                          .toString())) {
                                walletController.validateUpdateAmount(
                                    walletController.updateAmountId!);
                              } else if (walletController
                                          .cWithdrawAmount.text !=
                                      "" &&
                                  int.parse(walletController
                                          .cWithdrawAmount.text) <
                                      int.parse(walletController
                                          .cWithdrawAmount.text)) {
                                walletController.validateUpdateAmount(
                                    walletController.updateAmountId!);
                              } else {
                                global.showToast(
                                    message: tr("Please enter a valid amount"));
                              }
                            } else {
                              if (walletController.cWithdrawAmount.text != "" &&
                                  double.parse(walletController
                                          .cWithdrawAmount.text) <=
                                      double.parse(walletController
                                          .withdraw.walletAmount
                                          .toString())) {
                                walletController.validateAmount();
                              } else {
                                global.showToast(
                                    message: tr("Please enter a valid amount"));
                              }
                            }
                            await walletController.getAmountList();
                            walletController.update();
                          } catch (e) {
                            debugPrint(
                                'Exception in add_amount_screen :- SUBMIT button:- $e');
                          }
                        },
                        child: const Text("SUBMIT").tr(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
