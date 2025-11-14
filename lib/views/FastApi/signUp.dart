// file: astrologer_signup_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

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

  // KYC / Bank fields
  final TextEditingController aadhaarNumberCtrl = TextEditingController();
  final TextEditingController panNumberCtrl = TextEditingController();
  final TextEditingController bankNameCtrl = TextEditingController();
  final TextEditingController accountNumberCtrl = TextEditingController();
  final TextEditingController ifscCtrl = TextEditingController();
  final TextEditingController upiCtrl = TextEditingController();

  // Settings switches & selection
  bool isVerified = false;
  bool isActive = true;
  String selectedGender = "Male"; // Male / Female / Other

  // Password visibility toggle
  bool _obscurePassword = true;

  // Profile Image + KYC images
  File? profileImageFile;
  File? aadhaarFrontFile;
  File? aadhaarBackFile;
  File? panCardFile;
  File? bankPassbookFile;

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

    // KYC
    aadhaarNumberCtrl.dispose();
    panNumberCtrl.dispose();
    bankNameCtrl.dispose();
    accountNumberCtrl.dispose();
    ifscCtrl.dispose();
    upiCtrl.dispose();

    super.dispose();
  }

  // ---------------------------
  // Pick image helper
  // ---------------------------
  Future<File?> _pickImage({required String purpose}) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }

  Future<void> _pickProfileImage() async {
    final file = await _pickImage(purpose: 'profile');
    if (file != null) {
      setState(() => profileImageFile = file);
    }
  }

  Future<void> _pickAadhaarFront() async {
    final file = await _pickImage(purpose: 'aadhaar_front');
    if (file != null) setState(() => aadhaarFrontFile = file);
  }

  Future<void> _pickAadhaarBack() async {
    final file = await _pickImage(purpose: 'aadhaar_back');
    if (file != null) setState(() => aadhaarBackFile = file);
  }

  Future<void> _pickPanCard() async {
    final file = await _pickImage(purpose: 'pan_card');
    if (file != null) setState(() => panCardFile = file);
  }

  Future<void> _pickBankPassbook() async {
    final file = await _pickImage(purpose: 'bank_passbook');
    if (file != null) setState(() => bankPassbookFile = file);
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

  String? _validateAadhaar(String? v) {
    if (v == null || v.trim().isEmpty) return "Aadhaar number is required";
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 12) return "Aadhaar must be exactly 12 digits";
    return null;
  }

  String? _validatePAN(String? v) {
    if (v == null || v.trim().isEmpty) return "PAN is required";
    final pan = v.trim().toUpperCase();
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    if (!panRegex.hasMatch(pan)) return "Enter a valid PAN (e.g. AAAAA9999A)";
    return null;
  }

  String? _validateIFSC(String? v) {
    if (v == null || v.trim().isEmpty) return "IFSC is required";
    final ifsc = v.trim().toUpperCase();
    final ifscRegex = RegExp(r'^[A-Z]{4}0[0-9A-Z]{6}$');
    if (ifsc.length != 11 || !ifscRegex.hasMatch(ifsc))
      return "Enter a valid IFSC (11 chars, e.g. ABCD0XXXXX)";
    return null;
  }

  String? _validateAccount(String? v) {
    if (v == null || v.trim().isEmpty) return "Account number is required";
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return "Account number must be at least 8 digits";
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

    // Ensure KYC images are provided
    if (aadhaarFrontFile == null ||
        aadhaarBackFile == null ||
        panCardFile == null ||
        bankPassbookFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text("❌ Please attach all required KYC documents."),
        ),
      );
      _pageController.jumpToPage(3);
      return;
    }

    setState(() => isLoading = true);

    final uri = Uri.parse(
        "https://fastapi.jyotishionline.com/api/v1/users/signup/astrologer");

    print("====================================");
    print("🟡 DEBUG: Preparing Signup Request");
    print("API: $uri");
    print("====================================");

    final request = http.MultipartRequest("POST", uri);

    // DEBUG: print all fields
    Map<String, dynamic> debugFields = {
      "email": emailCtrl.text.trim(),
      "password": passwordCtrl.text.trim(),
      "contactNo": contactNoCtrl.text.trim(),
      "countryCode": countryCodeCtrl.text.trim(),
      "name": nameCtrl.text.trim(),
      "gender": selectedGender,
      "birthDate": DateTime.now().toIso8601String(),
      "primarySkill": skillCtrl.text.trim(),
      "languageKnown": languageCtrl.text.trim(),
      "chatCharge": chatChargeCtrl.text.trim(),
      "audioCallCharge": audioChargeCtrl.text.trim(),
      "videoCallCharge": videoChargeCtrl.text.trim(),
      "experienceInYears": expCtrl.text.trim(),
      "currentCity": cityCtrl.text.trim(),
      "highestQualification": qualificationCtrl.text.trim(),
      "learnAstrology": learnAstroCtrl.text.trim(),
      "aadhaarNumber": aadhaarNumberCtrl.text.trim(),
      "panNumber": panNumberCtrl.text.trim(),
      "bankName": bankNameCtrl.text.trim(),
      "accountNumber": accountNumberCtrl.text.trim(),
      "ifscCode": ifscCtrl.text.trim(),
      "upiId": upiCtrl.text.trim(),
    };

    print("🟡 DEBUG: Fields Being Sent:");
    debugFields.forEach((key, value) {
      print("$key => $value");
    });

    // Add fields to request
    debugFields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Optional extras
    request.fields['instaProfileLink'] = instaCtrl.text.trim();
    request.fields['facebookProfileLink'] = fbCtrl.text.trim();
    request.fields['linkedInProfileLink'] = linkedinCtrl.text.trim();
    request.fields['youtubeChannelLink'] = youtubeCtrl.text.trim();
    request.fields['websiteProfileLink'] = websiteCtrl.text.trim();
    request.fields['astrologerCategoryId'] = "";

    print("🟡 DEBUG: Optional Fields Added");

    // Add image files
    Future<void> addFile(String fieldName, File? file) async {
      if (file != null) {
        final bytes = await file.length();
        print(
            "📸 DEBUG: Adding File => $fieldName :: ${file.path} :: $bytes bytes");

        request.files.add(await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: MediaType('image', 'jpeg'),
          filename: p.basename(file.path),
        ));
      }
    }

    await addFile("profileImage", profileImageFile);
    await addFile("aadhaarFront", aadhaarFrontFile);
    await addFile("aadhaarBack", aadhaarBackFile);
    await addFile("panCardImage", panCardFile);
    await addFile("bankPassbookImage", bankPassbookFile);

    print("====================================");
    print("🚀 DEBUG: Sending Request to API...");
    print("====================================");

    try {
      final streamedResponse = await request.send();
      final responseStr = await streamedResponse.stream.bytesToString();

      print("====================================");
      print("🟢 Response Status: ${streamedResponse.statusCode}");
      print("🟢 Response Body: $responseStr");
      print("====================================");

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
      print("❌ DEBUG ERROR: $e");

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

    // KYC
    aadhaarNumberCtrl.clear();
    panNumberCtrl.clear();
    bankNameCtrl.clear();
    accountNumberCtrl.clear();
    ifscCtrl.clear();
    upiCtrl.clear();

    selectedGender = "Male";
    isVerified = false;
    isActive = true;
    profileImageFile = null;
    aadhaarFrontFile = null;
    aadhaarBackFile = null;
    panCardFile = null;
    bankPassbookFile = null;
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
    // now 4 pages
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
          _buildPageIndicator(),
        ],
      ),
    );
  }

  // Optional & Settings sections remain the same
  Widget _buildOptionalSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
          const SizedBox(height: 24),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _kycFileTile(String title, File? file, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 64,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
          image: file != null ? DecorationImage(image: FileImage(file)) : null,
        ),
        child:
            file == null ? const Icon(Icons.insert_drive_file_outlined) : null,
      ),
      title: Text(title),
      trailing: ElevatedButton(
        onPressed: onTap,
        style:
            ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
        child: Text(file == null ? "Attach" : "Change"),
      ),
    );
  }

  Widget _buildKycSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("KYC & Bank Details",
              "Upload Aadhaar, PAN and bank details for verification."),
          _buildTextField(aadhaarNumberCtrl, "Aadhaar Number",
              required: true,
              keyboardType: TextInputType.number,
              icon: Icons.credit_card,
              validator: _validateAadhaar),
          const SizedBox(height: 12),
          _buildTextField(panNumberCtrl, "PAN Number",
              required: true,
              keyboardType: TextInputType.text,
              icon: Icons.credit_card,
              validator: _validatePAN),
          const SizedBox(height: 12),
          _buildTextField(bankNameCtrl, "Bank Name",
              required: true, icon: Icons.account_balance),
          const SizedBox(height: 12),
          _buildTextField(accountNumberCtrl, "Account Number",
              required: true,
              keyboardType: TextInputType.number,
              icon: Icons.numbers,
              validator: _validateAccount),
          const SizedBox(height: 12),
          _buildTextField(ifscCtrl, "IFSC Code",
              required: true,
              keyboardType: TextInputType.text,
              icon: Icons.code,
              validator: _validateIFSC),
          const SizedBox(height: 12),
          _buildTextField(upiCtrl, "UPI ID (optional)",
              required: false, icon: Icons.send_to_mobile),
          const SizedBox(height: 16),
          Text("Required Documents",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _kycFileTile("Aadhaar Front", aadhaarFrontFile, _pickAadhaarFront),
          const SizedBox(height: 8),
          _kycFileTile("Aadhaar Back", aadhaarBackFile, _pickAadhaarBack),
          const SizedBox(height: 8),
          _kycFileTile("PAN Card", panCardFile, _pickPanCard),
          const SizedBox(height: 8),
          _kycFileTile("Bank Passbook / Cancelled Cheque", bankPassbookFile,
              _pickBankPassbook),
          const SizedBox(height: 24),
          _buildPageIndicator(),
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
                _buildKycSection(), // new KYC page (index 3)
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
                  if (_currentPage < 3) {
                    // validate current page's fields before moving forward
                    final valid = _validateCurrentPage(_currentPage);
                    if (valid) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  } else {
                    submitForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107)),
                child: Text(_currentPage < 3 ? "Next" : "Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateCurrentPage(int pageIndex) {
    // For simple UX: run form validation for all fields, but if invalid,
    // jump to the first page so user sees errors. We still allow navigating
    // step-by-step, but prevent moving forward if required fields on current page fail.
    // We'll do a minimal check per page to avoid forcing user to fill everything at once.
    switch (pageIndex) {
      case 0:
        // required section validations
        final emailValid = _validateEmail(emailCtrl.text) == null;
        final pwdValid = _validatePassword(passwordCtrl.text) == null;
        final phoneValid = _validatePhone(contactNoCtrl.text) == null;
        final nameValid = _validateRequired(nameCtrl.text, "Full Name") == null;
        final skillValid =
            _validateRequired(skillCtrl.text, "Primary Skill") == null;
        final langValid =
            _validateRequired(languageCtrl.text, "Languages Known") == null;
        final cityValid =
            _validateRequired(cityCtrl.text, "Current City") == null;
        final chatValid =
            _validateMinInt(chatChargeCtrl.text, "Chat charge", 50) == null;
        final audioValid =
            _validateMinInt(audioChargeCtrl.text, "Audio call charge", 200) ==
                null;
        final videoValid =
            _validateMinInt(videoChargeCtrl.text, "Video call charge", 250) ==
                null;
        final expValid =
            _validateRequired(expCtrl.text, "Experience (Years)") == null;
        final bioValid =
            _validateRequired(bioCtrl.text, "Bio / Introduction") == null;
        if (!emailValid ||
            !pwdValid ||
            !phoneValid ||
            !nameValid ||
            !skillValid ||
            !langValid ||
            !cityValid ||
            !chatValid ||
            !audioValid ||
            !videoValid ||
            !expValid ||
            !bioValid) {
          // show errors visually
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              content: Text("Please fill all required fields on this page."),
            ),
          );
          return false;
        }
        return true;
      case 1:
        // Optional page - always allow moving forward
        return true;
      case 2:
        // Settings page - nothing required
        return true;
      case 3:
        // KYC page checks
        final aadhaarValid = _validateAadhaar(aadhaarNumberCtrl.text) == null;
        final panValid = _validatePAN(panNumberCtrl.text) == null;
        final bankNameValid =
            _validateRequired(bankNameCtrl.text, "Bank Name") == null;
        final accValid = _validateAccount(accountNumberCtrl.text) == null;
        final ifscValid = _validateIFSC(ifscCtrl.text) == null;
        if (!aadhaarValid ||
            !panValid ||
            !bankNameValid ||
            !accValid ||
            !ifscValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              content: Text("Please fill all required KYC fields correctly."),
            ),
          );
          return false;
        }
        if (aadhaarFrontFile == null ||
            aadhaarBackFile == null ||
            panCardFile == null ||
            bankPassbookFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              content: Text("Please attach all required KYC documents."),
            ),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }
}
