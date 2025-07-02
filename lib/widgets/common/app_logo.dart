// widgets/common/app_logo.dart
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final Color? backgroundColor;

  const AppLogo({
    Key? key,
    this.size = 80,
    this.showShadow = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.asset(
          'assets/images/logo.png', // Tu imagen personalizada
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback al icono original si no encuentra la imagen
            return Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
              child: Icon(
                Icons.fitness_center,
                size: size * 0.5,
                color: AppColors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}