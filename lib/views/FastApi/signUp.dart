// file: astrologer_signup_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

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

  // ---------------------------
  // Controllers
  // ---------------------------
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController countryCodeCtrl =
      TextEditingController(text: "+91");
  final TextEditingController contactNoCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController skillCtrl = TextEditingController();
  final TextEditingController languageCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController expCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();

  // NEW: separate charges with minimums
  final TextEditingController chatChargeCtrl =
      TextEditingController(); // min 50
  final TextEditingController audioChargeCtrl =
      TextEditingController(); // min 200
  final TextEditingController videoChargeCtrl =
      TextEditingController(); // min 250

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

  // Profile Image
  File? profileImageFile;
  final ImagePicker _picker = ImagePicker();

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
    expCtrl.dispose();
    bioCtrl.dispose();

    // Charges
    chatChargeCtrl.dispose();
    audioChargeCtrl.dispose();
    videoChargeCtrl.dispose();

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
  // Pick profile image
  // ---------------------------
  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImageFile = File(pickedFile.path);
      });
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

  String? _validateMinInt(String? v, String label, int min) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    final parsed = int.tryParse(v.trim());
    if (parsed == null) return "$label must be a number";
    if (parsed < min) return "$label must be at least ₹$min";
    return null;
  }

  // ---------------------------
  // Submit form -> API
  // ---------------------------
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _pageController.jumpToPage(0);
      return;
    }

    setState(() => isLoading = true);

    final uri = Uri.parse(
        "https://fastapi.jyotishionline.com/api/v1/users/signup/astrologer");
    final request = http.MultipartRequest("POST", uri);

    // Parse & enforce minimums (already validated)
    final int chatCharge = int.parse(chatChargeCtrl.text.trim()); // min 50
    final int audioCharge = int.parse(audioChargeCtrl.text.trim()); // min 200
    final int videoCharge = int.parse(videoChargeCtrl.text.trim()); // min 250

    // Add all text fields
    request.fields['email'] = emailCtrl.text.trim();
    request.fields['password'] = passwordCtrl.text.trim();
    request.fields['contactNo'] = contactNoCtrl.text.trim().isNotEmpty
        ? contactNoCtrl.text.trim()
        : "0000000000";
    // API shows countryCode as string; strip + if present
    final cc = countryCodeCtrl.text.trim();
    request.fields['countryCode'] = cc.startsWith('+') ? cc.substring(1) : cc;

    request.fields['name'] =
        nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : "Unknown";
    request.fields['gender'] = selectedGender;
    // you can replace this with a proper date field if required by backend
    request.fields['birthDate'] = DateTime.now().toIso8601String();

    request.fields['primarySkill'] = skillCtrl.text.trim();
    request.fields['languageKnown'] = languageCtrl.text.trim();

    // IMPORTANT: charges mapped to API fields
    request.fields['chatCharge'] = chatCharge.toString(); // 💬 minimum 50
    request.fields['audioCallCharge'] =
        audioCharge.toString(); // 🎧 minimum 200
    request.fields['videoCallCharge'] =
        videoCharge.toString(); // 🎥 minimum 250

    request.fields['experienceInYears'] = expCtrl.text.trim();
    request.fields['currentCity'] = cityCtrl.text.trim();
    request.fields['highestQualification'] = qualificationCtrl.text.trim();
    request.fields['learnAstrology'] = learnAstroCtrl.text.trim();

    // If your API expects this, fill it; otherwise leave empty string
    request.fields['astrologerCategoryId'] = "";

    // Optionals / extras you had (these are harmless to include if backend ignores)
    request.fields['instaProfileLink'] = instaCtrl.text.trim();
    request.fields['facebookProfileLink'] = fbCtrl.text.trim();
    request.fields['linkedInProfileLink'] = linkedinCtrl.text.trim();
    request.fields['youtubeChannelLink'] = youtubeCtrl.text.trim();
    request.fields['websiteProfileLink'] = websiteCtrl.text.trim();
    request.fields['minimumEarning'] = "0";
    request.fields['maximumEarning'] = "0";
    request.fields['monthlyEarning'] = "";
    request.fields['totalOrder'] = "0";
    request.fields['currentlyworkingfulltimejob'] = "";
    request.fields['nameofplateform'] = "";
    request.fields['referedPerson'] = "";
    request.fields['loginBio'] = bioCtrl.text.trim();
    request.fields['goodQuality'] = "";
    request.fields['whatwillDo'] = "";
    request.fields['isVerified'] = isVerified.toString();
    request.fields['isActive'] = isActive.toString();
    request.fields['isDelete'] = "false";
    request.fields['chatStatus'] = "";
    request.fields['chatWaitTime'] = "";
    request.fields['callStatus'] = "";
    request.fields['callWaitTime'] = "";
    request.fields['videoCallRate'] = "0";
    request.fields['reportRate'] = "0";
    request.fields['createdBy'] = "0";
    request.fields['modifiedBy'] = "0";

    // Add profile image file if available
    if (profileImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        profileImageFile!.path,
        contentType: MediaType('image', 'jpeg'),
        filename: p.basename(profileImageFile!.path),
      ));
    }

    try {
      final streamedResponse = await request.send();
      final responseStr = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            content: Text("✅ Astrologer created successfully!"),
          ),
        );
        _formKey.currentState?.reset();
        _resetControllers();
        _pageController.jumpToPage(0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text("❌ Signup failed: $responseStr"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text("❌ Signup failed: $e"),
        ),
      );
    }

    if (!mounted) return;
    setState(() => isLoading = false);
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
    expCtrl.clear();
    bioCtrl.clear();

    chatChargeCtrl.clear();
    audioChargeCtrl.clear();
    videoChargeCtrl.clear();

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
    profileImageFile = null;
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
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profileImageFile != null
                      ? FileImage(profileImageFile!)
                      : null,
                  child: profileImageFile == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC107),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.edit, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            emailCtrl,
            "Email",
            required: true,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.email_outlined,
            validator: _validateEmail,
          ),
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
                child: _buildTextField(
                  countryCodeCtrl,
                  "Code",
                  required: true,
                  keyboardType: TextInputType.phone,
                  icon: Icons.flag_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 5,
                child: _buildTextField(
                  contactNoCtrl,
                  "Contact Number",
                  required: true,
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone_outlined,
                  validator: _validatePhone,
                ),
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

          // NEW: Three charge fields with min validation
          const SizedBox(height: 20),
          _buildTextField(
            chatChargeCtrl,
            "Chat Charge (₹/min) — min 50",
            required: true,
            keyboardType: TextInputType.number,
            icon: Icons.chat_bubble_outline,
            validator: (v) => _validateMinInt(v, "Chat charge", 50),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            audioChargeCtrl,
            "Audio Call Charge (₹/min) — min 200",
            required: true,
            keyboardType: TextInputType.number,
            icon: Icons.call_outlined,
            validator: (v) => _validateMinInt(v, "Audio call charge", 200),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            videoChargeCtrl,
            "Video Call Charge (₹/min) — min 250",
            required: true,
            keyboardType: TextInputType.number,
            icon: Icons.videocam_outlined,
            validator: (v) => _validateMinInt(v, "Video call charge", 250),
          ),

          const SizedBox(height: 20),
          _buildTextField(
            expCtrl,
            "Experience (Years)",
            required: true,
            keyboardType: TextInputType.number,
            icon: Icons.work_outline,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            bioCtrl,
            "Bio / Introduction",
            required: true,
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Optional & Settings sections remain the same
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
          _buildTextField(linkedinCtrl, "LinkedIn", icon: Icons.linked_camera),
          const SizedBox(height: 12),
          _buildTextField(youtubeCtrl, "YouTube", icon: Icons.video_collection),
          const SizedBox(height: 12),
          _buildTextField(websiteCtrl, "Website", icon: Icons.web_outlined),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          _buildSectionHeader(
              "Settings", "Toggle your visibility and verification"),
          SwitchListTile(
            value: isVerified,
            onChanged: (v) => setState(() => isVerified = v),
            title: const Text("Verified"),
          ),
          SwitchListTile(
            value: isActive,
            onChanged: (v) => setState(() => isActive = v),
            title: const Text("Active"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------------------------
  // Main build
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Astrologer Signup"),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
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
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300]),
                  child:
                      const Text("Back", style: TextStyle(color: Colors.black)),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < 2) {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  } else {
                    submitForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107)),
                child: Text(_currentPage < 2 ? "Next" : "Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
