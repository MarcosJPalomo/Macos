import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String eventId;
  final String userName;
  final String userEmail;
  final DateTime bookedAt;
  final String status;
  final EventModel? event;

  BookingModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.userName,
    required this.userEmail,
    required this.bookedAt,
    this.status = 'confirmed',
    this.event,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      bookedAt: (map['bookedAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'confirmed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'userName': userName,
      'userEmail': userEmail,
      'bookedAt': Timestamp.fromDate(bookedAt),
      'status': status,
    };
  }

  BookingModel copyWith({
    String? userId,
    String? eventId,
    String? userName,
    String? userEmail,
    DateTime? bookedAt,
    String? status,
    EventModel? event,
  }) {
    return BookingModel(
      id: id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      bookedAt: bookedAt ?? this.bookedAt,
      status: status ?? this.status,
      event: event ?? this.event,
    );
  }

  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isNoShow => status == 'no_show';
}