import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:astrowaypartner/fastApi/sessionController.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/edit_profile_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/withdraw_history.dart';
import 'package:astrowaypartner/views/reviewPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'editprofile/editprofile.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? errorMessage;
  double _averageRating = 0.0;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchReviewStats();
  }

  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final api = FastApiServices();
      final fetchedProfile = await api.getAstrologerById();

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

  Future<void> fetchReviewStats() async {
    try {
      final api = FastApiServices();
      final stats = await api.getAstrologerReviewsStats();
      setState(() {
        _averageRating = stats['averageRating'] ?? 0.0;
        _totalReviews = stats['totalReviews'] ?? 0;
      });
    } catch (e) {
      print("Error fetching review stats: $e");
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([fetchProfile(), fetchReviewStats()]);
  }

  bool _hasValidData(String? value) {
    return value != null &&
        value.isNotEmpty &&
        value.trim().isNotEmpty &&
        value.trim().toLowerCase() != 'not specified' &&
        value.trim().toLowerCase() != 'not mentioned' &&
        value.trim().toLowerCase() != 'null';
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            title: Text(title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                )),
            subtitle: Text(value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                )),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    final isVerified = profile!['isVerified'] == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVerified
              ? [Colors.yellow.shade600, Colors.orange.shade600]
              : [Colors.grey.shade400, Colors.grey.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isVerified ? Colors.orange : Colors.grey).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            isVerified ? "Verified Astrologer" : "Verification Pending",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReviewsPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade50, Colors.orange.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.star_rate_rounded,
                    size: 32,
                    color: Colors.amber.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Reviews",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < _averageRating.floor()
                                  ? Icons.star
                                  : index < _averageRating
                                      ? Icons.star_half
                                      : Icons.star_border,
                              size: 16,
                              color: Colors.amber.shade600,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            "${_averageRating.toStringAsFixed(1)}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            " ($_totalReviews reviews)",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProfileImage() {
    final raw =
        (profile == null) ? null : (profile!['profileImage'] as String?);
    final trimmed = (raw ?? '').trim();

    String? imageUrl;
    if (trimmed.isNotEmpty) {
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        imageUrl = trimmed;
      } else {
        final path = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
        imageUrl = 'https://fastapi.jyotishionline.com/$path';
      }
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.yellow.shade100,
                  child: Icon(Icons.person,
                      size: 50, color: Colors.yellow.shade800),
                ),
              )
            : Container(
                color: Colors.yellow.shade100,
                child:
                    Icon(Icons.person, size: 50, color: Colors.yellow.shade800),
              ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileView() {
    if (profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              "No profile data found",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Text(
              "Please check your connection and try again",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final String? primarySkill = profile!['primarySkill'];
    final String? city = profile!['currentCity'];
    final String? languages = profile!['languageKnown'];
    final String? qualification = profile!['highestQualification'];
    final int experienceYears = profile!['experienceInYears'] ?? 0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header Section
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.yellow.shade50,
                      Colors.orange.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: 20),
                    Text(
                      profile!['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile!['contactNo'] ?? 'No Contact',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildVerifiedBadge(),
                  ],
                ),
              ),
            ),
          ),

          // Stats Row
          Row(
            children: [
              _buildStatCard(
                "Experience",
                "$experienceYears yrs",
                Icons.work_history_rounded,
                Colors.orange.shade700,
              ),
              const SizedBox(width: 12),
              const SizedBox(width: 12),
            ],
          ),

          const SizedBox(height: 24),

          // Reviews Card
          _buildRatingCard(),

          // Professional Details Section
          _buildSectionHeader("Professional Details",
              "Your professional information and expertise"),
          _buildInfoCard(
            "Years of Experience",
            "${profile!['experienceInYears'] ?? 0} years",
            Icons.work_history_rounded,
            Colors.orange.shade700,
          ),

          if (_hasValidData(primarySkill))
            _buildInfoCard(
              "Primary Skill",
              primarySkill!,
              Icons.star_rounded,
              Colors.amber.shade700,
            ),

          const SizedBox(height: 28),

          // Personal Details Section
          _buildSectionHeader("Personal Details", "Your personal information"),

          if (_hasValidData(city))
            _buildInfoCard(
              "City",
              city!,
              Icons.location_city_rounded,
              Colors.orange.shade600,
            ),

          if (_hasValidData(languages))
            _buildInfoCard(
              "Languages Known",
              languages!,
              Icons.language_rounded,
              Colors.yellow.shade600,
            ),

          if (_hasValidData(qualification))
            _buildInfoCard(
              "Highest Qualification",
              qualification!,
              Icons.school_rounded,
              Colors.amber.shade600,
            ),

          if (!_hasValidData(city) &&
              !_hasValidData(languages) &&
              !_hasValidData(qualification))
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline,
                      size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    "No personal details added yet",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Update your profile to add this information",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewEditProfileScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: Colors.yellow.shade700),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 20, color: Colors.yellow.shade700),
                      const SizedBox(width: 8),
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.yellow.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WithdrawHistoryPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.yellow.shade700,
                    elevation: 2,
                    shadowColor: Colors.yellow.shade300,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        "Withdraw History",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // View All Reviews Button
          // OutlinedButton.icon(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const ReviewsPage(),
          //       ),
          //     );
          //   },
          //   icon: Icon(Icons.rate_review, color: Colors.yellow.shade700),
          //   label: Text(
          //     "View All Reviews",
          //     style: TextStyle(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.yellow.shade700,
          //     ),
          //   ),
          //   style: OutlinedButton.styleFrom(
          //     padding: const EdgeInsets.symmetric(vertical: 12),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     side: BorderSide(color: Colors.yellow.shade700),
          //   ),
          // ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              final sessionController = Get.find<SessionController>();
              sessionController.logout();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.red.shade600,
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.exit_to_app, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade50,
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Loading your profile...",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please wait",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Unable to Load Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text("Try Again"),
                          onPressed: fetchProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: Colors.yellow.shade700,
                  backgroundColor: Colors.white,
                  strokeWidth: 2.5,
                  displacement: 20,
                  child: buildProfileView(),
                ),
    );
  }
}

// Reviews Page
