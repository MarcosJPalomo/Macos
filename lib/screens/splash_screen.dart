// Actualización de splash_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/constants.dart';
import '../widgets/common/app_logo.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: AppAnimations.slow,
                child: AppLogo(
                  size: 120,
                  showShadow: true,
                ),
              ),
              SizedBox(height: AppDimensions.paddingLarge),
              FadeInUp(
                duration: AppAnimations.slow,
                delay: Duration(milliseconds: 200),
                child: Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: AppDimensions.fontHeader,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.paddingSmall),
              FadeInUp(
                duration: AppAnimations.slow,
                delay: Duration(milliseconds: 400),
                child: Text(
                  'Tu gimnasio, tu ritmo',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLarge,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}