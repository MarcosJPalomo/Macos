// screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              FadeInDown(
                child: Column(
                  children: [
                    Text(
                      AppStrings.createAccount,
                      style: TextStyle(
                        fontSize: AppDimensions.fontHeader,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      'Únete a la comunidad NovaFit',
                      style: TextStyle(
                        fontSize: AppDimensions.fontLarge,
                        color: AppColors.dark.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.paddingXLarge),

              // Formulario
              FadeInUp(
                delay: Duration(milliseconds: 200),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _fullNameController,
                        label: AppStrings.fullName,
                        prefixIcon: Icons.person_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.nameRequired;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppDimensions.paddingMedium),
                      CustomTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.emailRequired;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return AppStrings.emailInvalid;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppDimensions.paddingMedium),
                      CustomTextField(
                        controller: _phoneController,
                        label: AppStrings.phone,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      SizedBox(height: AppDimensions.paddingMedium),
                      CustomTextField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.passwordRequired;
                          }
                          if (value.length < 6) {
                            return AppStrings.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppDimensions.paddingMedium),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.passwordRequired;
                          }
                          if (value != _passwordController.text) {
                            return AppStrings.passwordsDontMatch;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.paddingLarge),

              // Botón de registro
              FadeInUp(
                delay: Duration(milliseconds: 400),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: AppStrings.createAccount,
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleRegister(authProvider),
                    );
                  },
                ),
              ),

              SizedBox(height: AppDimensions.paddingLarge),

              // Login
              FadeInUp(
                delay: Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.hasAccount,
                      style: TextStyle(color: AppColors.dark.withOpacity(0.7)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppStrings.login,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.error != null) {
                    return FadeInUp(
                      child: Container(
                        margin: EdgeInsets.only(top: AppDimensions.paddingMedium),
                        padding: EdgeInsets.all(AppDimensions.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(
                          authProvider.error!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: AppDimensions.fontMedium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      authProvider.clearError();

      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.registerSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }
}