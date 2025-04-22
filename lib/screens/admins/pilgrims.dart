import 'dart:async'; // For Future
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sanad/models/models.dart';
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
InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: const OutlineInputBorder(),
  );
}

// ========================================================================
// Pilgrim Management Screens (Normally in screens/pilgrim_management/)
// ========================================================================

// --- Pilgrim List Screen ---
// Pilgrim List Screen (displays list of pilgrims)
class PilgrimListScreen extends StatelessWidget {
  const PilgrimListScreen({Key? key}) : super(key: key);

  Future<void> _confirmDelete(
    BuildContext context,
    String pilgrimId,
    String name,
  ) async {
    return Get.defaultDialog(
      title: "confirmDelete".tr,
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      middleText: "${'areYouSureDeletePilgrim'.tr} '$name'?",
      middleTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      backgroundColor: Colors.white,
      barrierDismissible: false,
      radius: 12,
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back(); // Close dialog
          try {
            // Start a batch to delete the pilgrim and its health_data subcollection.
            WriteBatch batch = FirebaseFirestore.instance.batch();

            // Get all health_data documents under the pilgrim.
            QuerySnapshot healthDataSnapshot =
                await FirebaseFirestore.instance
                    .collection(pilgrimsCollection)
                    .doc(pilgrimId)
                    .collection(healthDataSubcollection)
                    .get();

            // Queue deletion for each health_data document.
            for (var doc in healthDataSnapshot.docs) {
              batch.delete(doc.reference);
            }

            // Queue deletion of the pilgrim document.
            DocumentReference pilgrimRef = FirebaseFirestore.instance
                .collection(pilgrimsCollection)
                .doc(pilgrimId);
            batch.delete(pilgrimRef);

            // Commit the batch.
            await batch.commit();

            Get.snackbar(
              'success'.tr,
              'pilgrimDeletedSuccess'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
          } catch (e) {
            Get.snackbar(
              'error'.tr,
              "${'errorDeletingPilgrim'.tr}: ${e.toString()}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text("delete".tr, style: const TextStyle(color: Colors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: Colors.red),
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
                .collection(pilgrimsCollection)
                .orderBy('lastName')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${'error'.tr}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('noPilgrimsFound'.tr));
          }
          final pilgrims = snapshot.data!.docs;
          return ListView.builder(
            itemCount: pilgrims.length,
            itemBuilder: (context, index) {
              final pilgrim = Pilgrim.fromFirestore(pilgrims[index]);

              // Decode the avatar base64 string if available
              ImageProvider avatarProvider;
              avatarProvider = const AssetImage('assets/default_avatar.png');
              if (pilgrim.avatar != null && pilgrim.avatar!.isNotEmpty) {
                try {
                  // avatarProvider = MemoryImage(base64Decode(pilgrim.avatar!));
                } catch (e) {
                  avatarProvider = const AssetImage(
                    'assets/default_avatar.png',
                  );
                }
              } else {
                avatarProvider = const AssetImage('assets/default_avatar.png');
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: avatarProvider),
                  title: Text(pilgrim.fullName),
                  subtitle: Text(
                    "${'age'.tr}: ${pilgrim.age}, ${'gender'.tr}: ${pilgrim.gender.tr}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.orange,
                        ),
                        tooltip: 'editPilgrim'.tr,
                        onPressed:
                            () =>
                                Get.to(() => EditPilgrimPage(pilgrim: pilgrim)),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outlined,
                          color: Colors.red,
                        ),
                        tooltip: 'delete'.tr,
                        onPressed:
                            () => _confirmDelete(
                              context,
                              pilgrim.id,
                              pilgrim.fullName,
                            ),
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
        tooltip: 'addPilgrim'.tr,
        child: const Icon(Icons.add),
        onPressed: () => Get.to(() => const CreatePilgrimPage()),
      ),
    );
  }
}

// Create Pilgrim Screen (role fixed to 'pilgrim' and avatar stored as binary)
class CreatePilgrimPage extends StatefulWidget {
  const CreatePilgrimPage({Key? key}) : super(key: key);
  @override
  _CreatePilgrimPageState createState() => _CreatePilgrimPageState();
}

class _CreatePilgrimPageState extends State<CreatePilgrimPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Personal information controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();

  // Gender selection
  String? _selectedGender;

  // Avatar file (picked image)
  File? _avatarFile;
  String? _avatarBase64; // Will store the base64-encoded string

  // Assignment dropdowns
  String? _selectedCampaignId;
  String? _selectedBraceletId;
  List<DropdownMenuItem<String>> _campaignItems = [];
  List<DropdownMenuItem<String>> _braceletItems = [];
  bool _loadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // Method to pick avatar image (using image_picker)
  Future<void> _pickAvatar() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  // Converts an image file to a base64-encoded string.
  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _loadDropdownData() async {
    if (!mounted) return;
    setState(() => _loadingDropdowns = true);
    try {
      // Fetch Campaigns
      QuerySnapshot campaignSnapshot =
          await FirebaseFirestore.instance
              .collection(campaignsCollection)
              .orderBy('campaignName')
              .get();
      _campaignItems =
          campaignSnapshot.docs
              .map(
                (doc) => DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(
                    "${doc.get('campaignName')} (${doc.get('campaignYear')})",
                  ),
                ),
              )
              .toList();

      // Fetch Unassigned Bracelets
      QuerySnapshot braceletSnapshot =
          await FirebaseFirestore.instance
              .collection(smartBraceletsCollection)
              .get();
      List<String> allBraceletIds =
          braceletSnapshot.docs.map((doc) => doc.id).toList();
      Set<String> assignedBraceletIds = {};
      if (allBraceletIds.isNotEmpty) {
        QuerySnapshot assignedPilgrimsSnapshot =
            await FirebaseFirestore.instance
                .collection(pilgrimsCollection)
                .where('braceletId', whereIn: allBraceletIds)
                .get();
        assignedBraceletIds =
            assignedPilgrimsSnapshot.docs
                .map((doc) => doc.get('braceletId') as String)
                .where((id) => id.isNotEmpty)
                .toSet();
      }
      _braceletItems =
          braceletSnapshot.docs
              .where((doc) => !assignedBraceletIds.contains(doc.id))
              .map(
                (doc) => DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(doc.get('serialNumber')),
                ),
              )
              .toList();
    } catch (e) {
      print("Error loading dropdowns: $e");
      if (mounted)
        Get.snackbar(
          'error'.tr,
          'errorLoadingDropdownData'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      _campaignItems = [];
      _braceletItems = [];
    } finally {
      if (mounted) setState(() => _loadingDropdowns = false);
    }
  }

  Future<void> _createPilgrim() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null ||
          _selectedCampaignId == null ||
          _selectedBraceletId == null) {
        Get.snackbar(
          'error'.tr,
          'pleaseSelectAllRequired'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.black,
        );
        return;
      }
      if (_isLoading) return;
      setState(() => _isLoading = true);
      try {
        // Create Firebase Authentication user using email and password.
        UserCredential authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        String newUserId = authResult.user!.uid;

        // If an avatar image was picked, convert it to base64.
        if (_avatarFile != null) {
          _avatarBase64 = await _convertImageToBase64(_avatarFile!);
        }

        // Create the user account document with default role 'pilgrim'
        UserModel userData = UserModel(
          id: newUserId,
          username:
              "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: 'pilgrim',
        );
        await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(newUserId)
            .set(userData.toMap());

        // Create the pilgrim document including the new userId and avatar as a base64 string.
        Map<String, dynamic> pilgrimData = {
          'userId': newUserId,
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'gender': _selectedGender!,
          'campaignId': _selectedCampaignId!,
          'braceletId': _selectedBraceletId!,
          'country': _countryController.text.trim(),
          'avatar': _avatarBase64 ?? '', // Save as base64 string.
        };

        // Add the pilgrim document and get its reference.
        DocumentReference pilgrimRef = await FirebaseFirestore.instance
            .collection(pilgrimsCollection)
            .add(pilgrimData);

        // Create default health data document within the pilgrim's health_data subcollection.
        await pilgrimRef.collection(healthDataSubcollection).add({
          'temperature': 36.5, // default temperature value
          'bloodOxygen': 98.0, // default blood oxygen value
          'heartRate': 75, // default heart rate value
          'timestamp': Timestamp.now(),
          // Default GPS location set to Mecca, Saudi Arabia (21.4225° N, 39.8262° E)
          'location': GeoPoint(21.4225, 39.8262),
          'smartBraceletId': _selectedBraceletId!,
          'pilgrimId': pilgrimRef.id,
        });

        Get.snackbar(
          'success'.tr,
          'pilgrimCreatedSuccess'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          '${'errorCreatingPilgrim'.tr}: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Helper decoration method (assumes you have your own styling).
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('createPilgrim'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar selection section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _avatarFile != null
                              ? FileImage(_avatarFile!)
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _pickAvatar,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'personalInformation'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _firstNameController,
                decoration: _inputDecoration(
                  'firstName'.tr,
                  Icons.person_outline,
                ),
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _middleNameController,
                decoration: _inputDecoration(
                  'middleName'.tr,
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: _inputDecoration(
                  'lastName'.tr,
                  Icons.person_outline,
                ),
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: _inputDecoration('age'.tr, Icons.cake_outlined),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'requiredField'.tr;
                  if (int.tryParse(v) == null || int.parse(v) <= 0)
                    return 'invalidAge'.tr;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('email'.tr, Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: _inputDecoration('password'.tr, Icons.lock_outline),
                obscureText: true,
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
              TextFormField(
                controller: _countryController,
                decoration: _inputDecoration('country'.tr, Icons.flag_outlined),
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('gender'.tr, Icons.wc_outlined),
                value: _selectedGender,
                items: [
                  DropdownMenuItem(value: 'Male', child: Text('male'.tr)),
                  DropdownMenuItem(value: 'Female', child: Text('female'.tr)),
                ],
                onChanged: (v) => setState(() => _selectedGender = v),
                validator: (v) => v == null ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 24),
              Text(
                'assignmentInformation'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              _loadingDropdowns
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration(
                          'campaign'.tr,
                          Icons.campaign_outlined,
                        ),
                        value: _selectedCampaignId,
                        items:
                            _campaignItems.isEmpty
                                ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('noCampaignsAvailable'.tr),
                                  ),
                                ]
                                : _campaignItems,
                        onChanged:
                            _campaignItems.isEmpty
                                ? null
                                : (v) =>
                                    setState(() => _selectedCampaignId = v),
                        validator: (v) => v == null ? 'requiredField'.tr : null,
                        isExpanded: true,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration(
                          'smartBracelet'.tr,
                          Icons.watch_outlined,
                        ),
                        value: _selectedBraceletId,
                        items:
                            _braceletItems.isEmpty
                                ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('noBraceletsAvailable'.tr),
                                  ),
                                ]
                                : _braceletItems,
                        onChanged:
                            _braceletItems.isEmpty
                                ? null
                                : (v) =>
                                    setState(() => _selectedBraceletId = v),
                        validator: (v) => v == null ? 'requiredField'.tr : null,
                      ),
                    ],
                  ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed:
                    _isLoading || _loadingDropdowns ? null : _createPilgrim,
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

// Edit Pilgrim Screen (allows editing personal info, assignment and avatar stored as binary)
class EditPilgrimPage extends StatefulWidget {
  final Pilgrim pilgrim;
  const EditPilgrimPage({Key? key, required this.pilgrim}) : super(key: key);
  @override
  _EditPilgrimPageState createState() => _EditPilgrimPageState();
}

class _EditPilgrimPageState extends State<EditPilgrimPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;

  String? _selectedGender;
  String? _selectedCampaignId;
  String? _selectedBraceletId;

  // Avatar: we now store the existing avatar as a base64 String.
  String? _avatarBase64;
  File? _newAvatarFile; // New file if picked

  List<DropdownMenuItem<String>> _campaignItems = [];
  List<DropdownMenuItem<String>> _braceletItems = [];
  bool _loadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.pilgrim.firstName,
    );
    _middleNameController = TextEditingController(
      text: widget.pilgrim.middleName,
    );
    _lastNameController = TextEditingController(text: widget.pilgrim.lastName);
    _ageController = TextEditingController(text: widget.pilgrim.age.toString());
    _selectedGender = widget.pilgrim.gender;
    _selectedCampaignId = widget.pilgrim.campaignId;
    _selectedBraceletId = widget.pilgrim.braceletId;
    _avatarBase64 = widget.pilgrim.avatar; // Avatar stored as base64 string.
    _loadDropdownData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // Method to pick a new avatar image for editing.
  Future<void> _pickAvatar() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _newAvatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _loadDropdownData() async {
    if (!mounted) return;
    setState(() => _loadingDropdowns = true);
    try {
      QuerySnapshot campaignSnapshot =
          await FirebaseFirestore.instance
              .collection(campaignsCollection)
              .orderBy('campaignName')
              .get();
      _campaignItems =
          campaignSnapshot.docs
              .map(
                (doc) => DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(
                    "${doc.get('campaignName')} (${doc.get('campaignYear')})",
                  ),
                ),
              )
              .toList();

      QuerySnapshot braceletSnapshot =
          await FirebaseFirestore.instance
              .collection(smartBraceletsCollection)
              .get();
      List<String> allBraceletIds =
          braceletSnapshot.docs.map((doc) => doc.id).toList();
      Set<String> assignedToOthersIds = {};
      if (allBraceletIds.isNotEmpty) {
        QuerySnapshot assignedPilgrimsSnapshot =
            await FirebaseFirestore.instance
                .collection(pilgrimsCollection)
                .where('braceletId', whereIn: allBraceletIds)
                .where(FieldPath.documentId, isNotEqualTo: widget.pilgrim.id)
                .get();
        assignedToOthersIds =
            assignedPilgrimsSnapshot.docs
                .map((doc) => doc.get('braceletId') as String)
                .where((id) => id.isNotEmpty)
                .toSet();
      }
      _braceletItems =
          braceletSnapshot.docs
              .where((doc) {
                return !assignedToOthersIds.contains(doc.id);
              })
              .map((doc) {
                final bracelet = SmartBracelet.fromFirestore(doc);
                return DropdownMenuItem<String>(
                  value: bracelet.id,
                  child: Text(
                    bracelet.serialNumber +
                        (doc.id == widget.pilgrim.braceletId
                            ? ' (${'current'.tr})'
                            : ''),
                  ),
                );
              })
              .toList();
    } catch (e) {
      print("Error loading dropdowns: $e");
      if (mounted)
        Get.snackbar(
          'error'.tr,
          'errorLoadingDropdownData'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      _campaignItems = [];
      _braceletItems = [];
    } finally {
      if (mounted) setState(() => _loadingDropdowns = false);
    }
  }

  Future<void> _updatePilgrim() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null ||
          _selectedCampaignId == null ||
          _selectedBraceletId == null) {
        Get.snackbar(
          'error'.tr,
          'pleaseSelectAllRequired'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.black,
        );
        return;
      }
      if (_isLoading) return;
      setState(() => _isLoading = true);

      // If a new avatar has been picked, convert it to base64; otherwise keep the existing.
      String? updatedAvatar;
      if (_newAvatarFile != null) {
        final bytes = await _newAvatarFile!.readAsBytes();
        updatedAvatar = base64Encode(bytes);
      } else {
        updatedAvatar = _avatarBase64;
      }

      // Data to update for the pilgrim document.
      Map<String, dynamic> data = {
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'gender': _selectedGender!,
        'campaignId': _selectedCampaignId!,
        'braceletId': _selectedBraceletId!,
        'avatar': updatedAvatar, // Save as base64 string.
      };
      try {
        await FirebaseFirestore.instance
            .collection(pilgrimsCollection)
            .doc(widget.pilgrim.id)
            .update(data);
        // Also update the user document with the new avatar if needed.
        await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(widget.pilgrim.userId)
            .update({'avatar': updatedAvatar});
        Get.snackbar(
          'success'.tr,
          'pilgrimUpdatedSuccess'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          '${'errorUpdatingPilgrim'.tr}: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('editPilgrim'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar editing section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _newAvatarFile != null
                              ? FileImage(_newAvatarFile!)
                              : (_avatarBase64 != null &&
                                  _avatarBase64!.isNotEmpty)
                              ? MemoryImage(base64Decode(_avatarBase64!))
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _pickAvatar,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'personalInformation'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _firstNameController,
                decoration: _inputDecoration(
                  'firstName'.tr,
                  Icons.person_outline,
                ),
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _middleNameController,
                decoration: _inputDecoration(
                  'middleName'.tr,
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: _inputDecoration(
                  'lastName'.tr,
                  Icons.person_outline,
                ),
                validator: (v) => v!.isEmpty ? 'requiredField'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: _inputDecoration('age'.tr, Icons.cake_outlined),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'requiredField'.tr;
                  if (int.tryParse(v) == null || int.parse(v) <= 0)
                    return 'invalidAge'.tr;
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed:
                    _isLoading || _loadingDropdowns ? null : _updatePilgrim,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('update'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
