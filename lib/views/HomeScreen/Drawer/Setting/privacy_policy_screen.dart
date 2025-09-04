// ignore_for_file: must_be_immutable

import 'package:astrowaypartner/services/apiHelper.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

String privacyUrl = "https://astroway.diploy.in/privacyPolicy";

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  APIHelper helper = APIHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }

  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
          const CircularProgressIndicator();
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('Terms condition error- > $error');
        },
      ),
    )
    ..loadRequest(Uri.parse(privacyUrl));
}
