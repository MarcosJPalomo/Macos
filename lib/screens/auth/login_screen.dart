import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/app_logo.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppDimensions.paddingXLarge),

              // Logo y título
              FadeInDown(
                child: Column(
                  children: [
                    AppLogo(size: 80),
                    SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: AppDimensions.fontHeader,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      AppStrings.welcome,
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
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.paddingLarge),

              // Botón de login
              FadeInUp(
                delay: Duration(milliseconds: 400),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: AppStrings.login,
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleLogin(authProvider),
                    );
                  },
                ),
              ),

              SizedBox(height: AppDimensions.paddingMedium),

              // Olvidé mi contraseña
              FadeInUp(
                delay: Duration(milliseconds: 500),
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: Text(
                    AppStrings.forgotPassword,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.paddingLarge),

              // Registro
              FadeInUp(
                delay: Duration(milliseconds: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.noAccount,
                      style: TextStyle(color: AppColors.dark.withOpacity(0.7)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      ),
                      child: Text(
                        AppStrings.register,
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

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      authProvider.clearError();

      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recuperar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingresa tu correo electrónico para recibir un enlace de recuperación.'),
            SizedBox(height: AppDimensions.paddingMedium),
            CustomTextField(
              controller: emailController,
              label: AppStrings.email,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return TextButton(
                onPressed: () async {
                  if (emailController.text.isNotEmpty) {
                    final success = await authProvider.resetPassword(emailController.text.trim());
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Enlace enviado a tu correo'
                            : 'Error al enviar enlace'),
                        backgroundColor: success ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                },
                child: Text('Enviar'),
              );
            },
          ),
        ],
      ),
    );
  }
}