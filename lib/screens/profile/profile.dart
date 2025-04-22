import 'package:autoimagepaper/screens/auth/login.dart';
import 'package:autoimagepaper/screens/notifications/notifications_screen.dart';
import 'package:autoimagepaper/screens/profile/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("profile".tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Get.to(() => const NotificationsScreen()),
            // onPressed: () => Get.to(() => ProfileScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 70,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage("assets/avatar.png") as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? "N/A",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              user?.email ?? "N/A",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Divider(thickness: 1.5, color: Theme.of(context).dividerColor),
            const SizedBox(height: 12),

            Text("health_info".tr,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.start),
            const SizedBox(height: 12),

            // Grid for biological information
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _gridItem(context, Icons.favorite, "heart_rate".tr, "72 bpm"),
                _gridItem(
                    context, Icons.thermostat, "temperature".tr, "36.7°C"),
                _gridItem(context, Icons.bloodtype, "blood_oxygen".tr, "98%"),
                _gridItem(context, Icons.location_on, "gps_location".tr,
                    "Mecca, Saudi Arabia"),
              ],
            ),

            const SizedBox(height: 20),

            Divider(thickness: 1.5, color: Theme.of(context).dividerColor),
            const SizedBox(height: 12),

            Text("device_info".tr,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.start),
            const SizedBox(height: 12),

            // Card for device information
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
                    trailing: Text("85%"),
                  ),
                  ListTile(
                    leading: Icon(Icons.bluetooth_connected,
                        color: Theme.of(context).primaryColor),
                    title: Text("connection_status".tr),
                    trailing: Text("Connected"),
                  ),
                  ListTile(
                    leading: Icon(Icons.watch,
                        color: Theme.of(context).primaryColor),
                    title: Text("device_id".tr),
                    trailing: Text("HC-001234"),
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
      ),
    );
  }
}
