import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ------------------------
/// LANGUAGE CONTROLLER
/// ------------------------
class LanguageController extends GetxController {
  Rx<Locale> locale = const Locale('en', 'US').obs;
  final List<Map<String, dynamic>> languages = [
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': 'العربية', 'locale': const Locale('ar', 'SA')},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      locale.value = Locale(languageCode);
      Get.updateLocale(locale.value);
    }
  }

  void setLanguage(Locale newLocale) async {
    locale.value = newLocale;
    Get.updateLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', newLocale.languageCode);
  }
}
