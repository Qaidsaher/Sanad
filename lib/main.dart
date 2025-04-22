import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:sanad/core/localization/language.dart';
import 'package:sanad/core/localization/translate.dart';
import 'package:sanad/core/theme/theme_controller.dart';
import 'package:sanad/screens/onboarding/initial_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase Messaging Background Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up background messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Get the FCM token and save it
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('fcmToken', token ?? '');

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Received a foreground message: ${message.messageId}");
    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? "Notification",
        message.notification!.body ?? "",
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
      );
    }
  });

  runApp(SanadApp());
}

class SanadApp extends StatelessWidget {
  // Instantiate controllers for theme and language
  final ThemeController themeController = Get.put(ThemeController());
  final LanguageController languageController = Get.put(LanguageController());

  SanadApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sanad',
        translations: AppTranslations(),
        locale: languageController.locale.value,
        fallbackLocale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: themeController.currentTheme,
        home: const InitialScreen(),
      );
    });
  }
}
