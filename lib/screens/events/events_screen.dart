import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/event_model.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'create_event_screen.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  PageController _calendarController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text('Eventos'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAdmin) {
                return IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateEventScreen()),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarSection(),
          _buildCategoryFilter(),
          Expanded(child: _buildEventsList()),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      height: 120,
      color: AppColors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy', 'es').format(_selectedDate),
                  style: TextStyle(
                    fontSize: AppDimensions.fontXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.today, color: AppColors.primary),
                  onPressed: () => _selectToday(),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _calendarController,
              onPageChanged: (index) {
                setState(() {
                  _selectedDate = DateTime.now().add(Duration(days: index - 30));
                });
                Provider.of<EventsProvider>(context, listen: false)
                    .setSelectedDate(_selectedDate);
              },
              itemBuilder: (context, pageIndex) {
                final baseDate = DateTime.now().add(Duration(days: pageIndex - 30));
                return _buildWeekView(baseDate);
              },
              itemCount: 61, // 30 días atrás + hoy + 30 días adelante
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(DateTime baseDate) {
    final weekStart = baseDate.subtract(Duration(days: baseDate.weekday - 1));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Row(
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          final isToday = date.day == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year;

          return Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(date),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'es').format(date).substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: AppDimensions.fontSmall,
                        color: isSelected ? AppColors.dark : AppColors.dark.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: AppDimensions.fontMedium,
                        color: isSelected ? AppColors.dark : AppColors.dark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      color: AppColors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        children: [
          _buildCategoryChip('Todos', null),
          ...EventCategory.categoryNames.entries.map(
                (entry) => _buildCategoryChip(entry.value, entry.key),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;

    return Container(
      margin: EdgeInsets.only(right: AppDimensions.paddingSmall, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          Provider.of<EventsProvider>(context, listen: false)
              .setSelectedCategory(_selectedCategory);
        },
        backgroundColor: AppColors.lightGray,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.dark : AppColors.dark.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (eventsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 60, color: AppColors.error),
                SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  'Error al cargar eventos',
                  style: TextStyle(fontSize: AppDimensions.fontLarge),
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  eventsProvider.error!,
                  style: TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                ElevatedButton(
                  onPressed: () => eventsProvider.loadEvents(),
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final events = eventsProvider.events;

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: AppColors.mediumGray,
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  'No hay eventos',
                  style: TextStyle(
                    fontSize: AppDimensions.fontXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'No hay eventos disponibles para la fecha seleccionada',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMedium,
                    color: AppColors.dark.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: Container(
                margin: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
                child: EventCard(
                  event: event,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(event: event),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    Provider.of<EventsProvider>(context, listen: false).setSelectedDate(date);
  }

  void _selectToday() {
    final today = DateTime.now();
    _selectDate(today);
    _calendarController.animateToPage(
      30, // Página central (hoy)
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}