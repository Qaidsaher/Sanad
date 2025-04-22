import 'package:autoimagepaper/core/localization/language.dart';
import 'package:autoimagepaper/core/theme/theme_controller.dart';
import 'package:autoimagepaper/screens/pilgrims/profile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final themeController = Get.find<ThemeController>();
    final languages = languageController.languages;
    final themeColors = [
      const Color(0xFF0D47A1), // Blue Light
      const Color(0xFF1A237E), // Indigo Dark
      const Color(0xFF388E3C), // Green Light
      const Color(0xFF2E7D32), // Green Dark
      const Color(0xFFD32F2F), // Red Light
      const Color(0xFFB71C1C), // Red Dark
    ];

    return Scaffold(
      appBar: AppBar(title: Text("settings".tr)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("language".tr, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            children: languages.map((lang) {
              return ElevatedButton(
                onPressed: () {
                  languageController.setLanguage(lang['locale']);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // 👈 Button text color
                ),
                child: Text(lang['name']),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          Text("theme".tr, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            children: themeColors.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => themeController.setTheme(entry.key),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.person, color: Colors.white),
            label: Text("edit_profile".tr,
                style: const TextStyle(color: Colors.white)),
            onPressed: () => Get.to(() => const PilgrimEditProfileScreen()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(14),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
