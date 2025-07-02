import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../models/event_model.dart';
import '../../utils/constants.dart';
import '../events/create_event_screen.dart';
import '../events/events_screen.dart';
import 'package:flutter/material.dart';
import 'event_participants_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        Provider.of<EventsProvider>(context, listen: false).loadEvents();
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAdmin) {
          return Scaffold(
            body: Center(
              child: Text('Acceso denegado'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Panel de Admin'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                Tab(icon: Icon(Icons.event), text: 'Eventos'),
                Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(),
              _buildEventsManagement(),
              _buildStatsTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          SizedBox(height: 16),

          // Quick Actions Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildQuickActionCard(
                  'Crear Evento',
                  Icons.add_circle,
                  AppColors.primary,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateEventScreen()),
                  ),
                ),
                _buildQuickActionCard(
                  'Ver Todos los Eventos',
                  Icons.event_available,
                  AppColors.success,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventsScreen()),
                  ),
                ),
                _buildQuickActionCard(
                  'Gestionar Eventos',
                  Icons.edit_calendar,
                  AppColors.warning,
                      () => _tabController.animateTo(1),
                ),
                _buildQuickActionCard(
                  'Ver Estadísticas',
                  Icons.bar_chart,
                  AppColors.primaryDark,
                      () => _tabController.animateTo(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return FadeInUp(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsManagement() {
    return Column(
      children: [
        // Header with create button
        Container(
          padding: EdgeInsets.all(16),
          color: AppColors.lightGray,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestión de Eventos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEventScreen()),
                ),
                icon: Icon(Icons.add),
                label: Text('Crear Evento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.dark,
                ),
              ),
            ],
          ),
        ),

        // Events list
        Expanded(
          child: Consumer<EventsProvider>(
            builder: (context, eventsProvider, child) {
              if (eventsProvider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (eventsProvider.events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 80, color: AppColors.mediumGray),
                      SizedBox(height: 16),
                      Text('No hay eventos', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateEventScreen()),
                        ),
                        child: Text('Crear Primer Evento'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: eventsProvider.events.length,
                itemBuilder: (context, index) {
                  final event = eventsProvider.events[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100),
                    child: _buildEventAdminCard(event),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventAdminCard(EventModel event) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        EventCategory.categoryNames[event.category] ?? 'Fitness',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'participants',
                      child: Row(
                        children: [
                          Icon(Icons.people, size: 20),
                          SizedBox(width: 8),
                          Text('Ver Participantes'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'participants') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventParticipantsScreen(event: event),
                        ),
                      );
                    } else if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateEventScreen(event: event),
                        ),
                      );
                    } else if (value == 'delete') {
                      _deleteEvent(event);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                SizedBox(width: 4),
                Text(DateFormat('dd/MM/yyyy').format(event.date)),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: AppColors.primary),
                SizedBox(width: 4),
                Text('${event.startTime} - ${event.endTime}'),
              ],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppColors.primary),
                SizedBox(width: 4),
                Text(event.instructor),
                Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventParticipantsScreen(event: event),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          '${event.currentBookings}/${event.maxCapacity}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: event.isActive ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // En admin_panel_screen.dart - Reemplazar _buildStatsTab()

  // En admin_panel_screen.dart - Reemplazar _buildStatsTab()

  Widget _buildStatsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas del Sistema',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          SizedBox(height: 16),

          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: Provider.of<EventsProvider>(context, listen: false)
                  .firestoreService.getAdminStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error cargando estadísticas'));
                }

                final stats = snapshot.data ?? {};

                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    FadeInUp(
                      child: _buildStatCard(
                          'Eventos Totales',
                          '${stats['totalEvents'] ?? 0}',
                          Icons.event,
                          AppColors.primary
                      ),
                    ),
                    FadeInUp(
                      delay: Duration(milliseconds: 100),
                      child: _buildStatCard(
                          'Reservas Totales',
                          '${stats['totalBookings'] ?? 0}',
                          Icons.bookmark,
                          AppColors.success
                      ),
                    ),
                    FadeInUp(
                      delay: Duration(milliseconds: 200),
                      child: _buildStatCard(
                          'Usuarios',
                          '${stats['totalUsers'] ?? 0}',
                          Icons.people,
                          AppColors.warning
                      ),
                    ),
                    FadeInUp(
                      delay: Duration(milliseconds: 300),
                      child: _buildStatCard(
                          'Eventos Hoy',
                          '${stats['todayEvents'] ?? 0}',
                          Icons.today,
                          AppColors.error
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.dark.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEvent(EventModel event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Evento'),
        content: Text('¿Estás seguro de que quieres eliminar "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await Provider.of<EventsProvider>(context, listen: false)
          .deleteEvent(event.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evento "${event.title}" eliminado'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar evento'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}