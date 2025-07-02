// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // EVENTOS
  Stream<List<EventModel>> getEvents({
    DateTime? date,
    String? category,
    bool onlyActive = true,
  }) {
    Query query = _firestore.collection('events');

    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
    }

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener evento: ${e.toString()}');
    }
  }

  Future<void> createEvent(EventModel event) async {
    try {
      print('Creando evento en Firestore: ${event.toMap()}');
      await _firestore.collection('events').add(event.toMap());
      print('Evento creado exitosamente');
    } catch (e) {
      print('Error en createEvent: $e');
      throw Exception('Error al crear evento: ${e.toString()}');
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc(event.id).update(event.toMap());
    } catch (e) {
      throw Exception('Error al actualizar evento: ${e.toString()}');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Error al eliminar evento: ${e.toString()}');
    }
  }

  // RESERVAS
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // Obtener evento actual
        final eventRef = _firestore.collection('events').doc(booking.eventId);
        final eventSnapshot = await transaction.get(eventRef);

        if (!eventSnapshot.exists) {
          throw Exception('El evento no existe');
        }

        final eventData = eventSnapshot.data()!;
        final currentBookings = eventData['currentBookings'] ?? 0;
        final maxCapacity = eventData['maxCapacity'] ?? 0;

        if (currentBookings >= maxCapacity) {
          throw Exception('El evento está lleno');
        }

        // Verificar si ya tiene reserva
        final existingBooking = await _firestore
            .collection('bookings')
            .where('userId', isEqualTo: booking.userId)
            .where('eventId', isEqualTo: booking.eventId)
            .where('status', isEqualTo: 'confirmed')
            .get();

        if (existingBooking.docs.isNotEmpty) {
          throw Exception('Ya tienes una reserva para este evento');
        }

        // Crear reserva
        final bookingRef = _firestore.collection('bookings').doc();
        final newBooking = booking.copyWith();
        transaction.set(bookingRef, newBooking.toMap());

        // Actualizar contador de evento
        transaction.update(eventRef, {
          'currentBookings': currentBookings + 1
        });

        return BookingModel.fromMap(newBooking.toMap(), bookingRef.id);
      });
    } catch (e) {
      throw Exception('Error al crear reserva: ${e.toString()}');
    }
  }

  // En firestore_service.dart - Reemplazar método cancelBooking

  Future<void> cancelBooking(String bookingId, String eventId) async {
    try {
      print('Iniciando transacción de cancelación...');

      await _firestore.runTransaction((transaction) async {
        // PRIMERO: Hacer todas las lecturas
        print('Leyendo evento: $eventId');
        final eventRef = _firestore.collection('events').doc(eventId);
        final eventSnapshot = await transaction.get(eventRef);

        // SEGUNDO: Hacer todas las escrituras
        print('Actualizando booking: $bookingId');
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        transaction.update(bookingRef, {'status': 'cancelled'});

        if (eventSnapshot.exists) {
          final currentBookings = eventSnapshot.data()!['currentBookings'] ?? 0;
          print('Bookings actuales: $currentBookings');

          if (currentBookings > 0) {
            print('Actualizando evento: $eventId');
            transaction.update(eventRef, {
              'currentBookings': currentBookings - 1
            });
            print('Decrementado a: ${currentBookings - 1}');
          }
        }
      });

      print('Transacción completada exitosamente');
    } catch (e) {
      print('Error en cancelBooking: $e');
      throw Exception('Error al cancelar reserva: ${e.toString()}');
    }
  }

  Stream<List<BookingModel>> getUserBookings(String userId, {String? status}) {
    Query query = _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query
        .orderBy('bookedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }
// En firestore_service.dart - Reemplazar getUserBookingsWithEvents

  Stream<List<BookingModel>> getUserBookingsWithEvents(String userId, {String? status}) async* {
    Query query = _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    } else {
      // Por defecto, solo mostrar reservas confirmadas
      query = query.where('status', isEqualTo: 'confirmed');
    }

    await for (final bookingSnapshot in query
        .orderBy('bookedAt', descending: true)
        .snapshots()) {

      List<BookingModel> bookingsWithEvents = [];

      for (final bookingDoc in bookingSnapshot.docs) {
        final booking = BookingModel.fromMap(
            bookingDoc.data() as Map<String, dynamic>,
            bookingDoc.id
        );

        try {
          final eventDoc = await _firestore
              .collection('events')
              .doc(booking.eventId)
              .get();

          if (eventDoc.exists) {
            final event = EventModel.fromMap(
                eventDoc.data()!,
                eventDoc.id
            );

            final bookingWithEvent = booking.copyWith(event: event);
            bookingsWithEvents.add(bookingWithEvent);
          } else {
            bookingsWithEvents.add(booking);
          }
        } catch (e) {
          print('Error obteniendo evento ${booking.eventId}: $e');
          bookingsWithEvents.add(booking);
        }
      }

      yield bookingsWithEvents;
    }
  }
  Stream<List<BookingModel>> getEventBookings(String eventId) {
    return _firestore
        .collection('bookings')
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'confirmed')
        .orderBy('bookedAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<bool> hasUserBookedEvent(String userId, String eventId) async {
    try {
      final query = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
// Agregar este método en firestore_service.dart

  Stream<List<BookingModel>> getAllUserBookingsWithEvents(String userId) async* {
    await for (final bookingSnapshot in _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookedAt', descending: true)
        .snapshots()) {

      List<BookingModel> bookingsWithEvents = [];

      for (final bookingDoc in bookingSnapshot.docs) {
        final booking = BookingModel.fromMap(
            bookingDoc.data() as Map<String, dynamic>,
            bookingDoc.id
        );

        try {
          final eventDoc = await _firestore
              .collection('events')
              .doc(booking.eventId)
              .get();

          if (eventDoc.exists) {
            final event = EventModel.fromMap(
                eventDoc.data()!,
                eventDoc.id
            );

            final bookingWithEvent = booking.copyWith(event: event);
            bookingsWithEvents.add(bookingWithEvent);
          } else {
            bookingsWithEvents.add(booking);
          }
        } catch (e) {
          print('Error obteniendo evento ${booking.eventId}: $e');
          bookingsWithEvents.add(booking);
        }
      }

      yield bookingsWithEvents;
    }
  }
  // ESTADÍSTICAS PARA ADMIN
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .get();

      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'confirmed')
          .get();

      final usersSnapshot = await _firestore.collection('users').get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));

      final todayEvents = eventsSnapshot.docs.where((doc) {
        final eventDate = (doc.data()['date'] as Timestamp).toDate();
        return eventDate.isAfter(today) && eventDate.isBefore(tomorrow);
      }).length;

      return {
        'totalEvents': eventsSnapshot.docs.length,
        'totalBookings': bookingsSnapshot.docs.length,
        'totalUsers': usersSnapshot.docs.length,
        'todayEvents': todayEvents,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: ${e.toString()}');
    }
  }
}