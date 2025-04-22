import 'package:autoimagepaper/core/localization/language.dart';
import 'package:autoimagepaper/core/theme/theme_controller.dart';
import 'package:autoimagepaper/screens/pilgrims/profile/update_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final themeController = Get.find<ThemeController>();

    // List of supported languages from the language controller.
    final languages = languageController.languages;

    // List of theme colors for selection.
    final themeColors = [
      const Color(0xFF0D44A1), // Blue Light
      const Color(0xFF1A237E), // Indigo Dark
      const Color(0xFF388E3C), // Green Light
      const Color(0xFF2E7D32), // Green Dark
      const Color(0xFFD32F2F), // Red Light
      const Color(0xFFB71C1C), // Red Dark
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Section
            Text(
              "language".tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: languages.map((lang) {
                bool isSelected = languageController.locale.value.toString() ==
                    lang['locale'].toString();
                return ChoiceChip(
                  label: Text(lang['name']),
                  selected: isSelected,
                  onSelected: (_) =>
                      languageController.setLanguage(lang['locale']),
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Theme Section
            Text(
              "theme".tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              children: themeColors.asMap().entries.map((entry) {
                bool isSelected =
                    themeController.selectedThemeIndex.value == entry.key;
                return GestureDetector(
                  onTap: () => themeController.setTheme(entry.key),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Account Section (without Edit Profile)
            Text(
              "account_settings".tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Removed the edit profile option.
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: Text("update_password".tr),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Get.to(() => PilgrimUpdatePasswordScreen()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.delete_forever, color: Colors.red),
                    title: Text(
                      "delete_account".tr,
                      style: const TextStyle(color: Colors.red),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: () {
                      // Replace with your delete account logic.
                      Get.snackbar("info".tr, "deleteAccountAction".tr);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
