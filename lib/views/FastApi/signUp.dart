import 'package:flutter/material.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class AstrologerSignupPage extends StatefulWidget {
  const AstrologerSignupPage({Key? key}) : super(key: key);

  @override
  State<AstrologerSignupPage> createState() => _AstrologerSignupPageState();
}

class _AstrologerSignupPageState extends State<AstrologerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controllers (Required)
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController skillCtrl = TextEditingController();
  final TextEditingController languageCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController chargeCtrl = TextEditingController();
  final TextEditingController expCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();

  // Optional Fields
  final TextEditingController qualificationCtrl = TextEditingController();
  final TextEditingController learnAstroCtrl = TextEditingController();
  final TextEditingController instaCtrl = TextEditingController();
  final TextEditingController fbCtrl = TextEditingController();
  final TextEditingController linkedinCtrl = TextEditingController();
  final TextEditingController youtubeCtrl = TextEditingController();
  final TextEditingController websiteCtrl = TextEditingController();

  bool isLoading = false;
  bool isVerified = false;
  bool isActive = true;

  final FastApiServices api = FastApiServices();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    nameCtrl.dispose();
    skillCtrl.dispose();
    languageCtrl.dispose();
    cityCtrl.dispose();
    chargeCtrl.dispose();
    expCtrl.dispose();
    bioCtrl.dispose();
    qualificationCtrl.dispose();
    learnAstroCtrl.dispose();
    instaCtrl.dispose();
    fbCtrl.dispose();
    linkedinCtrl.dispose();
    youtubeCtrl.dispose();
    websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final now = DateTime.now().toIso8601String();

    final body = {
      "id": "",
      "availabilitiesId": 0,
      "birthDate": now,
      "primarySkill": skillCtrl.text.trim(),
      "languageKnown": languageCtrl.text.trim(),
      "profileImage": "",
      "charge": int.tryParse(chargeCtrl.text) ?? 0,
      "experienceInYears": int.tryParse(expCtrl.text) ?? 0,
      "currentCity": cityCtrl.text.trim(),
      "highestQualification": qualificationCtrl.text.trim(),
      "learnAstrology": learnAstroCtrl.text.trim(),
      "astrologerCategoryId": "",
      "instaProfileLink": instaCtrl.text.trim(),
      "facebookProfileLink": fbCtrl.text.trim(),
      "linkedInProfileLink": linkedinCtrl.text.trim(),
      "youtubeChannelLink": youtubeCtrl.text.trim(),
      "websiteProfileLink": websiteCtrl.text.trim(),
      "minimumEarning": 0,
      "maximumEarning": 0,
      "loginBio": bioCtrl.text.trim(),
      "currentlyworkingfulltimejob": "",
      "goodQuality": "",
      "whatwillDo": "",
      "isVerified": isVerified,
      "totalOrder": 0,
      "country": "",
      "isActive": isActive,
      "isDelete": false,
      "created_at": now,
      "updated_at": now,
      "createdBy": 0,
      "modifiedBy": 0,
      "nameofplateform": "",
      "monthlyEarning": "",
      "referedPerson": "",
      "chatStatus": "",
      "chatWaitTime": "",
      "callStatus": "",
      "callWaitTime": "",
      "videoCallRate": 0,
      "reportRate": 0,
      "deleted_at": null
    };

    try {
      final result = await api.createAstrologer(body);

      if (!mounted) return;
      setState(() => isLoading = false);

      if (result["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            content: Text("✅ Astrologer Created: ${result["data"]["id"]}"),
          ),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text("❌ Error: ${result["error"]}"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text("❌ An unexpected error occurred: $e"),
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool required = false,
      TextInputType keyboardType = TextInputType.text,
      IconData? icon,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: const Color(0xFFFFC107))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFC107)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
        ),
        filled: true,
        fillColor: Colors.yellow[50],
      ),
      validator: required
          ? (v) {
              if (v == null || v.isEmpty) {
                return "$label is required";
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPage == index
                ? const Color(0xFFFFC107) // Yellow primary color
                : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRequiredSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              "Basic Information", "Please provide your essential details."),
          _buildTextField(nameCtrl, "Full Name",
              required: true, icon: Icons.person_outline),
          const SizedBox(height: 24),
          _buildTextField(skillCtrl, "Primary Skill",
              required: true, icon: Icons.star_border),
          const SizedBox(height: 24),
          _buildTextField(languageCtrl, "Languages Known",
              required: true, icon: Icons.language),
          const SizedBox(height: 24),
          _buildTextField(cityCtrl, "Current City",
              required: true, icon: Icons.location_city_outlined),
          const SizedBox(height: 24),
          _buildTextField(chargeCtrl, "Charge (₹ per session)",
              required: true,
              keyboardType: TextInputType.number,
              icon: Icons.currency_rupee),
          const SizedBox(height: 24),
          _buildTextField(expCtrl, "Experience (Years)",
              required: true,
              keyboardType: TextInputType.number,
              icon: Icons.work_outline),
          const SizedBox(height: 24),
          _buildTextField(bioCtrl, "Bio/Introduction",
              required: true, icon: Icons.description_outlined, maxLines: 5),
        ],
      ),
    );
  }

  Widget _buildOptionalSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Additional Information",
              "Help clients know you better (optional)."),
          _buildTextField(qualificationCtrl, "Highest Qualification",
              icon: Icons.school_outlined),
          const SizedBox(height: 24),
          _buildTextField(learnAstroCtrl, "How did you learn Astrology?",
              icon: Icons.auto_awesome_outlined, maxLines: 3),
          const SizedBox(height: 32),
          Text(
            "Social Media Links",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTextField(instaCtrl, "Instagram",
              icon: Icons.camera_alt_outlined),
          const SizedBox(height: 20),
          _buildTextField(fbCtrl, "Facebook", icon: Icons.facebook),
          const SizedBox(height: 20),
          _buildTextField(linkedinCtrl, "LinkedIn",
              icon: Icons.business_center_outlined),
          const SizedBox(height: 20),
          _buildTextField(youtubeCtrl, "YouTube",
              icon: Icons.video_library_outlined),
          const SizedBox(height: 20),
          _buildTextField(websiteCtrl, "Website", icon: Icons.public_outlined),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            "Account Settings", "Configure your account preferences."),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Verified Account",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text("Get a verified badge on your profile",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Switch(
                      value: isVerified,
                      onChanged: (v) => setState(() => isVerified = v),
                      activeColor: const Color(0xFFFFC107),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Active Status",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text("Make your profile visible to clients",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Switch(
                      value: isActive,
                      onChanged: (v) => setState(() => isActive = v),
                      activeColor: const Color(0xFFFFC107),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        isLoading
            ? Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFFFC107)),
                    ),
                    const SizedBox(height: 16),
                    Text("Creating your account...",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.grey[600])),
                  ],
                ),
              )
            : ElevatedButton(
                onPressed: submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  "Complete Registration",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Astrologer Registration",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageIndicator(),
                const SizedBox(height: 32),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildRequiredSection(),
                      _buildOptionalSection(),
                      _buildSettingsSection(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            side: const BorderSide(
                                color: Color(0xFFFFC107), width: 2),
                          ),
                          child: const Text("Back",
                              style: TextStyle(
                                  color: Color(0xFFFFC107),
                                  fontWeight: FontWeight.bold)),
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == 0) {
                            if (_formKey.currentState!.validate()) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                          } else if (_currentPage < 2) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            submitForm();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: Text(
                          _currentPage == 2 ? "Submit" : "Next",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
