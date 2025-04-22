import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'themes_variables.dart';

class ThemeController extends GetxController {
  RxInt selectedThemeIndex = 0.obs;
  final List<ThemeData> themes = [
    blueLightTheme,
    indigoDarkTheme,
    greenLightTheme,
    greenDarkTheme,
    redLightTheme,
    redDarkTheme,
  ];
  final List<String> themeNames = [
    'Blue Light',
    'Indigo Dark',
    'Green Light',
    'Green Dark',
    'Red Light',
    'Red Dark',
  ];

  ThemeData get currentTheme => themes[selectedThemeIndex.value];

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    selectedThemeIndex.value = prefs.getInt('themeIndex') ?? 0;
  }

  void setTheme(int index) async {
    selectedThemeIndex.value = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', index);
  }
}
