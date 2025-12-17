import 'dart:io';
import 'package:astrowaypartner/views/HomeScreen/Profile/profile_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/home_tab.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/livePage.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/payment_tab.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/profileTab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../fastApi/fastApiServices.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Add WidgetsBindingObserver to observe lifecycle changes.
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedItemPosition = 0;
  int previousposition = 0;
  String walletAmount = "";
  Map<String, dynamic>? profile;

  bool isLoading = true;
  String? errorMessage;
  int _retryCount = 0;
  final int _maxRetries = 2;

  // store astroId for quick use
  String? _astroId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // register observer
    fetchProfile();
    _initializeWallet();

    // set user online on init (best-effort)
    _setOnline(true);
  }

  @override
  void dispose() {
    // best-effort set offline when widget disposed
    _setOnline(false);
    WidgetsBinding.instance.removeObserver(this); // remove observer
    super.dispose();
  }

  // Listen to app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint("AppLifecycleState changed: $state");

    switch (state) {
      case AppLifecycleState.resumed:
      // app in foreground
        _setOnline(true);
        break;

    // Grouping all states where we want to mark user offline (best-effort)
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden: // <- Added to satisfy exhaustiveness (Flutter 3.22+)
        _setOnline(false);
        break;
    }
  }

  Future<void> fetchProfile({bool isRetry = false}) async {
    if (!isRetry) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final api = FastApiServices();
      final prefs = await SharedPreferences.getInstance();

      // READ token directly, NEVER call loginAndGetToken()
      String? token = prefs.getString("access_token");

      print("🔍 Token in fetchProfile: $token");

      if (token == null || token.isEmpty) {
        throw Exception("❌ Access token missing. User must verify OTP again.");
      }

      final astroId = prefs.getString("astro_id");
      if (astroId == null) {
        throw Exception("❌ astro_id missing. User must verify OTP again.");
      }

      final fetchedProfile = await api.getAstrologerById();
      _astroId = prefs.getString("astro_id") ?? fetchedProfile['astro_id'];

      setState(() {
        profile = fetchedProfile;
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }


  Future<void> _initializeWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _astroId = prefs.getString("astro_id") ?? _astroId;

      final astroIdLocal = _astroId;
      if (astroIdLocal != null) {
        final response = await FastApiServices().balanceAmountAstro(astroIdLocal);

        if (response != null) {
          final amount = double.tryParse(response['amount'].toString()) ?? 0.0;
          final formattedAmount = amount.toStringAsFixed(2);

          print("💰 Wallet Amount (API): $formattedAmount");

          setState(() {
            walletAmount = formattedAmount;
          });
        } else {
          print("⚠️ No data found for this wallet");
          setState(() {
            walletAmount = "--";
          });
        }
      } else {
        print("❌ Astro ID not found in SharedPreferences");
        setState(() {
          walletAmount = "--";
        });
      }
    } catch (e) {
      print("🚨 Error initializing wallet: $e");
      setState(() {
        walletAmount = "--";
      });
    }
  }

  // Single function to call API and set online/offline
  Future<void> _setOnline(bool isOnline) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? astroId = prefs.getString("astro_id") ?? _astroId;

      // If we still don't have astroId, try fetchProfile to get it (best-effort)
      if (astroId == null) {
        await fetchProfile();
        astroId = prefs.getString("astro_id") ?? _astroId;
      }

      if (astroId == null) {
        debugPrint("⚠️ astroId missing, cannot set online status.");
        return;
      }

      debugPrint("➡️ Setting online status: $isOnline for astroId=$astroId");

      final success = await FastApiServices().setOnlineStatus(astroId, isOnline);

      if (success == true) {
        debugPrint("✅ Online status updated: $isOnline");
      } else {
        debugPrint("❌ Failed to update online status (api returned false/null)");
      }
    } catch (e) {
      debugPrint("🚨 Error setting online status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        // set offline before exit (best-effort)
        await _setOnline(false);

        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile != null
                      ? (profile!['name'] ?? 'No Name')
                      : 'Loading...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              if (!isLoading) ...[
                // Refresh Wallet Button
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  constraints: const BoxConstraints(minWidth: 32),
                  onPressed: () async {
                    debugPrint("🔄 Refresh wallet");
                    await _initializeWallet();
                  },
                ),

                // WALLET BOX (Tap → Navigate to History Tab)
                GestureDetector(
                  onTap: () async {
                    // 🔥 Switch to HISTORY tab (index 2)
                    setState(() {
                      previousposition = _selectedItemPosition;
                      _selectedItemPosition = 2;
                    });

                    // keep user online
                    await _setOnline(true);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.7)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade100,
                          Colors.orange.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 18,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "₹${walletAmount.isNotEmpty ? walletAmount : "--"}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 4),
              ],
            ],
          ),

          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text("Error: $errorMessage"))
              : Container(
            height: height,
            color: Colors.grey.shade200,
            child: _buildSelectedTab(),
          ),
          bottomNavigationBar: SizedBox(
            height: 7.7.h,
            child: SnakeNavigationBar.color(
              behaviour: SnakeBarBehaviour.pinned,
              snakeViewColor: Colors.grey.shade500,
              unselectedItemColor: Colors.blueGrey,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              currentIndex: _selectedItemPosition,
              onTap: (value) {
                setState(() {
                  previousposition = _selectedItemPosition;
                  _selectedItemPosition = value;
                });
                // ensure online remains true while inside app
                _setOnline(true);
              },
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: const Icon(Icons.videocam), label: "Live"),
                BottomNavigationBarItem(icon: const Icon(Icons.history), label: "History"),
                BottomNavigationBarItem(icon: const Icon(Icons.person), label: "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTab() {
    switch (_selectedItemPosition) {
      case 0:
        return const HomeTabScreen();
      case 1:
        return GoLivePage();
      case 2:
        return const PaymentHistoryTab();
      case 3:
        return ProfileTabScreen();
      default:
        return const SizedBox();
    }
  }

  void _loadWalletAmount() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        walletAmount = "500"; // mock Data
      });
    } catch (e) {
      debugPrint("Error loading wallet: $e");
      setState(() {
        walletAmount = "--"; // fallback
      });
    }
  }
}
