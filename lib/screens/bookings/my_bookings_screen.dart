// screens/bookings/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/events_provider.dart';
import '../../models/booking_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state.dart';

class MyBookingsScreen extends StatefulWidget {
  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<BookingsProvider>(context, listen: false)
            .loadUserBookings(authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reservas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Próximas'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingBookings(),
          _buildPastBookings(),
        ],
      ),
    );
  }

  Widget _buildUpcomingBookings() {
    return Consumer<BookingsProvider>(
      builder: (context, bookingsProvider, child) {
        if (bookingsProvider.isLoading) {
          return LoadingWidget(message: 'Cargando reservas...');
        }

        final upcomingBookings = bookingsProvider.getUpcomingBookings();

        if (upcomingBookings.isEmpty) {
          return EmptyState(
            icon: Icons.event_busy,
            title: 'No tienes reservas',
            message: 'Reserva un evento para que aparezca aquí.',
            actionText: 'Ver Eventos',
            onAction: () => Navigator.pushReplacementNamed(context, '/home'),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: upcomingBookings.length,
          itemBuilder: (context, index) {
            final booking = upcomingBookings[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildBookingCard(booking, isUpcoming: true),
            );
          },
        );
      },
    );
  }

  Widget _buildPastBookings() {
    return Consumer<BookingsProvider>(
      builder: (context, bookingsProvider, child) {
        if (bookingsProvider.isLoading) {
          return LoadingWidget(message: 'Cargando historial...');
        }

        final pastBookings = bookingsProvider.getPastBookings();

        if (pastBookings.isEmpty) {
          return EmptyState(
            icon: Icons.history,
            title: 'Sin historial',
            message: 'No tienes eventos pasados aún.',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: pastBookings.length,
          itemBuilder: (context, index) {
            final booking = pastBookings[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildBookingCard(booking, isUpcoming: false),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking, {required bool isUpcoming}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.event?.title ?? 'Evento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(booking.event?.date ?? DateTime.now()),
                  style: TextStyle(color: AppColors.dark.withOpacity(0.7)),
                ),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  '${booking.event?.startTime} - ${booking.event?.endTime}',
                  style: TextStyle(color: AppColors.dark.withOpacity(0.7)),
                ),
              ],
            ),
            if (booking.event?.instructor != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    booking.event!.instructor,
                    style: TextStyle(color: AppColors.dark.withOpacity(0.7)),
                  ),
                ],
              ),
            ],
            if (isUpcoming && booking.isConfirmed) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _cancelBooking(booking),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.mediumGray;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmado';
      case 'cancelled':
        return 'Cancelado';
      case 'completed':
        return 'Completado';
      default:
        return 'Desconocido';
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Reserva'),
        content: Text('¿Estás seguro de que quieres cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await Provider.of<BookingsProvider>(context, listen: false)
          .cancelBooking(booking.id, booking.eventId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reserva cancelada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar reserva'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}