// file: astrologer_signup_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// AstrologerSignupPage
/// Full multi-step signup form wired to:
/// POST https://fastapi.jyotishionline.com/api/v1/users/signup/astrologer
class AstrologerSignupPage extends StatefulWidget {
  const AstrologerSignupPage({Key? key}) : super(key: key);

  @override
  State<AstrologerSignupPage> createState() => _AstrologerSignupPageState();
}

class _AstrologerSignupPageState extends State<AstrologerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isLoading = false;

  // Required controllers (added email/password/contact/countryCode)
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController countryCodeCtrl =
      TextEditingController(text: "+91");
  final TextEditingController contactNoCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController skillCtrl = TextEditingController();
  final TextEditingController languageCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController chargeCtrl = TextEditingController();
  final TextEditingController expCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();

  // Optional fields
  final TextEditingController qualificationCtrl = TextEditingController();
  final TextEditingController learnAstroCtrl = TextEditingController();
  final TextEditingController instaCtrl = TextEditingController();
  final TextEditingController fbCtrl = TextEditingController();
  final TextEditingController linkedinCtrl = TextEditingController();
  final TextEditingController youtubeCtrl = TextEditingController();
  final TextEditingController websiteCtrl = TextEditingController();

  // Settings switches & selection
  bool isVerified = false;
  bool isActive = true;
  String selectedGender = "Male"; // Male / Female / Other

  // Password visibility toggle
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page != null) {
        setState(() => _currentPage = page.round());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    // Required
    emailCtrl.dispose();
    passwordCtrl.dispose();
    countryCodeCtrl.dispose();
    contactNoCtrl.dispose();
    nameCtrl.dispose();
    skillCtrl.dispose();
    languageCtrl.dispose();
    cityCtrl.dispose();
    chargeCtrl.dispose();
    expCtrl.dispose();
    bioCtrl.dispose();

    // Optional
    qualificationCtrl.dispose();
    learnAstroCtrl.dispose();
    instaCtrl.dispose();
    fbCtrl.dispose();
    linkedinCtrl.dispose();
    youtubeCtrl.dispose();
    websiteCtrl.dispose();

    super.dispose();
  }

  // ---------------------------
  // Helper: HTTP call to API
  // ---------------------------
  Future<Map<String, dynamic>> createAstrologer(
      Map<String, dynamic> body) async {
    final url = Uri.parse(
        "https://fastapi.jyotishionline.com/api/v1/users/signup/astrologer");
    try {
      print("\n==============================");
      print("📤 POST $url");
      print(
          "📝 Request body (pretty):\n${const JsonEncoder.withIndent('  ').convert(body)}");
      print("==============================");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
        body: jsonEncode(body),
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📩 RAW RESPONSE: ${response.body}");
      if (response.body.isNotEmpty) {
        try {
          final parsed = jsonDecode(response.body);
          print(
              "📘 PARSED RESPONSE:\n${const JsonEncoder.withIndent('  ').convert(parsed)}");
        } catch (_) {
          // ignore parse error
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        // return server message if available
        final err = response.body.isNotEmpty
            ? response.body
            : "HTTP ${response.statusCode}";
        return {"success": false, "error": err};
      }
    } catch (e, st) {
      print("🚨 Exception while calling API: $e");
      print(st);
      return {"success": false, "error": e.toString()};
    }
  }

  // ---------------------------
  // Field validators
  // ---------------------------
  String? _validateRequired(String? v, String label) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";
    final email = v.trim();
    final emailRegex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(email)) return "Enter a valid email";
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return "Password is required";
    if (v.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return "Contact number is required";
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return "Enter a valid contact number";
    return null;
  }

  // ---------------------------
  // Submit form -> API
  // ---------------------------
  Future<void> submitForm() async {
    // Validate entire form before submission
    if (!_formKey.currentState!.validate()) {
      // If currently not on first page, navigate to it so user sees errors
      _pageController.jumpToPage(0);
      return;
    }

    setState(() => isLoading = true);

    // Build request according to API schema
    final nowIso = DateTime.now().toIso8601String();
    final Map<String, dynamic> body = {
      "email": emailCtrl.text.trim(),
      "password": passwordCtrl.text.trim(),
      "contactNo": contactNoCtrl.text.trim(),
      "countryCode": countryCodeCtrl.text.trim(),
      "name": nameCtrl.text.trim(),
      "gender": selectedGender,
      "isContactVerified": false,
      "otpCode": "", // if you plan to support OTP remove or set accordingly
      "otpExpiry": null,
      "birthDate": nowIso,
      "primarySkill": skillCtrl.text.trim(),
      "languageKnown": languageCtrl.text.trim(),
      "profileImage": "",
      "charge": int.tryParse(chargeCtrl.text.trim()) ?? 0,
      "experienceInYears": int.tryParse(expCtrl.text.trim()) ?? 0,
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
      "monthlyEarning": "",
      "totalOrder": 0,
      "currentlyworkingfulltimejob": "",
      "nameofplateform": "",
      "referedPerson": "",
      "loginBio": bioCtrl.text.trim(),
      "goodQuality": "",
      "whatwillDo": "",
      "isVerified": isVerified,
      "isActive": isActive,
      "isDelete": false,
      "chatStatus": "",
      "chatWaitTime": "",
      "callStatus": "",
      "callWaitTime": "",
      "videoCallRate": 0,
      "reportRate": 0,
      "createdBy": 0,
      "modifiedBy": 0
    };

    final result = await createAstrologer(body);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result["success"] == true) {
      // Success -> Show message and reset form
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: const Text("✅ Astrologer created successfully!"),
        ),
      );
      _formKey.currentState?.reset();
      // reset controllers as well
      _resetControllers();
      _pageController.jumpToPage(0);
    } else {
      // Error -> Show server message if available
      final err = result["error"]?.toString() ?? "Unknown error";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text("❌ Signup failed: $err"),
        ),
      );
    }
  }

  void _resetControllers() {
    emailCtrl.clear();
    passwordCtrl.clear();
    countryCodeCtrl.text = "+91";
    contactNoCtrl.clear();
    nameCtrl.clear();
    skillCtrl.clear();
    languageCtrl.clear();
    cityCtrl.clear();
    chargeCtrl.clear();
    expCtrl.clear();
    bioCtrl.clear();
    qualificationCtrl.clear();
    learnAstroCtrl.clear();
    instaCtrl.clear();
    fbCtrl.clear();
    linkedinCtrl.clear();
    youtubeCtrl.clear();
    websiteCtrl.clear();
    selectedGender = "Male";
    isVerified = false;
    isActive = true;
  }

  // ---------------------------
  // UI helpers
  // ---------------------------
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscure,
      validator:
          validator ?? (required ? (v) => _validateRequired(v, label) : null),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: const Color(0xFFFFC107))
            : null,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.yellow[50],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = _currentPage == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFC107) : Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender",
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: "Male",
                groupValue: selectedGender,
                onChanged: (v) => setState(() => selectedGender = v ?? "Male"),
                title: const Text("Male"),
                activeColor: const Color(0xFFFFC107),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: "Female",
                groupValue: selectedGender,
                onChanged: (v) =>
                    setState(() => selectedGender = v ?? "Female"),
                title: const Text("Female"),
                activeColor: const Color(0xFFFFC107),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: "Other",
                groupValue: selectedGender,
                onChanged: (v) => setState(() => selectedGender = v ?? "Other"),
                title: const Text("Other"),
                activeColor: const Color(0xFFFFC107),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------
  // Sections (PageView children)
  // ---------------------------
  Widget _buildRequiredSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              "Basic Information", "Please provide your essential details."),
          _buildTextField(emailCtrl, "Email",
              required: true,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
              validator: _validateEmail),
          const SizedBox(height: 20),
          _buildTextField(
            passwordCtrl,
            "Password",
            required: true,
            icon: Icons.lock_outline,
            obscure: _obscurePassword,
            validator: _validatePassword,
            suffix: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[700]),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Flexible(
                flex: 2,
                child: _buildTextField(countryCodeCtrl, "Code",
                    required: true,
                    keyboardType: TextInputType.phone,
                    icon: Icons.flag_outlined),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 5,
                child: _buildTextField(contactNoCtrl, "Contact Number",
                    required: true,
                    keyboardType: TextInputType.phone,
                    icon: Icons.phone_outlined,
                    validator: _validatePhone),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(nameCtrl, "Full Name",
              required: true, icon: Icons.person_outline),
          const SizedBox(height: 20),
          _buildGenderSelector(),
          const SizedBox(height: 20),
          _buildTextField(skillCtrl, "Primary Skill",
              required: true, icon: Icons.star_border),
          const SizedBox(height: 20),
          _buildTextField(languageCtrl, "Languages Known",
              required: true, icon: Icons.language),
          const SizedBox(height: 20),
          _buildTextField(cityCtrl, "Current City",
              required: true, icon: Icons.location_city_outlined),
          const SizedBox(height: 20),
          _buildTextField(chargeCtrl, "Charge (₹ per session)",
              required: true,
              keyboardType: TextInputType.number,
              icon: Icons.currency_rupee),
          const SizedBox(height: 20),
          _buildTextField(expCtrl, "Experience (Years)",
              required: true,
              keyboardType: TextInputType.number,
              icon: Icons.work_outline),
          const SizedBox(height: 20),
          _buildTextField(bioCtrl, "Bio / Introduction",
              required: true, icon: Icons.description_outlined, maxLines: 4),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOptionalSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Additional Information",
              "Help clients know you better (optional)."),
          _buildTextField(qualificationCtrl, "Highest Qualification",
              icon: Icons.school_outlined),
          const SizedBox(height: 20),
          _buildTextField(learnAstroCtrl, "How did you learn Astrology?",
              icon: Icons.auto_awesome_outlined, maxLines: 3),
          const SizedBox(height: 24),
          Text("Social Media Links",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(instaCtrl, "Instagram",
              icon: Icons.camera_alt_outlined),
          const SizedBox(height: 12),
          _buildTextField(fbCtrl, "Facebook", icon: Icons.facebook),
          const SizedBox(height: 12),
          _buildTextField(linkedinCtrl, "LinkedIn",
              icon: Icons.business_center_outlined),
          const SizedBox(height: 12),
          _buildTextField(youtubeCtrl, "YouTube",
              icon: Icons.video_library_outlined),
          const SizedBox(height: 12),
          _buildTextField(websiteCtrl, "Website", icon: Icons.public_outlined),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
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
          const SizedBox(height: 24),
          Text("Note: You can update other settings later from profile.",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
        const SizedBox(height: 6),
        Text(subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 18),
      ],
    );
  }

  // ---------------------------
  // Bottom navigation buttons
  // ---------------------------
  Widget _buildBottomButtons() {
    return Row(
      children: [
        if (_currentPage > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut);
                    },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(120, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: Color(0xFFFFC107), width: 2),
              ),
              child: const Text("Back",
                  style: TextStyle(
                      color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
            ),
          )
        else
          const Spacer(),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    // If on first page, validate required fields for page1 only
                    if (_currentPage == 0) {
                      // validate page1 inputs specifically
                      final page1Valid = _validatePage1();
                      if (page1Valid) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut);
                      }
                    } else if (_currentPage < 2) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut);
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
            child: Text(_currentPage == 2 ? "Submit" : "Next",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // Validate only page 1 required fields before moving to next page
  bool _validatePage1() {
    // We run validators for page1 controllers only
    final tmpKey = GlobalKey<FormState>();
    // Instead of creating a temporary form, we can manually validate required fields:
    final emailErr = _validateEmail(emailCtrl.text);
    final passErr = _validatePassword(passwordCtrl.text);
    final phoneErr = _validatePhone(contactNoCtrl.text);
    final nameErr = _validateRequired(nameCtrl.text, "Full Name");
    final skillErr = _validateRequired(skillCtrl.text, "Primary Skill");
    final langErr = _validateRequired(languageCtrl.text, "Languages Known");
    final cityErr = _validateRequired(cityCtrl.text, "Current City");
    final chargeErr = _validateRequired(chargeCtrl.text, "Charge");
    final expErr = _validateRequired(expCtrl.text, "Experience");
    final bioErr = _validateRequired(bioCtrl.text, "Bio");

    final errors = <String>[];
    if (emailErr != null) errors.add(emailErr);
    if (passErr != null) errors.add(passErr);
    if (phoneErr != null) errors.add(phoneErr);
    if (nameErr != null) errors.add(nameErr);
    if (skillErr != null) errors.add(skillErr);
    if (langErr != null) errors.add(langErr);
    if (cityErr != null) errors.add(cityErr);
    if (chargeErr != null) errors.add(chargeErr);
    if (expErr != null) errors.add(expErr);
    if (bioErr != null) errors.add(bioErr);

    if (errors.isNotEmpty) {
      // Show first error in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(errors.first)),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Astrologer Registration",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildPageIndicator(),
                const SizedBox(height: 20),
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
                const SizedBox(height: 18),
                isLoading
                    ? Column(
                        children: const [
                          CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(Color(0xFFFFC107))),
                          SizedBox(height: 12),
                          Text("Creating your account...",
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 12),
                        ],
                      )
                    : _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
