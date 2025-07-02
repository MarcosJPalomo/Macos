// widgets/common/error_widget.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/constants.dart';
import 'custom_button.dart';
import 'package:animate_do/animate_do.dart';
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElasticIn(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
              ),
            ),
            SizedBox(height: AppDimensions.paddingLarge),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: AppDimensions.fontXXLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            Text(
              message,
              style: TextStyle(
                fontSize: AppDimensions.fontLarge,
                color: AppColors.dark.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppDimensions.paddingLarge),
              CustomButton(
                text: AppStrings.tryAgain,
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}