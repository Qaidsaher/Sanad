import 'dart:async'; // For Future

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad/models/models.dart';
import 'package:sanad/screens/admins/dashboard.dart';
// ========================================================================

// ========================================================================
// Constants (Normally in constants.dart)
// ========================================================================
const String usersCollection = 'users';
const String adminsCollection = 'admins';
const String campaignsCollection = 'campaigns';
const String pilgrimsCollection = 'pilgrims';
const String smartBraceletsCollection = 'smart_bracelets';
const String healthDataSubcollection = 'health_data';

// ========================================================================
// User Management Screens (Normally in screens/user_management/)
// ========================================================================
InputDecoration _inputDecoration(
  String label,
  IconData icon, {
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}

// --- User List Screen ---
class UserListScreen extends StatelessWidget {
  const UserListScreen({Key? key}) : super(key: key);

  Future<void> _confirmDeleteUser(BuildContext context, UserModel user) async {
    Get.defaultDialog(
      title: "confirmDelete".tr,
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      middleText:
          "${'areYouSureDeleteUser'.tr} '${user.username}' (${user.email})?",
      middleTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      backgroundColor: Colors.white,
      barrierDismissible: false,
      radius: 12,
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back(); // Close dialog
          final currentUserUid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
          if (currentUserUid == user.id) {
            Get.snackbar(
              'error'.tr,
              'cannotDeleteSelf'.tr,
              backgroundColor: Colors.orangeAccent,
              colorText: Colors.black,
            );
            return;
          }
          try {
            await FirebaseFirestore.instance
                .collection(usersCollection)
                .doc(user.id)
                .delete();
            Get.snackbar(
              'success'.tr,
              'userDeletedSuccess'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
            // Consider triggering a Cloud Function here to delete the Auth user
          } catch (e) {
            Get.snackbar(
              'error'.tr,
              "${'errorDeletingUser'.tr}: ${e.toString()}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Radius set to 8
          ),
        ),
        child: Text("delete".tr, style: const TextStyle(color: Colors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Radius set to 8
          ),
          side: const BorderSide(color: Colors.black),
        ),
        child: Text("cancel".tr, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(usersCollection)
                .orderBy('username')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListShimmer();
          }
          if (snapshot.hasError) {
            return Center(child: Text('${'error'.tr}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('noUsersFound'.tr));
          }
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = UserModel.fromFirestore(users[index]);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user.role.isNotEmpty ? user.role[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(user.username),
                  subtitle: Text(
                    "${user.email}\n${'role'.tr}: ${user.role.tr}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.orange,
                        ),
                        tooltip: 'editUser'.tr,
                        onPressed:
                            () => Get.to(() => EditUserScreen(user: user)),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'deleteUser'.tr,
                        onPressed: () => _confirmDeleteUser(context, user),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'addUser'.tr,
        child: const Icon(Icons.add),
        onPressed: () => Get.to(() => const CreateUserScreen()),
      ),
    );
  }
}

// --- Create User Screen ---
class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({Key? key}) : super(key: key);
  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'admin'; // Default role

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final role = _selectedRole;

    try {
      fb_auth.UserCredential userCredential = await fb_auth
          .FirebaseAuth
          .instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        UserModel newUser = UserModel(
          id: uid,
          username: username,
          email: email,
          phone: phone,
          role: role,
        );

        await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(uid)
            .set(newUser.toMap());
        Admin newAdmin = Admin(id: newUser.id, userId: uid);
        await FirebaseFirestore.instance
            .collection(adminsCollection)
            .doc(newAdmin.id)
            .set(newAdmin.toMap());
        // Show a success message
        Get.snackbar(
          'success'.tr,
          '${'userCreatedSuccess'.tr}: ${newUser.email}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Delay for 2 seconds so the snackbar is visible, then go back
        Get.back();
      } else {
        Get.snackbar(
          'error'.tr,
          "Firebase Auth user creation failed silently.",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.redAccent,
        );
        throw Exception("Firebase Auth user creation failed silently.");
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'firebaseAuthError'.tr}: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.redAccent,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'errorCreatingUser'.tr}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.redAccent,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('createUser'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: _inputDecoration('username'.tr, Icons.person),
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('email'.tr, Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) =>
                        v!.isEmpty
                            ? 'requiredField'.tr
                            : (!GetUtils.isEmail(v) ? 'invalidEmail'.tr : null),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('phone'.tr, Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  'password'.tr,
                  Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),
                validator:
                    (v) =>
                        v!.isEmpty
                            ? 'requiredField'.tr
                            : (v.length < 6 ? 'passwordTooShort'.tr : null),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _inputDecoration('role'.tr, Icons.security),
                items: [
                  DropdownMenuItem(value: 'admin', child: Text('admin'.tr)),
                  DropdownMenuItem(
                    value: 'supervisor',
                    child: Text('supervisor'.tr),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
                validator: (v) => v == null ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _createUser,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('create'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Edit User Screen ---
class EditUserScreen extends StatefulWidget {
  final UserModel user;
  const EditUserScreen({Key? key, required this.user}) : super(key: key);
  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> updateData = {
        'username': _usernameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
      };
      await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(widget.user.id)
          .update(updateData);
      Get.snackbar(
        'success'.tr,
        'userUpdatedSuccess'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'errorUpdatingUser'.tr}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('editUser'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  initialValue: widget.user.email,
                  decoration: _inputDecoration(
                    'email'.tr,
                    Icons.email,
                  ).copyWith(filled: true, fillColor: Colors.grey[200]),
                  readOnly: true,
                ),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: _inputDecoration('username'.tr, Icons.person),
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('phone'.tr, Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _inputDecoration('role'.tr, Icons.security),
                items: [
                  DropdownMenuItem(value: 'admin', child: Text('admin'.tr)),
                  DropdownMenuItem(
                    value: 'supervisor',
                    child: Text('supervisor'.tr),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
                validator: (v) => v == null ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _updateUser,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('update'.tr),
              ),
              // Optional: Password Reset Button
              // TextButton(onPressed: () async { try { await fb_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: widget.user.email); Get.snackbar("Success", "Password reset email sent to ${widget.user.email}"); } catch (e) { Get.snackbar("Error", "Failed to send reset email: $e"); } }, child: Text("Send Password Reset Email")),
            ],
          ),
        ),
      ),
    );
  }
}
