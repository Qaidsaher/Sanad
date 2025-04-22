import 'dart:math';

import 'package:autoimagepaper/screens/admins/campaig.dart';
import 'package:autoimagepaper/screens/admins/health_notifications.dart';
import 'package:autoimagepaper/screens/admins/medical_services.dart';
import 'package:autoimagepaper/screens/admins/settings.dart';
import 'package:autoimagepaper/screens/admins/users_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;

  // Random statistics for demonstration
  int emergencyCount = 0;
  int warningCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animationController.forward();

    // Generate random stats
    emergencyCount = Random().nextInt(10);
    warningCount = Random().nextInt(15);

    // Simulate a loading delay for 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Account menu: displays logout and delete account actions using a settings icon.
  Widget _buildAccountMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "logout",
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: Text("logout".tr),
          ),
        ),
        PopupMenuItem(
          value: "delete",
          child: ListTile(
            leading: const Icon(Icons.delete_forever),
            title: Text("delete_account".tr),
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == "logout") {
          await FirebaseAuth.instance.signOut();
          Get.offAllNamed('/login');
        } else if (value == "delete") {
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
                      backgroundColor: Colors.redAccent),
                  child: Text("delete".tr),
                ),
              ],
            ),
          );
          if (confirmed) {
            try {
              await FirebaseAuth.instance.currentUser!.delete();
              Get.offAllNamed('/login');
              Get.snackbar("account_deleted".tr, "account_deleted_msg".tr,
                  backgroundColor: Colors.green, colorText: Colors.white);
            } catch (e) {
              Get.snackbar("delete_error".tr, e.toString(),
                  backgroundColor: Colors.red, colorText: Colors.white);
            }
          }
        }
      },
    );
  }

  // Health stats card with emergency and warning counts.
  Widget _buildHealthStatsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statusStat(context, Icons.error, "emergency".tr, emergencyCount),
            _statusStat(context, Icons.warning, "warning".tr, warningCount),
          ],
        ),
      ),
    );
  }

  Widget _statusStat(
      BuildContext context, IconData icon, String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: icon == Icons.error ? Colors.red : Colors.orange,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text("$count", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  // Grid card for each admin dashboard option.
  Widget _adminCard(BuildContext context, IconData icon, String label,
      VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  // Shimmer placeholder for grid items.
  Widget _buildGridShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 50, height: 50, color: Colors.white),
              const SizedBox(height: 10),
              Container(width: 80, height: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer grid for admin cards.
  Widget _buildGridShimmer() {
    return GridView.count(
      key: const ValueKey('gridShimmer'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: List.generate(4, (index) => _buildGridShimmerItem()),
    );
  }

  // Shimmer placeholder for health stats card.
  Widget _buildHealthStatsShimmer(BuildContext context) {
    return Shimmer.fromColors(
      key: const ValueKey('healthStatsShimmer'),
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        child: Container(
          height: 80,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("admin_panel".tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(const SettingsScreen()),
          ),
          _buildAccountMenu(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isLoading
                    ? _buildGridShimmer()
                    : GridView.count(
                        key: const ValueKey('gridContent'),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _adminCard(context, Icons.people, "pilgrims".tr, () {
                            Get.to(() => const UsersListPage());
                          }, Colors.blue),
                          _adminCard(context, Icons.health_and_safety,
                              "health_notifications".tr, () {
                            Get.to(() => const HealthNotificationsPage());
                          }, Colors.red),
                          _adminCard(context, Icons.medical_services,
                              "medical_services".tr, () {
                            Get.to(() => MedicalServicesPage());
                          }, Colors.green),
                          _adminCard(
                              context, Icons.devices, "device_management".tr,
                              () {
                            Get.to(() => const SupervisorCampaignsPage());
                          }, Colors.orange),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isLoading
                    ? _buildHealthStatsShimmer(context)
                    : _buildHealthStatsCard(context),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
