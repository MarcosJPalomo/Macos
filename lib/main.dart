import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:novafit_gym/screens/events/events_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/events_provider.dart';
import 'providers/bookings_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/events/event_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/bookings/my_bookings_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBoVMYwrdQrgPla7290IY5Rx746g9uTDoU",
        authDomain: "novafitapp-9e463.firebaseapp.com",
        projectId: "novafitapp-9e463",
        storageBucket: "novafitapp-9e463.firebasestorage.app",
        messagingSenderId: "427010099137",
        appId: "1:427010099137:web:bde84d6744dc24b7c21140",
        measurementId: "G-02FSLBYJZ7",
      ),
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app') ||
        e.toString().contains('already exists')) {
      print('Firebase ya inicializado, continuando...');
    } else {
      print('Error inicializando Firebase: $e');
      rethrow;
    }
  }

  runApp(NovaFitApp());
}

class NovaFitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
      ],
      child: MaterialApp(
        title: 'NovaFit Gym',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme.copyWith(
              bodyLarge: TextStyle(color: AppColors.textPrimary),
              bodyMedium: TextStyle(color: AppColors.textPrimary),
              displayLarge: TextStyle(color: AppColors.textPrimary),
              displayMedium: TextStyle(color: AppColors.textPrimary),
              displaySmall: TextStyle(color: AppColors.textPrimary),
              headlineLarge: TextStyle(color: AppColors.textPrimary),
              headlineMedium: TextStyle(color: AppColors.textPrimary),
              headlineSmall: TextStyle(color: AppColors.textPrimary),
              titleLarge: TextStyle(color: AppColors.textPrimary),
              titleMedium: TextStyle(color: AppColors.textPrimary),
              titleSmall: TextStyle(color: AppColors.textPrimary),
              labelLarge: TextStyle(color: AppColors.textPrimary),
              labelMedium: TextStyle(color: AppColors.textPrimary),
              labelSmall: TextStyle(color: AppColors.textPrimary),
              bodySmall: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.cardBackground,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black, // Cambiado a negro
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.cardBackground,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            labelStyle: TextStyle(color: AppColors.textSecondary),
            hintStyle: TextStyle(color: AppColors.textSecondary),
            prefixIconColor: AppColors.primary,
            suffixIconColor: AppColors.textSecondary,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppColors.cardBackground,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            elevation: 8,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: AppColors.cardBackground,
            surfaceTintColor: Colors.transparent,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.cardBackground,
            contentTextStyle: TextStyle(color: AppColors.textPrimary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
          dividerTheme: DividerThemeData(
            color: AppColors.divider,
            thickness: 1,
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: AppColors.primary,
          ),
          tabBarTheme: TabBarThemeData(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: AppColors.cardBackground,
            textStyle: TextStyle(color: AppColors.textPrimary),
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: AuthWrapper(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/events': (context) => EventsScreen(),
          '/profile': (context) => ProfileScreen(),
          '/my-bookings': (context) => MyBookingsScreen(),
          '/admin': (context) => AdminPanelScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return SplashScreen();
        }

        if (authProvider.user != null) {
          return HomeScreen();
        }

        return LoginScreen();
      },
    );
  }
}