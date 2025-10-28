import 'dart:io';
import 'package:astrowaypartner/views/HomeScreen/Profile/profile_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/home_tab.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedItemPosition = 0;
  int previousposition = 0;
  String walletAmount = ""; // ✅ Safe placeholder
  Map<String, dynamic>? profile;

  bool isLoading = true;
  String? errorMessage;
  int _retryCount = 0;
  final int _maxRetries = 2;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    _initializeWallet();
    // Removed direct API calls
    // You can trigger API calls later when needed
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
      String? token = prefs.getString("access_token");

      // If token is null or we're retrying due to auth error, get new token
      if (token == null || isRetry) {
        await api.loginAndGetToken();
        token = prefs.getString("access_token");
        _retryCount++;
      }

      if (token == null) {
        throw Exception("Token missing even after login!");
      }

      final userId = prefs.getString("user_id");
      if (userId == null) {
        throw Exception("User ID missing. Cannot fetch profile.");
      }

      final fetchedProfile = await api.getAstrologerById();

      // Reset retry count on successful fetch
      _retryCount = 0;

      setState(() {
        profile = fetchedProfile;
        isLoading = false;
      });
    } catch (e) {
      // Handle unauthorized error specifically
      if (e.toString().contains('Unauthorized') && _retryCount < _maxRetries) {
        // Retry with new token
        await fetchProfile(isRetry: true);
        return;
      }

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }


  Future<void> _initializeWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final astroId = prefs.getString("astro_id");

      if (astroId != null) {
        final response = await FastApiServices().balanceAmountAstro(astroId);

        if (response != null) {
          final amount = (response['amount'] as num).toDouble(); // ensures it's a double
          final formattedAmount = amount.toStringAsFixed(2); // 2 decimal places
          print("💰 Wallet Amount (API): $formattedAmount");

          // ✅ Update UI safely
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


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
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
            title: Text(
              profile != null ? (profile!['name'] ?? 'No Name') : 'Loading...',
            ),
            actions: [
              if (!isLoading) ...[
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _initializeWallet,
                ),
                GestureDetector(
                  onTap: () {
                    debugPrint("Wallet tapped");
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Row(
                      children: [
                        const Text("₹"),
                        Text(walletAmount.isNotEmpty ? walletAmount : "--"),
                      ],
                    ),
                  ),
                ),
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
              },
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.videocam), label: "Live"),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.history), label: "History"),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.person), label: "Profile"),
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
        return const Center(child: Text("Live Tab"));
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
        walletAmount = "500"; // ✅ Mock Data
      });
    } catch (e) {
      debugPrint("Error loading wallet: $e");
      setState(() {
        walletAmount = "--"; // fallback
      });
    }
  }
}
