import 'dart:async'; // For Future

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator.pop()
import 'package:get/get.dart';
import 'package:sanad/screens/admins/campaigns.dart'; // Assuming these exist
import 'package:sanad/screens/admins/pilgrims.dart'; // Assuming these exist
import 'package:sanad/screens/admins/settings.dart'; // Assuming these exist
import 'package:sanad/screens/admins/smart_bracelet.dart'; // Assuming these exist
import 'package:sanad/screens/admins/users.dart'; // Assuming these exist
import 'package:shimmer/shimmer.dart';
// ========================================================================

// ========================================================================
// Constants (Normally in constants.dart)
// ========================================================================
const String usersCollection = 'users';
const String adminsCollection = 'admins'; // Not used in stats, but good to have
const String campaignsCollection = 'campaigns';
const String pilgrimsCollection = 'pilgrims';
const String smartBraceletsCollection = 'smart_bracelets';
const String healthDataSubcollection =
    'health_data'; // For potential future use

// ========================================================================
// Helper Widgets (Normally in widgets/ folder)
// ========================================================================

// --- Shimmer Placeholder for Lists ---
class ListShimmer extends StatelessWidget {
  final int itemCount;
  const ListShimmer({Key? key, this.itemCount = 6}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Shimmer.fromColors(
              baseColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
              highlightColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade500
                      : Colors.grey.shade100,
              child: Container(
                height: 70, // Adjusted height for typical list item
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors
                              .white, // Shimmer requires a non-transparent color
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
    );
  }
}

// --- Shimmer Placeholder for Stat Cards ---
class StatCardShimmer extends StatelessWidget {
  const StatCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          // Added a child container to ensure shimmer applies correctly
          // to the card's shape and background.
          decoration: BoxDecoration(
            color: Colors.white, // Shimmer needs a background color
            borderRadius: BorderRadius.circular(12),
          ),
          // You can add some dummy content structure if you want the shimmer
          // to resemble the actual card content more closely.
          // For example:
          // child: Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Container(width: 40, height: 40, color: Colors.white), // Icon placeholder
          //       const SizedBox(height: 8),
          //       Container(width: 100, height: 16, color: Colors.white), // Title placeholder
          //       const SizedBox(height: 4),
          //       Container(width: 60, height: 24, color: Colors.white), // Count placeholder
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }
}

// ========================================================================
// Admin Dashboard Screen (Normally in admin_dashboard.dart)
// ========================================================================
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  // Screens corresponding to bottom nav items
  // Ensure these screens are correctly implemented elsewhere in your project
  final List<Widget> _screens = [
    const StatisticsScreen(),
    const UserListScreen(), // Manages Admins/Supervisors via UserModel
    const PilgrimListScreen(), // Manages Pilgrims
    const SmartBraceletListScreen(),
    const CampaignListScreen(),
  ];

  // _navItems is REMOVED from here

  void _onMenuSelected(String value) {
    if (value == 'language') {
      Get.defaultDialog(
        title: 'changeLanguage'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.updateLocale(const Locale('en', 'US'));
                Get.back();
                // setState(() {}); // Usually not needed as GetX should trigger rebuild
              },
              child: const Text("English"),
            ),
            ElevatedButton(
              onPressed: () {
                Get.updateLocale(const Locale('ar', 'SA'));
                Get.back();
                // setState(() {}); // Usually not needed
              },
              child: const Text("العربية"),
            ),
          ],
        ),
      );
    } else if (value == 'logout') {
      FirebaseAuth.instance.signOut();
      // Adjust the route as per your login screen.
      // Example: Get.offAllNamed('/login');
      Get.snackbar(
        "Logged Out", // Consider translating this as well
        "You have been logged out.", // And this
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define navItems INSIDE the build method for dynamic translation
    final List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.bar_chart),
        label: 'statistics'.tr,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.manage_accounts),
        label: 'users'.tr,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.people_alt),
        label: 'pilgrims'.tr,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.watch),
        label: 'bracelets'.tr,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.campaign),
        label: 'campaigns'.tr,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('adminDashboard'.tr),
        actions: [
          IconButton(
            // Using () => for Get.to to ensure a new instance of SettingsScreen is pushed
            // if that's the desired behavior.
            onPressed: () => Get.to(() => SettingsScreen()),
            icon: const Icon(Icons.settings),
          ),
          // You can add the PopupMenuButton for language and logout here if it was intended
          // If SettingsScreen handles these, then the IconButton is correct.
          // Example if you want it directly on the AppBar:
          // PopupMenuButton<String>(
          //   onSelected: _onMenuSelected,
          //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          //     PopupMenuItem<String>(
          //       value: 'language',
          //       child: Text('changeLanguage'.tr),
          //     ),
          //     const PopupMenuDivider(),
          //     PopupMenuItem<String>(
          //       value: 'logout',
          //       child: Text('logout'.tr), // Assuming 'logout' key exists
          //     ),
          //   ],
          // ),
        ],
      ),
      body: IndexedStack(
        // Keeps state of inactive screens
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Good for 3-5 items
        items: navItems, // Use the dynamically created navItems
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Optional: Add styling to match your theme if default is not sufficient
        // selectedItemColor: Theme.of(context).colorScheme.primary,
        // unselectedItemColor: Colors.grey,
        // selectedFontSize: 12,
        // unselectedFontSize: 12,
      ),
    );
  }
}

// ========================================================================
// Statistics Screen (Normally in screens/statistics_screen.dart)
// ========================================================================
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  // This _getCount method is now duplicated in StatisticsView.
  // Consider moving it to a service or making StatisticsView handle its own data fetching.
  // For this example, I'll leave it, but in a larger app, refactor.
  Future<int> _getCount(String collectionName) async {
    try {
      AggregateQuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection(collectionName)
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print("Error counting $collectionName: $e");
      Get.snackbar('error'.tr, '${'couldNotLoadCountFor'.tr} $collectionName');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const StatisticsView();
  }
}

class StatisticsView extends StatefulWidget {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  _StatisticsViewState createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  Future<int> _getCount(String collectionName) async {
    // This is a helper specific to this view now.
    try {
      AggregateQuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection(collectionName)
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print("Error counting $collectionName (in StatisticsView): $e");
      // Snackbar might be annoying if multiple cards fail, consider a general error message.
      return 0; // Return 0 on error to prevent breaking the UI for other cards.
    }
  }

  Future<Map<String, int>> _fetchStats() async {
    // Using try-catch for individual counts can make it more robust
    // if one query fails, others can still succeed.
    final users = await _getCount(usersCollection);
    final pilgrims = await _getCount(pilgrimsCollection);
    final campaigns = await _getCount(campaignsCollection);
    final bracelets = await _getCount(smartBraceletsCollection);

    return {
      'users': users,
      'pilgrims': pilgrims,
      'campaigns': campaigns,
      'bracelets': bracelets,
    };
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _fetchStats(); // Re-fetch all stats
    });
  }

  Widget _buildStatCard(
    String titleKey, // Changed to titleKey to emphasize it needs translation
    int count,
    IconData icon,
    BuildContext context,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              titleKey.tr, // Translate the title here
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2, // Allow for slightly longer translated text
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // No need for an inner Scaffold if StatisticsView is always part of AdminDashboard's body
    return Padding(
      padding: const EdgeInsets.all(8.0), // Unified padding
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, int>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: List.generate(
                      4,
                      (index) => const StatCardShimmer(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${'errorLoadingStats'.tr}: ${snapshot.error}'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _refreshStats,
                          child: Text('retry'.tr), // Assuming 'retry' key
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('noStatsAvailable'.tr));
                }

                Map<String, int> stats = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refreshStats,
                  child: GridView.count(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Allow scroll for refresh
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        'users',
                        stats['users'] ?? 0,
                        Icons.manage_accounts,
                        context,
                      ),
                      _buildStatCard(
                        'pilgrims',
                        stats['pilgrims'] ?? 0,
                        Icons.people_alt,
                        context,
                      ),
                      _buildStatCard(
                        'campaigns',
                        stats['campaigns'] ?? 0,
                        Icons.campaign,
                        context,
                      ),
                      _buildStatCard(
                        'bracelets',
                        stats['bracelets'] ?? 0,
                        Icons.watch,
                        context,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Consider a confirmation dialog before exiting
              Get.defaultDialog(
                title:
                    "confirmExit".tr, // Assuming 'confirmExit' translation key
                middleText:
                    "areYouSureYouWantToExit"
                        .tr, // Assuming 'areYouSureYouWantToExit'
                textConfirm: "exit".tr,
                textCancel: "cancel".tr, // Assuming 'cancel'
                confirmTextColor: Colors.white,
                onConfirm: () {
                  SystemNavigator.pop(); // Exits the app
                },
                onCancel: () {
                  Get.back(); // Dismiss dialog
                },
              );
            },
            icon: const Icon(Icons.exit_to_app),
            label: Text("Exit".tr), // Assuming 'exit' key
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Theme.of(
                    context,
                  ).colorScheme.error, // Use error color for exit
              foregroundColor: Theme.of(context).colorScheme.onError,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
