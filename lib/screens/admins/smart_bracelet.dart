import 'dart:async'; // For Future

import 'package:cloud_firestore/cloud_firestore.dart';
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
InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: const OutlineInputBorder(),
  );
}

// ========================================================================
// Smart Bracelet Management Screens
// ========================================================================

// --- Smart Bracelet List Screen ---
class SmartBraceletListScreen extends StatelessWidget {
  const SmartBraceletListScreen({Key? key}) : super(key: key);

  // --- Delete Confirmation Logic ---
  Future<void> _confirmDelete(
    BuildContext context,
    String braceletId,
    String serialNumber,
  ) async {
    bool isAssigned = false;
    try {
      QuerySnapshot pilgrimCheck =
          await FirebaseFirestore.instance
              .collection(pilgrimsCollection)
              .where('braceletId', isEqualTo: braceletId)
              .limit(1)
              .get();
      isAssigned = pilgrimCheck.docs.isNotEmpty;
    } catch (e) {
      print("Error checking bracelet assignment: $e");
      Get.snackbar(
        'error'.tr,
        'errorCheckingAssignment'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isAssigned) {
      Get.snackbar(
        'error'.tr,
        'cannotDeleteAssignedBracelet'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.black,
      );
      return;
    }

    Get.defaultDialog(
      title: "confirmDelete".tr,
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      middleText: "${'areYouSureDeleteBracelet'.tr} '$serialNumber'?",
      middleTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      backgroundColor: Colors.white,
      barrierDismissible: false,
      radius: 8,
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back(); // Close dialog
          try {
            // Proceed with deletion
            await FirebaseFirestore.instance
                .collection(smartBraceletsCollection)
                .doc(braceletId)
                .delete();
            Get.snackbar(
              'success'.tr,
              'braceletDeletedSuccess'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
          } catch (e) {
            Get.snackbar(
              'error'.tr,
              "${'errorDeletingBracelet'.tr}: ${e.toString()}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Set button radius to 8
          ),
        ),
        child: Text("delete".tr, style: const TextStyle(color: Colors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Set button radius to 8
          ),
          side: const BorderSide(color: Colors.red),
        ),
        child: Text("cancel".tr, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar can be added here if this screen needs its own,
      // but it's part of the dashboard structure, so likely not needed.
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(
                  smartBraceletsCollection,
                ) // Assumes constant is defined
                .orderBy('serialNumber') // Sort by serial number
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Use the ListShimmer widget defined elsewhere
            return const ListShimmer(itemCount: 8);
          }
          if (snapshot.hasError) {
            return Center(child: Text('${'error'.tr}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Use a key defined in AppTranslations
            return Center(child: Text('noBraceletsFound'.tr));
          }

          final bracelets = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bracelets.length,
            itemBuilder: (context, index) {
              // Assumes SmartBracelet model is defined
              final bracelet = SmartBracelet.fromFirestore(bracelets[index]);
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ), // Adjusted margin
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.watch, color: Colors.white),
                  ),
                  title: Text(bracelet.serialNumber),
                  subtitle: Text('ID: ${bracelet.id}'), // Show document ID
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.orange,
                        ),
                        tooltip: 'editBracelet'.tr, // Add key
                        iconSize: 22, // Slightly smaller icon
                        onPressed:
                            () => Get.to(
                              () => EditSmartBraceletScreen(bracelet: bracelet),
                            ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'delete'.tr,
                        iconSize: 22, // Slightly smaller icon
                        onPressed:
                            () => _confirmDelete(
                              context,
                              bracelet.id,
                              bracelet.serialNumber,
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
        tooltip: 'addBracelet'.tr, // Add key
        child: const Icon(Icons.add),
        onPressed: () => Get.to(() => const CreateSmartBraceletScreen()),
      ),
    );
  }
}

// --- Create Smart Bracelet Screen ---
class CreateSmartBraceletScreen extends StatefulWidget {
  const CreateSmartBraceletScreen({Key? key}) : super(key: key);
  @override
  _CreateSmartBraceletScreenState createState() =>
      _CreateSmartBraceletScreenState();
}

class _CreateSmartBraceletScreenState extends State<CreateSmartBraceletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serialNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _serialNumberController.dispose();
    super.dispose();
  }

  // --- Create Logic ---
  Future<void> _createBracelet() async {
    if (_formKey.currentState!.validate()) {
      if (_isLoading) return;
      setState(() => _isLoading = true);
      final serial = _serialNumberController.text.trim();

      try {
        // Check if serial number already exists before adding
        QuerySnapshot existing =
            await FirebaseFirestore.instance
                .collection(smartBraceletsCollection) // Use constant
                .where('serialNumber', isEqualTo: serial)
                .limit(1)
                .get();

        if (existing.docs.isNotEmpty) {
          // Use key from AppTranslations
          Get.snackbar(
            'error'.tr,
            'serialNumberExists'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.black,
          );
          // Reset loading state here if check fails
          if (mounted) setState(() => _isLoading = false);
          return; // Stop if exists
        }

        // Create using the SmartBracelet model's toMap method
        SmartBracelet newBracelet = SmartBracelet(
          id: '',
          serialNumber: serial,
        ); // ID will be auto-generated
        await FirebaseFirestore.instance
            .collection(smartBraceletsCollection) // Use constant
            .add(newBracelet.toMap());

        // Use key from AppTranslations
        Get.snackbar(
          'success'.tr,
          'braceletCreatedSuccess'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back(); // Go back to the list screen after successful creation
      } catch (e) {
        // Use key from AppTranslations
        Get.snackbar(
          'error'.tr,
          '${'errorCreatingBracelet'.tr}: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      } finally {
        // Ensure loading state is reset even if an error occurs
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use key from AppTranslations
        title: Text('createBracelet'.tr),
      ),
      body: SingleChildScrollView(
        // Allows scrolling on smaller screens
        padding: const EdgeInsets.all(20.0), // Increased padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch button
            children: [
              Text(
                'enterBraceletDetails'.tr, // Add key
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _serialNumberController,
                // Use the shared _inputDecoration function if available
                decoration: _inputDecoration(
                  'serialNumber'.tr,
                  Icons.confirmation_number_outlined,
                ), // Use outlined icon
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'requiredField'.tr
                            : null,
                textInputAction: TextInputAction.done, // Set keyboard action
              ),
              const SizedBox(height: 32), // Increased spacing
              ElevatedButton.icon(
                // Use Button with icon
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // Full width button
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ), // Rounded corners
                ),
                // Disable button while loading
                onPressed: _isLoading ? null : _createBracelet,
                icon:
                    _isLoading
                        ? Container()
                        : const Icon(
                          Icons.add_circle_outline,
                        ), // Hide icon when loading
                label:
                    _isLoading
                        ? const SizedBox(
                          // Centered indicator
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                        : Text('create'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Edit Smart Bracelet Screen ---
class EditSmartBraceletScreen extends StatefulWidget {
  final SmartBracelet bracelet; // Pass the object to edit
  const EditSmartBraceletScreen({Key? key, required this.bracelet})
    : super(key: key);
  @override
  _EditSmartBraceletScreenState createState() =>
      _EditSmartBraceletScreenState();
}

class _EditSmartBraceletScreenState extends State<EditSmartBraceletScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serialNumberController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller with existing data
    _serialNumberController = TextEditingController(
      text: widget.bracelet.serialNumber,
    );
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    super.dispose();
  }

  // --- Update Logic ---
  Future<void> _updateBracelet() async {
    if (_formKey.currentState!.validate()) {
      if (_isLoading) return;
      setState(() => _isLoading = true);
      final serial = _serialNumberController.text.trim();

      try {
        // Check if the *new* serial number already exists (excluding the current doc)
        // Only perform check if the serial number has actually changed
        if (serial != widget.bracelet.serialNumber) {
          QuerySnapshot existing =
              await FirebaseFirestore.instance
                  .collection(smartBraceletsCollection) // Use constant
                  .where('serialNumber', isEqualTo: serial)
                  // Exclude the current document from the check
                  .where(FieldPath.documentId, isNotEqualTo: widget.bracelet.id)
                  .limit(1)
                  .get();

          if (existing.docs.isNotEmpty) {
            // Use key from AppTranslations
            Get.snackbar(
              'error'.tr,
              'serialNumberExists'.tr,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orangeAccent,
              colorText: Colors.black,
            );
            if (mounted) setState(() => _isLoading = false);
            return; // Stop if new serial number exists elsewhere
          }
        }

        // Prepare update data (only serialNumber in this case)
        Map<String, dynamic> updateData = {'serialNumber': serial};

        // Update the specific document
        await FirebaseFirestore.instance
            .collection(smartBraceletsCollection) // Use constant
            .doc(widget.bracelet.id) // Target the specific document
            .update(updateData);

        // Use key from AppTranslations
        Get.snackbar(
          'success'.tr,
          'braceletUpdatedSuccess'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back(); // Go back after successful update
      } catch (e) {
        // Use key from AppTranslations
        Get.snackbar(
          'error'.tr,
          '${'errorUpdatingBracelet'.tr}: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use key from AppTranslations
        title: Text('editBracelet'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'updateBraceletDetails'.tr, // Add key
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Display Original ID (read-only)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: widget.bracelet.id,
                  decoration: _inputDecoration(
                    'Document ID',
                    Icons.vpn_key_outlined,
                  ) // Use shared _inputDecoration
                  .copyWith(filled: true, fillColor: Colors.grey[200]),
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serialNumberController,
                // Use the shared _inputDecoration function if available
                decoration: _inputDecoration(
                  'serialNumber'.tr,
                  Icons.confirmation_number_outlined,
                ),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'requiredField'.tr
                            : null,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _updateBracelet,
                icon:
                    _isLoading
                        ? Container()
                        : const Icon(Icons.save_alt_outlined),
                label:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                        : Text('update'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
