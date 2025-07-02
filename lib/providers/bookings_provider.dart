// providers/bookings_provider.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class BookingsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<BookingModel> _userBookings = [];
  List<BookingModel> _eventBookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get eventBookings => _eventBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadUserBookings(String userId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getUserBookingsWithEvents(userId).listen(
          (bookings) {
        _userBookings = bookings;
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

  void loadEventBookings(String eventId) {
    _firestoreService.getEventBookings(eventId).listen(
          (bookings) {
        _eventBookings = bookings;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> createBooking({
    required String userId,
    required String eventId,
    required String userName,
    required String userEmail,
    required EventModel event,
  }) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final booking = BookingModel(
        id: '',
        userId: userId,
        eventId: eventId,
        userName: userName,
        userEmail: userEmail,
        bookedAt: DateTime.now(),
      );

      await _firestoreService.createBooking(booking);

      // Mostrar notificación de confirmación
      await NotificationService.showBookingConfirmation(
        eventTitle: event.title,
        eventDate: '${event.date.day}/${event.date.month}/${event.date.year}',
        eventTime: event.startTime,
      );

      // Programar recordatorio
      await NotificationService.showEventReminder(
        eventTitle: event.title,
        eventDateTime: event.startDateTime,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId, String eventId) async {
    try {
      print('=== INICIO CANCELACIÓN ===');
      print('BookingId: $bookingId');
      print('EventId: $eventId');

      _error = null;

      final result = await _firestoreService.cancelBooking(bookingId, eventId);
      print('Resultado cancelación: success');

      return true;
    } catch (e) {
      print('=== ERROR EN CANCELACIÓN ===');
      print('Error tipo: ${e.runtimeType}');
      print('Error mensaje: $e');
      print('Stack trace: ${StackTrace.current}');

      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  Future<bool> hasUserBookedEvent(String userId, String eventId) async {
    try {
      return await _firestoreService.hasUserBookedEvent(userId, eventId);
    } catch (e) {
      return false;
    }
  }

  List<BookingModel> getUpcomingBookings() {
    final now = DateTime.now();
    return _userBookings.where((booking) =>
    booking.isConfirmed &&
        booking.event != null &&
        booking.event!.startDateTime.isAfter(now)
    ).toList();
  }

  List<BookingModel> getPastBookings() {
    final now = DateTime.now();
    return _userBookings.where((booking) =>
    booking.event != null &&
        booking.event!.startDateTime.isBefore(now)
    ).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }


  void loadUserBookingsHistory(String userId) {
    _isLoading = true;
    notifyListeners();

    // Obtener todas las reservas (confirmadas, canceladas, completadas)
    _firestoreService.getAllUserBookingsWithEvents(userId).listen(
          (bookings) {
        _userBookings = bookings;
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
}