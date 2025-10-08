import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../fastApi/fastApiServices.dart';
import '../../../../fastApi/fastApiEndPoints.dart';

class NewEditProfileScreen extends StatefulWidget {
  const NewEditProfileScreen({super.key});

  @override
  State<NewEditProfileScreen> createState() => _NewEditProfileScreenState();
}

class _NewEditProfileScreenState extends State<NewEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _audioCallController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _videoCallController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl; // <-- URL of existing image from API
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;
  Map<String, dynamic>? profile;
  String? errorMessage;

  int _retryCount = 0;
  final int _maxRetries = 1;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await fetchProfile();
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

      if (token == null || isRetry) {
        await api.loginAndGetToken();
        token = prefs.getString("access_token");
        _retryCount++;
      }

      if (token == null) throw Exception("Token missing even after login!");

      final fetchedProfile = await api.getAstrologerById();

      _retryCount = 0;

      setState(() {
        profile = fetchedProfile;
        isLoading = false;
        // Save profile image URL
        final rawImagePath = profile?['profileImage'] ?? '';
        final cleanedBaseUrl = FastApiEndpoints.fastApiBaseUrl.replaceAll('+', '');
        final cleanedImagePath = rawImagePath.startsWith('/')
            ? rawImagePath.substring(1)
            : rawImagePath;

        _profileImageUrl = "$cleanedBaseUrl/$cleanedImagePath";


      });

      // Pre-fill controllers
      _nameController.text = profile?['name'] ?? '';
      _contactController.text = profile?['contactNo'] ?? '';
      _cityController.text = profile?['currentCity'] ?? '';
      _experienceController.text =
          (profile?['experienceInYears'] ?? '').toString();
      _audioCallController.text =
          (profile?['audioCallCharge'] ?? '').toString();
      _chatController.text = (profile?['chatCharge'] ?? '').toString();
      _videoCallController.text =
          (profile?['videoCallCharge'] ?? '').toString();
      _languageController.text = profile?['languageKnown'] ?? '';
      _skillController.text = profile?['primarySkill'] ?? '';
    } catch (e) {
      if (e.toString().contains('Unauthorized') && _retryCount < _maxRetries) {
        await fetchProfile(isRetry: true);
        return;
      }

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
        _profileImageUrl = null; // clear URL if user picks new image
      });
    }
  }

  // Submit form
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final result = await FastApiServices().editProfile(
          name: _nameController.text.trim(),
          contactNo: _contactController.text.trim(),
          currentCity: _cityController.text.trim(),
          experienceInYears: int.parse(_experienceController.text.trim()),
          audioCallCharge: int.parse(_audioCallController.text.trim()),
          chatCharge: int.parse(_chatController.text.trim()),
          videoCallCharge: int.parse(_videoCallController.text.trim()),
          languageKnown: _languageController.text.trim(),
          primarySkill: _skillController.text.trim(),
          profileImage: _profileImage,
        );

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Profile updated successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Error: ${result['error']}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🚨 Exception: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text("Error: $errorMessage")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!) as ImageProvider
                          : null),
                      child: (_profileImage == null && _profileImageUrl == null)
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              ..._buildTextFields(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Update Profile",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTextFields() => [
    TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: "Name"),
      validator: (value) => value!.isEmpty ? "Please enter your name" : null,
    ),
    const SizedBox(height: 10),
    TextFormField(
      controller: _contactController,
      decoration: const InputDecoration(labelText: "Contact No"),
      keyboardType: TextInputType.phone,
      validator: (value) =>
      value!.isEmpty ? "Please enter contact number" : null,
    ),
    const SizedBox(height: 10),
    TextFormField(
      controller: _cityController,
      decoration: const InputDecoration(labelText: "Current City"),
      validator: (value) =>
      value!.isEmpty ? "Please enter current city" : null,
    ),
    const SizedBox(height: 10),
    TextFormField(
      controller: _experienceController,
      decoration: const InputDecoration(labelText: "Experience in Years"),
      keyboardType: TextInputType.number,
      validator: (value) =>
      value!.isEmpty ? "Please enter experience" : null,
    ),
    const SizedBox(height: 10),
    TextFormField(
      controller: _audioCallController,
      decoration: const InputDecoration(labelText: "Audio Call Charge"),
      keyboardType: TextInputType.number,
      validator: (value) =>
      value!.isEmpty ? "Please enter audio call charge" : null,
    ),
    const SizedBox(height: 10),
    TextFormField(
      controller: _chatController,
      decoration: const InputDecoration(labelText: "Chat Charge"),
      keyboardType: TextInputType.number,
      validator: (value) =>
      value!.isEmpty ? "Please enter chat charge" : null,
    ),
    const SizedBox(height: 10),
    TextFormField(
      controller: _videoCallController,
      decoration: const InputDecoration(labelText: "Video Call Charge"),
      keyboardType: TextInputType.number,
      validator: (value) =>
      value!.isEmpty ? "Please enter video call charge" : null,
    ),
    const SizedBox(height: 10),
    TextFormField(
      controller: _languageController,
      decoration: const InputDecoration(labelText: "Languages Known"),
      validator: (value) =>
      value!.isEmpty ? "Please enter languages known" : null,
    ),
    const SizedBox(height: 10),
    TextFormField(
      controller: _skillController,
      decoration: const InputDecoration(labelText: "Primary Skill"),
      validator: (value) =>
      value!.isEmpty ? "Please enter primary skill" : null,
    ),
  ];
}
