// NewEditProfileScreen.dart
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../../fastApi/fastApiServices.dart';
import '../../../../fastApi/fastApiEndPoints.dart';
import 'package:path/path.dart' show basename;

class NewEditProfileScreen extends StatefulWidget {
  const NewEditProfileScreen({super.key});

  @override
  State<NewEditProfileScreen> createState() => _NewEditProfileScreenState();
}

class _NewEditProfileScreenState extends State<NewEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FastApiServices _api = FastApiServices();

  // Controllers (all fields supported by your API)
  final TextEditingController _astroIdController = TextEditingController(); // read-only display
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _audioCallController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _videoCallController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();

  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _instaController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _categoryIdController = TextEditingController();
  final TextEditingController _highestQualificationController = TextEditingController();
  final TextEditingController _learnAstrologyController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _loginBioController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? profile;

  // server blocked fields -> user cannot edit these until admin unlocks
  final Set<String> _blockedFields = {};

  int _retryCount = 0;
  final int _maxRetries = 1;

  @override
  void initState() {
    super.initState();
    _loadProfileAndBlocked();
  }

  /// Load profile via getAstrologerById and also fetch blocked_fields from admin endpoint
  Future<void> _loadProfileAndBlocked({bool isRetry = false}) async {
    if (!isRetry) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");

      if ((token == null || token.isEmpty) && _retryCount < _maxRetries) {
        await _api.loginAndGetToken();
        token = prefs.getString("access_token");
        _retryCount++;
      }

      if (token == null || token.isEmpty) {
        throw Exception("Missing auth token");
      }

      // fetch profile
      final fetchedProfile = await _api.getAstrologerById();

      // astro id: prefer astro_id from profile, else from prefs
      final astroId = (fetchedProfile['astro_id'] as String?) ??
          prefs.getString('astro_id') ??
          prefs.getString('user_id') ??
          '';

      // fetch blocked/unlock info from admin endpoint (if available)
      final unlockUri = Uri.parse('${FastApiEndpoints.fastApiBaseUrl}/admin/admin/unlock-fields/$astroId');
      final unlockResp = await http.get(unlockUri, headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      Set<String> blockedFromApi = {};
      if (unlockResp.statusCode == 200) {
        try {
          final unlockJson = json.decode(unlockResp.body) as Map<String, dynamic>;
          final blockedList = (unlockJson['blocked_fields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
              <String>[];
          blockedFromApi = blockedList.toSet();
        } catch (_) {
          // ignore parse errors — default no blocked
          blockedFromApi = {};
        }
      } else {
        // If admin endpoint not available, keep blockedFields empty (so user can edit),
        // but you previously wanted user to only edit when admin approves: if you prefer conservative approach, uncomment:
        // blockedFromApi = _allFieldKeys().toSet(); // lock everything if admin endpoint not reachable
      }

      // update UI
      setState(() {
        profile = fetchedProfile;
        isLoading = false;

        _blockedFields
          ..clear()
          ..addAll(blockedFromApi);

        // profile image
        final rawImagePath = profile?['profileImage'] ?? '';
        final base = FastApiEndpoints.fastApiBaseUrl.replaceAll('+', '');
        final imagePath = (rawImagePath ?? '').toString().startsWith('/')
            ? rawImagePath.toString().substring(1)
            : rawImagePath.toString();
        _profileImageUrl = imagePath.isNotEmpty ? "$base/$imagePath" : null;

        // prefills
        // ---- replace the previous "prefills" block with this ----
        _astroIdController.text = profile?['astro_id']?.toString() ?? prefs.getString('astro_id') ?? prefs.getString('user_id') ?? '';

// Basic identity/contact
        _nameController.text = profile?['name'] ?? '';
        _emailController.text = profile?['email'] ?? '';
        _contactController.text = profile?['contactNo'] ?? '';
        _countryCodeController.text = profile?['countryCode'] ?? ''; // may be null in API
        _cityController.text = profile?['currentCity'] ?? '';

// Skills / bio / experience / charges
        _languageController.text = profile?['languageKnown'] ?? '';
        _skillController.text = profile?['primarySkill'] ?? '';
        _experienceController.text = (profile?['experienceInYears'] ?? '').toString();
        _audioCallController.text = (profile?['audioCallCharge'] ?? '').toString();
        _chatController.text = (profile?['chatCharge'] ?? '').toString();
        _videoCallController.text = (profile?['videoCallCharge'] ?? '').toString();
        _loginBioController.text = profile?['loginBio'] ?? '';

// Social links
        _linkedInController.text = profile?['linkedInProfileLink'] ?? '';
        _facebookController.text = profile?['facebookProfileLink'] ?? '';
        _instaController.text = profile?['instaProfileLink'] ?? '';
        _youtubeController.text = profile?['youtubeChannelLink'] ?? '';
        _websiteController.text = profile?['websiteProfileLink'] ?? '';

// KYC / bank
        _panNumberController.text = profile?['panNumber'] ?? '';
        _aadhaarController.text = profile?['aadhaarNumber'] ?? '';
        _highestQualificationController.text = profile?['highestQualification'] ?? '';
        _learnAstrologyController.text = profile?['learnAstrology'] ?? '';
        _bankNameController.text = profile?['bankName'] ?? '';
        _accountNumberController.text = profile?['accountNumber'] ?? '';
        _ifscController.text = profile?['ifscCode'] ?? '';
        _upiController.text = profile?['upiId'] ?? '';

// Category / misc
        _categoryIdController.text = profile?['astrologerCategoryId'] ?? '';


        _retryCount = 0;
      });
    } catch (e) {
      if (e.toString().contains('Unauthorized') && _retryCount < _maxRetries) {
        await _loadProfileAndBlocked(isRetry: true);
        return;
      }
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_isBlocked('profileImage')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This field is blocked and requires admin approval.')));
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
        _profileImageUrl = null;
      });
    }
  }

  // Collect all fields (we send everything; server will accept or mark blocked)
  Map<String, dynamic> _collectAllFields() {
    Map<String, dynamic> m = {};
    void put(String key, String? v) => m[key] = (v ?? '').trim();

    put('name', _nameController.text);
    put('email', _emailController.text);
    put('contactNo', _contactController.text);
    put('countryCode', _countryCodeController.text);
    put('currentCity', _cityController.text);
    put('experienceInYears', _experienceController.text);
    put('audioCallCharge', _audioCallController.text);
    put('chatCharge', _chatController.text);
    put('videoCallCharge', _videoCallController.text);
    put('languageKnown', _languageController.text);
    put('primarySkill', _skillController.text);

    put('linkedInProfileLink', _linkedInController.text);
    put('panNumber', _panNumberController.text);
    put('bankName', _bankNameController.text);
    put('websiteProfileLink', _websiteController.text);
    put('instaProfileLink', _instaController.text);
    put('upiId', _upiController.text);
    put('astrologerCategoryId', _categoryIdController.text);
    put('highestQualification', _highestQualificationController.text);
    put('learnAstrology', _learnAstrologyController.text);
    put('accountNumber', _accountNumberController.text);
    put('aadhaarNumber', _aadhaarController.text);
    put('youtubeChannelLink', _youtubeController.text);
    put('ifscCode', _ifscController.text);
    put('facebookProfileLink', _facebookController.text);
    put('loginBio', _loginBioController.text);

    return m;
  }

  /// Submit using PATCH multipart to /update and show raw response in a SnackBar.
  /// Replace your _submitPatch() with this _submit() which calls FastApiServices.editProfile
  /// New _submit() — shows different messages based on updated_fields presence
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      // collect fields + image
      final Map<String, dynamic> formFields = _collectAllFields();
      final File? imageFile = _profileImage;

      // call centralised service that does PUT -> PATCH -> POST fallback
      final result = await _api.editProfile(formFields: formFields, profileImage: imageFile);

      setState(() => isLoading = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No response from server')));
        return;
      }

      // --- Robustly extract JSON payload returned by editProfile ---
      Map<String, dynamic>? decoded;

      // Many variants were used before: check common places
      if (result is Map<String, dynamic>) {
        // If service already returned parsed data under 'data' or 'body'
        if (result['data'] is Map<String, dynamic>) {
          decoded = result['data'] as Map<String, dynamic>;
        } else if (result['body'] is Map<String, dynamic>) {
          decoded = result['body'] as Map<String, dynamic>;
        } else if (result.containsKey('updated_fields') || result.containsKey('blocked_fields') || result.containsKey('success') || result.containsKey('message')) {
          // result itself looks like the API JSON
          decoded = Map<String, dynamic>.from(result);
        } else if (result['raw'] is String) {
          try {
            final tmp = json.decode(result['raw'] as String);
            if (tmp is Map<String, dynamic>) decoded = tmp;
          } catch (_) {}
        }
      }

      // fallback: try to parse raw JSON from result.toString()
      if (decoded == null) {
        try {
          final raw = result.toString();
          final tmp = json.decode(raw);
          if (tmp is Map<String, dynamic>) decoded = tmp;
        } catch (_) {}
      }

      // --- Build user-visible message ---
      List<String> updated = <String>[];
      List<String> blocked = <String>[];

      if (decoded != null) {
        updated = (decoded['updated_fields'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            <String>[];
        blocked = (decoded['blocked_fields'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            <String>[];
      }

      // If server provided blocked fields, lock them locally
      if (blocked.isNotEmpty) {
        setState(() {
          _blockedFields
            ..clear()
            ..addAll(blocked);
        });
      }

      // Compose message according to updated list presence
      String title;
      String message;

      if (updated.isEmpty) {
        // nothing updated => pending approval
        title = 'Pending approval';
        if (blocked.isNotEmpty) {
          message = 'Your changes have been submitted and are pending admin approval.';
        } else if (decoded != null && decoded['message'] != null) {
          message = decoded['message'].toString();
        } else {
          message = 'Your changes have been submitted and are pending admin approval.';
        }
      } else {
        // some fields were updated
        title = 'Updated successfully';
        message = 'Updated fields: ${updated.join(', ')}';
        // optionally include blocked if any

      }

      // Show preview snack (short) and a full dialog
      final preview = message.length > 160 ? '${message.substring(0, 160)}...' : message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(preview)));

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(updated.isEmpty ? Icons.hourglass_bottom : Icons.check_circle, color: updated.isEmpty ? Colors.orange : Colors.green),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        ),
      );

      // If API says updated or success, refresh profile so UI reflects new values / locks
      if (updated.isNotEmpty || (decoded != null && decoded['success'] == true)) {
        await _loadProfileAndBlocked();
      }
    } catch (e) {
      setState(() => isLoading = false);
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exception: $msg')));
    }
  }


  void _showSimpleSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool _isBlocked(String key) => _blockedFields.contains(key);

  // Build field and disable it if server previously blocked it
  Widget _buildField(String label, TextEditingController controller, String keyName,
      {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator, int maxLines = 1}) {
    final bool blocked = _isBlocked(keyName);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: blocked ? Tooltip(message: 'Change requires admin approval', child: const Icon(Icons.lock, size: 18)) : null,
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: !blocked,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (errorMessage != null) return Scaffold(appBar: AppBar(title: const Text('Edit Profile')), body: Center(child: Text('Error: $errorMessage')));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: RefreshIndicator(
        onRefresh: _loadProfileAndBlocked,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Profile (astro id shown below). Fields blocked by admin are disabled.'),
              const SizedBox(height: 12),

              // Astro ID (read-only)
              TextFormField(
                controller: _astroIdController,
                decoration: const InputDecoration(labelText: 'Astrologer ID'),
                readOnly: true,
              ),
              const SizedBox(height: 12),

              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_profileImageUrl != null ? NetworkImage(_profileImageUrl!) as ImageProvider : null),
                        child: (_profileImage == null && _profileImageUrl == null) ? const Icon(Icons.camera_alt, size: 40) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.yellow.shade700, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]),
                          padding: const EdgeInsets.all(6),
                          child: _isBlocked('profileImage') ? const Icon(Icons.lock, size: 20, color: Colors.white) : const Icon(Icons.edit, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildField('Name', _nameController, 'name', validator: (v) => v == null || v.isEmpty ? 'Enter name' : null),
              const SizedBox(height: 10),
              _buildField('Email', _emailController, 'email', keyboardType: TextInputType.emailAddress, validator: (v) {
                if (v == null || v.isEmpty) return null; // optional
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                return emailRegex.hasMatch(v) ? null : 'Enter valid email';
              }),
              const SizedBox(height: 10),
              _buildField('Contact No', _contactController, 'contactNo', keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildField('Country Code', _countryCodeController, 'countryCode', keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildField('Current City', _cityController, 'currentCity'),
              const SizedBox(height: 10),
              _buildField('Languages Known', _languageController, 'languageKnown'),
              const SizedBox(height: 10),
              _buildField('Primary Skill', _skillController, 'primarySkill'),
              const SizedBox(height: 10),
              _buildField('Experience (Years)', _experienceController, 'experienceInYears', keyboardType: TextInputType.number),

              const SizedBox(height: 16),
              _buildField('Audio Call Charge (₹/10 min)', _audioCallController, 'audioCallCharge', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _buildField('Chat Charge (₹/10 min)', _chatController, 'chatCharge', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _buildField('Video Call Charge (₹/10 min)', _videoCallController, 'videoCallCharge', keyboardType: TextInputType.number),

              const SizedBox(height: 16),
              _buildField('LinkedIn Profile Link', _linkedInController, 'linkedInProfileLink', keyboardType: TextInputType.url),
              const SizedBox(height: 10),
              _buildField('Facebook Profile Link', _facebookController, 'facebookProfileLink', keyboardType: TextInputType.url),
              const SizedBox(height: 10),
              _buildField('Instagram Profile Link', _instaController, 'instaProfileLink', keyboardType: TextInputType.url),
              const SizedBox(height: 10),
              _buildField('Website Profile Link', _websiteController, 'websiteProfileLink', keyboardType: TextInputType.url),
              const SizedBox(height: 10),
              _buildField('YouTube Channel Link', _youtubeController, 'youtubeChannelLink', keyboardType: TextInputType.url),
              const SizedBox(height: 10),
              _buildField('Pan Number', _panNumberController, 'panNumber'),
              const SizedBox(height: 10),
              _buildField('Aadhaar Number', _aadhaarController, 'aadhaarNumber'),
              const SizedBox(height: 10),
              _buildField('Highest Qualification', _highestQualificationController, 'highestQualification'),
              const SizedBox(height: 10),
              _buildField('Learn Astrology (brief)', _learnAstrologyController, 'learnAstrology', maxLines: 3),
              const SizedBox(height: 10),
              _buildField('Bank Name', _bankNameController, 'bankName'),
              const SizedBox(height: 10),
              _buildField('Account Number', _accountNumberController, 'accountNumber'),
              const SizedBox(height: 10),
              _buildField('IFSC Code', _ifscController, 'ifscCode'),
              const SizedBox(height: 10),
              _buildField('UPI ID', _upiController, 'upiId'),
              const SizedBox(height: 10),
              _buildField('Astrologer Category ID', _categoryIdController, 'astrologerCategoryId'),
              const SizedBox(height: 10),
              _buildField('Login Bio', _loginBioController, 'loginBio', maxLines: 3),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Update Profile (PATCH)', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              Text('Fields the server requires admin approval for will be locked after submit and the server response is shown.'),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // dispose controllers
    _astroIdController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _countryCodeController.dispose();
    _cityController.dispose();
    _experienceController.dispose();
    _audioCallController.dispose();
    _chatController.dispose();
    _videoCallController.dispose();
    _languageController.dispose();
    _skillController.dispose();

    _linkedInController.dispose();
    _panNumberController.dispose();
    _bankNameController.dispose();
    _websiteController.dispose();
    _instaController.dispose();
    _upiController.dispose();
    _categoryIdController.dispose();
    _highestQualificationController.dispose();
    _learnAstrologyController.dispose();
    _accountNumberController.dispose();
    _aadhaarController.dispose();
    _youtubeController.dispose();
    _ifscController.dispose();
    _emailController.dispose();
    _facebookController.dispose();
    _loginBioController.dispose();

    super.dispose();
  }
}
