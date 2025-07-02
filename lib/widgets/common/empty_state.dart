// widgets/common/empty_state.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/constants.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppDimensions.paddingLarge),
            FadeInUp(
              delay: Duration(milliseconds: 200),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppDimensions.fontXXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            FadeInUp(
              delay: Duration(milliseconds: 300),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: AppDimensions.fontLarge,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: AppDimensions.paddingLarge),
              FadeInUp(
                delay: Duration(milliseconds: 400),
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.dark,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingLarge,
                      vertical: AppDimensions.paddingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  child: Text(
                    actionText!,
                    style: TextStyle(
                      fontSize: AppDimensions.fontLarge,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}