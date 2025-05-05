import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Assuming you use GetX for translation/snackbar
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import Shimmer package

// --- Notification Type Constants ---
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
  NotificationType._();
}

// --- Updated Notification Model ---
// (AppNotification Class remains the same as the previous correct version)
class AppNotification {
  final String id;
  final String title;
  final String body;
  final int timestamp;
  final String type;
  final bool readStatus;
  final String userId;
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

  factory AppNotification.fromMap(Map<dynamic, dynamic> data, String id) {
    int parseTimestamp(dynamic timestampData) {
      /* ... timestamp parsing ... */
      if (timestampData is int) {
        return timestampData;
      } else if (timestampData is String) {
        return int.tryParse(timestampData) ??
            DateTime.now().millisecondsSinceEpoch;
      } else if (timestampData is double) {
        return timestampData.toInt();
      }
      return DateTime.now().millisecondsSinceEpoch;
    }

    return AppNotification(
      id: id,
      title: data['title']?.toString() ?? 'No Title',
      body: data['body']?.toString() ?? 'No Body',
      timestamp: parseTimestamp(data['timestamp']),
      type: data['type']?.toString() ?? NotificationType.INFO,
      readStatus: data['readStatus'] == true,
      userId: data['userId']?.toString() ?? '',
      pilgrimId: data['pilgrimId']?.toString(),
      pilgrimName: data['pilgrimName']?.toString(),
    );
  }
  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
}

// --- Notification Screen Widget ---
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  DatabaseReference? _userNotificationsRef;
  StreamSubscription<DatabaseEvent>? _notificationSubscription;
  // ** Separate lists for read and unread **
  final List<AppNotification> _unreadNotifications = [];
  final List<AppNotification> _readNotifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListener();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _setupListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _error = "User not logged in.";
        });
      return;
    }
    _userNotificationsRef = FirebaseDatabase.instance
        .ref()
        .child('notifications')
        .child(currentUser.uid);
    _listenNotifications();
  }

  void _listenNotifications() {
    if (_userNotificationsRef == null || !mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _notificationSubscription?.cancel();
    _notificationSubscription = _userNotificationsRef!
        .orderByChild('timestamp') // Fetch ordered by time
        .onValue
        .listen(
          (DatabaseEvent event) {
            if (!mounted) return;
            final data = event.snapshot.value;
            // ** Temporary lists to process fetched data **
            final List<AppNotification> currentUnread = [];
            final List<AppNotification> currentRead = [];

            if (data is Map<dynamic, dynamic>) {
              data.forEach((key, value) {
                if (value is Map<dynamic, dynamic>) {
                  try {
                    final notification = AppNotification.fromMap(
                      value,
                      key.toString(),
                    );
                    // ** Split into read/unread lists **
                    if (notification.readStatus) {
                      currentRead.add(notification);
                    } else {
                      currentUnread.add(notification);
                    }
                  } catch (e) {
                    /* ... error handling ... */
                  }
                }
              });
              // Sort both lists descending (newest first)
              currentUnread.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              currentRead.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            }

            setState(() {
              _unreadNotifications.clear();
              _unreadNotifications.addAll(currentUnread);
              _readNotifications.clear();
              _readNotifications.addAll(currentRead);
              _isLoading = false;
              _error = null;
            });
          },
          onError: (error) {
            /* ... error handling ... */
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _error = "Failed load.";
            });
          },
        );
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (_userNotificationsRef == null || notification.readStatus) return;
    try {
      await _userNotificationsRef!
          .child(notification.id)
          .child('readStatus')
          .set(true);
    } catch (error) {
      Get.snackbar("Error", "Could not mark as read.");
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    if (_userNotificationsRef == null) return;
    try {
      await _userNotificationsRef!.child(notificationId).remove();
    } catch (error) {
      Get.snackbar("Error", "Could not delete notification.");
    }
    // State updates via listener
  }

  // --- UI Helper Methods ---
  Color _getNotificationColor(BuildContext context, String type) {
    // ... (Color logic same as previous version, using context) ...
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

  IconData _getNotificationIcon(String type) {
    /* ... Same icon logic ... */
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

  String _formatTimestamp(int timestamp) {
    /* ... Same timestamp format ... */
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (e) {
      return "Invalid Date";
    }
  }

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(title: Text('notifications'.tr), elevation: 1),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerList(context); // Use updated shimmer
    }
    if (_error != null) {
      // ... (Error display - Same as before) ...
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.refresh),
                label: Text("Retry"),
                onPressed: _setupListener,
              ),
            ],
          ),
        ),
      );
    }
    // Check if both lists are empty AFTER loading and no error
    if (_unreadNotifications.isEmpty && _readNotifications.isEmpty) {
      // ... (Nicer empty state - Same as before) ...
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'no_notifications'.tr,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // --- Build List with Sections ---
    return RefreshIndicator(
      onRefresh: () async {
        _listenNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ), // Only vertical padding for list
        // Calculate total items including headers
        itemCount: _calculateListItemCount(),
        itemBuilder: (context, index) {
          final bool hasUnread = _unreadNotifications.isNotEmpty;
          final bool hasRead = _readNotifications.isNotEmpty;

          // Determine item type (unread header, unread item, read header, read item)
          if (hasUnread && index == 0) {
            return _buildSectionHeader(
              context,
              'Unread',
            ); // Index 0 is Unread Header
          } else if (hasUnread && index <= _unreadNotifications.length) {
            // Index 1 to n are unread items
            final itemIndex = index - 1;
            return _buildNotificationItem(
              context,
              _unreadNotifications[itemIndex],
              true,
            );
          } else if (hasRead &&
              index == (hasUnread ? _unreadNotifications.length + 1 : 0)) {
            // Index after unread items is Read Header
            return _buildSectionHeader(context, 'Read');
          } else if (hasRead) {
            // Remaining indices are read items
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
          // Should not happen with correct itemCount, but return empty container as fallback
          return Container();
        },
      ),
    );
  }

  // Helper to calculate total list items including headers
  int _calculateListItemCount() {
    int count = 0;
    if (_unreadNotifications.isNotEmpty) {
      count += _unreadNotifications.length + 1; // items + header
    }
    if (_readNotifications.isNotEmpty) {
      count += _readNotifications.length + 1; // items + header
    }
    return count;
  }

  // --- Widget Builder for Section Headers ---
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Text(
        title.tr, // Use translation if available
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // --- Widget Builder for a Single Notification Item ---
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
        /* ... Delete background ... */
        color: Colors.redAccent.shade100.withOpacity(0.8),
        margin: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 0,
        ), // Match item padding
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Icon(Icons.delete_sweep_outlined, color: Colors.red.shade900),
      ),
      child: InkWell(
        // Use InkWell for tap effect instead of Card
        onTap: () {
          _markAsRead(notif);
          // Show details in bottom sheet
          Get.bottomSheet(
            /* ... Bottom sheet content - same as before ... */
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Wrap(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Icon(icon, color: Colors.white),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      _formatTimestamp(notif.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(notif.body, style: TextStyle(fontSize: 15)),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            isScrollControlled: true,
          );
        },
        child: Container(
          // Modern item container - no Card
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
          margin: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.0,
          ), // Margin around item
          decoration: BoxDecoration(
            color: Colors.white, // White background for items
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              // Subtle shadow
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ** Leading indicator line (only if unread) **
              if (isUnread)
                Container(
                  width: 4,
                  height: 60, // Adjust height based on content estimate
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(right: 10.0),
                ),
              // ** Icon **
              CircleAvatar(
                backgroundColor: color.withOpacity(
                  0.15,
                ), // Lighter background for icon
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ), // Icon color matches type
                radius: 20,
              ),
              const SizedBox(width: 12),
              // ** Text Content **
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight:
                            isUnread
                                ? FontWeight.bold
                                : FontWeight.w600, // Bold or semi-bold
                        fontSize: 15,
                        color:
                            isUnread
                                ? Colors.black87
                                : Colors.black54, // Slightly dimmer if read
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.body,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isUnread
                                ? Colors.black54
                                : Colors.grey.shade600, // Dimmer if read
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
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
              // ** Timestamp **
              Padding(
                padding: const EdgeInsets.only(
                  top: 2.0,
                ), // Align timestamp better
                child: Text(
                  _formatTimestamp(
                    notif.timestamp,
                  ), // Consider relative time (timeago package)
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Updated Shimmer Loading Widget ---
  Widget _buildShimmerList(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200, // Lighter base for white background
      highlightColor: Colors.white,
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: 8, // Display shimmer placeholders
        itemBuilder: (context, index) {
          // Mimic the new item structure (no Card, use Container)
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 12.0,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white, // Placeholder has white bg
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optional: Shimmer for leading line if needed
                // Container(width: 4, height: 60, color: Colors.white, margin: const EdgeInsets.only(right: 10.0)),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                ), // Icon placeholder
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16.0,
                        width: MediaQuery.of(context).size.width * 0.5,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 6),
                      ), // Title
                      Container(
                        height: 12.0,
                        width: double.infinity,
                        color: Colors.white,
                      ), // Body line 1
                      const SizedBox(height: 6),
                      Container(
                        height: 12.0,
                        width: double.infinity,
                        color: Colors.white,
                      ), // Body line 2
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 10.0,
                  width: 50.0,
                  color: Colors.white,
                ), // Timestamp
              ],
            ),
          );
        },
      ),
    );
  }
}
