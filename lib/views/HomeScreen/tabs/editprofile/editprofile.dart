import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart'; // optional
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show basename;
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../fastApi/fastApiServices.dart';
import '../../../../fastApi/fastApiEndPoints.dart';
import 'fullscreen.dart';

class NewEditProfileScreen extends StatefulWidget {
  const NewEditProfileScreen({super.key});

  @override
  State<NewEditProfileScreen> createState() => _NewEditProfileScreenState();
}

class _NewEditProfileScreenState extends State<NewEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FastApiServices _api = FastApiServices();

  // Controllers
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
  final TextEditingController _accountholdername = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _loginBioController = TextEditingController();

  // --- USD charge controllers
  final TextEditingController _chatUsdController = TextEditingController();
  final TextEditingController _audioUsdController = TextEditingController();
  final TextEditingController _videoUsdController = TextEditingController();

  // profile image (editable)
  File? _profileImage;
  String? _profileImageUrl;

  // KYC docs: local selected files
  final Map<String, File?> _docFiles = {
    'aadhaarFrontImage': null,
    'aadhaarBackImage': null,
    'panCardImage': null,
    'bankPassbookImage': null,
  };

  // KYC docs: urls fetched from server for preview
  final Map<String, String?> _docUrls = {
    'aadhaarFrontImage': null,
    'aadhaarBackImage': null,
    'panCardImage': null,
    'bankPassbookImage': null,
  };

  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? profile;

  // server locked fields
  final Set<String> _blockedFields = {};

  int _retryCount = 0;
  final int _maxRetries = 1;

  // allowed extensions & max size
  final Set<String> _allowedExt = {'png', 'jpg', 'jpeg', 'webp', 'gif', 'pdf'};
  final int _maxBytes = 2 * 1024 * 1024; // 2 MB

  @override
  void initState() {
    super.initState();
    _loadProfileAndBlocked();
  }

  // ----------------- Validation helpers -----------------
  bool _isNumeric(String s) => RegExp(r'^[0-9]+$').hasMatch(s);

  bool _isValidEmail(String s) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
    r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");
    return emailRegex.hasMatch(s);
  }

  bool _isValidPan(String s) {
    final pan = s.toUpperCase();
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan);
  }

  bool _isValidAadhaar(String s) {
    return RegExp(r'^[0-9]{12}$').hasMatch(s);
  }

  bool _isValidIfsc(String s) {
    return RegExp(r'^[A-Za-z0-9]{11}$').hasMatch(s);
  }

  bool _isValidUpi(String s) {
    return RegExp(r'^[\w.\-]{2,256}@[a-zA-Z]{2,64}$').hasMatch(s);
  }

  bool _isValidAccountNumber(String s) {
    return RegExp(r'^[0-9]{8,18}$').hasMatch(s);
  }

  bool _isValidBankName(String s) {
    return RegExp(r'^[A-Za-z\s\.\&\-]{2,80}$').hasMatch(s);
  }

  bool _isValidaccountholdername(String s) {
    return RegExp(r'^[A-Za-z\s\.\&\-]{2,80}$').hasMatch(s);
  }

  bool _isValidUrl(String s) {
    if (s.trim().isEmpty) return true;
    try {
      final uri = Uri.parse(s);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter name';
    final t = v.trim();
    if (t.length < 3) return 'Name must be at least 3 characters';
    if (t.length > 50) return 'Name must be maximum 50 characters';
    if (!RegExp(r"^[A-Za-z\s\.\-']+$").hasMatch(t)) return 'Name contains invalid characters';
    return null;
  }

  String? _validateContact(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter contact number';
    final t = v.trim();
    if (!_isNumeric(t)) return 'Contact must contain only digits';
    if (t.length < 10) return 'Contact must be 10 digits';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _isValidEmail(v.trim()) ? null : 'Enter a valid email address';
  }

  String? _validateCharge(String? v, int minValue, String label) {
    if (v == null || v.trim().isEmpty) return 'Enter $label';
    final t = v.trim();
    if (!_isNumeric(t)) return '$label must be a number';
    final n = int.tryParse(t) ?? 0;
    if (n < minValue) return '$label must be at least ₹$minValue (for 10 mins)';
    return null;
  }

  // --- USD validator: allow zero or positive integer (no admin block assumptions here)
  String? _validateUsdCharge(String? v, String label) {
    if (v == null || v.trim().isEmpty) return null; // allow empty
    final t = v.trim();
    if (!_isNumeric(t)) return '$label must be a number';
    final n = int.tryParse(t) ?? 0;
    if (n < 0) return '$label must be non-negative';
    return null;
  }

  String? _validatePan(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _isValidPan(v.trim()) ? null : 'PAN must be 5 letters, 4 digits, 1 letter (e.g. ABCDE1234F)';
  }

  String? _validateAadhaar(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _isValidAadhaar(v.trim()) ? null : 'Aadhaar must be a 12-digit number';
  }

  String? _validateBankName(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _isValidBankName(v.trim()) ? null : 'Invalid bank name';
  }

  String? _validateAccount(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _isValidAccountNumber(v.trim()) ? null : 'Account number must be 8 to 18 digits';
  }

  String? _validateIfsc(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _isValidIfsc(v.trim()) ? null : 'IFSC must be 11 alphanumeric characters';
  }

  String? _validateUpi(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _isValidUpi(v.trim()) ? null : 'Invalid UPI id (example: name@bank)';
  }

  String? _validateBio(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final t = v.trim();
    if (t.length < 3) return 'Bio must be at least 3 characters';
    if (t.length > 300) return 'Bio must be at most 300 characters';
    return null;
  }

  String? _validateUrlField(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _isValidUrl(v.trim()) ? null : 'Enter a valid URL (http/https)';
  }
  // ----------------- End validation helpers -----------------

  Future<void> _loadProfileAndBlocked({bool isRetry = false}) async {
    if (!isRetry) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if ((token == null || token.isEmpty) && _retryCount < _maxRetries) {
        await _api.loginAndGetToken();
        token = prefs.getString('access_token');
        _retryCount++;
      }

      if (token == null || token.isEmpty) throw Exception('Missing auth token');

      final fetchedProfile = await _api.getAstrologerById();

      final String astroId = (fetchedProfile['astro_id'] as String?) ?? prefs.getString('astro_id') ?? prefs.getString('user_id') ?? '';

      final unlockUri = Uri.parse(FastApiEndpoints.fastApiBaseUrl + '/admin/admin/unlock-fields/' + astroId);
      final unlockResp = await http.get(unlockUri, headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer ' + token,
      });

      Set<String> blockedFromApi = {};
      if (unlockResp.statusCode == 200) {
        try {
          final unlockJson = json.decode(unlockResp.body) as Map<String, dynamic>;
          final blockedList = (unlockJson['blocked_fields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
          blockedFromApi = blockedList.toSet();
        } catch (_) {
          blockedFromApi = {};
        }
      }

      // populate fields + urls
      setState(() {
        profile = fetchedProfile;
        isLoading = false;
        _blockedFields..clear()..addAll(blockedFromApi);

        // profile image
        final rawImagePath = profile?['profileImage'] ?? '';
        final base = FastApiEndpoints.fastApiBaseUrl.replaceAll('+', '');
        final imagePath = (rawImagePath ?? '').toString().startsWith('/') ? rawImagePath.toString().substring(1) : rawImagePath.toString();
        _profileImageUrl = imagePath.isNotEmpty ? "$base/$imagePath" : null;

        // fill controllers (text)
        _nameController.text = profile?['name'] ?? '';
        _emailController.text = profile?['email'] ?? '';
        _contactController.text = profile?['contactNo'] ?? '';
        _countryCodeController.text = profile?['countryCode'] ?? '';
        _cityController.text = profile?['currentCity'] ?? '';
        _languageController.text = profile?['languageKnown'] ?? '';
        _skillController.text = profile?['primarySkill'] ?? '';
        _experienceController.text = (profile?['experienceInYears'] ?? '').toString();
        _audioCallController.text = (profile?['audioCallCharge'] ?? '').toString();
        _chatController.text = (profile?['chatCharge'] ?? '').toString();
        _videoCallController.text = (profile?['videoCallCharge'] ?? '').toString();
        _loginBioController.text = profile?['loginBio'] ?? '';

        _linkedInController.text = profile?['linkedInProfileLink'] ?? '';
        _facebookController.text = profile?['facebookProfileLink'] ?? '';
        _instaController.text = profile?['instaProfileLink'] ?? '';
        _youtubeController.text = profile?['youtubeChannelLink'] ?? '';
        _websiteController.text = profile?['websiteProfileLink'] ?? '';

        _panNumberController.text = profile?['panNumber'] ?? '';
        _aadhaarController.text = profile?['aadhaarNumber'] ?? '';
        _highestQualificationController.text = profile?['highestQualification'] ?? '';
        _learnAstrologyController.text = profile?['learnAstrology'] ?? '';
        _bankNameController.text = profile?['bankName'] ?? '';
        _accountNumberController.text = profile?['accountNumber'] ?? '';
        _ifscController.text = profile?['ifscCode'] ?? '';
        _accountholdername.text = profile?['account_holder_name'] ?? '';
        _upiController.text = profile?['upiId'] ?? '';
        _categoryIdController.text = profile?['astrologerCategoryId'] ?? '';

        // --- USD fields (from API: chatChargeUSD, audioCallChargeUSD, videoCallChargeUSD)
        _chatUsdController.text = (profile?['chatChargeUSD'] ?? '').toString();
        _audioUsdController.text = (profile?['audioCallChargeUSD'] ?? '').toString();
        _videoUsdController.text = (profile?['videoCallChargeUSD'] ?? '').toString();

        // KYC doc urls
        String makeUrl(String? raw) {
          if (raw == null || raw.trim().isEmpty) return '';
          final r = raw.trim();
          if (r.startsWith('http')) return r;
          final base2 = FastApiEndpoints.fastApiBaseUrl.replaceAll('+', '');
          final p = r.startsWith('/') ? r.substring(1) : r;
          return '$base2/$p';
        }

        _docUrls['aadhaarFrontImage'] = makeUrl(profile?['aadhaarFrontImage'] as String?);
        _docUrls['aadhaarBackImage'] = makeUrl(profile?['aadhaarBackImage'] as String?);
        _docUrls['panCardImage'] = makeUrl(profile?['panCardImage'] as String?);
        _docUrls['bankPassbookImage'] = makeUrl(profile?['bankPassbookImage'] as String?);

        // clear local picked files map (we show server versions)
        _docFiles.updateAll((k, v) => null);

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

  // ---------------- file validators ----------------
  bool _isExtAllowed(String pathOrName) {
    final parts = pathOrName.split('?').first.split('/').last.split('.');
    if (parts.length < 2) return false;
    final ext = parts.last.toLowerCase();
    return _allowedExt.contains(ext);
  }

  bool _isFileSizeOk(File file) {
    try {
      final len = file.lengthSync();
      return len <= _maxBytes;
    } catch (_) {
      return false;
    }
  }

  // ---------------- pick & upload profile image ----------------
  Future<void> _pickProfileImage() async {
    if (_isBlocked('profileImage')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This field is blocked and requires admin approval.')));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: _allowedExt.toList(),
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;

    if (picked.path == null) {
      _showSimpleSnack('Picked file path not available');
      return;
    }

    final file = File(picked.path!);

    if (!_isExtAllowed(file.path)) {
      _showSimpleSnack('Allowed types: png, jpg, jpeg, webp, gif, pdf');
      return;
    }
    if (!_isFileSizeOk(file)) {
      _showSimpleSnack('File too large. Max allowed size is 2 MB.');
      return;
    }

    setState(() {
      _profileImage = file;
      _profileImageUrl = null;
      isLoading = true;
    });

    try {
      final result = await _api.editProfile(formFields: {}, profileImage: file, extraFiles: null);
      setState(() => isLoading = false);

      if (result == null) {
        _showSimpleSnack('No response from server');
      } else {
        _showSimpleSnack('Profile file uploaded (may require admin approval).');
        await _loadProfileAndBlocked();
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSimpleSnack('Upload failed: $e');
    }
  }

  // ---------------- pick & upload kyc doc ----------------
  Future<void> _pickAndUploadDoc(String fieldName) async {
    if (_isBlocked(fieldName)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This field is blocked and requires admin approval.')));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExt.toList(),
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) {
      _showSimpleSnack('Picked file path not available');
      return;
    }
    final file = File(picked.path!);

    if (!_isExtAllowed(file.path)) {
      _showSimpleSnack('Allowed types: png, jpg, jpeg, webp, gif, pdf');
      return;
    }
    if (!_isFileSizeOk(file)) {
      _showSimpleSnack('File too large. Max allowed size is 2 MB.');
      return;
    }

    setState(() {
      _docFiles[fieldName] = file;
      _docUrls[fieldName] = null;
      isLoading = true;
    });

    try {
      final result = await _api.editProfile(formFields: {}, profileImage: null, extraFiles: {fieldName: file});
      setState(() => isLoading = false);

      if (result == null) {
        _showSimpleSnack('No response from server');
        return;
      }

      if ((result['success'] == true) || (result['statusCode'] != null && result['statusCode'] is int && result['statusCode'] >= 200 && result['statusCode'] < 300)) {
        _showSimpleSnack('Uploaded — changes submitted for approval.');
        await _loadProfileAndBlocked();
      } else {
        _showSimpleSnack('Upload failed: ${result['error'] ?? result['body'] ?? result['raw'] ?? result}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSimpleSnack('Exception uploading file: $e');
    }
  }

  void _showSimpleSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool _isBlocked(String key) => _blockedFields.contains(key);

  Widget _buildField(String label, TextEditingController controller, String keyName,
      {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator, int maxLines = 1}) {
    final bool blocked = _isBlocked(keyName);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.yellow.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        suffixIcon: blocked ? Tooltip(message: 'Change requires admin approval', child: const Icon(Icons.lock, size: 18)) : null,
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: !blocked,
    );
  }

  // Build doc tile
  Widget _buildDocTile(String label, String fieldName) {
    final url = _docUrls[fieldName];
    final localFile = _docFiles[fieldName];

    Widget previewChild;
    if (localFile != null) {
      final ext = localFile.path.split('.').last.toLowerCase();
      if (ext == 'pdf') {
        previewChild = Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent),
          SizedBox(height: 6),
          Text('PDF'),
        ]));
      } else {
        previewChild = Image.file(localFile, fit: BoxFit.cover, width: double.infinity);
      }
    } else if (url != null && url.isNotEmpty) {
      final ext = url.split('.').last.toLowerCase();
      if (ext == 'pdf') {
        previewChild = Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent),
          SizedBox(height: 6),
          Text('PDF'),
        ]));
      } else {
        previewChild = Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => Container(color: Colors.yellow.shade50, child: const Center(child: Icon(Icons.image_not_supported))),
        );
      }
    } else {
      previewChild = Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 28, color: Colors.yellow.shade800),
            const SizedBox(height: 8),
            Text('Tap to view\nor use edit to upload', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                final has = (localFile != null) || (url != null && url.isNotEmpty);
                if (!has) {
                  _showSimpleSnack('No document uploaded yet. Tap the edit icon to upload.');
                  return;
                }
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FullScreenMediaPage(localFile: localFile, url: url, title: label),
                ));
              },
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(10), child: previewChild),
              ),
            ),

            Positioned(
              right: 8,
              top: 8,
              child: InkWell(
                onTap: () => _pickAndUploadDoc(fieldName),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.yellow.shade400]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ),

            if (_isBlocked(fieldName))
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.lock, size: 28, color: Colors.black45),
                          SizedBox(height: 6),
                          Text('Requires admin approval', style: TextStyle(color: Colors.black54)),
                        ],
                      )),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ---------------- New submit logic: only changed fields & files ----------------

  /// Collect all fields (string values)
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

    // --- USD fields
    put('chatChargeUSD', _chatUsdController.text);
    put('audioCallChargeUSD', _audioUsdController.text);
    put('videoCallChargeUSD', _videoUsdController.text);

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
    put('account_holder_name', _accountholdername.text);
    put('facebookProfileLink', _facebookController.text);
    put('loginBio', _loginBioController.text);

    return m;
  }

  /// Return list of changed textual keys by comparing with loaded `profile`
  List<String> _getChangedKeys(Map<String, dynamic> newFields) {
    final List<String> changes = [];
    if (profile == null) return newFields.keys.toList();
    for (final k in newFields.keys) {
      final newVal = (newFields[k] ?? '').toString().trim();
      final oldVal = (profile?[k] ?? '').toString().trim();
      if (newVal != oldVal) changes.add(k);
    }
    return changes;
  }

  /// Build a map containing only changed key/value pairs (text fields)
  Map<String, dynamic> _buildChangedFields(Map<String, dynamic> allFields, Iterable<String> changedKeys) {
    final Map<String, dynamic> m = {};
    for (final k in changedKeys) {
      if (allFields.containsKey(k)) {
        m[k] = allFields[k];
      }
    }
    return m;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final Map<String, dynamic> allFields = _collectAllFields();

      // textual changes
      final List<String> changedKeys = _getChangedKeys(allFields);

      // file changes
      final List<String> fileChangedKeys = [];
      if (_profileImage != null) fileChangedKeys.add('profileImage');

      _docFiles.forEach((k, file) {
        if (file != null) fileChangedKeys.add(k);
      });

      final changedSet = <String>{...changedKeys, ...fileChangedKeys};

      if (changedSet.isEmpty) {
        setState(() => isLoading = false);
        _showSimpleSnack('No changes detected');
        return;
      }

      // fast-path: only charges changed -> patch endpoint
      final chargesSet = {
        'chatCharge',
        'audioCallCharge',
        'videoCallCharge',
        // include USD fields as well (these are allowed to be patched directly)
        'chatChargeUSD',
        'audioCallChargeUSD',
        'videoCallChargeUSD'
      };
      final onlyCharges = changedSet.difference(chargesSet).isEmpty && changedSet.isNotEmpty;

      if (onlyCharges) {
        final ok = await _patchChargesDirectly(allFields);
        setState(() => isLoading = false);
        if (ok) {
          _showSimpleSnack('Charges updated successfully');
          await _loadProfileAndBlocked();
          return;
        } else {
          _showSimpleSnack('Failed to update charges.');
          return;
        }
      }

      // build formFields & extraFiles
      final changedTextKeys = changedSet.where((k) => k != 'profileImage' && !_docFiles.keys.contains(k));
      final formFieldsToSend = _buildChangedFields(allFields, changedTextKeys);

      final Map<String, File?> extraFilesToSend = {};
      _docFiles.forEach((fieldName, file) {
        if (file != null) extraFilesToSend[fieldName] = file;
      });

      final File? profileImageFile = _profileImage;

      debugPrint('Submitting changed fields: ${formFieldsToSend.keys.toList()} files: ${[if (profileImageFile != null) 'profileImage', ...extraFilesToSend.keys]}');

      final result = await _api.editProfile(
        formFields: formFieldsToSend,
        profileImage: profileImageFile,
        extraFiles: extraFilesToSend.isEmpty ? null : extraFilesToSend,
      );

      setState(() => isLoading = false);

      if (result == null) {
        _showSimpleSnack('No response from server');
        return;
      }

      Map<String, dynamic>? decoded;
      if (result is Map<String, dynamic>) decoded = result;

      final updated = (decoded?['pending_fields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
      final message = decoded?['message']?.toString() ?? 'Changes submitted for admin approval';

      _showSimpleSnack(message);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(updated.isEmpty ? Icons.hourglass_bottom : Icons.check_circle, color: updated.isEmpty ? Colors.orange : Colors.green),
              const SizedBox(width: 8),
              Text(updated.isEmpty ? 'Pending' : 'Updated'),
            ],
          ),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );

      if (updated.isNotEmpty) await _loadProfileAndBlocked();
    } catch (e, st) {
      debugPrint('Exception in _submit: $e\n$st');
      _showSimpleSnack('Exception: $e');
      setState(() => isLoading = false);
    }
  }

  Future<bool> _patchChargesDirectly(Map<String, dynamic> fields) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception('Missing token');

      final astroId = (profile?['astro_id'] as String?) ?? prefs.getString('astro_id') ?? prefs.getString('user_id');
      if (astroId == null) throw Exception('Missing astro id');

      final uri = Uri.parse(FastApiEndpoints.fastApiBaseUrl + '/api/v1/astro/astrologers/' + astroId + '/charges');

      int parseCharge(dynamic v) {
        if (v == null) return 0;
        if (v is int) return v;
        final s = v.toString().trim();
        if (s.isEmpty) return 0;
        return int.tryParse(s) ?? 0;
      }

      final body = json.encode({
        'chatCharge': parseCharge(fields['chatCharge']),
        'audioCallCharge': parseCharge(fields['audioCallCharge']),
        'videoCallCharge': parseCharge(fields['videoCallCharge']),
        // --- USD fields included here
        'chatChargeUSD': parseCharge(fields['chatChargeUSD']),
        'audioCallChargeUSD': parseCharge(fields['audioCallChargeUSD']),
        'videoCallChargeUSD': parseCharge(fields['videoCallChargeUSD']),
      });

      final resp = await http.patch(uri, headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + (await SharedPreferences.getInstance()).getString('access_token')!,
      }, body: body);

      if (kDebugMode) {
        debugPrint('Patch charges response: ${resp.statusCode} ${resp.body}');
      }

      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      debugPrint('Exception in _patchChargesDirectly: $e');
      return false;
    }
  }

  // ---------------- UI build ----------------
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (errorMessage != null) return Scaffold(appBar: AppBar(title: const Text('Edit Profile')), body: Center(child: Text('Error: ' + errorMessage!)));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.yellow.shade700,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadProfileAndBlocked(),
        color: Colors.yellow.shade700,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final has = (_profileImage != null) || (_profileImageUrl != null && _profileImageUrl!.isNotEmpty);
                                if (!has) {
                                  _showSimpleSnack('No profile image. Tap edit to upload.');
                                  return;
                                }
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => FullScreenMediaPage(localFile: _profileImage, url: _profileImageUrl, title: 'Profile Image'),
                                ));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.amber.shade600, Colors.yellow.shade400]),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor: Colors.grey.shade100,
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : (_profileImageUrl != null ? NetworkImage(_profileImageUrl!) as ImageProvider : null),
                                  child: (_profileImage == null && _profileImageUrl == null) ? const Icon(Icons.camera_alt, size: 36, color: Colors.black45) : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: _pickProfileImage,
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Colors.amber.shade700, Colors.yellow.shade400],
                                      ),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0,2))],
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              _nameController.text.isNotEmpty ? _nameController.text : (profile?['name'] ?? 'Your Name'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(profile?['primarySkill'] ?? 'Astrologer', style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(height: 10),
                            Text(profile?['contactNo'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                          ]),
                        )
                      ]),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Profile Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),

                          LayoutBuilder(builder: (context, constraints) {
                            final wide = constraints.maxWidth > 720;
                            if (wide) {
                              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(
                                    child: Column(children: [
                                      _buildField('Name', _nameController, 'name', validator: _validateName),
                                      const SizedBox(height: 12),
                                      _buildField('Email', _emailController, 'email', keyboardType: TextInputType.emailAddress, validator: _validateEmail),
                                      const SizedBox(height: 12),
                                      _buildField('Contact No', _contactController, 'contactNo', keyboardType: TextInputType.phone, validator: _validateContact),
                                      const SizedBox(height: 12),
                                      _buildField('Country Code', _countryCodeController, 'countryCode', keyboardType: TextInputType.phone),
                                    ])),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: Column(children: [
                                      _buildField('Current City', _cityController, 'currentCity'),
                                      const SizedBox(height: 12),
                                      _buildField('Languages Known', _languageController, 'languageKnown'),
                                      const SizedBox(height: 12),
                                      _buildField('Primary Skill', _skillController, 'primarySkill'),
                                      const SizedBox(height: 12),
                                      _buildField('Experience (Years)', _experienceController, 'experienceInYears', keyboardType: TextInputType.number),
                                    ])),
                              ]);
                            }

                            return Column(children: [
                              _buildField('Name', _nameController, 'name', validator: _validateName),
                              const SizedBox(height: 12),
                              _buildField('Email', _emailController, 'email', keyboardType: TextInputType.emailAddress, validator: _validateEmail),
                              const SizedBox(height: 12),
                              _buildField('Contact No', _contactController, 'contactNo', keyboardType: TextInputType.phone, validator: _validateContact),
                              const SizedBox(height: 12),
                              _buildField('Country Code', _countryCodeController, 'countryCode', keyboardType: TextInputType.phone),
                              const SizedBox(height: 12),
                              _buildField('Current City', _cityController, 'currentCity'),
                              const SizedBox(height: 12),
                              _buildField('Languages Known', _languageController, 'languageKnown'),
                              const SizedBox(height: 12),
                              _buildField('Primary Skill', _skillController, 'primarySkill'),
                              const SizedBox(height: 12),
                              _buildField('Experience (Years)', _experienceController, 'experienceInYears', keyboardType: TextInputType.number),
                            ]);
                          }),

                          const SizedBox(height: 16),

                          _buildField(
                            'Audio Call Charge (₹/10 min)',
                            _audioCallController,
                            'audioCallCharge',
                            keyboardType: TextInputType.number,
                            validator: (v) => _validateCharge(v, 200, 'Audio Call Charge'),
                          ),
                          const SizedBox(height: 8),

                          // USD version of Audio charge
                          _buildField(
                            'Audio Call Charge (USD)',
                            _audioUsdController,
                            'audioCallChargeUSD',
                            keyboardType: TextInputType.number,
                            validator: (v) => _validateUsdCharge(v, 'Audio Call Charge (USD)'),
                          ),
                          const SizedBox(height: 12),

                          _buildField(
                            'Chat Charge (₹/10 min)',
                            _chatController,
                            'chatCharge',
                            keyboardType: TextInputType.number,
                            validator: (v) => _validateCharge(v, 50, 'Chat Charge'),
                          ),
                          const SizedBox(height: 8),

                          // USD chat
                          _buildField(
                            'Chat Charge (USD)',
                            _chatUsdController,
                            'chatChargeUSD',
                            keyboardType: TextInputType.number,
                            validator: (v) => _validateUsdCharge(v, 'Chat Charge (USD)'),
                          ),
                          const SizedBox(height: 12),

                          _buildField(
                            'Video Call Charge (₹/10 min)',
                            _videoCallController,
                            'videoCallCharge',
                            keyboardType: TextInputType.number,
                            validator: (v) => _validateCharge(v, 250, 'Video Call Charge'),
                          ),
                          const SizedBox(height: 8),

                          // USD video
                          _buildField(
                            'Video Call Charge (USD)',
                            _videoUsdController,
                            'videoCallChargeUSD',
                            keyboardType: TextInputType.number,
                            validator: (v) => _validateUsdCharge(v, 'Video Call Charge (USD)'),
                          ),
                          const SizedBox(height: 18),

                          const Text('KYC & Bank details', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),

                          _buildField('Pan Number', _panNumberController, 'panNumber', validator: _validatePan),
                          const SizedBox(height: 12),

                          _buildField('Aadhaar Number', _aadhaarController, 'aadhaarNumber', validator: _validateAadhaar),
                          const SizedBox(height: 12),

                          _buildField('Bank Name', _bankNameController, 'bankName', validator: _validateBankName),
                          const SizedBox(height: 12),

                          _buildField('Account Number', _accountNumberController, 'accountNumber', validator: _validateAccount),
                          const SizedBox(height: 12),

                          _buildField('IFSC Code', _ifscController, 'ifscCode', validator: _validateIfsc),
                          const SizedBox(height: 12),
                          _buildField('Account Holder Name', _accountholdername, 'account_holder_name', validator: _validateBankName),
                          const SizedBox(height: 12),

                          _buildField('UPI ID', _upiController, 'upiId', validator: _validateUpi),

                          const SizedBox(height: 16),

                          // KYC document images
                          _buildDocTile('Aadhaar Front', 'aadhaarFrontImage'),
                          _buildDocTile('Aadhaar Back', 'aadhaarBackImage'),
                          _buildDocTile('PAN Card', 'panCardImage'),
                          _buildDocTile('Bank Passbook', 'bankPassbookImage'),

                          const SizedBox(height: 16),
                          const Text('Social & Links', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),

                          _buildField('LinkedIn', _linkedInController, 'linkedInProfileLink',
                              keyboardType: TextInputType.url, validator: _validateUrlField),
                          const SizedBox(height: 12),

                          _buildField('Youtube', _youtubeController, 'websiteProfileLink',
                              keyboardType: TextInputType.url, validator: _validateUrlField),
                          const SizedBox(height: 12),

                          _buildField('Instagram', _instaController, 'instaProfileLink',
                              keyboardType: TextInputType.url, validator: _validateUrlField),
                          const SizedBox(height: 12),

                          _buildField('Facebook', _facebookController, 'facebookProfileLink',
                              keyboardType: TextInputType.url, validator: _validateUrlField),
                          const SizedBox(height: 12),

                          _buildField('Login Bio', _loginBioController, 'loginBio', maxLines: 4, validator: _validateBio),

                          const SizedBox(height: 22),

                          Center(
                            child: InkWell(
                              onTap: _submit,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: mq.size.width > 600 ? 360 : double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.yellow.shade400]),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: const [
                                  Icon(Icons.save_outlined, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text('Update Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))
                                ]),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Center(child: Text('Changes to sensitive fields require admin approval. USD/inr charge changes are patched directly.', style: TextStyle(color: Colors.grey.shade700))),

                        ]),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
    _accountholdername.dispose();
    _emailController.dispose();
    _facebookController.dispose();
    _loginBioController.dispose();

    // USD controllers
    _chatUsdController.dispose();
    _audioUsdController.dispose();
    _videoUsdController.dispose();

    super.dispose();
  }
}
