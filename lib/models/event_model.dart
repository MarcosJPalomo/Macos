import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int maxCapacity;
  final int currentBookings;
  final String instructor;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final String category;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    this.currentBookings = 0,
    required this.instructor,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.category,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      maxCapacity: map['maxCapacity'] ?? 0,
      currentBookings: map['currentBookings'] ?? 0,
      instructor: map['instructor'] ?? '',
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      category: map['category'] ?? 'fitness',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'maxCapacity': maxCapacity,
      'currentBookings': currentBookings,
      'instructor': instructor,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
    };
  }

  EventModel copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? maxCapacity,
    int? currentBookings,
    String? instructor,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    String? category,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      currentBookings: currentBookings ?? this.currentBookings,
      instructor: instructor ?? this.instructor,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }

  bool get isFull => currentBookings >= maxCapacity;
  bool get hasSpace => currentBookings < maxCapacity;
  int get availableSpots => maxCapacity - currentBookings;

  DateTime get startDateTime {
    final timeParts = startTime.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  DateTime get endDateTime {
    final timeParts = endTime.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  Duration get duration => endDateTime.difference(startDateTime);

  bool get isPast => DateTime.now().isAfter(endDateTime);
  bool get isToday =>
      date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
}