import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalServicesPage extends StatelessWidget {
  MedicalServicesPage({Key? key}) : super(key: key);

  // Emergency numbers and hospital data.
  final List<Map<String, dynamic>> emergencyNumbers = [
    {'label': '911', 'description': 'emergency_call', 'phone': '911'},
    {'label': '997', 'description': 'ambulance', 'phone': '997'},
    {'label': '998', 'description': 'civil_defense', 'phone': '998'},
  ];

  final Map<String, List<Map<String, String>>> hospitalAreas = {
    'منى': [
      {'name': 'hospital_mena_1', 'phone': '+966555123456'},
      {'name': 'health_center_mena', 'phone': '+966555234567'},
    ],
    'مزدلفة': [
      {'name': 'health_center_muzdalfah', 'phone': '+966555345678'},
    ],
    'عرفات': [
      {'name': 'hospital_arafat', 'phone': '+966555456789'},
      {'name': 'health_center_arafat', 'phone': '+966555567890'},
    ],
  };

  /// Launch a call using url_launcher.
  Future<void> _callNumber(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      Get.snackbar("calling".tr, phone,
          backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "medical_services".tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emergency Numbers Card with title inside.
            Card(
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "emergency_numbers".tr,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...emergencyNumbers.map((e) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.shade100,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.call, color: Colors.red),
                        ),
                        title: Text(
                          e['label'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(e['description'].toString().tr),
                        trailing: IconButton(
                          icon: const Icon(Icons.phone_forwarded,
                              color: Colors.red),
                          onPressed: () => _callNumber(e['phone']),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Hospitals Section Header
            Center(
              child: Text(
                "available_hospitals".tr,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Hospital Areas Listing without divider lines.
            ...hospitalAreas.entries.map((area) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                elevation: 4,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    area.key, // Area name (translation can be added if needed)
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  children: area.value.map((hospital) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.shade100,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.local_hospital,
                            color: Colors.green),
                      ),
                      title: Text(
                        hospital['name']!.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _callNumber(hospital['phone'] ?? ''),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
