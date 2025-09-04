// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, prefer_typing_uninitialized_variables

import 'dart:developer';
import 'package:astrowaypartner/models/wallet_model.dart';
import 'package:astrowaypartner/services/apiHelper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import '../../models/amount_model.dart';
import '../../models/withdrawOptionModel.dart';

class WalletController extends GetxController {
  String screen = 'wallet_controller.dart';
  APIHelper apiHelper = APIHelper();
  int minBalance = 0;
  updateminBalance(int val) {
    minBalance = val;
    update();
  }

  List<RecordList> withdrawList = [];
  //Bank account
  final cBankNumber = TextEditingController();
  final cIfscCode = TextEditingController();
  final cAccountHolder = TextEditingController();
  final cUPI = TextEditingController();
  List payment = [
    '50',
    '100',
    '200',
    '300',
    '500',
    '1000',
    '2000',
    '3000',
    '4000',
    '8000',
    '15000',
    '20000',
    '50000',
    '100000'
  ];
  List rechrage = ['50', '100', '200', '300', '500', '1000', '2000', '3000'];
  var paymentAmount = <AmountModel>[];
  final cWithdrawAmount = TextEditingController();
  double? amount;
  int? updateAmountId;
  WalletModel walletModel = WalletModel();
  Withdraw withdraw = Withdraw();
  int? wallet; //Radio button value
  @override
  void onInit() {
    super.onInit();
    wallet = 1;
  }

  bool isChashbackMsg = true;
  bool isWallet = false;

  updateChashbackStatus() {
    isChashbackMsg = false;
    update();
  }

  updateWallet() {
    isWallet = !isWallet;
    update();
  }

  getAmount() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getpaymentAmount().then((result) {
            if (result.status == "200") {
              paymentAmount = result.recordList;
              payment.clear();
              rechrage.clear();
              for (int i = 0; i < paymentAmount.length; i++) {
                payment.add(paymentAmount[i].amount.toString());
                rechrage.add(paymentAmount[i].amount.toString());
              }
              update();
            } else {
              global.showToast(
                message: 'Failed to get amount',
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  getAmount:-" + e.toString());
    }
  }

  withdrawWalletAmount() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getWalletinformations().then((result) {
            if (result.status == "200") {
              withdrawList = result.recordList;
              debugPrint('list size is ${withdrawList.length}');
              update();
            } else {
              global.showToast(
                message: 'Failed to get amount',
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in getAmount: $e");
    }
  }

  //choose Bank or UPI
  void changeAccount(int? index) {
    try {
      wallet = index;
      log('wallet tyype-$wallet');
      update();
    } catch (e) {
      print('Exception - $screen - changeAccount() :' + e.toString());
    }
  }

  //clear amount
  clearAmount() {
    cWithdrawAmount.text = '';
    cBankNumber.text = '';
    cIfscCode.text = '';
    cAccountHolder.text = '';
    cUPI.text = '';
  }

  //fill amount
  fillAmount(WalletModel walletModel) {
    if (walletModel.withdrawAmount != null) {
      cWithdrawAmount.text = walletModel.withdrawAmount.toString();
    }
    if (walletModel.accountNumber != null ||
        walletModel.accountNumber!.isNotEmpty) {
      cBankNumber.text = walletModel.accountNumber.toString();
    }
    if (walletModel.ifscCode != null || walletModel.ifscCode!.isNotEmpty) {
      cIfscCode.text = walletModel.ifscCode.toString();
    }
    if (walletModel.accountHolderName != null ||
        walletModel.accountHolderName!.isNotEmpty) {
      cAccountHolder.text = walletModel.accountHolderName.toString();
    }
    if (walletModel.upiId != null || walletModel.upiId!.isNotEmpty) {
      cUPI.text = walletModel.upiId.toString();
    }
  }

  validateAmount() {
    try {
      if (cWithdrawAmount.text != "" &&
              (wallet == 1 && cBankNumber.text != "") &&
              (wallet == 1 && cIfscCode.text != "") &&
              (wallet == 1 && cAccountHolder.text != "") ||
          (wallet == 2 && cUPI.text != "") ||
          (wallet == 3 && cWithdrawAmount.text != "")) {
        addAmount();
      } else if (cWithdrawAmount.text == "") {
        global.showToast(message: "Please Enter Valid amount");
      } else if (wallet == 1 && cBankNumber.text == "") {
        global.showToast(message: "Please Enter account number");
      } else if (wallet == 1 && cIfscCode.text == "") {
        global.showToast(message: "Please Enter IFSC code");
      } else if (wallet == 1 && cAccountHolder.text == "") {
        global.showToast(message: "Please Enter account holder name");
      } else if (wallet == 2 && cUPI.text == "") {
        global.showToast(message: "Please Enter UPI Id");
      }
    } catch (e) {
      print("Exception: $screen - validateAmount(): " + e.toString());
    }
  }

  //Add Amount
  addAmount() async {
    try {
      await global.checkBody().then(
        (networkResult) async {
          if (networkResult) {
            int id = global.user.id ?? 0;
            amount = double.parse(cWithdrawAmount.text);
            walletModel.upiId = cUPI.text;
            walletModel.accountNumber = cBankNumber.text;
            walletModel.ifscCode = cIfscCode.text;
            walletModel.accountHolderName = cAccountHolder.text;
            walletModel.paymentMethod = wallet.toString();
            global.showOnlyLoaderDialog();
            await apiHelper
                .withdrawAdd(
                    id,
                    amount!,
                    walletModel.paymentMethod!,
                    walletModel.upiId!,
                    walletModel.accountNumber!,
                    walletModel.ifscCode!,
                    walletModel.accountHolderName!)
                .then(
              (apiResult) async {
                global.hideLoader();
                if (apiResult.status == '200') {
                  global.showToast(message: apiResult.message.toString());
                  await getAmountList();
                  Get.back();
                } else if (apiResult.status == '400') {
                  global.showToast(message: apiResult.message.toString());
                  update();
                } else {
                  global.showToast(
                      message: "Something went wrong please try again later");
                }
              },
            );
          } else {
            global.showToast(message: "No Network Available");
          }
        },
      );
    } catch (e) {
      print("Exception: $screen - addAmount(): " + e.toString());
    }
  }

  //Get amount
  Future getAmountList({int? isLoading = 1}) async {
    try {
      await global.checkBody().then(
        (result) async {
          if (result) {
            int id = global.user.id ?? 0;
            await apiHelper.getWithdrawAmount(id).then((result) {
              if (result.status == "200") {
                withdraw = result.recordList;
                update();
              } else {
                result = null;
                global.showToast(message: result.message);
              }
            });
          }
        },
      );
      update();
    } catch (e) {
      print('Exception: $screen - getAmountList():- ' + e.toString());
    }
  }

  validateUpdateAmount(int id) {
    try {
      if (cWithdrawAmount.text != "" &&
              (wallet == 1 && cBankNumber.text != "") &&
              (wallet == 1 && cIfscCode.text != "") &&
              (wallet == 1 && cAccountHolder.text != "") ||
          (wallet == 2 && cUPI.text != "") ||
          (wallet == 3 && cWithdrawAmount.text != "")) {
        updateAmount(id);
      } else if (cWithdrawAmount.text == "") {
        global.showToast(message: "Please Enter Valid amount");
      } else if (wallet == 1 && cBankNumber.text == "") {
        global.showToast(message: "Please Enter account number");
      } else if (wallet == 1 && cIfscCode.text == "") {
        global.showToast(message: "Please Enter IFSC code");
      } else if (wallet == 1 && cAccountHolder.text == "") {
        global.showToast(message: "Please Enter account holder name");
      } else if (wallet == 2 && cUPI.text == "") {
        global.showToast(message: "Please Enter UPI Id");
      }
    } catch (e) {
      print("Exception: $screen - validateAmount(): " + e.toString());
    }
  }

  //Update Amount
  updateAmount(int id) async {
    try {
      await global.checkBody().then(
        (networkResult) async {
          if (networkResult) {
            amount = double.parse(cWithdrawAmount.text);
            walletModel.upiId = cUPI.text;
            walletModel.accountNumber = cBankNumber.text;
            walletModel.ifscCode = cIfscCode.text;
            walletModel.accountHolderName = cAccountHolder.text;
            walletModel.paymentMethod = wallet.toString();

            await apiHelper
                .withdrawUpdate(
              id,
              global.user.id ?? 0,
              amount!,
              walletModel.paymentMethod!,
              walletModel.upiId!,
              walletModel.accountNumber!,
              walletModel.ifscCode!,
              walletModel.accountHolderName!,
            )
                .then(
              (apiResult) async {
                if (apiResult.status == '200') {
                  global.showToast(message: apiResult.message);
                  //Get.back();
                  await getAmountList();
                  // Get.to(() => WalletScreen());
                  Get.back();
                } else if (apiResult.status == '400') {
                  global.showToast(message: apiResult.message);
                } else {
                  global.showToast(
                      message: "Something went wrong, please try again later");
                }
              },
            );
          } else {
            global.showToast(message: "No Network Available");
          }
        },
      );
      update();
    } catch (e) {
      print("Exception - $screen - updateAmount(): " + e.toString());
    }
  }
}
