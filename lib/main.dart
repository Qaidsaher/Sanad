import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:sanad/core/localization/language.dart';
import 'package:sanad/core/localization/translate.dart';
import 'package:sanad/core/theme/theme_controller.dart';
import 'package:sanad/screens/notifications/notifications_screen.dart';
import 'package:sanad/screens/onboarding/initial_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORTANT: Define your Notification Model ---
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final String
  type; // e.g., 'info', 'alert', 'promo', 'blood', 'error', 'battery'
  bool isRead; // Optional: track read status

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  // Factory constructor to create from a map (e.g., from RTDB)
  factory AppNotification.fromMap(String id, Map<dynamic, dynamic> map) {
    return AppNotification(
      id: id,
      title: map['title'] ?? 'Notification',
      body: map['body'] ?? '',
      timestamp: map['timestamp'] ?? DateTime.now().toIso8601String(),
      type: map['type'] ?? 'info', // Default type if missing
      isRead: map['isRead'] ?? false,
    );
  }

  // Method to convert to a map (for saving to RTDB)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'type': type,
      'isRead': isRead,
    };
  }
}

// --- Firebase Background Message Handler (Keep Top-Level) ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Required for background isolate
  final String type = message.data['type'] ?? 'info'; // Get type here too
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}, Type: $type");
    print("Background Message data: ${message.data}");
    print("Background Notification: ${message.notification?.title}");
  }

  // Save notification (including type) to history
  await _saveNotificationToHistory(message);
}

// --- Helper Function to Save Notification to RTDB ---
Future<void> _saveNotificationToHistory(RemoteMessage message) async {
  try {
    final DatabaseReference notificationsRef = FirebaseDatabase.instance
        .ref()
        .child('notifications');
    final String? newNotificationId = notificationsRef.push().key;

    if (newNotificationId == null) {
      if (kDebugMode) print("Error: Could not generate RTDB key.");
      return;
    }

    final Map<String, dynamic> data = message.data;
    final RemoteNotification? notification = message.notification;

    // Prioritize data payload, fallback to notification payload
    final String title =
        data['title']?.toString() ?? notification?.title ?? 'Notification';
    final String body = data['body']?.toString() ?? notification?.body ?? '';
    // *** Ensure 'type' is extracted from the data payload ***
    final String type =
        data['type']?.toString() ?? 'info'; // Default to 'info' if missing

    final AppNotification appNotification = AppNotification(
      id: newNotificationId,
      title: title,
      body: body,
      timestamp: DateTime.now().toIso8601String(),
      type: type, // Save the extracted type
      isRead: false,
    );

    await notificationsRef
        .child(newNotificationId)
        .set(appNotification.toMap());
    if (kDebugMode) {
      print("Notification (Type: $type) saved to RTDB: $newNotificationId");
    }
  } catch (e) {
    if (kDebugMode)
      print(
        "Error saving notification (Type: ${message.data['type']}) to RTDB: $e",
      );
  }
}

// --- Helper Function for Handling Notification Taps ---
void _handleNotificationTap(RemoteMessage message) {
  final String type = message.data['type'] ?? 'info'; // Extract type
  if (kDebugMode) {
    print(
      "Handling tap for message: ${message.messageId}, Type: $type, Data: ${message.data}",
    );
  }

  final Map<String, dynamic> data = message.data;
  final String? screen = data['screen'] as String?;
  final String? itemId = data['itemId'] as String?;

  // --- Navigation Logic ---
  // You can now use the 'type' here to influence navigation or pass it along
  if (kDebugMode) {
    print("Notification Tap Data Payload: $data");
    print("Notification Type on Tap: $type");
  }

  // Example: Navigate to a specific screen based on type if 'screen' isn't specified
  // if (screen == null) {
  //   if (type == 'error') {
  //      Get.to(() => ErrorDetailsScreen(messageData: data)); // Example
  //      return; // Exit after handling
  //   } else if (type == 'battery') {
  //      Get.to(() => BatteryStatusScreen(messageData: data)); // Example
  //      return; // Exit after handling
  //   }
  // }

  // Existing screen-based navigation (can be combined with type)
  if (screen != null) {
    if (kDebugMode) print("Navigating based on 'screen': $screen");
    switch (screen) {
      case '/notifications':
        // Pass type if the notification screen needs it
        Get.to(() => NotificationsScreen()); // Example modification
        break;
      case '/details':
        if (kDebugMode)
          print("Navigating to Details Screen (itemId: $itemId, type: $type)");
        // Pass type and itemId to your details screen
        // Get.to(() => DetailScreen(itemId: itemId, notificationType: type));
        Get.snackbar(
          'Navigation',
          'Would navigate to Details Screen (ID: $itemId, Type: $type)',
        );
        break;
      default:
        if (kDebugMode)
          print("Unknown screen ('$screen'). Navigating to default.");
        Get.to(() => NotificationsScreen()); // Pass type to default
    }
  } else {
    // Default navigation if no 'screen' key - maybe go to general notifications
    if (kDebugMode)
      print(
        "No 'screen' key. Navigating to default (NotificationsScreen), Type: $type",
      );
    Get.to(() => NotificationsScreen()); // Pass type to default
  }

  // You wouldn't typically save here if you save on receive (foreground/background)
  // await _saveNotificationToHistory(message);
}

// --- Main Application Entry Point ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // --- Permission Request (keep as is) ---
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (kDebugMode)
    print('User permission status: ${settings.authorizationStatus}');

  // --- Token Handling (keep as is) ---
  try {
    String? token = await messaging.getToken();
    if (kDebugMode) print("FCM Token: $token");
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcmToken', token);
      // TODO: Send token to your server
    }
    messaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) print("FCM Token Refreshed: $newToken");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcmToken', newToken);
      // TODO: Send refreshed token to your server
    });
  } catch (e) {
    if (kDebugMode) print("Error with FCM token: $e");
  }

  // --- Foreground Message Listener ---
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final String type = message.data['type'] ?? 'info'; // Extract type
    if (kDebugMode) {
      print("Foreground Message Received: ${message.messageId}, Type: $type");
      print('Foreground Message data: ${message.data}');
    }
    RemoteNotification? notification = message.notification;
    String title =
        message.data['title'] ?? notification?.title ?? "Notification";
    String body = message.data['body'] ?? notification?.body ?? "";

    // *** Differentiate Snackbar based on Type ***
    Color snackbarColor = Colors.blueAccent; // Default
    IconData snackbarIcon = Icons.info_outline; // Default

    switch (type) {
      case 'error':
        snackbarColor = Colors.redAccent;
        snackbarIcon = Icons.error_outline;
        break;
      case 'battery':
        snackbarColor = Colors.orangeAccent;
        snackbarIcon = Icons.battery_alert;
        break;
      case 'blood': // Assuming 'blood' means something important/alerting
        snackbarColor = Colors.pinkAccent; // Or another distinct color
        snackbarIcon = Icons.bloodtype; // Example icon
        break;
      case 'warning':
        snackbarColor = Colors.amberAccent;
        snackbarIcon = Icons.warning_amber_outlined;
        break;
      // Add more cases for other types
    }

    if (title.isNotEmpty || body.isNotEmpty) {
      Get.snackbar(
        title,
        body,
        backgroundColor: snackbarColor.withOpacity(0.9),
        colorText: Colors.white,
        icon: Icon(snackbarIcon, color: Colors.white, size: 28),
        shouldIconPulse:
            type == 'error' ||
            type == 'blood', // Optional pulsing for important types
        duration: const Duration(seconds: 7), // Slightly longer duration
        isDismissible: true,
        onTap: (_) {
          if (kDebugMode) print("Foreground Snackbar tapped! Type: $type");
          _handleNotificationTap(message); // Handle tap
        },
      );
    }

    // Save notification to history when received in foreground
    _saveNotificationToHistory(message);
  });

  // --- Background/Terminated Tap Handlers (keep as is, _handleNotificationTap now knows type) ---
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (kDebugMode)
      print(
        'App opened via background tap: ${message.messageId}, Type: ${message.data['type']}',
      );
    _handleNotificationTap(message);
  });

  final RemoteMessage? initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    if (kDebugMode)
      print(
        'App opened via terminated tap: ${initialMessage.messageId}, Type: ${initialMessage.data['type']}',
      );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationTap(initialMessage);
    });
  }

  // Run App
  runApp(SanadApp());
}

// --- SanadApp Class (Modify constructor if needed for type handling) ---
// Example: Pass initial type to InitialScreen if needed
class SanadApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  final LanguageController languageController = Get.put(LanguageController());

  // Optional: Store initial type if needed immediately
  final String? initialNotificationType;

  SanadApp({Key? key, this.initialNotificationType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode && initialNotificationType != null) {
      print(
        "App starting with initial notification type: $initialNotificationType",
      );
    }
    // Use Obx for reactivity
    return Obx(() {
      return GetMaterialApp(
        // ... (Rest of GetMaterialApp properties: debug, title, translations, etc.)
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
        // Pass data to InitialScreen if necessary
        home: const InitialScreen(),
      );
    });
  }
}
