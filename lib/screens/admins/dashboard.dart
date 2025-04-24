import 'dart:async'; // For Future

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator.pop()
import 'package:get/get.dart';
import 'package:sanad/screens/admins/campaigns.dart';
import 'package:sanad/screens/admins/pilgrims.dart';
import 'package:sanad/screens/admins/settings.dart';
import 'package:sanad/screens/admins/smart_bracelet.dart';
import 'package:sanad/screens/admins/users.dart';
import 'package:shimmer/shimmer.dart';
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 70, // Adjusted height for typical list item
                decoration: BoxDecoration(
                  color: Colors.white,
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
          decoration: BoxDecoration(
            color: Colors.white, // Shimmer needs a background color
            borderRadius: BorderRadius.circular(12),
          ),
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
  final List<Widget> _screens = [
    const StatisticsScreen(),
    const UserListScreen(), // Manages Admins/Supervisors via UserModel
    const PilgrimListScreen(), // Manages Pilgrims
    const SmartBraceletListScreen(), // Index 2: Pilgrims
    const CampaignListScreen(),
  ];

  // Bottom navigation labels and icons
  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: const Icon(Icons.bar_chart),
      label: 'statistics'.tr,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.manage_accounts),
      label: 'users'.tr,
    ), // For Admins/Supervisors
    BottomNavigationBarItem(
      icon: const Icon(Icons.people_alt),
      label: 'pilgrims'.tr,
    ),
    BottomNavigationBarItem(
      // Added for Bracelets
      icon: const Icon(Icons.watch),
      label: 'bracelets'.tr, // Add 'bracelets' key to AppTranslations
    ),
    BottomNavigationBarItem(
      // Added for Campaigns
      icon: const Icon(Icons.campaign),
      label: 'campaigns'.tr,
    ),
  ];

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
              },
              child: const Text("English"),
            ),
            ElevatedButton(
              onPressed: () {
                Get.updateLocale(const Locale('ar', 'SA'));
                Get.back();
              },
              child: const Text("العربية"),
            ),
          ],
        ),
      );
    } else if (value == 'logout') {
      FirebaseAuth.instance.signOut();
      // Adjust the route as per your login screen, assuming no dedicated login page for now
      // If you have a login page, navigate to it: Get.offAllNamed('/login');
      Get.snackbar(
        "Logged Out",
        "You have been logged out.",
      ); // Placeholder feedback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('adminDashboard'.tr),
        actions: [
          IconButton(
            onPressed: () => Get.to(new SettingsScreen()),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: IndexedStack(
        // Keeps state of inactive screens
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ========================================================================
// Statistics Screen (Normally in screens/statistics_screen.dart)
// ========================================================================
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  // Use Firestore aggregate query for counting
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
      Get.snackbar('error'.tr, 'Could not load count for $collectionName');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using a StatefulWidget here allows easier refresh implementation
    return const StatisticsView();
  }
}

// Separate widget for stateful logic if needed (e.g., for refresh)

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

  Future<Map<String, int>> _fetchStats() async {
    final counts = await Future.wait([
      _getCount(usersCollection),
      _getCount(pilgrimsCollection),
      _getCount(campaignsCollection),
      _getCount(smartBraceletsCollection),
    ]);
    return {
      'users': counts[0],
      'pilgrims': counts[1],
      'campaigns': counts[2],
      'bracelets': counts[3],
    };
  }

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
      return 0;
    }
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _fetchStats();
    });
  }

  Widget _buildStatCard(
    String title,
    int count,
    IconData icon,
    BuildContext context,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            // Expand the main content (grid or shimmers)
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
                          Text('errorLoadingStats'.tr + ': ${snapshot.error}'),
                          ElevatedButton(
                            onPressed: _refreshStats,
                            child: const Text("Retry"),
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildStatCard(
                          'users'.tr,
                          stats['users']!,
                          Icons.manage_accounts,
                          context,
                        ),
                        _buildStatCard(
                          'pilgrims'.tr,
                          stats['pilgrims']!,
                          Icons.people_alt,
                          context,
                        ),
                        _buildStatCard(
                          'campaigns'.tr,
                          stats['campaigns']!,
                          Icons.campaign,
                          context,
                        ),
                        _buildStatCard(
                          'bracelets'.tr,
                          stats['bracelets']!,
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
            // Exit Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  SystemNavigator.pop();
                  // Alternatively, you could use exit(0); but it's not recommended.
                },
                icon: const Icon(Icons.exit_to_app),
                label: Text("Exit".tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Shimmer for Stat Cards ---
// class StatCardShimmer extends StatelessWidget {
//   const StatCardShimmer({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade100,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(width: 40, height: 40, color: Colors.white),
//               const SizedBox(height: 8),
//               Container(height: 18, width: 80, color: Colors.white),
//               const SizedBox(height: 4),
//               Container(height: 24, width: 40, color: Colors.white),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
