import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HealthNotification {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final String status; // "healthy", "warning", "critical"

  HealthNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.status,
  });
}

class HealthNotificationsPage extends StatefulWidget {
  const HealthNotificationsPage({Key? key}) : super(key: key);

  @override
  _HealthNotificationsPageState createState() =>
      _HealthNotificationsPageState();
}

class _HealthNotificationsPageState extends State<HealthNotificationsPage> {
  // Generate 15 random health notifications for testing
  final List<HealthNotification> notifications = List.generate(15, (index) {
    final statuses = ["healthy", "warning", "critical"];
    final status = statuses[Random().nextInt(statuses.length)];
    return HealthNotification(
      id: "$index",
      title: "health_notif_title_$status".tr,
      body: "health_notif_body_$status".tr,
      timestamp: DateTime.now()
          .subtract(Duration(minutes: Random().nextInt(120)))
          .toIso8601String(),
      status: status,
    );
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case "warning":
        return Colors.orange;
      case "critical":
        return Colors.red;
      case "healthy":
      default:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "warning":
        return Icons.warning;
      case "critical":
        return Icons.error;
      case "healthy":
      default:
        return Icons.check_circle;
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
        title: Text("health_notifications".tr),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final color = _getStatusColor(notif.status);
          final icon = _getStatusIcon(notif.status);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              title: Text(notif.title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.body),
                  const SizedBox(height: 4),
                  Text(_formatTimestamp(notif.timestamp),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
              onTap: () {
                Get.snackbar(notif.title, notif.body,
                    backgroundColor: color, colorText: Colors.white);
              },
            ),
          );
        },
      ),
    );
  }
}
