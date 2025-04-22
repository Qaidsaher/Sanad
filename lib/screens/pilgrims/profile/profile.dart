import 'dart:convert';

import 'package:autoimagepaper/screens/auth/login.dart';
import 'package:autoimagepaper/screens/pilgrims/pilgrimNotifications.dart';
import 'package:autoimagepaper/screens/pilgrims/profile/setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper function to safely parse an integer from a dynamic value.
/// Returns defaultValue if conversion fails.
int parseInt(dynamic value, [int defaultValue = 72]) {
  try {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
  } catch (_) {}
  return defaultValue;
}

/// Helper function to safely parse a double from a dynamic value.
/// Returns defaultValue if conversion fails.
double parseDouble(dynamic value, [double defaultValue = 36.7]) {
  try {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
  } catch (_) {}
  return defaultValue;
}

class PilgrimProfileScreen extends StatefulWidget {
  const PilgrimProfileScreen({Key? key}) : super(key: key);

  @override
  _PilgrimProfileScreenState createState() => _PilgrimProfileScreenState();
}

class _PilgrimProfileScreenState extends State<PilgrimProfileScreen> {
  DateTime? _lastNotificationTime; // Store time of the last notification

  /// Checks whether health values are abnormal based on provided thresholds.
  bool _isHealthAbnormal(
      int heartRate, double temperature, double bloodOxygen) {
    return (heartRate < 60 || heartRate > 100) ||
        (temperature < 35.0 || temperature > 37.5) ||
        (bloodOxygen < 95.0);
  }

  /// Notifies the supervisor that the pilgrim's health parameters are abnormal.
  Future<void> _notifySupervisor() async {
    print("Notifying supervisor due to abnormal health values.");
    Get.snackbar(
      "abnormal_health_alert".tr,
      "notification_sent_to_supervisor".tr,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
    // Record the notification time to prevent frequent notifications.
    setState(() {
      _lastNotificationTime = DateTime.now();
    });
  }

  /// Function to be called whenever health data changes.
  /// It parses the new values and triggers a notification if they are abnormal.
  void _onHealthDataChanged(DocumentSnapshot? healthData) {
    if (healthData == null) return;
    final int heartRate = parseInt(healthData.get('heartRate'), 72);
    final double temperature = parseDouble(healthData.get('temperature'), 36.7);
    final double bloodOxygen = parseDouble(healthData.get('bloodOxygen'), 98.0);
    if (_isHealthAbnormal(heartRate, temperature, bloodOxygen)) {
      final now = DateTime.now();
      if (_lastNotificationTime == null ||
          now.difference(_lastNotificationTime!) > const Duration(minutes: 1)) {
        _notifySupervisor();
      }
    }
  }

  /// Shows a confirmation dialog and deletes the current account if confirmed.
  Future<void> _deleteAccount(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("delete_account".tr),
        content: Text("delete_account_confirm".tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("cancel".tr),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text("delete".tr),
          ),
        ],
      ),
    );
    if (confirmed) {
      try {
        await FirebaseAuth.instance.currentUser!.delete();
        Get.offAll(() => const LoginScreen());
        Get.snackbar("account_deleted".tr, "account_deleted_msg".tr,
            backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar("delete_error".tr, e.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  /// Returns a widget to display a health or device info item.
  Widget _gridItem(
      BuildContext context, IconData icon, String label, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(value,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return const Scaffold(
        body: Center(child: Text("No user signed in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("pilgrim_profile".tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Get.to(() => const NotificationsScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
      // Outer StreamBuilder: listens for changes to the pilgrim document.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pilgrims')
            .where('userId', isEqualTo: authUser.uid)
            .limit(1)
            .snapshots(),
        builder: (context, pilgrimSnapshot) {
          if (pilgrimSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!pilgrimSnapshot.hasData || pilgrimSnapshot.data!.docs.isEmpty) {
            return Center(child: Text("no_profile_data".tr));
          }
          final DocumentSnapshot pilgrimDoc = pilgrimSnapshot.data!.docs.first;
          final firstName = pilgrimDoc.get('firstName') ?? '';
          final middleName = pilgrimDoc.get('middleName') ?? '';
          final lastName = pilgrimDoc.get('lastName') ?? '';
          final fullName = "$firstName $middleName $lastName".trim();

          // Determine the avatar image.
          ImageProvider avatarProvider;
          final storedAvatar = pilgrimDoc.get('avatar') ?? '';
          if (storedAvatar is String && storedAvatar.isNotEmpty) {
            try {
              avatarProvider = MemoryImage(base64Decode(storedAvatar));
            } catch (e) {
              avatarProvider = const AssetImage("assets/avatar.png");
            }
          } else if (authUser.photoURL != null) {
            avatarProvider = NetworkImage(authUser.photoURL!);
          } else {
            avatarProvider = const AssetImage("assets/avatar.png");
          }

          // Inner StreamBuilder: listens for changes in the latest health_data document.
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pilgrims')
                .doc(pilgrimDoc.id)
                .collection('health_data')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, healthSnapshot) {
              DocumentSnapshot? healthData;
              if (healthSnapshot.hasData &&
                  healthSnapshot.data!.docs.isNotEmpty) {
                healthData = healthSnapshot.data!.docs.first;
                // Call our function to handle the new health data.
                _onHealthDataChanged(healthData);
              }
              // Safely parse health values.
              final int heartRate = healthData != null
                  ? parseInt(healthData.get('heartRate'), 72)
                  : 72;
              final double temperature = healthData != null
                  ? parseDouble(healthData.get('temperature'), 36.7)
                  : 36.7;
              final double bloodOxygen = healthData != null
                  ? parseDouble(healthData.get('bloodOxygen'), 98.0)
                  : 98.0;
              // Parse GPS location with fallback.
              GeoPoint location = const GeoPoint(21.4225, 39.8262);
              if (healthData != null) {
                try {
                  final dynamic loc = healthData.get('location');
                  if (loc is GeoPoint) {
                    location = loc;
                  }
                } catch (_) {
                  location = const GeoPoint(21.4225, 39.8262);
                }
              }
              final String gpsLocationText = (location.latitude == 21.4225 &&
                      location.longitude == 39.8262)
                  ? "Mecca, Saudi Arabia"
                  : "Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}";

              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: avatarProvider,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName.isNotEmpty ? fullName : "N/A",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      authUser.email ?? "N/A",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Divider(
                        thickness: 1.5, color: Theme.of(context).dividerColor),
                    const SizedBox(height: 12),
                    Text("health_info".tr,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.start),
                    const SizedBox(height: 12),
                    // Display health data in a grid.
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _gridItem(context, Icons.favorite, "heart_rate".tr,
                            "$heartRate bpm"),
                        _gridItem(context, Icons.thermostat, "temperature".tr,
                            "${temperature.toStringAsFixed(1)}°C"),
                        _gridItem(context, Icons.bloodtype, "blood_oxygen".tr,
                            "${bloodOxygen.toStringAsFixed(0)}%"),
                        _gridItem(context, Icons.location_on, "gps_location".tr,
                            gpsLocationText),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(
                        thickness: 1.5, color: Theme.of(context).dividerColor),
                    const SizedBox(height: 12),
                    Text("device_info".tr,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.start),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.battery_charging_full,
                                color: Theme.of(context).primaryColor),
                            title: Text("battery_level".tr),
                            trailing: const Text("85%"),
                          ),
                          ListTile(
                            leading: Icon(Icons.bluetooth_connected,
                                color: Theme.of(context).primaryColor),
                            title: Text("connection_status".tr),
                            trailing: const Text("Connected"),
                          ),
                          ListTile(
                            leading: Icon(Icons.watch,
                                color: Theme.of(context).primaryColor),
                            title: Text("device_id".tr),
                            trailing: const Text("HC-001234"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(() => const LoginScreen());
                      },
                      icon: const Icon(Icons.logout),
                      label: Text("logout".tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _deleteAccount(context),
                      icon: const Icon(Icons.delete_forever),
                      label: Text("delete_account".tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
