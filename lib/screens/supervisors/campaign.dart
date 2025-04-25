import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanad/models/models.dart'; // Contains Campaign and Pilgrim models
import 'package:shimmer/shimmer.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({Key? key}) : super(key: key);

  @override
  State<CampaignsPage> createState() =>
      _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  // Build a modern search bar with rounded corners and a filled background.
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
          hintText: "search_campaigns".tr,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Shimmer placeholder for a campaign card.
  Widget _buildCampaignShimmer() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simulated header row.
              Row(
                children: [
                  Container(width: 32, height: 32, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 20, color: Colors.white)),
                  Container(width: 40, height: 20, color: Colors.white),
                ],
              ),
              const SizedBox(height: 8),
              // Simulated phone row.
              Container(height: 16, width: 150, color: Colors.white),
              const SizedBox(height: 4),
              // Simulated date row.
              Container(height: 16, width: 100, color: Colors.white),
              const SizedBox(height: 12),
              // Simulated pilgrim count.
              Container(height: 16, width: 80, color: Colors.white),
            ],
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
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text("my_campaigns".tr)),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('campaigns')
                      .where('supervisorId', isEqualTo: currentUser?.uid)
                      .snapshots(),
              builder: (context, campaignSnapshot) {
                if (campaignSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  // Show shimmer placeholders while loading.
                  return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildCampaignShimmer(),
                  );
                }
                if (!campaignSnapshot.hasData ||
                    campaignSnapshot.data!.docs.isEmpty) {
                  return Center(child: Text("no_campaigns_found".tr));
                }
                List<DocumentSnapshot> campaignDocs =
                    campaignSnapshot.data!.docs;

                // Filter campaigns based on search query.
                if (searchQuery.isNotEmpty) {
                  campaignDocs =
                      campaignDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final campaignName =
                            (data['campaignName'] ?? '')
                                .toString()
                                .toLowerCase();
                        return campaignName.contains(searchQuery);
                      }).toList();
                }
                if (campaignDocs.isEmpty) {
                  return Center(child: Text("no_campaigns_found".tr));
                }
                return ListView.builder(
                  itemCount: campaignDocs.length,
                  itemBuilder: (context, index) {
                    final campaign = Campaign.fromFirestore(
                      campaignDocs[index],
                    );

                    // Format the campaign date.
                    String formattedDate = "N/A";
                    if (campaign.campaignYear != null &&
                        campaign.campaignYear! > 0) {
                      // In your original code, campaignYear is an int.
                      // Adjust formatting as needed.
                      formattedDate = campaign.campaignYear.toString();
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campaign header: icon, name, and year.
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.campaign,
                                  size: 32,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    campaign.campaignName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${campaign.campaignYear}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Campaign phone number.
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "Phone: ${campaign.phone}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Campaign date.
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Date: $formattedDate",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Pilgrim count for this campaign.
                            StreamBuilder<QuerySnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection('pilgrims')
                                      .where(
                                        'campaignId',
                                        isEqualTo: campaign.id,
                                      )
                                      .snapshots(),
                              builder: (context, pilgrimSnapshot) {
                                if (pilgrimSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 100,
                                      height: 16,
                                      color: Colors.white,
                                    ),
                                  );
                                }
                                int count =
                                    pilgrimSnapshot.data?.docs.length ?? 0;
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$count Pilgrims",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
