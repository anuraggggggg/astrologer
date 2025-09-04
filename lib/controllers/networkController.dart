// // ignore_for_file: file_names

// import 'dart:async';
// import 'dart:developer';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:get/get.dart';

// class NetworkController extends GetxController {
//   var connectionStatus = 0.obs;
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;

//   @override
//   void onInit() {
//     super.onInit();
//     _connectivitySubscription =
//         _connectivity.onConnectivityChanged.listen(updateConnectivity);
//     initConnectivity(); // Initial check
//   }

//   @override
//   void onClose() {
//     super.onClose();
//     _connectivitySubscription.cancel();
//   }

//   Future<void> initConnectivity() async {
//     ConnectivityResult? result;
//     try {
//       result = await _connectivity.checkConnectivity();
//     } catch (e) {
//       log(e.toString());
//     }
//     updateConnectivity(result!);
//   }

//   void updateConnectivity(ConnectivityResult result) {
//     switch (result) {
//       case ConnectivityResult.wifi:
//         connectionStatus.value = 1;
//         break;
//       case ConnectivityResult.mobile:
//         connectionStatus.value = 2;
//         break;
//       case ConnectivityResult.none:
//         connectionStatus.value = 0;

//         break;
//       default:
//     }
//   }
// }
// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  var connectionStatus = 0.obs;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }

  Future<void> initConnectivity() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Handle multiple results if needed (e.g., both mobile and Wi-Fi)
    ConnectivityResult effectiveResult =
        results.isNotEmpty ? results.first : ConnectivityResult.none;

    switch (effectiveResult) {
      case ConnectivityResult.wifi:
        connectionStatus.value = 1;
        break;
      case ConnectivityResult.mobile:
        connectionStatus.value = 2;
        break;
      case ConnectivityResult.none:
        connectionStatus.value = 0;
        break;
      default:
        log('Unknown connectivity: $effectiveResult');
    }
  }
}
