// screens/admin/event_participants_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/event_model.dart';
import '../../models/booking_model.dart';
import '../../providers/bookings_provider.dart';
import '../../utils/constants.dart';

class EventParticipantsScreen extends StatefulWidget {
  final EventModel event;

  const EventParticipantsScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventParticipantsScreenState createState() => _EventParticipantsScreenState();
}

class _EventParticipantsScreenState extends State<EventParticipantsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<BookingsProvider>(context, listen: false)
        .loadEventBookings(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participantes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => Provider.of<BookingsProvider>(context, listen: false)
                .loadEventBookings(widget.event.id),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildEventHeader(),
          Expanded(child: _buildParticipantsList()),
        ],
      ),
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.event.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeaderStat(
                'Fecha',
                DateFormat('dd/MM/yyyy').format(widget.event.date),
              ),
              _buildHeaderStat(
                'Hora',
                '${widget.event.startTime} - ${widget.event.endTime}',
              ),
              _buildHeaderStat(
                'Ocupación',
                '${widget.event.currentBookings}/${widget.event.maxCapacity}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsList() {
    return Consumer<BookingsProvider>(
      builder: (context, bookingsProvider, child) {
        if (bookingsProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final participants = bookingsProvider.eventBookings;

        if (participants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: AppColors.mediumGray),
                SizedBox(height: 16),
                Text(
                  'Sin participantes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                Text(
                  'Nadie se ha registrado aún',
                  style: TextStyle(color: AppColors.dark.withOpacity(0.6)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildParticipantCard(participant, index + 1),
            );
          },
        );
      },
    );
  }

  Widget _buildParticipantCard(BookingModel booking, int position) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Número de posición
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),

            // Información del participante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    booking.userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.dark.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Reservado: ${DateFormat('dd/MM/yyyy HH:mm').format(booking.bookedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Estado
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
      case 'no_show':
        return AppColors.warning;
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
      case 'no_show':
        return 'No asistió';
      default:
        return 'Desconocido';
    }
  }
}