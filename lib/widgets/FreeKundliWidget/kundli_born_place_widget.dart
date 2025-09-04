import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/KundliMatching/place_of_birth_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KundliBornPlaceWidget extends StatefulWidget {
  final KundliController kundliController;
  final void Function()? onPresseds;
  const KundliBornPlaceWidget(
      {super.key, required this.kundliController, this.onPresseds});

  @override
  State<KundliBornPlaceWidget> createState() => _KundliBornPlaceWidgetState();
}

class _KundliBornPlaceWidgetState extends State<KundliBornPlaceWidget> {
  WalletController walletController = Get.find<WalletController>();
  int selectedRadio = 3;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              Get.to(() => PlaceOfBirthSearchScreen());
            },
            child: IgnorePointer(
                child: TextField(
              cursorColor: const Color(0xFF757575),
              style: const TextStyle(fontSize: 16, color: Colors.black),
              controller: widget.kundliController.birthKundliPlaceController,
              onChanged: (_) {},
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.search),
                isDense: true,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: tr('Birth Place'),
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
          ),
        ),
        SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RadioListTile(
                title: Text(
                    "Full-fledged Kundali (₹${widget.kundliController.pdfPriceData!.recordList!.large})"),
                value: 1,
                groupValue: selectedRadio,
                onChanged: (value) {
                  setState(() {
                    selectedRadio = value!;
                    widget.kundliController.getKundaliType('large');
                    walletController.updateminBalance(widget
                        .kundliController.pdfPriceData!.recordList!.large!);
                  });
                },
              ),
              RadioListTile(
                title: Text(
                    "Detailed Kundali (₹${widget.kundliController.pdfPriceData!.recordList!.medium})"),
                value: 2,
                groupValue: selectedRadio,
                onChanged: (value) {
                  setState(() {
                    selectedRadio = value!;
                    widget.kundliController.getKundaliType('medium');
                    walletController.updateminBalance(widget
                        .kundliController.pdfPriceData!.recordList!.medium!);
                  });
                },
              ),
              RadioListTile(
                title: Text(
                    "Basic Kundali (₹${widget.kundliController.pdfPriceData!.recordList!.small})"),
                value: 3,
                groupValue: selectedRadio,
                onChanged: (value) {
                  setState(() {
                    selectedRadio = value!;
                    widget.kundliController.getKundaliType('small');
                    walletController.updateminBalance(widget
                        .kundliController.pdfPriceData!.recordList!.small!);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 25,
        ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
              backgroundColor:
                  WidgetStateProperty.all(Get.theme.primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.grey)),
              ),
            ),
            onPressed: widget.onPresseds,
            child: Text(
              'Submit',
              textAlign: TextAlign.center,
              style: Get.theme.primaryTextTheme.titleMedium,
            ).tr(),
          ),
        ),
      ],
    );
  }
}
