// services/notification_service.dart - Actualizado
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> showBookingConfirmation({
    required String eventTitle,
    required String eventDate,
    required String eventTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Confirmaciones de Reserva',
      channelDescription: 'Notificaciones de confirmación de reservas',
      importance: Importance.high,
      priority: Priority.high,
      // Usar ícono integrado de Android
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        '¡Reserva Confirmada!',
        '$eventTitle - $eventDate a las $eventTime',
        details,
      );
    } catch (e) {
      print('Error mostrando notificación: $e');
    }
  }

  static Future<void> showEventReminder({
    required String eventTitle,
    required DateTime eventDateTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Recordatorios de Eventos',
      channelDescription: 'Recordatorios de eventos próximos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        eventDateTime.millisecondsSinceEpoch.remainder(100000),
        'Recordatorio de Evento',
        '$eventTitle comienza pronto',
        details,
      );
    } catch (e) {
      print('Error mostrando recordatorio: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}