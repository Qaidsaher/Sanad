import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad/screens/admins/settings.dart';
import 'package:sanad/screens/auth/login.dart';
// Make sure this import points to your actual campaigns page
import 'package:sanad/screens/supervisors/campaign.dart';
import 'package:sanad/screens/supervisors/health_notifications.dart';
import 'package:sanad/screens/supervisors/medical_services.dart';
import 'package:sanad/screens/supervisors/pilgrams.dart';
import 'package:shimmer/shimmer.dart';

class SupervisorHomePage extends StatefulWidget {
  const SupervisorHomePage({Key? key}) : super(key: key);

  @override
  State<SupervisorHomePage> createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage>
    with SingleTickerProviderStateMixin {
  // Removed animation controller as it wasn't actively used beyond initial forward
  // If you need animations, you can re-add it.
  bool _isLoading = true;
  int emergencyCount = 0;
  int warningCount = 0;
  final Random _random = Random(); // Reuse Random instance

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Function to simulate loading and set initial data
  Future<void> _loadInitialData() async {
    // Set initial counts
    _updateCountsInternal();

    // Simulate network delay or data fetching
    await Future.delayed(const Duration(seconds: 2)); // Reduced delay slightly

    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to update counts (can be called externally if needed)
  void _updateCounts() {
    if (mounted) {
      setState(() {
        _updateCountsInternal();
      });
      // Optional: Show a snackbar feedback
      Get.snackbar(
        "Stats Updated",
        "Emergency and Warning counts refreshed.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // Internal helper to avoid duplicating random logic
  void _updateCountsInternal() {
    emergencyCount = _random.nextInt(10); // Max 9 emergencies
    warningCount = _random.nextInt(15); // Max 14 warnings
  }

  // --- Menu ---
  Widget _buildAccountMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.account_circle_outlined,
        size: 28,
      ), // More modern user icon
      tooltip: "Account Options", // Accessibility
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: "logout",
              child: Row(
                // Use Row for better layout control
                children: [
                  Icon(Icons.logout_outlined, color: Colors.redAccent.shade200),
                  const SizedBox(width: 12),
                  Text("logout".tr),
                ],
              ),
            ),
            // PopupMenuItem(
            //   value: "delete",
            //   child: Row(
            //     children: [
            //       Icon(
            //         Icons.delete_forever_outlined,
            //         color: Colors.red.shade700,
            //       ),
            //       const SizedBox(width: 12),
            //       Text("delete_account".tr),
            //     ],
            //   ),
            // ),
          ],
      onSelected: (value) async {
        // (Keep your existing logout/delete logic here)
        if (value == "logout") {
          await FirebaseAuth.instance.signOut();
          Get.offAll(() => const LoginScreen());
        } else if (value == "delete") {
          bool confirmed = await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
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
          if (confirmed == true) {
            // Explicit check for true
            try {
              await FirebaseAuth.instance.currentUser
                  ?.delete(); // Use null-safe operator
              Get.offAllNamed('/login');
              Get.snackbar(
                "account_deleted".tr,
                "account_deleted_msg".tr,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } on FirebaseAuthException catch (e) {
              // Catch specific exception
              String errorMessage = e.message ?? "An unknown error occurred.";
              // Handle common errors like 'requires-recent-login'
              if (e.code == 'requires-recent-login') {
                errorMessage =
                    "Please log out and log back in to delete your account.";
              }
              Get.snackbar(
                "delete_error".tr,
                errorMessage,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(
                  seconds: 5,
                ), // Longer duration for error
              );
            } catch (e) {
              // Catch general errors
              Get.snackbar(
                "delete_error".tr,
                "An unexpected error occurred: ${e.toString()}",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
        }
      },
    );
  }

  // --- Health Stats ---
  Widget _buildHealthStatsCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Use Card for elevation and shape
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statusStat(
              context,
              Icons.error_outline, // Use outlined icon
              "emergency".tr,
              emergencyCount,
              Colors.redAccent.shade200,
            ),
            _statusStat(
              context,
              Icons.warning_amber_rounded, // Use outlined icon
              "warning".tr,
              warningCount,
              Colors.orangeAccent.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusStat(
    BuildContext context,
    IconData icon,
    String label,
    int count,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          // Use CircleAvatar for standard circular background
          radius: 28,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(height: 12),
        Text(
          "$count",
          style: textTheme.headlineMedium?.copyWith(
            // Slightly larger headline
            color: color, // Use text color appropriate for container
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  // --- Admin Grid Card ---
  Widget _adminCard(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    Color iconColor,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Use Card widget
      elevation: 2, // Softer elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8), // Consistent margin
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Match Card shape
        splashColor: iconColor.withOpacity(0.1), // Themed splash
        highlightColor: iconColor.withOpacity(0.05), // Themed highlight
        child: Padding(
          padding: const EdgeInsets.all(16), // Increased padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                // Consistent circle for icon
                radius: 30,
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(height: 16),
              Expanded(
                // Allow text to wrap if needed
                child: Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(
                    // Use themed text style
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.arrow_forward_ios_rounded, // Slightly different arrow
                size: 18,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Shimmer Placeholders ---
  Widget _buildGridShimmerItem() {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white, // Shimmer needs a solid background
          ),
        ),
      ),
    );
  }

  Widget _buildGridShimmer() {
    return GridView.count(
      key: const ValueKey('gridShimmer'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 4, // Reduced spacing slightly
      mainAxisSpacing: 4,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ), // Add horizontal padding
      children: List.generate(4, (index) => _buildGridShimmerItem()),
    );
  }

  Widget _buildHealthStatsShimmer(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Shimmer.fromColors(
        key: const ValueKey('healthStatsShimmer'),
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 140, // Match approximate height of the real card
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "admin_panel".tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 1.0, // Slightly lower elevation

        actions: [
          IconButton(
            tooltip: "Settings",
            icon: const Icon(Icons.settings_outlined), // Outlined icon
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
          _buildAccountMenu(context),
          const SizedBox(width: 4), // Add slight padding
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80), // Padding for FAB
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch children horizontally
          children: [
            const SizedBox(height: 20), // Top padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "dashboard_overview".tr, // Example title for the grid
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // Grid Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ), // Padding around grid
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child:
                    _isLoading
                        ? _buildGridShimmer()
                        : GridView.count(
                          key: const ValueKey('gridContent'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 4, // Consistent spacing
                          mainAxisSpacing: 4,
                          children: [
                            _adminCard(
                              context,
                              Icons.people_outline, // Outlined icon
                              "pilgrims".tr,
                              () => Get.to(() => const PilgramsListPage()),
                              Colors.blueAccent.shade400,
                            ),
                            _adminCard(
                              context,
                              Icons
                                  .monitor_heart_outlined, // More specific health icon
                              "health_notifications".tr,
                              () => Get.to(() => const NotificationsScreen()),
                              Colors.redAccent.shade200, // Consistent red
                            ),
                            _adminCard(
                              context,
                              Icons.medical_services_outlined, // Outlined icon
                              "medical_services".tr,
                              () => Get.to(() => MedicalServicesPage()),
                              Colors.green.shade500,
                            ),
                            _adminCard(
                              context,
                              Icons.campaign_outlined, // ** CHANGED ICON **
                              "campaigns".tr, // ** CHANGED LABEL **
                              () => Get.to(
                                () => const CampaignsPage(),
                              ), // Ensure this page exists
                              Colors.orange.shade600,
                            ),
                          ],
                        ),
              ),
            ),

            const SizedBox(height: 24), // Spacing before stats card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "current_status".tr, // Example title for stats
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // Health Stats Section
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child:
                  _isLoading
                      ? _buildHealthStatsShimmer(context)
                      : _buildHealthStatsCard(context),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),

      // --- Floating Action Button to Refresh Counts ---
    );
  }

  @override
  void dispose() {
    // Dispose any controllers if you re-add them
    super.dispose();
  }
}
