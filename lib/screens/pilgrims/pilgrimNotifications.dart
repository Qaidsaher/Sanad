import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final String type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
  });

  factory AppNotification.fromMap(Map<dynamic, dynamic> data, String id) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: data['timestamp'] ?? '',
      type: data['type'] ?? 'info',
    );
  }

  Map<String, String> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'type': type,
    };
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseReference _notificationsRef =
      FirebaseDatabase.instance.ref().child('notifications');
  final List<AppNotification> _notifications = [];

  bool isAdmin = false;

  final List<String> notificationTypes = [
    'info',
    'warning',
    'alert',
    'success',
    'health_critical',
    'temperature_alert',
    'battery_low',
    'gps_update',
    'oxygen_low',
    'heart_rate_alert',
  ];

  @override
  void initState() {
    super.initState();
    // _checkAdmin();
    _listenNotifications();
  }

  void _checkAdmin() {
    final adminEmails = ['saherqaid2020@gmail.com']; // Add real admin emails
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    setState(() {
      isAdmin = adminEmails.contains(currentUserEmail);
    });
  }

  void _listenNotifications() {
    _notificationsRef.limitToLast(15).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _notifications.clear();
        data.forEach((key, value) {
          _notifications.insert(0, AppNotification.fromMap(value, key));
        });
        setState(() {});
      }
    });
  }

  void _deleteNotification(String id) {
    _notificationsRef.child(id).remove();
  }

  void _generateRandomNotification() {
    final random = Random();
    final id = _notificationsRef.push().key;
    final type = notificationTypes[random.nextInt(notificationTypes.length)];

    final notification = AppNotification(
      id: id!,
      title: 'notification_${type}_title'.tr,
      body: 'notification_${type}_body'.tr,
      timestamp: DateTime.now().toIso8601String(),
      type: type,
    );

    _notificationsRef.child(id).set(notification.toMap());
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'warning':
      case 'temperature_alert':
      case 'battery_low':
        return Colors.orange;
      case 'alert':
      case 'health_critical':
      case 'oxygen_low':
      case 'heart_rate_alert':
        return Colors.red;
      case 'success':
        return Colors.green;
      case 'gps_update':
        return Colors.blue;
      case 'info':
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'alert':
        return Icons.error;
      case 'success':
        return Icons.check_circle;
      case 'health_critical':
        return Icons.favorite;
      case 'temperature_alert':
        return Icons.thermostat;
      case 'battery_low':
        return Icons.battery_alert;
      case 'gps_update':
        return Icons.gps_fixed;
      case 'oxygen_low':
        return Icons.bloodtype;
      case 'heart_rate_alert':
        return Icons.monitor_heart;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _generateRandomNotification,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add_alert),
              tooltip: 'generate_notification'.tr,
            )
          : null,
      body: _notifications.isEmpty
          ? Center(
              child: Text('no_notifications'.tr,
                  style: Theme.of(context).textTheme.bodyLarge),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  final color = _getNotificationColor(notif.type);
                  final icon = _getNotificationIcon(notif.type);
                  return Dismissible(
                    key: Key(notif.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _deleteNotification(notif.id),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.snackbar(notif.title, notif.body,
                              backgroundColor: color, colorText: Colors.white);
                        },
                        child: Row(
                          children: [
                            // Color Indicator on the left side
                            Container(
                              width: 6,
                              height: 100,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: CircleAvatar(
                                backgroundColor: color,
                                child: Icon(icon, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.body,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatTimestamp(notif.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
