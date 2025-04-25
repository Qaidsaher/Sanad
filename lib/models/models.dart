import 'package:cloud_firestore/cloud_firestore.dart';

// Models (Normally in models.dart)
// ========================================================================

// --- User Model (Corresponds to your 'User' class) ---
// Pilgrim Model (linked with a User account via userId)
class Pilgrim {
  final String id; // Pilgrim Document ID
  final String userId; // Link to the associated UserModel document (for login)
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final int age;
  final String campaignId; // Foreign key reference to Campaign document ID
  final String braceletId; // Foreign key reference to SmartBracelet document ID
  final String? avatar; // Avatar stored as a base64-encoded string (nullable)
  final String country; // Pilgrim's country

  Pilgrim({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.campaignId,
    required this.braceletId,
    this.avatar,
    required this.country,
  });

  factory Pilgrim.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pilgrim(
      id: doc.id,
      userId: data['userId'] ?? '',
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      lastName: data['lastName'] ?? '',
      gender: data['gender'] ?? '',
      age: data['age'] ?? 0,
      campaignId: data['campaignId'] ?? '',
      braceletId: data['braceletId'] ?? '',
      avatar: data['avatar'], // Stored as a base64 string
      country: data['country'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'gender': gender,
      'age': age,
      'campaignId': campaignId,
      'braceletId': braceletId,
      'avatar': avatar, // Save as a base64 string
      'country': country,
    };
  }

  // Helper to get full name
  String get fullName =>
      '$firstName $middleName $lastName'.trim().replaceAll(RegExp(' +'), ' ');
}

// User Model (corresponds to the authentication account)
class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String token; // Default value: ''

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.token = '', // ✅ Default value
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      token: data['token'] ?? '', // ✅ Uses default if null in Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'token': token,
    };
  }
}

// --- Admin Profile Model ---
class Admin {
  final String id; // Admin Document ID
  final String
  userId; // Foreign key reference to a UserModel document ID (or Auth UID)

  Admin({required this.id, required this.userId});

  factory Admin.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Admin(id: doc.id, userId: data['userId'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId};
  }
}

// --- Campaign Model ---
class Campaign {
  final String id;
  final String campaignName;
  final int campaignYear;
  final String phone;
  final String adminId;
  final String supervisorId; // New field for supervisor

  Campaign({
    required this.id,
    required this.campaignName,
    required this.campaignYear,
    required this.phone,
    required this.adminId,
    required this.supervisorId,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      campaignName: data['campaignName'] ?? '',
      campaignYear: data['campaignYear'] ?? 0,
      phone: data['phone'] ?? '',
      adminId: data['adminId'] ?? '',
      supervisorId: data['supervisorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campaignName': campaignName,
      'campaignYear': campaignYear,
      'phone': phone,
      'adminId': adminId,
      'supervisorId': supervisorId,
    };
  }
}

// --- Smart Bracelet Model ---
class SmartBracelet {
  final String id; // Bracelet Document ID
  final String serialNumber;

  SmartBracelet({required this.id, required this.serialNumber});

  factory SmartBracelet.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SmartBracelet(id: doc.id, serialNumber: data['serialNumber'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'serialNumber': serialNumber};
  }
}

// --- Health Data Model ---

class HealthData {
  final String id; // Health Data Document ID
  final double temperature;
  final double bloodOxygen;
  final int heartRate;
  final DateTime timestamp;
  final GeoPoint location; // New field for GPS location
  final String smartBraceletId; // New field for SmartBracelet id
  final String pilgrimId; // New field for Pilgrim id

  HealthData({
    required this.id,
    required this.temperature,
    required this.bloodOxygen,
    required this.heartRate,
    required this.timestamp,
    required this.location,
    required this.smartBraceletId,
    required this.pilgrimId,
  });

  factory HealthData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HealthData(
      id: doc.id,
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
      bloodOxygen: (data['bloodOxygen'] as num?)?.toDouble() ?? 0.0,
      heartRate: data['heartRate'] as int? ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Use the provided location if available; otherwise, default to Mecca, Saudi Arabia.
      location: data['location'] as GeoPoint? ?? GeoPoint(21.4225, 39.8262),
      smartBraceletId: data['smartBraceletId'] ?? '',
      pilgrimId: data['pilgrimId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'bloodOxygen': bloodOxygen,
      'heartRate': heartRate,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
      'smartBraceletId': smartBraceletId,
      'pilgrimId': pilgrimId,
    };
  }
}
