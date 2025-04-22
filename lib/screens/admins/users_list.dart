import 'dart:convert';

import 'package:autoimagepaper/models/models.dart'; // assuming models are in models.dart
import 'package:autoimagepaper/screens/admins/user_profile_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({Key? key}) : super(key: key);

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  /// Retrieves the list of campaign IDs where the current user is the supervisor.
  Future<List<String>> _getCampaignIdsForSupervisor() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];
    QuerySnapshot campaignSnapshot = await FirebaseFirestore.instance
        .collection('campaigns')
        .where('supervisorId', isEqualTo: currentUser.uid)
        .get();
    List<String> campaignIds =
        campaignSnapshot.docs.map((doc) => doc.id).toList();
    return campaignIds;
  }

  // A simple shimmer widget styled as a professional card placeholder.
  Widget _buildShimmerItem() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    Container(
                      height: 14,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A modern search bar design.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "search_users".tr,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          // Optional: add a subtle shadow
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("users".tr),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _getCampaignIdsForSupervisor(),
              builder: (context, campaignSnapshot) {
                if (campaignSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildShimmerItem(),
                  );
                }
                if (!campaignSnapshot.hasData ||
                    campaignSnapshot.data!.isEmpty) {
                  return Center(child: Text("no_campaigns_found".tr));
                }
                final campaignIds = campaignSnapshot.data!;
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pilgrims')
                      .where('campaignId', whereIn: campaignIds)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("error_occurred".tr));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) => _buildShimmerItem(),
                      );
                    }
                    final docs = snapshot.data!.docs;
                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          ("${data['firstName'] ?? ''} ${data['middleName'] ?? ''} ${data['lastName'] ?? ''}")
                              .toLowerCase();
                      final country =
                          (data['country'] ?? '').toString().toLowerCase();
                      return name.contains(searchQuery) ||
                          country.contains(searchQuery);
                    }).toList();
                    if (filteredDocs.isEmpty) {
                      return Center(child: Text("no_pilgrims_found".tr));
                    }
                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final pilgrim =
                            Pilgrim.fromFirestore(filteredDocs[index]);
                        ImageProvider avatarProvider;
                        if (pilgrim.avatar != null &&
                            pilgrim.avatar!.isNotEmpty) {
                          try {
                            avatarProvider =
                                MemoryImage(base64Decode(pilgrim.avatar!));
                          } catch (e) {
                            avatarProvider =
                                const AssetImage("assets/avatar.png");
                          }
                        } else {
                          avatarProvider =
                              const AssetImage("assets/avatar.png");
                        }
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: avatarProvider,
                            ),
                            title: Text(
                              pilgrim.fullName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(Icons.flag,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(pilgrim.country),
                                const SizedBox(width: 8),
                                const Icon(Icons.cake,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("${pilgrim.age} yrs"),
                              ],
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Get.to(() => UserProfileAdmin(pilgrim: pilgrim));
                            },
                          ),
                        );
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
