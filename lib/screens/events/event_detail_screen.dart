import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../providers/events_provider.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isBooking = false;
  bool _hasBooked = false;

  @override
  void initState() {
    super.initState();
    _checkBookingStatus();
  }

  Future<void> _checkBookingStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingsProvider = Provider.of<BookingsProvider>(context, listen: false);

    if (authProvider.user != null) {
      final hasBooked = await bookingsProvider.hasUserBookedEvent(
        authProvider.user!.id,
        widget.event.id,
      );

      if (mounted) {
        setState(() => _hasBooked = hasBooked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildEventDetails(),
        ],
      ),
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.share, color: AppColors.dark),
            onPressed: _shareEvent,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.event.imageUrl != null)
              CachedNetworkImage(
                imageUrl: widget.event.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Icon(
                    EventCategory.categoryIcons[widget.event.category] ?? Icons.fitness_center,
                    size: 80,
                    color: AppColors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Icon(
                    EventCategory.categoryIcons[widget.event.category] ?? Icons.fitness_center,
                    size: 80,
                    color: AppColors.white,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusLarge),
                    topRight: Radius.circular(AppDimensions.radiusLarge),
                  ),
                ),
                child: Icon(
                  EventCategory.categoryIcons[widget.event.category] ?? Icons.fitness_center,
                  size: 60,
                  color: AppColors.white,
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Event status badge
            Positioned(
              top: 100,
              right: 20,
              child: FadeInRight(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: widget.event.isFull
                        ? AppColors.error
                        : widget.event.availableSpots <= 5
                        ? AppColors.warning
                        : AppColors.success,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                  child: Text(
                    widget.event.isFull
                        ? 'AGOTADO'
                        : '${widget.event.availableSpots} CUPOS',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.fontMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusXLarge),
            topRight: Radius.circular(AppDimensions.radiusXLarge),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and category
              FadeInUp(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.title,
                            style: TextStyle(
                              fontSize: AppDimensions.fontHeader,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          SizedBox(height: AppDimensions.paddingSmall),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingMedium,
                              vertical: AppDimensions.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                            ),
                            child: Text(
                              EventCategory.categoryNames[widget.event.category] ?? 'Fitness',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: AppDimensions.fontMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.paddingLarge),

              // Event info cards
              FadeInUp(
                delay: Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.access_time,
                        title: 'Horario',
                        subtitle: '${widget.event.startTime} - ${widget.event.endTime}',
                      ),
                    ),
                    SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Fecha',
                        subtitle: DateFormat('dd/MM/yyyy').format(widget.event.date),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.paddingMedium),

              FadeInUp(
                delay: Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.person,
                        title: 'Instructor',
                        subtitle: widget.event.instructor,
                      ),
                    ),
                    SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.group,
                        title: 'Capacidad',
                        subtitle: '${widget.event.currentBookings}/${widget.event.maxCapacity}',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.paddingLarge),

              // Description
              FadeInUp(
                delay: Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: AppDimensions.fontXLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      widget.event.description,
                      style: TextStyle(
                        fontSize: AppDimensions.fontLarge,
                        color: AppColors.dark.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.paddingLarge),

              // Duration info
              FadeInUp(
                delay: Duration(milliseconds: 500),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          Icons.timer,
                          color: AppColors.white,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: AppDimensions.paddingMedium),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duración del evento',
                            style: TextStyle(
                              fontSize: AppDimensions.fontLarge,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                          Text(
                            '${widget.event.duration.inMinutes} minutos',
                            style: TextStyle(
                              fontSize: AppDimensions.fontMedium,
                              color: AppColors.dark.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Booking status message
              if (_hasBooked)
                FadeInUp(
                  delay: Duration(milliseconds: 600),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: AppDimensions.paddingLarge),
                    padding: EdgeInsets.all(AppDimensions.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 30,
                        ),
                        SizedBox(width: AppDimensions.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Ya estás registrado!',
                                style: TextStyle(
                                  fontSize: AppDimensions.fontLarge,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                'Tienes una reserva confirmada para este evento.',
                                style: TextStyle(
                                  fontSize: AppDimensions.fontMedium,
                                  color: AppColors.success.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          SizedBox(height: AppDimensions.paddingSmall),
          Text(
            title,
            style: TextStyle(
              fontSize: AppDimensions.fontSmall,
              color: AppColors.dark.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppDimensions.fontMedium,
              color: AppColors.dark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Consumer2<AuthProvider, BookingsProvider>(
        builder: (context, authProvider, bookingsProvider, child) {
          if (widget.event.isPast) {
            return CustomButton(
              text: 'Evento Finalizado',
              backgroundColor: AppColors.mediumGray,
              textColor: AppColors.dark.withOpacity(0.7),
              onPressed: null,
            );
          }

          if (_hasBooked) {
            return CustomButton(
              text: 'Ver Mis Reservas',
              backgroundColor: AppColors.success,
              textColor: AppColors.white,
              onPressed: () => Navigator.pushNamed(context, '/my-bookings'),
              icon: Icons.bookmark,
            );
          }

          if (widget.event.isFull) {
            return CustomButton(
              text: 'Evento Agotado',
              backgroundColor: AppColors.error,
              textColor: AppColors.white,
              onPressed: null,
            );
          }

          return CustomButton(
            text: widget.event.availableSpots <= 5
                ? 'Reservar (¡Solo ${widget.event.availableSpots} cupos!)'
                : 'Reservar Cupo',
            isLoading: _isBooking,
            onPressed: () => _bookEvent(authProvider, bookingsProvider),
            icon: Icons.add,
          );
        },
      ),
    );
  }

  Future<void> _bookEvent(AuthProvider authProvider, BookingsProvider bookingsProvider) async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes iniciar sesión para reservar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final success = await bookingsProvider.createBooking(
        userId: authProvider.user!.id,
        eventId: widget.event.id,
        userName: authProvider.user!.fullName,
        userEmail: authProvider.user!.email,
        event: widget.event,
      );

      if (success) {
        setState(() => _hasBooked = true);

        // ACTUALIZAR EL EVENTO LOCALMENTE
        final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
        final updatedEvent = widget.event.copyWith(
          currentBookings: widget.event.currentBookings + 1,
        );

        // Forzar actualización del evento en el provider
        eventsProvider.loadEvents();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Reserva confirmada exitosamente!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingsProvider.error ?? 'Error al reservar'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reservar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isBooking = false);
    }
  }

  void _shareEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de compartir próximamente'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}