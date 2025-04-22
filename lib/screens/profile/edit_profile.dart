import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'update_password.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;
  String? avatarBase64; // Stores the image from Firestore

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';

      // Load avatarBinary from Firestore if exists
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.get('avatarBinary') != null) {
        setState(() {
          avatarBase64 = userDoc.get('avatarBinary');
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("No user is logged in.");

      // If a new avatar was picked, update avatarBase64 from that file
      if (_avatarFile != null) {
        avatarBase64 = await _convertImageToBase64(_avatarFile!);
      }

      // Update Firebase Auth (name and email only)
      await user.updateDisplayName(_nameController.text.trim());
      await user.updateEmail(_emailController.text.trim());
      await user.reload();

      // Update Firestore user record (update name, email, and avatarBinary if new image provided)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        if (avatarBase64 != null) 'avatarBinary': avatarBase64,
      });

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
    _nameController.dispose();
    _emailController.dispose();
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
                  // Avatar section: shows new picked image if available, else shows Firestore image, else default asset.
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (avatarBase64 != null
                                  ? MemoryImage(base64Decode(avatarBase64!))
                                  : (user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : const AssetImage("assets/avatar.png")))
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _pickImage,
                    child: Text("change_avatar".tr),
                  ),
                  const SizedBox(height: 20),
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "name".tr,
                      prefixIcon: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "enter_name".tr : null,
                  ),
                  const SizedBox(height: 16),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "email".tr,
                      prefixIcon: Icon(
                        Icons.email,
                        color: Theme.of(context).primaryColor,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "enter_email".tr
                        : null,
                  ),
                  const SizedBox(height: 30),
                  // Save button
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
                        : Text(
                            "save".tr,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Update password button
                  TextButton(
                    onPressed: () => Get.to(() => const UpdatePasswordScreen()),
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
