import 'dart:async'; // For Future

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
// Campaign Management Screens (Add to your single file)
// ========================================================================

// --- Campaign List Screen ---
class CampaignListScreen extends StatelessWidget {
  const CampaignListScreen({Key? key}) : super(key: key);

  Future<void> _confirmDelete(
    BuildContext context,
    String campaignId,
    String name,
  ) async {
    return Get.defaultDialog(
      title: "confirmDelete".tr,
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      middleText: "${'areYouSureDeleteCampaign'.tr} '$name'?",
      middleTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      backgroundColor: Colors.white,
      barrierDismissible: false,
      radius: 12,
      // Instead of using textConfirm/textCancel, provide your own buttons:
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back(); // Close dialog
          try {
            // Check if any pilgrims are assigned to this campaign
            QuerySnapshot pilgrimCheck =
                await FirebaseFirestore.instance
                    .collection(pilgrimsCollection)
                    .where('campaignId', isEqualTo: campaignId)
                    .limit(1)
                    .get();
            if (pilgrimCheck.docs.isNotEmpty) {
              Get.snackbar(
                'error'.tr,
                'cannotDeleteCampaignWithPilgrims'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orangeAccent,
                colorText: Colors.black,
              );
              return; // Stop deletion
            }
            // Proceed with deletion
            await FirebaseFirestore.instance
                .collection(campaignsCollection)
                .doc(campaignId)
                .delete();
            Get.snackbar(
              'success'.tr,
              'campaignDeletedSuccess'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
          } catch (e) {
            Get.snackbar(
              'error'.tr,
              "${'errorDeletingCampaign'.tr}: ${e.toString()}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Set desired radius here
          ),
        ),
        child: Text("delete".tr, style: const TextStyle(color: Colors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Set desired radius here
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
      body: StreamBuilder<QuerySnapshot>(
        // Only order by campaignYear in the query to avoid composite index error
        stream:
            FirebaseFirestore.instance
                .collection(campaignsCollection)
                .orderBy('campaignYear', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListShimmer(); // Your ListShimmer widget
          }
          if (snapshot.hasError) {
            return Center(child: Text('${'error'.tr}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('noCampaignsFound'.tr));
          }
          // Get the documents and sort them by campaignName in memory
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          docs.sort((a, b) {
            final campaignA = Campaign.fromFirestore(a);
            final campaignB = Campaign.fromFirestore(b);
            return campaignA.campaignName.compareTo(campaignB.campaignName);
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final campaign = Campaign.fromFirestore(docs[index]);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.campaign, color: Colors.purple),
                  title: Text(campaign.campaignName),
                  subtitle: Text(
                    "${'year'.tr}: ${campaign.campaignYear}, ${'phone'.tr}: ${campaign.phone}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.orange,
                        ),
                        tooltip: 'editCampaign'.tr,
                        onPressed:
                            () => Get.to(
                              () => EditCampaignScreen(campaign: campaign),
                            ),
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
                              campaign.id,
                              campaign.campaignName,
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
        tooltip: 'addCampaign'.tr,
        child: const Icon(Icons.add),
        onPressed: () => Get.to(() => const CreateCampaignScreen()),
      ),
    );
  }
}

// --- Create Campaign Screen ---
class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({Key? key}) : super(key: key);

  @override
  _CreateCampaignScreenState createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _adminDocId; // Firestore Admin document ID
  String? _selectedSupervisorId; // Selected Supervisor's document ID
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentAdminDocId();
    _yearController.text = '2036'; // Optionally set a default year
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Fetch the Admin document ID corresponding to the logged-in Firebase User UID
  Future<void> _fetchCurrentAdminDocId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'error'.tr,
        'notLoggedIn'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final String userUid = currentUser.uid;

    try {
      // Assuming the 'admins' collection links the Firebase UID ('userId') to the Admin Doc ID
      QuerySnapshot adminSnapshot =
          await FirebaseFirestore.instance
              .collection(adminsCollection)
              .where('userId', isEqualTo: userUid)
              .limit(1)
              .get();
      if (adminSnapshot.docs.isNotEmpty) {
        setState(() => _adminDocId = adminSnapshot.docs.first.id);
      } else {
        print("Error: No admin profile found for user UID: $userUid");
        Get.snackbar(
          'error'.tr,
          'adminProfileNotFound'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _adminDocId = null);
      }
    } catch (e) {
      print("Error fetching admin ID: $e");
      Get.snackbar(
        'error'.tr,
        'errorFetchingAdminInfo'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() => _adminDocId = null);
    }
  }

  Future<void> _createCampaign() async {
    if (_formKey.currentState!.validate()) {
      if (_adminDocId == null) {
        Get.snackbar(
          'error'.tr,
          'cannotCreateCampaignNoAdmin'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
        return;
      }
      if (_isLoading) return;
      setState(() => _isLoading = true);

      try {
        // Generate a document reference with a new ID
        DocumentReference docRef =
            FirebaseFirestore.instance.collection(campaignsCollection).doc();

        Campaign newCampaign = Campaign(
          id: docRef.id, // Use the generated document ID
          campaignName: _nameController.text.trim(),
          campaignYear:
              int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
          phone: _phoneController.text.trim(),
          adminId: _adminDocId!,
          supervisorId:
              _selectedSupervisorId!, // Supervisor selection is required
        );

        // Save the campaign to Firestore
        await docRef.set(newCampaign.toMap());

        Get.snackbar(
          'success'.tr,
          'campaignCreatedSuccess'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          '${'errorCreatingCampaign'.tr}: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('createCampaign'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('campaignName'.tr, Icons.title),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'requiredField'.tr
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: _inputDecoration(
                  'campaignYear'.tr,
                  Icons.calendar_today,
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'requiredField'.tr;
                  }
                  final year = int.tryParse(val);
                  if (year == null || year < 1440 || year > 1500) {
                    return 'invalidYear'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('phone'.tr, Icons.phone),
                keyboardType: TextInputType.phone,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'requiredField'.tr
                            : null,
              ),
              const SizedBox(height: 16),
              // Dropdown for selecting a supervisor (users with role 'supervisor')
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection(usersCollection)
                        .where('role', isEqualTo: 'supervisor')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  List<DropdownMenuItem<String>> supervisorItems =
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final supervisorName = data['username'] ?? 'No Name';
                        final supervisorId = doc.id;
                        return DropdownMenuItem<String>(
                          value: supervisorId,
                          child: Text(supervisorName),
                        );
                      }).toList();
                  return DropdownButtonFormField<String>(
                    decoration: _inputDecoration(
                      'selectSupervisor'.tr,
                      Icons.supervisor_account,
                    ),
                    value: _selectedSupervisorId,
                    items: supervisorItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedSupervisorId = value;
                      });
                    },
                    validator:
                        (value) => value == null ? 'requiredField'.tr : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              if (_adminDocId == null && !_isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'warningCannotCreateAdmin'.tr,
                    style: TextStyle(color: Colors.orange.shade800),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed:
                    _isLoading || _adminDocId == null ? null : _createCampaign,
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

// --- Edit Campaign Screen ---
class EditCampaignScreen extends StatefulWidget {
  final Campaign campaign;
  const EditCampaignScreen({Key? key, required this.campaign})
    : super(key: key);
  @override
  _EditCampaignScreenState createState() => _EditCampaignScreenState();
}

class _EditCampaignScreenState extends State<EditCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late TextEditingController _nameController;
  late TextEditingController _yearController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.campaign.campaignName);
    _yearController = TextEditingController(
      text: widget.campaign.campaignYear.toString(),
    );
    _phoneController = TextEditingController(text: widget.campaign.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateCampaign() async {
    if (_formKey.currentState!.validate()) {
      if (_isLoading) return;
      setState(() => _isLoading = true);
      try {
        Map<String, dynamic> data = {
          'campaignName': _nameController.text.trim(),
          'campaignYear':
              int.tryParse(_yearController.text.trim()) ??
              widget.campaign.campaignYear,
          'phone': _phoneController.text.trim(),
          // adminId is usually not changed during edit
        };
        await FirebaseFirestore.instance
            .collection(campaignsCollection)
            .doc(widget.campaign.id)
            .update(data);
        Get.snackbar(
          'success'.tr,
          'campaignUpdatedSuccess'.tr, // Add key
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          '${'errorUpdatingCampaign'.tr}: ${e.toString()}', // Add key
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('editCampaign'.tr)), // Add key
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('campaignName'.tr, Icons.title),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'requiredField'.tr
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: _inputDecoration(
                  'campaignYear'.tr,
                  Icons.calendar_today,
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return 'requiredField'.tr;
                  final year = int.tryParse(val);
                  if (year == null || year < 1440 || year > 1500)
                    return 'invalidYear'.tr;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('phone'.tr, Icons.phone),
                keyboardType: TextInputType.phone,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'requiredField'.tr
                            : null,
              ),
              // Optional: Display Admin ID (read-only)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextFormField(
                  initialValue: widget.campaign.adminId,
                  decoration: _inputDecoration(
                    'Admin ID',
                    Icons.admin_panel_settings,
                  ).copyWith(
                    filled: true,
                    fillColor: Colors.grey[200],
                  ), // Assuming 'Admin ID' key exists
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _updateCampaign,
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
