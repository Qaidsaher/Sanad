import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'update_password.dart';

class PilgrimEditProfileScreen extends StatefulWidget {
  const PilgrimEditProfileScreen({Key? key}) : super(key: key);

  @override
  _PilgrimEditProfileScreenState createState() =>
      _PilgrimEditProfileScreenState();
}

class _PilgrimEditProfileScreenState extends State<PilgrimEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for the "users" document.
  final TextEditingController _emailController = TextEditingController();

  // Controllers for the pilgrim name fields (in the "pilgrims" document).
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  String? avatarBase64; // Avatar image stored as a base64-encoded string
  String? _pilgrimDocId; // Store the pilgrim document ID

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPilgrimData();
  }

  /// Load Firebase Auth and "users" data.
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      // Optionally, load additional user data from the "users" collection here.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    }
  }

  /// Load pilgrim details from the "pilgrims" collection.
  Future<void> _loadPilgrimData() async {
    final user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('pilgrims')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        _pilgrimDocId = doc.id;
        setState(() {
          _firstNameController.text = doc.get('firstName') ?? '';
          _middleNameController.text = doc.get('middleName') ?? '';
          _lastNameController.text = doc.get('lastName') ?? '';
        });
        if (doc.exists && doc.get('avatar') != null) {
          setState(() {
            avatarBase64 = doc.get('avatar');
          });
        }
      }
    }
  }

  /// Let the pilgrim pick a new avatar image.
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  /// Convert the image file to a base64-encoded string.
  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  /// Helper method to select the proper image provider for the avatar.
  ImageProvider _getAvatarImage(User? user) {
    if (_avatarFile != null) {
      return FileImage(_avatarFile!);
    } else if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      return MemoryImage(base64Decode(avatarBase64!));
    } else if (user?.photoURL != null) {
      return NetworkImage(user!.photoURL!);
    } else {
      return const AssetImage("assets/avatar.png");
    }
  }

  /// Save updates:
  /// 1. Build a combined name from first, middle, last.
  /// 2. Update Firebase Auth (display name and email) and the "users" document.
  /// 3. Update the pilgrim document with separate name fields and avatar.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      // If a new avatar has been picked, convert it to a base64 string.
      if (_avatarFile != null) {
        avatarBase64 = await _convertImageToBase64(_avatarFile!);
      }

      // Build the combined name.
      final combinedName = "${_firstNameController.text.trim()} "
              "${_middleNameController.text.trim()} "
              "${_lastNameController.text.trim()}"
          .trim();

      // Update Firebase Auth details.
      await user.updateDisplayName(combinedName);
      await user.updateEmail(_emailController.text.trim());
      await user.reload();

      // Update the "users" document with the new display name and email.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': combinedName,
        'email': _emailController.text.trim(),
      });

      // Update the pilgrim document with separate name fields and avatar.
      if (_pilgrimDocId != null) {
        await FirebaseFirestore.instance
            .collection('pilgrims')
            .doc(_pilgrimDocId)
            .update({
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          if (avatarBase64 != null) 'avatar': avatarBase64,
        });
      }

      Get.back();
      Get.snackbar("profile_updated".tr, "profile_updated_msg".tr,
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("update_error".tr, e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text("edit_profile".tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Section: Show new image if picked, else display the existing one.
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _getAvatarImage(user),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _pickImage,
                    child: Text("change_avatar".tr),
                  ),
                  const SizedBox(height: 20),
                  // First Name Field
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: "first_name".tr,
                      prefixIcon: Icon(Icons.person,
                          color: Theme.of(context).primaryColor),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "enter_first_name".tr
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Middle Name Field
                  TextFormField(
                    controller: _middleNameController,
                    decoration: InputDecoration(
                      labelText: "middle_name".tr,
                      prefixIcon: Icon(Icons.person_outline,
                          color: Theme.of(context).primaryColor),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "enter_middle_name".tr
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Last Name Field
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: "last_name".tr,
                      prefixIcon: Icon(Icons.person,
                          color: Theme.of(context).primaryColor),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "enter_last_name".tr
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "email".tr,
                      prefixIcon: Icon(Icons.email,
                          color: Theme.of(context).primaryColor),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "enter_email".tr
                        : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text("save".tr,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Get.to(() => const PilgrimUpdatePasswordScreen()),
                    child: Text("update_password".tr),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
