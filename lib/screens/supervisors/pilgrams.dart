import 'dart:async';
import 'dart:convert'; // Needed for base64Decode if used in PilgrimListItem

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Assuming you use GetX for translation and navigation
import 'package:sanad/models/models.dart'; // <-- ADJUST PATH: Assuming models (Pilgrim, HealthData, Campaign) are in models.dart
import 'package:sanad/screens/supervisors/pilgrams_profile.dart'; // <-- ADJUST PATH: Import your profile screen
import 'package:shimmer/shimmer.dart'; // For loading effect

// --- Health Threshold Constants ---
// Consider placing these in a central constants file
const double MAX_TEMPERATURE = 38.5; // degrees Celsius
const double MIN_TEMPERATURE = 35.0; // degrees Celsius
const int MAX_HEART_RATE = 125; // beats per minute
const int MIN_HEART_RATE = 50; // beats per minute
const double MIN_BLOOD_OXYGEN = 92.0; // percentage

// --- Health Status Enum ---
// Used within PilgrimListItem to manage display state
enum HealthStatus { loading, normal, abnormal, error, unknown }

// --- Main Supervisor's Pilgrim List Page ---
class PilgramsListPage extends StatefulWidget {
  const PilgramsListPage({Key? key}) : super(key: key);

  @override
  State<PilgramsListPage> createState() => _PilgramsListPageState();
}

class _PilgramsListPageState extends State<PilgramsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  /// Retrieves the list of campaign IDs where the current user is the supervisor.
  Future<List<String>> _getCampaignIdsForSupervisor() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("Supervisor not logged in.");
      return []; // Return empty list if no user
    }
    try {
      QuerySnapshot campaignSnapshot =
          await FirebaseFirestore.instance
              .collection('campaigns') // Ensure collection name is correct
              .where('supervisorId', isEqualTo: currentUser.uid)
              .get();
      List<String> campaignIds =
          campaignSnapshot.docs.map((doc) => doc.id).toList();
      print("Supervisor campaigns found: $campaignIds");
      return campaignIds;
    } catch (e) {
      print("Error fetching campaigns for supervisor: $e");
      Get.snackbar(
        "Error",
        "Could not load campaign assignments.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return []; // Return empty on error
    }
  }

  // Builds a shimmer placeholder item for the list while loading.
  Widget _buildShimmerItem() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // Adjusted padding
          child: Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 150,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                    ), // Name placeholder
                    Container(
                      height: 14,
                      width: 200,
                      color: Colors.white,
                    ), // Subtitle placeholder
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Placeholder for icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16), // Spacing for arrow
                  Container(width: 10, height: 14, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the search bar widget.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        16.0,
        16.0,
        8.0,
      ), // Adjusted padding
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          // Update search query state on change
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "search_users".tr, // Assumes GetX translation
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade100, // Lighter fill color
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none, // No border
          ),
          focusedBorder: OutlineInputBorder(
            // Keep border consistent when focused
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              width: 1,
            ), // Subtle focus border
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("pilgrims".tr)), // Assuming translation
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            // First FutureBuilder: Get the campaign IDs the supervisor manages
            child: FutureBuilder<List<String>>(
              future: _getCampaignIdsForSupervisor(),
              builder: (context, campaignSnapshot) {
                // Show shimmer while fetching campaign IDs
                if (campaignSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildShimmerItem(),
                  );
                }
                // Handle errors fetching campaign IDs
                if (campaignSnapshot.hasError) {
                  return Center(
                    child: Text("error_loading_campaigns".tr),
                  ); // Assuming translation
                }
                // Handle case where supervisor manages no campaigns
                if (!campaignSnapshot.hasData ||
                    campaignSnapshot.data!.isEmpty) {
                  return Center(
                    child: Text("no_pilgrims_assigned".tr),
                  ); // Assuming translation
                }

                // If campaign IDs are loaded, use them to stream pilgrims
                final campaignIds = campaignSnapshot.data!;

                // Second StreamBuilder: Listen to pilgrims belonging to the fetched campaign IDs
                return StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection(
                            'pilgrims',
                          ) // Ensure correct collection name
                          .where(
                            'campaignId',
                            whereIn: campaignIds,
                          ) // Filter by campaign IDs
                          .snapshots(),
                  builder: (context, snapshot) {
                    // Handle stream errors
                    if (snapshot.hasError) {
                      print("Error streaming pilgrims: ${snapshot.error}");
                      return Center(
                        child: Text("error_loading_pilgrims".tr),
                      ); // Assuming translation
                    }
                    // Show shimmer while waiting for the initial pilgrim data
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) => _buildShimmerItem(),
                      );
                    }

                    // Process the pilgrim documents
                    final docs =
                        snapshot.data?.docs ?? []; // Handle null data safely

                    // Filter based on search query
                    final filteredDocs =
                        docs.where((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>? ?? {};
                          // Combine names safely, handling potential nulls
                          final name =
                              ("${data['firstName'] ?? ''} ${data['middleName'] ?? ''} ${data['lastName'] ?? ''}")
                                  .trim()
                                  .toLowerCase();
                          final country =
                              (data['country'] ?? '').toString().toLowerCase();
                          // Check if name or country contains the search query
                          return name.contains(searchQuery) ||
                              country.contains(searchQuery);
                        }).toList();

                    // Show message if no pilgrims found (considering search filter)
                    if (filteredDocs.isEmpty) {
                      return Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? "no_pilgrims_found".tr
                              : "no_matching_pilgrims".tr,
                        ),
                      ); // Assuming translation
                    }

                    // Build the list using the filtered documents
                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        // Parse the Pilgrim object safely
                        try {
                          final pilgrim = Pilgrim.fromFirestore(
                            filteredDocs[index],
                          );
                          // Use the dedicated widget for each item
                          return PilgrimListItem(pilgrim: pilgrim);
                        } catch (e) {
                          print("Error parsing Pilgrim at index $index: $e");
                          // Optionally return an error tile
                          return ListTile(
                            title: Text("Error loading pilgrim data"),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Dedicated Widget for Each Pilgrim in the List ---
// This widget manages fetching and displaying the health status for a single pilgrim.
class PilgrimListItem extends StatefulWidget {
  final Pilgrim pilgrim; // Requires a Pilgrim object

  const PilgrimListItem({Key? key, required this.pilgrim}) : super(key: key);

  @override
  State<PilgrimListItem> createState() => _PilgrimListItemState();
}

class _PilgrimListItemState extends State<PilgrimListItem> {
  StreamSubscription? _healthSubscription;
  HealthStatus _healthStatus =
      HealthStatus.loading; // Initial status while fetching

  @override
  void initState() {
    super.initState();
    _listenToHealthData(); // Start listening when the widget is created
  }

  @override
  void dispose() {
    _healthSubscription
        ?.cancel(); // Crucial: Cancel subscription to prevent memory leaks
    super.dispose();
  }

  // Sets up the stream listener for the latest health data for this specific pilgrim
  void _listenToHealthData() {
    _healthSubscription?.cancel(); // Cancel previous listener if exists

    // Query for the latest health data document in the subcollection
    final healthDataQuery = FirebaseFirestore.instance
        .collection('pilgrims')
        .doc(widget.pilgrim.id) // Use this pilgrim's ID
        .collection('health_data') // Access the correct subcollection name
        .orderBy('timestamp', descending: true) // Order by time to get latest
        .limit(1); // Only need the most recent one

    _healthSubscription = healthDataQuery.snapshots().listen(
      (snapshot) {
        if (!mounted)
          return; // Check if widget is still mounted before updating state

        if (snapshot.docs.isNotEmpty) {
          // If data exists, parse it
          final doc = snapshot.docs.first;
          try {
            // Assuming HealthData model with fromFirestore factory exists
            final healthData = HealthData.fromFirestore(doc);
            _updateHealthStatus(
              healthData,
            ); // Check thresholds and update state
          } catch (e) {
            print(
              "Error parsing HealthData for pilgrim ${widget.pilgrim.id}: $e",
            );
            if (mounted) setState(() => _healthStatus = HealthStatus.error);
          }
        } else {
          // No health data found for this pilgrim
          print("No health data found for pilgrim ${widget.pilgrim.id}.");
          if (mounted) setState(() => _healthStatus = HealthStatus.unknown);
        }
      },
      onError: (error) {
        // Handle errors during listening (e.g., permissions)
        print(
          "Error listening to health data for pilgrim ${widget.pilgrim.id}: $error",
        );
        if (mounted) setState(() => _healthStatus = HealthStatus.error);
      },
    );
  }

  // Checks the fetched health data against defined thresholds
  void _updateHealthStatus(HealthData data) {
    bool isAbnormal = false;

    // Check each metric against its threshold
    if (data.temperature > MAX_TEMPERATURE ||
        data.temperature < MIN_TEMPERATURE) {
      isAbnormal = true;
    } else if (data.heartRate > MAX_HEART_RATE ||
        data.heartRate < MIN_HEART_RATE) {
      // Use else if if only one condition should trigger 'abnormal',
      // or keep separate ifs if multiple can make it abnormal.
      // Let's assume any single abnormality is enough for now.
      isAbnormal = true;
    } else if (data.bloodOxygen < MIN_BLOOD_OXYGEN) {
      isAbnormal = true;
    }

    // Update the state to reflect the finding
    if (mounted) {
      setState(() {
        _healthStatus =
            isAbnormal ? HealthStatus.abnormal : HealthStatus.normal;
      });
    }
  }

  // Builds the visual health status indicator (icon + color)
  Widget _buildHealthStatusIndicator() {
    Color color;
    IconData iconData;

    switch (_healthStatus) {
      case HealthStatus.loading:
        color = Colors.blueGrey.shade300;
        iconData = Icons.hourglass_empty_rounded;
        break;
      case HealthStatus.normal:
        color = Colors.green.shade600;
        iconData = Icons.check_circle_outline_rounded;
        break;
      case HealthStatus.abnormal:
        color = Colors.red.shade600;
        iconData =
            Icons.error_outline_rounded; // Or Icons.warning_amber_rounded
        break;
      case HealthStatus.error:
      case HealthStatus.unknown:
      default:
        color = Colors.grey.shade500;
        iconData = Icons.help_outline_rounded;
        break;
    }
    // Tooltip provides text context for the icon
    return Tooltip(
      message:
          _healthStatus.toString().split('.').last ?? _healthStatus.toString(),
      child: Icon(iconData, color: color, size: 20), // Slightly larger icon
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine avatar image provider
    ImageProvider avatarProvider;
    if (widget.pilgrim.avatar != null && widget.pilgrim.avatar!.isNotEmpty) {
      try {
        avatarProvider = MemoryImage(base64Decode(widget.pilgrim.avatar!));
      } catch (e) {
        print("Error decoding avatar: $e");
        avatarProvider = const AssetImage("assets/avatar.png");
      } // Fallback image
    } else {
      avatarProvider = const AssetImage("assets/avatar.png");
    } // Default image

    // Build the ListTile within a Card
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: avatarProvider,
          backgroundColor: Colors.grey.shade200, // Background while image loads
        ),
        title: Text(
          widget.pilgrim.fullName.isNotEmpty
              ? widget.pilgrim.fullName
              : "Unnamed Pilgrim",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ), // Adjusted weight
        ),
        subtitle: Padding(
          // Add padding for spacing
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                widget.pilgrim.country.isNotEmpty
                    ? widget.pilgrim.country
                    : 'N/A',
                style: TextStyle(fontSize: 13),
              ), // Slightly larger font
              const SizedBox(width: 12), // Increased spacing
              Icon(Icons.cake_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text("${widget.pilgrim.age} yrs", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        trailing: Row(
          // Use Row for status indicator and arrow
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHealthStatusIndicator(), // Display the health status icon
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ), // Navigation arrow
          ],
        ),
        onTap: () {
          // Navigate to the specific pilgrim's profile screen
          Get.to(() => PilgramProfile(pilgrim: widget.pilgrim));
        },
      ),
    );
  }
}

// --- Helper Models (Should be in your models.dart) ---
// Example: Ensure these match your actual models

// class Pilgrim { ... constructor ... fromFirestore ... fullName ... }
// class HealthData { ... constructor ... fromFirestore ... }
// class Campaign { ... constructor ... fromFirestore ... }

// --- Safe Parsing Helpers (if not defined elsewhere) ---
// Included here for completeness if not imported
int parseInt(dynamic value, [int defaultValue = 0]) {
  // Default to 0 if unknown
  if (value == null) return defaultValue;
  try {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
  } catch (_) {}
  return defaultValue;
}

double parseDouble(dynamic value, [double defaultValue = 0.0]) {
  // Default to 0.0 if unknown
  if (value == null) return defaultValue;
  try {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
  } catch (_) {}
  return defaultValue;
}

// Helper for String capitalization
extension StringExtension on String {
  String? capitalizeFirst() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
