// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/event_card.dart';
import '../events/event_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../admin/admin_panel_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      final bookingsProvider = Provider.of<BookingsProvider>(context, listen: false);

      if (authProvider.user != null) {
        bookingsProvider.loadUserBookings(authProvider.user!.id);
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildDateSelector(),
            _buildCategoryFilter(),
            _buildEventsList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.radiusXLarge),
            bottomRight: Radius.circular(AppDimensions.radiusXLarge),
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return FadeInDown(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, ${authProvider.user?.fullName.split(' ').first ?? 'Usuario'}! 👋',
                            style: TextStyle(
                              fontSize: AppDimensions.fontXXLarge,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: AppDimensions.paddingSmall),
                          Text(
                            'Encuentra tu próximo entrenamiento',
                            style: TextStyle(
                              fontSize: AppDimensions.fontLarge,
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfileScreen()),
                        ),
                        child: AppLogo(
                          size: 50,
                          backgroundColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.paddingLarge),

                  // Stats rápidas
                  Consumer<BookingsProvider>(
                    builder: (context, bookingsProvider, child) {
                      final upcomingBookings = bookingsProvider.getUpcomingBookings();
                      return Row(
                        children: [
                          _buildStatCard(
                            icon: Icons.event,
                            label: 'Próximas',
                            value: '${upcomingBookings.length}',
                          ),
                          SizedBox(width: AppDimensions.paddingMedium),
                          _buildStatCard(
                            icon: Icons.fitness_center,
                            label: 'Este mes',
                            value: '${bookingsProvider.userBookings.length}',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.white, size: 20),
            SizedBox(width: AppDimensions.paddingSmall),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppDimensions.fontLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppDimensions.fontSmall,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        margin: EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
          itemCount: 7,
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index));
            final isSelected = date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;

            return FadeInLeft(
              delay: Duration(milliseconds: index * 100),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                  Provider.of<EventsProvider>(context, listen: false)
                      .setSelectedDate(date);
                },
                child: Container(
                  width: 70,
                  margin: EdgeInsets.only(right: AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          fontSize: AppDimensions.fontSmall,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.white : AppColors.dark.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: AppDimensions.fontLarge,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.white : AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = EventCategory.categoryNames.entries.toList();

    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              final isSelected = _selectedCategory == null;
              return FadeInLeft(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = null);
                    Provider.of<EventsProvider>(context, listen: false)
                        .setSelectedCategory(null);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: AppDimensions.paddingSmall),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    child: Center(
                      child: Text(
                        'Todos',
                        style: TextStyle(
                          fontSize: AppDimensions.fontMedium,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.white : AppColors.dark,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            final category = categories[index - 1];
            final isSelected = _selectedCategory == category.key;

            return FadeInLeft(
              delay: Duration(milliseconds: index * 50),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = category.key);
                  Provider.of<EventsProvider>(context, listen: false)
                      .setSelectedCategory(category.key);
                },
                child: Container(
                  margin: EdgeInsets.only(right: AppDimensions.paddingSmall),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                  child: Center(
                    child: Text(
                      category.value,
                      style: TextStyle(
                        fontSize: AppDimensions.fontMedium,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.dark,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.isLoading) {
          return SliverFillRemaining(
            child: LoadingWidget(message: 'Cargando eventos...'),
          );
        }

        if (eventsProvider.events.isEmpty) {
          return SliverFillRemaining(
            child: EmptyState(
              icon: Icons.event_busy,
              title: 'No hay eventos',
              message: 'No hay eventos disponibles para esta fecha.',
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final event = eventsProvider.events[index];
                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
                    child: EventCard(
                      event: event,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: eventsProvider.events.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusXLarge),
              topRight: Radius.circular(AppDimensions.radiusXLarge),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Inicio',
                isSelected: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.bookmark,
                label: 'Reservas',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyBookingsScreen()),
                ),
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Perfil',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                ),
              ),
              if (authProvider.isAdmin)
                _buildNavItem(
                  icon: Icons.admin_panel_settings,
                  label: 'Admin',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminPanelScreen()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.dark.withOpacity(0.6),
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDimensions.fontSmall,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.dark.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}