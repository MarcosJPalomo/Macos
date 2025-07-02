// providers/events_provider.dart
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';

class EventsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  FirestoreService get firestoreService => _firestoreService;

  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  List<EventModel> get events => _filteredEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  String? get selectedCategory => _selectedCategory;

  EventsProvider() {
    loadEvents();
  }

  void loadEvents() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getEvents().listen(
          (events) {
        _events = events;
        _applyFilters();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredEvents = _events.where((event) {
      bool matchesDate = event.date.year == _selectedDate.year &&
          event.date.month == _selectedDate.month &&
          event.date.day == _selectedDate.day;

      bool matchesCategory = _selectedCategory == null ||
          event.category == _selectedCategory;

      return matchesDate && matchesCategory && event.isActive;
    }).toList();

    _filteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<EventModel?> getEventById(String eventId) async {
    try {
      return await _firestoreService.getEventById(eventId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createEvent(EventModel event) async {
    try {
      _error = null;
      await _firestoreService.createEvent(event);
      // Forzar recarga inmediata
      loadEvents();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(EventModel event) async {
    try {
      _error = null;
      await _firestoreService.updateEvent(event);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      _error = null;
      await _firestoreService.deleteEvent(eventId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<EventModel> getUpcomingEvents() {
    final now = DateTime.now();
    return _events.where((event) =>
    event.startDateTime.isAfter(now) && event.isActive
    ).take(5).toList();
  }

  List<EventModel> getTodayEvents() {
    final today = DateTime.now();
    return _events.where((event) =>
    event.isToday && event.isActive
    ).toList();
  }
}