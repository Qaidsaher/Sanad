import 'dart:async'; // Import async
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad/models/models.dart'; // Contains the Pilgrim and Campaign models.
import 'package:shimmer/shimmer.dart';

// --- Health Threshold Constants ---
// Define these thresholds for checking health data
const double MAX_TEMPERATURE = 38.5; // degrees Celsius
const double MIN_TEMPERATURE = 35.0; // degrees Celsius
const int MAX_HEART_RATE =
    125; // beats per minute (adjust based on context, e.g., resting vs active)
const int MIN_HEART_RATE = 50; // beats per minute
const double MIN_BLOOD_OXYGEN = 92.0; // percentage

// --- Health Status Enum ---
// Represents the status of an individual health metric
enum HealthStatus { loading, normal, abnormal, error, unknown }

// --- Safe Parsing Helpers ---
// (Keep the parseInt and parseDouble functions as they were)
int parseInt(dynamic value, [int defaultValue = 0]) {
  // Default to 0
  if (value == null) return defaultValue;
  try {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
  } catch (_) {}
  return defaultValue;
}

double parseDouble(dynamic value, [double defaultValue = 0.0]) {
  // Default to 0.0
  if (value == null) return defaultValue;
  try {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
  } catch (_) {}
  return defaultValue;
}

// --- Pilgrim Profile Screen ---
class PilgramProfile extends StatefulWidget {
  // ** IMPORTANT: Assumes constructor takes Pilgrim object **
  // If navigating with only pilgrimId, this screen needs modification
  // to fetch the Pilgrim data first in initState.
  final Pilgrim pilgrim;
  const PilgramProfile({Key? key, required this.pilgrim}) : super(key: key);

  @override
  _PilgramProfileState createState() => _PilgramProfileState();
}

class _PilgramProfileState extends State<PilgramProfile> {
  // Use FutureBuilder for one-time fetch of Campaign data
  late Future<Campaign?> _campaignFuture;

  @override
  void initState() {
    super.initState();
    // Fetch campaign data once when the screen initializes
    _campaignFuture = _getCampaign();
    // Note: Loading state for shimmer is removed as FutureBuilder/StreamBuilder handle it.
  }

  /// Generic Info Tile (used for non-health data)
  Widget _infoTile(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 28,
      ), // Use theme color
      title: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ), // Adjusted style
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ), // Adjusted style
      dense: true, // Make tiles slightly more compact
    );
  }

  /// ** Specialized Tile for Health Info with Status Indication **
  Widget _healthInfoTile({
    required IconData icon,
    required String label,
    required num? value, // Make value nullable
    required String unit,
    required HealthStatus status,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    Color statusColor;
    String displayValue;

    // Determine color and display string based on status and value
    switch (status) {
      case HealthStatus.loading:
        statusColor = Colors.grey.shade400;
        displayValue = "..."; // Indicate loading
        break;
      case HealthStatus.normal:
        statusColor = Colors.green.shade600; // Green for normal
        displayValue =
            value != null
                ? "${(value is double) ? value.toStringAsFixed(1) : value} $unit"
                : "-- $unit";
        break;
      case HealthStatus.abnormal:
        statusColor =
            theme.colorScheme.error; // Use theme error color for abnormal
        displayValue =
            value != null
                ? "${(value is double) ? value.toStringAsFixed(1) : value} $unit"
                : "-- $unit";
        break;
      case HealthStatus.error:
        statusColor =
            Colors.orange.shade700; // Orange/Yellow for error fetching
        displayValue = "Error";
        break;
      case HealthStatus.unknown:
      default:
        statusColor = Colors.grey.shade500;
        displayValue = "-- $unit"; // Default display for unknown/null value
        break;
    }

    return ListTile(
      leading: Icon(
        icon,
        color: statusColor,
        size: 28,
      ), // Icon color reflects status
      title: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        displayValue,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          // ** Optionally make value color also reflect status **
          color:
              (status == HealthStatus.abnormal || status == HealthStatus.error)
                  ? statusColor
                  : theme.colorScheme.onSurface,
        ),
      ),
      dense: true,
    );
  }

  /// Fetches the campaign data using the pilgrim's campaignId.
  Future<Campaign?> _getCampaign() async {
    if (widget.pilgrim.campaignId.isEmpty) {
      print("Pilgrim has no campaign ID.");
      return null;
    }
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('campaigns') // Ensure correct collection name
              .doc(widget.pilgrim.campaignId)
              .get();
      if (doc.exists) {
        // Assuming Campaign.fromFirestore exists in your models
        return Campaign.fromFirestore(doc);
      } else {
        print("Campaign document ${widget.pilgrim.campaignId} not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching campaign ${widget.pilgrim.campaignId}: $e");
      return null; // Return null on error
    }
  }

  /// Builds a Health Information Card with realtime updates and status indicators.
  Widget _buildHealthInfoCard(BuildContext context) {
    return Card(
      // Wrap StreamBuilder in a Card
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // More rounded corners
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ), // Padding inside card
        child: StreamBuilder<QuerySnapshot>(
          // Stream for the latest health data document
          stream:
              FirebaseFirestore.instance
                  .collection('pilgrims')
                  .doc(widget.pilgrim.id) // Specific pilgrim
                  .collection('health_data') // Correct subcollection name
                  .orderBy('timestamp', descending: true) // Latest first
                  .limit(1) // Only the very latest
                  .snapshots(), // Listen to real-time updates
          builder: (context, snapshot) {
            // --- Default values and initial status ---
            HealthStatus hrStatus = HealthStatus.loading;
            HealthStatus tempStatus = HealthStatus.loading;
            HealthStatus boStatus = HealthStatus.loading;
            int? heartRate;
            double? temperature;
            double? bloodOxygen;
            GeoPoint? location; // Make location nullable

            // --- Handle stream states ---
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              // Still loading initial data
              hrStatus = tempStatus = boStatus = HealthStatus.loading;
            } else if (snapshot.hasError) {
              // Error fetching data
              print("Error in health data stream: ${snapshot.error}");
              hrStatus = tempStatus = boStatus = HealthStatus.error;
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Stream active, but no documents found
              hrStatus = tempStatus = boStatus = HealthStatus.unknown;
            } else {
              // Data received, parse and check thresholds
              try {
                final doc = snapshot.data!.docs.first;
                final data =
                    doc.data() as Map<String, dynamic>? ?? {}; // Safe access

                // Parse values safely
                heartRate = parseInt(
                  data['heartRate'],
                  0,
                ); // Use 0 or null default? Let's use null
                temperature = parseDouble(
                  data['temperature'],
                  -1,
                ); // Use invalid temp as default
                bloodOxygen = parseDouble(
                  data['bloodOxygen'],
                  -1,
                ); // Use invalid O2 as default
                final dynamic locData = data['location'];
                if (locData is GeoPoint) location = locData;

                // Determine status for each metric if value exists
                hrStatus =
                    (heartRate == 0) // Check if default was used
                        ? HealthStatus.unknown
                        : (heartRate! > MAX_HEART_RATE ||
                            heartRate < MIN_HEART_RATE)
                        ? HealthStatus.abnormal
                        : HealthStatus.normal;

                tempStatus =
                    (temperature == -1)
                        ? HealthStatus.unknown
                        : (temperature! > MAX_TEMPERATURE ||
                            temperature < MIN_TEMPERATURE)
                        ? HealthStatus.abnormal
                        : HealthStatus.normal;

                boStatus =
                    (bloodOxygen == -1)
                        ? HealthStatus.unknown
                        : (bloodOxygen! < MIN_BLOOD_OXYGEN)
                        ? HealthStatus.abnormal
                        : HealthStatus.normal;
              } catch (e) {
                // Error during parsing
                print("Error parsing latest health data: $e");
                hrStatus = tempStatus = boStatus = HealthStatus.error;
              }
            }

            // --- Build the Column of Health Info Tiles ---
            // Determine GPS text safely
            String gpsLocationText = "Not Available";
            if (location != null) {
              gpsLocationText =
                  (location.latitude == 21.4225 &&
                          location.longitude ==
                              39.8262) // Check for default Mecca coords
                      ? "Mecca, Saudi Arabia (Default)"
                      : "Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}";
            }

            return Column(
              children: [
                _healthInfoTile(
                  icon: Icons.favorite_border_outlined, // Use outline icons
                  label: "heart_rate".tr,
                  value: heartRate, // Pass nullable value
                  unit: "bpm",
                  status: hrStatus,
                  context: context,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.green.shade600,
                ), // Add dividers
                _healthInfoTile(
                  icon: Icons.thermostat_outlined,
                  label: "temperature".tr,
                  value: temperature, // Pass nullable value
                  unit: "°C",
                  status: tempStatus,
                  context: context,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.green.shade600,
                ),
                _healthInfoTile(
                  icon: Icons.air_outlined, // Updated icon
                  label: "blood_oxygen".tr,
                  value: bloodOxygen, // Pass nullable value
                  unit: "%",
                  status: boStatus,
                  context: context,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.green.shade600,
                ),
                // Use generic info tile for GPS - no status check needed here
                _infoTile(
                  Icons.location_on_outlined,
                  "gps_location".tr,
                  gpsLocationText,
                  context,
                ),
              ],
            );
          },
        ),
      ),
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
      }
    } else {
      avatarProvider = const AssetImage("assets/avatar.png");
    }

    final theme = Theme.of(context); // Get theme for consistent styling

    return Scaffold(
      appBar: AppBar(title: Text("pilgrim_profile".tr)), // Assuming translation
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center content horizontally
          children: [
            // --- Pilgrim Header ---
            CircleAvatar(
              radius: 60,
              backgroundImage: avatarProvider,
              backgroundColor: Colors.grey.shade200,
            ), // Slightly smaller avatar
            const SizedBox(height: 16),
            Text(
              widget.pilgrim.fullName.isNotEmpty
                  ? widget.pilgrim.fullName
                  : "Unnamed Pilgrim",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.pilgrim.country.isNotEmpty
                  ? widget.pilgrim.country
                  : "Country not specified",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24), // More spacing before cards
            // --- Personal Info Card ---
            _buildSectionTitle(
              "personal_info".tr,
              context,
            ), // Section title helper
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                // Add padding inside card
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _infoTile(
                      Icons.flag_outlined,
                      "country".tr,
                      widget.pilgrim.country.isNotEmpty
                          ? widget.pilgrim.country
                          : "N/A",
                      context,
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.green.shade600,
                    ),
                    _infoTile(
                      Icons.cake_outlined,
                      "age".tr,
                      "${widget.pilgrim.age > 0 ? widget.pilgrim.age : '--'} yrs",
                      context,
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.green.shade600,
                    ),
                    _infoTile(
                      Icons.person_outline,
                      "gender".tr,
                      widget.pilgrim.gender.isNotEmpty
                          ? widget.pilgrim.gender
                          : "N/A",
                      context,
                    ), // Assuming gender exists
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Campaign Info Card ---
            _buildSectionTitle("campaign_info".tr, context),
            FutureBuilder<Campaign?>(
              // Use FutureBuilder for campaign
              future:
                  _campaignFuture, // Use the future initialized in initState
              builder: (context, campaignSnapshot) {
                if (campaignSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  // Shimmer for campaign card
                  return _buildShimmerCard(height: 120);
                }
                final campaign = campaignSnapshot.data;
                if (campaign == null) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "no_campaign_data".tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                // Display Campaign Card
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        _infoTile(
                          Icons.group_work_outlined,
                          "campaign".tr,
                          "${campaign.campaignName} (${campaign.campaignYear})",
                          context,
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Colors.green.shade600,
                        ),
                        _infoTile(
                          Icons.phone_outlined,
                          "campaign_phone".tr,
                          campaign.phone.isNotEmpty ? campaign.phone : "N/A",
                          context,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // --- Health Info Card ---
            _buildSectionTitle("health_info".tr, context),
            _buildHealthInfoCard(context), // Use the StreamBuilder card
            const SizedBox(height: 20),

            // --- Device Info Card ---
            _buildSectionTitle("device_info".tr, context),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    // Assuming braceletId exists on pilgrim model
                    _infoTile(
                      Icons.watch_outlined,
                      "Bracelet ID",
                      widget.pilgrim.braceletId.isNotEmpty
                          ? widget.pilgrim.braceletId
                          : "N/A",
                      context,
                    ),
                    // Hardcoded examples below - Replace with real data if available
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.green.shade600,
                    ),
                    _infoTile(
                      Icons.battery_charging_full_outlined,
                      "battery_level".tr,
                      "85%",
                      context,
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.green.shade600,
                    ),
                    _infoTile(
                      Icons.bluetooth_connected_outlined,
                      "connection_status".tr,
                      "Connected",
                      context,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Bottom padding
          ],
        ),
      ),
    );
  }

  // Helper to build section titles consistently
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0), // Add top padding
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ), // Use titleLarge
      ),
    );
  }

  // Helper to build a generic shimmer card placeholder
  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(height: height), // Use SizedBox for height
      ),
    );
  }

  // --- REMOVED _buildShimmerScreen as individual card shimmers are used ---
} // End of _PilgramProfileState

// --- Ensure Models are Defined/Imported ---
// Example (should be in your models.dart or similar):
// class Pilgrim { ... constructor ... fromFirestore ... fullName ... campaignId ... braceletId ... }
// class HealthData { ... constructor ... fromFirestore ... temperature, heartRate, bloodOxygen ... }
// class Campaign { ... constructor ... fromFirestore ... campaignName, campaignYear, phone ... }

// Helper for String capitalization (if not defined elsewhere)
extension StringExtension on String {
  String? capitalizeFirst() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
