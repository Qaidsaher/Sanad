import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Assuming GetX for translation/snackbar
import 'package:intl/intl.dart';
// --- !!! IMPORT YOUR MODELS HERE (including Pilgrim) !!! ---
import 'package:sanad/models/models.dart'; // <-- ADJUST PATH AS NEEDED
// --- !!! IMPORT YOUR PILGRIM PROFILE SCREEN HERE !!! ---
import 'package:sanad/screens/supervisors/pilgrams_profile.dart'; // <-- ADJUST PATH AS NEEDED
import 'package:shimmer/shimmer.dart'; // Import Shimmer package

// --- Notification Type Constants ---
// Defines the possible 'type' strings for notifications
class NotificationType {
  static const String TEMP_ALERT = 'temperature_alert';
  static const String HR_ALERT = 'heart_rate_alert';
  static const String OXYGEN_LOW = 'oxygen_low';
  static const String HEALTH_CRITICAL = 'health_critical';
  static const String INFO = 'info';
  static const String WARNING = 'warning';
  static const String ALERT = 'alert';
  static const String SUCCESS = 'success';
  static const String BATTERY_LOW = 'battery_low';
  static const String GPS_UPDATE = 'gps_update';

  // Private constructor to prevent instantiation
  NotificationType._();
}

// --- Notification Data Model ---
// Represents the structure of a notification object stored in RTDB
// and used within the app.
class AppNotification {
  final String id; // RTDB push key
  final String title;
  final String body;
  final int timestamp; // Milliseconds since epoch
  final String type;
  final bool readStatus;
  final String userId; // User ID of the recipient (e.g., the supervisor's ID)
  // Optional fields included in notifications sent TO supervisors ABOUT pilgrims
  final String? pilgrimId;
  final String? pilgrimName;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    required this.readStatus,
    required this.userId,
    this.pilgrimId,
    this.pilgrimName,
  });

  // Factory constructor to create an AppNotification from RTDB data map
  factory AppNotification.fromMap(Map<dynamic, dynamic> data, String id) {
    // Helper to safely parse timestamp, handling various potential types
    int parseTimestamp(dynamic timestampData) {
      if (timestampData is int) {
        return timestampData;
      } else if (timestampData is String) {
        return int.tryParse(timestampData) ??
            DateTime.now().millisecondsSinceEpoch;
      } else if (timestampData is double) {
        return timestampData.toInt();
      }
      print(
        "Warning: Unexpected timestamp format ($timestampData), using current time.",
      );
      return DateTime.now().millisecondsSinceEpoch;
    }

    return AppNotification(
      id: id,
      title: data['title']?.toString() ?? 'Notification',
      body: data['body']?.toString() ?? 'Details unavailable.',
      timestamp: parseTimestamp(data['timestamp']),
      type: data['type']?.toString() ?? NotificationType.INFO,
      readStatus: data['readStatus'] == true,
      userId: data['userId']?.toString() ?? '',
      pilgrimId: data['pilgrimId']?.toString(),
      pilgrimName: data['pilgrimName']?.toString(),
    );
  }

  // Helper to get DateTime object, localized
  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
}

// --- Notification Screen Widget ---
// Displays a list of notifications for the currently logged-in user (Pilgrim or Supervisor)
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  DatabaseReference?
  _userNotificationsRef; // Reference to /notifications/{userId}
  StreamSubscription<DatabaseEvent>?
  _notificationSubscription; // Manages the RTDB listener

  // State lists to hold sorted notifications
  final List<AppNotification> _unreadNotifications = [];
  final List<AppNotification> _readNotifications = [];

  // UI State flags
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Setup listener after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListener();
    });
  }

  @override
  void dispose() {
    // Cancel the listener when the screen is removed to prevent memory leaks
    _notificationSubscription?.cancel();
    print("NotificationsScreen disposed, listener cancelled.");
    super.dispose();
  }

  // Initializes the database reference and starts listening for notifications
  void _setupListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("Notification listener setup failed: User not logged in.");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "User not logged in. Please log in to see notifications.";
        });
      }
      return;
    }
    final userId = currentUser.uid;
    print("Setting up notification listener for user: $userId");
    // Point to the specific user's notification node in RTDB
    _userNotificationsRef = FirebaseDatabase.instance
        .ref()
        .child('notifications')
        .child(userId);

    _listenNotifications();
  }

  // Attaches the listener to the user's notification node
  void _listenNotifications() {
    // Ensure reference is set and widget is still mounted
    if (_userNotificationsRef == null || !mounted) return;

    setState(() {
      _isLoading = true; // Show loading shimmer
      _error = null;
    });

    _notificationSubscription?.cancel(); // Cancel any previous listener
    print("Starting RTDB listener at ${_userNotificationsRef!.path}");

    // Listen for value changes, ordering by timestamp server-side
    _notificationSubscription = _userNotificationsRef!
        .orderByChild('timestamp')
        .onValue
        .listen(
          (DatabaseEvent event) {
            if (!mounted) return; // Check if widget still exists
            print("RTDB listener received data snapshot.");

            final data = event.snapshot.value; // Raw data (can be Map or null)
            final List<AppNotification> currentUnread = [];
            final List<AppNotification> currentRead = [];

            if (data is Map<dynamic, dynamic>) {
              // Process if data is a Map
              print("Processing ${data.length} notification entries...");
              data.forEach((key, value) {
                if (value is Map<dynamic, dynamic>) {
                  try {
                    // Create AppNotification object from map data
                    final notification = AppNotification.fromMap(
                      value,
                      key.toString(),
                    );
                    // Split into read/unread lists based on status
                    if (notification.readStatus) {
                      currentRead.add(notification);
                    } else {
                      currentUnread.add(notification);
                    }
                  } catch (e, stacktrace) {
                    print("Error parsing notification key $key: $e");
                    print("Problematic data: $value");
                    print("Stacktrace: $stacktrace");
                  }
                } else {
                  print(
                    "Warning: Invalid data format for notification key $key. Expected Map, got ${value.runtimeType}",
                  );
                }
              });
              // Sort both lists descending by timestamp (newest first) in the app
              currentUnread.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              currentRead.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              print(
                "Finished processing. Unread: ${currentUnread.length}, Read: ${currentRead.length}.",
              );
            } else if (data == null) {
              print(
                "No notification data found for this user at ${_userNotificationsRef!.path}.",
              );
            } else {
              // Log if unexpected data type is received
              print(
                "Warning: Unexpected data type received from RTDB at ${_userNotificationsRef!.path}: ${data.runtimeType}",
              );
            }

            // Update the state with the processed lists
            setState(() {
              _unreadNotifications.clear();
              _unreadNotifications.addAll(currentUnread);
              _readNotifications.clear();
              _readNotifications.addAll(currentRead);
              _isLoading = false; // Hide shimmer
              _error = null; // Clear any previous error
            });
          },
          onError: (error) {
            // Handle listener errors (e.g., permission denied)
            if (!mounted) return;
            print(
              "Error listening to notifications at ${_userNotificationsRef?.path}: $error",
            );
            setState(() {
              _isLoading = false;
              _error =
                  "Failed to load notifications. Check connection or permissions.";
            });
          },
        );
  }

  // Updates the 'readStatus' of a notification in RTDB to true
  Future<void> _markAsRead(AppNotification notification) async {
    if (_userNotificationsRef == null || notification.readStatus)
      return; // No need to update

    print(
      "Marking notification ${notification.id} as read for user ${notification.userId}.",
    );
    try {
      await _userNotificationsRef!
          .child(notification.id) // Target specific notification ID
          .child('readStatus') // Target the readStatus field
          .set(true); // Set value to true
      print("Successfully marked ${notification.id} as read in RTDB.");
      // UI updates via listener
    } catch (error) {
      print("Error marking notification ${notification.id} as read: $error");
      Get.snackbar(
        "Error",
        "Could not mark notification as read.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // Deletes a notification from RTDB
  Future<void> _deleteNotification(String notificationId) async {
    if (_userNotificationsRef == null) return;

    print("Deleting notification ${notificationId}");
    try {
      await _userNotificationsRef!.child(notificationId).remove();
      print("Successfully deleted ${notificationId} from RTDB.");
      // UI updates via listener
    } catch (error) {
      print("Error deleting notification ${notificationId}: $error");
      Get.snackbar(
        "Error",
        "Could not delete notification.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // --- UI Helper Methods ---

  // Gets the color associated with a notification type
  Color _getNotificationColor(BuildContext context, String type) {
    final theme = Theme.of(context);
    switch (type) {
      case NotificationType.WARNING:
      case NotificationType.TEMP_ALERT:
      case NotificationType.BATTERY_LOW:
        return Colors.amber.shade700;
      case NotificationType.ALERT:
      case NotificationType.HEALTH_CRITICAL:
      case NotificationType.OXYGEN_LOW:
      case NotificationType.HR_ALERT:
        return theme.colorScheme.error;
      case NotificationType.SUCCESS:
        return Colors.green.shade600;
      case NotificationType.GPS_UPDATE:
        return Colors.blue.shade700;
      case NotificationType.INFO:
      default:
        return theme.colorScheme.secondary;
    }
  }

  // Gets the icon associated with a notification type
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case NotificationType.WARNING:
        return Icons.warning_amber_rounded;
      case NotificationType.ALERT:
        return Icons.error_outline;
      case NotificationType.SUCCESS:
        return Icons.check_circle_outline;
      case NotificationType.HEALTH_CRITICAL:
        return Icons.monitor_heart_outlined;
      case NotificationType.TEMP_ALERT:
        return Icons.thermostat_outlined;
      case NotificationType.BATTERY_LOW:
        return Icons.battery_alert_outlined;
      case NotificationType.GPS_UPDATE:
        return Icons.location_on_outlined;
      case NotificationType.OXYGEN_LOW:
        return Icons.air_outlined;
      case NotificationType.HR_ALERT:
        return Icons.favorite_border_outlined;
      default:
        return Icons.info_outline;
    }
  }

  // Formats the integer timestamp into a readable date/time string
  String _formatTimestamp(int timestamp) {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
      return DateFormat(
        'dd MMM, hh:mm a',
      ).format(dt); // Example: 05 May, 03:27 AM
    } catch (e) {
      return "Invalid Date";
    }
  }

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Use theme background
      appBar: AppBar(title: Text('notifications'.tr), elevation: 1),

      body: _buildBody(),
    );
  }

  // Builds the main body content based on loading/error/data state
  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerList(context); // Show loading shimmer
    }
    if (_error != null) {
      // Enhanced Error display
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$_error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.refresh),
                label: Text("Retry"),
                onPressed: _setupListener, // Retry fetching data
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  backgroundColor: Theme.of(context).colorScheme.error,
                ), // Button style
              ),
            ],
          ),
        ),
      );
    }
    // Enhanced Empty state
    if (_unreadNotifications.isEmpty && _readNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'no_notifications'.tr, // Assumes GetX translation
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "You're all caught up!",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // Build the list with sections if there are notifications
    return RefreshIndicator(
      onRefresh: () async {
        _listenNotifications();
      }, // Allow pull-to-refresh
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ), // Vertical padding for the whole list
        itemCount: _calculateListItemCount(),
        itemBuilder: (context, index) {
          final bool hasUnread = _unreadNotifications.isNotEmpty;
          final bool hasRead = _readNotifications.isNotEmpty;

          // --- Logic to determine if current index is a header or item ---
          if (hasUnread && index == 0) {
            return _buildSectionHeader(context, 'Unread');
          } else if (hasUnread && index <= _unreadNotifications.length) {
            final itemIndex = index - 1;
            return _buildNotificationItem(
              context,
              _unreadNotifications[itemIndex],
              true,
            );
          } else if (hasRead &&
              index == (hasUnread ? _unreadNotifications.length + 1 : 0)) {
            return _buildSectionHeader(context, 'Read');
          } else if (hasRead) {
            final itemIndex =
                index - (hasUnread ? _unreadNotifications.length + 2 : 1);
            if (itemIndex >= 0 && itemIndex < _readNotifications.length) {
              return _buildNotificationItem(
                context,
                _readNotifications[itemIndex],
                false,
              );
            }
          }
          return const SizedBox.shrink(); // Fallback
        },
      ),
    );
  }

  // Helper to calculate total list items (notifications + headers)
  int _calculateListItemCount() {
    int count = 0;
    if (_unreadNotifications.isNotEmpty)
      count += _unreadNotifications.length + 1;
    if (_readNotifications.isNotEmpty) count += _readNotifications.length + 1;
    return count;
  }

  // Builds a styled section header widget
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 20.0,
        bottom: 10.0,
      ),
      child: Text(
        title.tr.toUpperCase(), // Assumes GetX translation
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Builds a single notification list item (Unread or Read)
  Widget _buildNotificationItem(
    BuildContext context,
    AppNotification notif,
    bool isUnread,
  ) {
    final color = _getNotificationColor(context, notif.type);
    final icon = _getNotificationIcon(notif.type);

    String? subtitle;
    if (notif.pilgrimName != null && notif.pilgrimName!.isNotEmpty) {
      subtitle = 'Regarding Pilgrim: ${notif.pilgrimName}';
      if (notif.pilgrimId != null) {
        final idToShow =
            notif.pilgrimId!.length > 6
                ? notif.pilgrimId!.substring(0, 6)
                : notif.pilgrimId;
        subtitle += ' (ID: ${idToShow}...)';
      }
    }

    return Dismissible(
      key: ValueKey(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notif.id);
      },
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Icon(Icons.delete_outline, color: Colors.red.shade700),
      ),
      child: Material(
        color: Colors.white, // Use Material for InkWell on Container
        child: InkWell(
          onTap: () {
            _markAsRead(notif);
            _showNotificationDetails(context, notif, color, icon, subtitle);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              // Subtle bottom border instead of margin/card
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading colored line indicator for unread items
                Container(
                  width: 5,
                  height: 60, // Fixed height might need adjustment
                  decoration: BoxDecoration(
                    color:
                        isUnread
                            ? color
                            : Colors.transparent, // Only show if unread
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                // Icon
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 22),
                  radius: 22,
                ),
                const SizedBox(width: 12),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface
                              .withOpacity(isUnread ? 0.7 : 0.5),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    _formatTimestamp(notif.timestamp),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to show bottom sheet details (with navigation logic)
  void _showNotificationDetails(
    BuildContext context,
    AppNotification notif,
    Color color,
    IconData icon,
    String? subtitle,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  child: Icon(icon, color: Colors.white, size: 20),
                  radius: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTimestamp(notif.timestamp),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24, thickness: 0.5),
            // Body
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                notif.body,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            // Subtitle (Pilgrim info)
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            // "View Profile" Button
            if (notif.pilgrimId != null) ...[
              Divider(height: 24, thickness: 0.5),
              Center(
                child: TextButton.icon(
                  icon: Icon(Icons.person_search_outlined, size: 20),
                  label: Text("View Pilgrim Profile"),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () async {
                    // Make async
                    // Close sheet
                    if (Get.isBottomSheetOpen ?? false) Get.back();
                    // Show loading
                    Get.dialog(
                      Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    try {
                      // Fetch Pilgrim Data
                      DocumentSnapshot pilgrimDocSnapshot =
                          await FirebaseFirestore.instance
                              .collection(
                                'pilgrims',
                              ) // Ensure correct collection name
                              .doc(notif.pilgrimId!)
                              .get();
                      // Dismiss loading
                      if (Get.isDialogOpen ?? false) Get.back();

                      if (pilgrimDocSnapshot.exists) {
                        // Parse to Pilgrim object (Requires Pilgrim.fromFirestore)
                        Pilgrim fetchedPilgrim = Pilgrim.fromFirestore(
                          pilgrimDocSnapshot,
                        );
                        // Navigate
                        print(
                          "Navigating to profile for Pilgrim: ${fetchedPilgrim.fullName}",
                        );
                        Get.to(
                          () => PilgramProfile(pilgrim: fetchedPilgrim),
                        ); // Pass object
                      } else {
                        print("Error: Pilgrim not found: ${notif.pilgrimId}");
                        Get.snackbar(
                          "Not Found",
                          "Could not find pilgrim details.",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    } catch (e) {
                      if (Get.isDialogOpen ?? false)
                        Get.back(); // Dismiss loading on error
                      print("Error fetching/navigating to pilgrim profile: $e");
                      Get.snackbar(
                        "Error",
                        "Failed to load pilgrim profile.",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
              ),
            ],
            SizedBox(
              height:
                  MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 8,
            ), // Bottom padding
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration: Duration(milliseconds: 200),
      exitBottomSheetDuration: Duration(milliseconds: 150),
    );
  }

  // --- Updated Shimmer Loading Widget ---
  Widget _buildShimmerList(BuildContext context) {
    // Build shimmer placeholders reflecting the modern item style
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white, // Use white highlight for white items
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: 10, // More shimmer items
        itemBuilder: (context, index) {
          bool isHeaderPlaceholder =
              index % 5 == 0; // Header placeholder example

          if (isHeaderPlaceholder) {
            // Shimmer Header
            return Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 20.0,
                bottom: 10.0,
              ),
              child: Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ), // Header placeholder
            );
          }
          // Shimmer Item placeholder
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
              ),
            ), // Mimic divider
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ), // Line placeholder
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 22,
                ), // Icon placeholder
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16.0,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        margin: EdgeInsets.only(bottom: 8),
                      ), // Title
                      Container(
                        height: 12.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ), // Body line 1
                      const SizedBox(height: 6),
                      Container(
                        height: 12.0,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ), // Body line 2
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 10.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ), // Timestamp
              ],
            ),
          );
        },
      ),
    );
  }
} // End of _NotificationsScreenState
