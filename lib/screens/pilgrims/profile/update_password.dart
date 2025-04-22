import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// -------------------------
/// Pilgrim Update Password Screen
/// -------------------------
class PilgrimUpdatePasswordScreen extends StatefulWidget {
  const PilgrimUpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  _PilgrimUpdatePasswordScreenState createState() =>
      _PilgrimUpdatePasswordScreenState();
}

class _PilgrimUpdatePasswordScreenState
    extends State<PilgrimUpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isLoading = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!, password: _currentPasswordController.text);
      await user.reauthenticateWithCredential(credential);
      if (_newPasswordController.text != _confirmPasswordController.text) {
        Get.snackbar("update_error".tr, "passwords_do_not_match".tr,
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      await user.updatePassword(_newPasswordController.text);
      Get.snackbar("password_updated".tr, "password_updated_msg".tr,
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.back();
    } catch (e) {
      Get.snackbar("update_error".tr, e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("update_password".tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Header Text
                Text(
                  "Update Your Password",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Subtitle Text
                Text(
                  "Please fill in your current and new password details to update your password.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: InputDecoration(
                          labelText: "current_password".tr,
                          prefixIcon: Icon(Icons.lock,
                              color: Theme.of(context).primaryColor),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? "enter_current_password".tr
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: "new_password".tr,
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Theme.of(context).primaryColor),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "enter_new_password".tr;
                          }
                          if (value.length < 6) return "password_length".tr;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: "confirm_password".tr,
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Theme.of(context).primaryColor),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? "enter_confirm_password".tr
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Full Width Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white))
                        : Text(
                            "save".tr,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
