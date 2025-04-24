import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _countryController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _convertAvatarToBase64(File avatarFile) async {
    final bytes = await avatarFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      await _animationController.forward();

      // Register with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      User? user = userCredential.user;
      if (user == null) throw Exception("User registration failed");

      // Update display name
      await user.updateDisplayName(_nameController.text.trim());

      // Get FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();

      // Convert avatar to base64
      String avatarBase64 = "";
      if (_avatarFile != null) {
        avatarBase64 = await _convertAvatarToBase64(_avatarFile!);
      }

      // Save user to Firestore
      await _firestore.collection("users").doc(user.uid).set({
        'id': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'country': _countryController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'avatarBinary': avatarBase64,
        'notificationToken': fcmToken ?? '',
        'role': 'pilgrim',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "register_success".tr,
        "welcome".tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.off(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "register_error".tr,
        e.message ?? "error_occurred".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("register_title".tr)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : const AssetImage("assets/avatar.png")
                                as ImageProvider,
                  ),
                ),
                TextButton(
                  onPressed: _pickAvatar,
                  child: Text("change_avatar".tr),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  "name".tr,
                  _nameController,
                  Icons.person,
                  "enter_name".tr,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "email".tr,
                  _emailController,
                  Icons.email,
                  "enter_email".tr,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "password".tr,
                  _passwordController,
                  Icons.lock,
                  "enter_password".tr,
                  obscure: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "country".tr,
                  _countryController,
                  Icons.flag,
                  "enter_country".tr,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "age".tr,
                  _ageController,
                  Icons.cake,
                  "enter_age".tr,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _register,
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                                : Text(
                                  "register".tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  child: Text("already_account".tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String validationMessage, {
    bool obscure = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return validationMessage;
        if (label == "password".tr && value.length < 6) {
          return "password_length".tr;
        }
        return null;
      },
    );
  }
}
