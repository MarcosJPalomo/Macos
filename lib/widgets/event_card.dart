// widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event_model.dart';
import '../utils/constants.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.eventCardHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del evento
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusLarge),
                    topRight: Radius.circular(AppDimensions.radiusLarge),
                  ),
                  gradient: AppColors.primaryGradient,
                ),
                child: Stack(
                  children: [
                    if (event.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppDimensions.radiusLarge),
                          topRight: Radius.circular(AppDimensions.radiusLarge),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: event.imageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.lightGray,
                            child: Icon(
                              EventCategory.categoryIcons[event.category] ?? Icons.fitness_center,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.lightGray,
                            child: Icon(
                              EventCategory.categoryIcons[event.category] ?? Icons.fitness_center,
                              size: 50,
                              color: AppColors.primary,
                            ),
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
                          EventCategory.categoryIcons[event.category] ?? Icons.fitness_center,
                          size: 60,
                          color: AppColors.white,
                        ),
                      ),

                    // Badge de categoría
                    Positioned(
                      top: AppDimensions.paddingMedium,
                      left: AppDimensions.paddingMedium,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmall,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: Text(
                          EventCategory.categoryNames[event.category] ?? 'Fitness',
                          style: TextStyle(
                            fontSize: AppDimensions.fontSmall,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                    ),

                    // Badge de estado
                    Positioned(
                      top: AppDimensions.paddingMedium,
                      right: AppDimensions.paddingMedium,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmall,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: event.isFull
                              ? AppColors.error
                              : event.availableSpots <= 5
                              ? AppColors.warning
                              : AppColors.success,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: Text(
                          event.isFull
                              ? 'Agotado'
                              : '${event.availableSpots} cupos',
                          style: TextStyle(
                            fontSize: AppDimensions.fontSmall,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Información del evento
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: AppDimensions.fontLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: AppDimensions.fontMedium,
                        color: AppColors.dark.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${event.startTime} - ${event.endTime}',
                          style: TextStyle(
                            fontSize: AppDimensions.fontMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          event.instructor,
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
          ],
        ),
      ),
    );
  }
}