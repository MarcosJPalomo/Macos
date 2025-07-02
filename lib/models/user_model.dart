import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final DateTime createdAt;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.role = 'user',
    required this.createdAt,
    this.profileImageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'],
      role: map['role'] ?? 'user',
      createdAt: _parseDateTime(map['createdAt']),
      profileImageUrl: map['profileImageUrl'],
    );
  }

  // Método helper para manejar diferentes tipos de fechas
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }

    if (dateValue is DateTime) {
      return dateValue;
    }

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }

    // Si es cualquier otro tipo, usar fecha actual como fallback
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'profileImageUrl': profileImageUrl,
    };
  }

  UserModel copyWith({
    String? email,
    String? fullName,
    String? phone,
    String? role,
    DateTime? createdAt,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  bool get isAdmin => role == 'admin';
}