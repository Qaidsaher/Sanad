import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad/models/models.dart'; // Contains the Pilgrim and Campaign models.
import 'package:shimmer/shimmer.dart';

/// Safely parses an integer; returns [defaultValue] if conversion fails.
int parseInt(dynamic value, [int defaultValue = 75]) {
  try {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
  } catch (_) {}
  return defaultValue;
}

/// Safely parses a double; returns [defaultValue] if conversion fails.
double parseDouble(dynamic value, [double defaultValue = 36.5]) {
  try {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
  } catch (_) {}
  return defaultValue;
}

class PilgramProfile extends StatefulWidget {
  final Pilgrim pilgrim;
  const PilgramProfile({Key? key, required this.pilgrim}) : super(key: key);

  @override
  _PilgramProfileState createState() => _PilgramProfileState();
}

class _PilgramProfileState extends State<PilgramProfile> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Show shimmer placeholder for 4 seconds.
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  /// A helper widget to create an info tile.
  Widget _infoTile(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor, size: 30),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  /// Fetches the campaign data using the pilgrim's campaignId.
  Future<Campaign?> _getCampaign() async {
    if (widget.pilgrim.campaignId.isEmpty) return null;
    DocumentSnapshot doc =
        await FirebaseFirestore.instance
            .collection('campaigns')
            .doc(widget.pilgrim.campaignId)
            .get();
    if (doc.exists) {
      return Campaign.fromFirestore(doc);
    }
    return null;
  }

  /// Builds a shimmer placeholder for the entire profile page.
  Widget _buildShimmerScreen(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: const CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(height: 24, width: 200, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(height: 16, width: 150, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          // Personal Information Card Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(height: 120, padding: const EdgeInsets.all(16)),
            ),
          ),
          const SizedBox(height: 16),
          // Campaign Information Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(height: 100, padding: const EdgeInsets.all(16)),
            ),
          ),
          const SizedBox(height: 16),
          // Health Information Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(height: 120, padding: const EdgeInsets.all(16)),
            ),
          ),
          const SizedBox(height: 16),
          // Device Information Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(height: 80, padding: const EdgeInsets.all(16)),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a Health Information Card with realtime updates.
  Widget _buildHealthInfoCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('pilgrims')
              .doc(widget.pilgrim.id)
              .collection('health_data')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .snapshots(),
      builder: (context, snapshot) {
        int heartRate = 75;
        double temperature = 36.5;
        double bloodOxygen = 98.0;
        GeoPoint location = const GeoPoint(21.4225, 39.8262);
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          try {
            final doc = snapshot.data!.docs.first;
            heartRate = parseInt(doc.get('heartRate'), 75);
            temperature = parseDouble(doc.get('temperature'), 36.5);
            bloodOxygen = parseDouble(doc.get('bloodOxygen'), 98.0);
            final dynamic loc = doc.get('location');
            if (loc is GeoPoint) {
              location = loc;
            }
          } catch (e) {
            // In case of error, the default values are used.
          }
        }
        final String gpsLocationText =
            (location.latitude == 21.4225 && location.longitude == 39.8262)
                ? "Mecca, Saudi Arabia"
                : "Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}";
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              _infoTile(
                Icons.favorite,
                "heart_rate".tr,
                "$heartRate bpm",
                context,
              ),
              _infoTile(
                Icons.thermostat,
                "temperature".tr,
                "${temperature.toStringAsFixed(1)}°C",
                context,
              ),
              _infoTile(
                Icons.bloodtype,
                "blood_oxygen".tr,
                "${bloodOxygen.toStringAsFixed(0)}%",
                context,
              ),
              _infoTile(
                Icons.location_on,
                "gps_location".tr,
                gpsLocationText,
                context,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the avatar image from the Pilgrim model.
    ImageProvider avatarProvider;
    if (widget.pilgrim.avatar != null && widget.pilgrim.avatar!.isNotEmpty) {
      try {
        avatarProvider = MemoryImage(base64Decode(widget.pilgrim.avatar!));
      } catch (e) {
        avatarProvider = const AssetImage("assets/avatar.png");
      }
    } else {
      avatarProvider = const AssetImage("assets/avatar.png");
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("pilgrim_profile".tr)),
        body: _buildShimmerScreen(context),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("pilgrim_profile".tr)),
      body: FutureBuilder<Campaign?>(
        future: _getCampaign(),
        builder: (context, campaignSnapshot) {
          final campaign = campaignSnapshot.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: avatarProvider,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    widget.pilgrim.fullName.isNotEmpty
                        ? widget.pilgrim.fullName
                        : "N/A",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    widget.pilgrim.country,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                // Personal & Contact Information Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _infoTile(
                        Icons.flag,
                        "country".tr,
                        widget.pilgrim.country,
                        context,
                      ),
                      _infoTile(
                        Icons.cake,
                        "age".tr,
                        "${widget.pilgrim.age} yrs",
                        context,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Campaign Information Section
                Text(
                  "campaign_info".tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                campaignSnapshot.connectionState == ConnectionState.waiting
                    ? _buildShimmerScreen(context)
                    : campaign != null
                    ? Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _infoTile(
                            Icons.campaign,
                            "campaign".tr,
                            "${campaign.campaignName} (${campaign.campaignYear})",
                            context,
                          ),
                          _infoTile(
                            Icons.phone,
                            "campaign_phone".tr,
                            campaign.phone,
                            context,
                          ),
                        ],
                      ),
                    )
                    : Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "no_campaign_data".tr,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                // Health Information Section with Realtime Updates
                Text(
                  "health_info".tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHealthInfoCard(context),
                const SizedBox(height: 16),
                // Device Information Section
                Text(
                  "device_info".tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _infoTile(
                        Icons.battery_charging_full,
                        "battery_level".tr,
                        "85%",
                        context,
                      ),
                      _infoTile(
                        Icons.bluetooth_connected,
                        "connection_status".tr,
                        "Connected",
                        context,
                      ),
                      _infoTile(
                        Icons.watch,
                        "device_id".tr,
                        "HC-1234",
                        context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
