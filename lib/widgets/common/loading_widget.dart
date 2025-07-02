// widgets/common/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Pulse(
            infinite: true,
            duration: AppAnimations.medium,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(size / 2),
              ),
              child: Icon(
                Icons.fitness_center,
                color: AppColors.white,
                size: size * 0.5,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppDimensions.paddingMedium),
            Text(
              message!,
              style: TextStyle(
                fontSize: AppDimensions.fontLarge,
                color: AppColors.dark.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}