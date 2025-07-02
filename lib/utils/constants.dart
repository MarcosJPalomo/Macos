import 'package:flutter/material.dart';

class AppColors {
  // Colores principales para tema oscuro
  static const Color primary = Color(0xFFC6FF00);        // Verde lima vibrante (mantener)
  static const Color primaryDark = Color(0xFF9FCC00);    // Verde lima más oscuro
  static const Color white = Color(0xFF1E1E1E);          // Casi negro para fondos
  static const Color lightGray = Color(0xFF2A2A2A);      // Gris oscuro para tarjetas
  static const Color mediumGray = Color(0xFF404040);     // Gris medio oscuro
  static const Color dark = Color(0xFFE0E0E0);           // Gris claro para textos
  static const Color surface = Color(0xFF262626);        // Superficie oscura
  static const Color background = Color(0xFF1A1A1A);     // Fondo principal oscuro
  static const Color success = Color(0xFF4CAF50);        // Verde éxito
  static const Color error = Color(0xFFFF5252);          // Rojo error
  static const Color warning = Color(0xFFFF9800);        // Naranja advertencia

  // Nuevos colores para tema oscuro
  static const Color cardBackground = Color(0xFF2C2C2C); // Fondo de tarjetas
  static const Color inputBackground = Color(0xFF333333); // Fondo de inputs
  static const Color divider = Color(0xFF3A3A3A);        // Divisores
  static const Color textSecondary = Color(0xFFB0B0B0);  // Texto secundario
  static const Color textPrimary = Color(0xFFFFFFFF);    // Texto principal blanco

  // Gradientes actualizados para tema oscuro
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppStrings {
  // Títulos de pantallas
  static const String appName = 'NovaFit';
  static const String home = 'Inicio';
  static const String events = 'Eventos';
  static const String myBookings = 'Mis Reservas';
  static const String profile = 'Perfil';
  static const String admin = 'Administración';

  // Autenticación
  static const String welcome = '¡Bienvenido a NovaFit!';
  static const String login = 'Iniciar Sesión';
  static const String register = 'Registrarse';
  static const String email = 'Correo Electrónico';
  static const String password = 'Contraseña';
  static const String confirmPassword = 'Confirmar Contraseña';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String noAccount = '¿No tienes cuenta?';
  static const String hasAccount = '¿Ya tienes cuenta?';
  static const String createAccount = 'Crear Cuenta';
  static const String fullName = 'Nombre Completo';
  static const String phone = 'Teléfono';

  // Eventos
  static const String availableEvents = 'Eventos Disponibles';
  static const String eventDetails = 'Detalles del Evento';
  static const String bookNow = 'Reservar Ahora';
  static const String booked = 'Reservado';
  static const String soldOut = 'Agotado';
  static const String spotsLeft = 'cupos disponibles';
  static const String duration = 'Duración';
  static const String instructor = 'Instructor';
  static const String date = 'Fecha';
  static const String time = 'Hora';
  static const String capacity = 'Capacidad';

  // Reservas
  static const String myReservations = 'Mis Reservas';
  static const String upcomingEvents = 'Próximos Eventos';
  static const String pastEvents = 'Eventos Pasados';
  static const String cancelBooking = 'Cancelar Reserva';
  static const String confirmCancel = '¿Estás seguro de cancelar?';
  static const String bookingCancelled = 'Reserva cancelada';
  static const String bookingConfirmed = 'Reserva confirmada';

  // Estados
  static const String loading = 'Cargando...';
  static const String error = 'Error';
  static const String success = 'Éxito';
  static const String noData = 'No hay datos disponibles';
  static const String noEvents = 'No hay eventos disponibles';
  static const String noBookings = 'No tienes reservas';
  static const String tryAgain = 'Intentar de nuevo';

  // Validaciones
  static const String emailRequired = 'El correo es requerido';
  static const String emailInvalid = 'Correo inválido';
  static const String passwordRequired = 'La contraseña es requerida';
  static const String passwordTooShort = 'Mínimo 6 caracteres';
  static const String passwordsDontMatch = 'Las contraseñas no coinciden';
  static const String nameRequired = 'El nombre es requerido';

  // Mensajes
  static const String loginSuccess = 'Bienvenido de vuelta';
  static const String registerSuccess = 'Cuenta creada exitosamente';
  static const String logoutSuccess = 'Sesión cerrada';
  static const String loginError = 'Error al iniciar sesión';
  static const String registerError = 'Error al crear cuenta';
  static const String bookingError = 'Error al reservar';
  static const String eventFull = 'El evento está lleno';
  static const String alreadyBooked = 'Ya tienes una reserva para este evento';
}

class AppDimensions {
  // Espaciado
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Tamaños de fuente
  static const double fontSmall = 12.0;
  static const double fontMedium = 14.0;
  static const double fontLarge = 16.0;
  static const double fontXLarge = 18.0;
  static const double fontXXLarge = 20.0;
  static const double fontTitle = 24.0;
  static const double fontHeader = 28.0;

  // Bordes
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // Elevaciones
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // Alturas
  static const double buttonHeight = 50.0;
  static const double inputHeight = 56.0;
  static const double cardHeight = 120.0;
  static const double eventCardHeight = 280.0;
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 2000);
}

class EventCategory {
  static const String boxing = 'boxing';
  static const String fitness = 'fitness';
  static const String yoga = 'yoga';
  static const String dance = 'dance';
  static const String cardio = 'cardio';
  static const String strength = 'strength';
  static const String pilates = 'pilates';
  static const String crossfit = 'crossfit';

  static const Map<String, String> categoryNames = {
    boxing: 'Boxeo',
    fitness: 'Fitness',
    yoga: 'Yoga',
    dance: 'Baile',
    cardio: 'Cardio',
    strength: 'Fuerza',
    pilates: 'Pilates',
    crossfit: 'CrossFit',
  };

  static const Map<String, IconData> categoryIcons = {
    boxing: Icons.sports_martial_arts,
    fitness: Icons.fitness_center,
    yoga: Icons.self_improvement,
    dance: Icons.music_note,
    cardio: Icons.directions_run,
    strength: Icons.sports_gymnastics,
    pilates: Icons.spa,
    crossfit: Icons.sports_handball,
  };
}

class UserRole {
  static const String user = 'user';
  static const String admin = 'admin';
}

class BookingStatus {
  static const String confirmed = 'confirmed';
  static const String cancelled = 'cancelled';
  static const String completed = 'completed';
  static const String noShow = 'no_show';
}