// screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/app_logo.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (user == null) return Center(child: CircularProgressIndicator());

          return CustomScrollView(
            slivers: [
              _buildAppBar(user.fullName),
              _buildProfileContent(authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(String userName) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              FadeInDown(
                child: AppLogo(
                  size: 80,
                  backgroundColor: AppColors.white,
                ),
              ),
              SizedBox(height: 16),
              FadeInUp(
                delay: Duration(milliseconds: 200),
                child: Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(AuthProvider authProvider) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Form
            FadeInUp(
              delay: Duration(milliseconds: 300),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Información Personal',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(_isEditing ? Icons.save : Icons.edit),
                              onPressed: _isEditing ? _saveProfile : _toggleEdit,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          controller: _nameController,
                          label: 'Nombre Completo',
                          readOnly: !_isEditing,
                          prefixIcon: Icons.person,
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          readOnly: true,
                          prefixIcon: Icons.email,
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Teléfono',
                          readOnly: !_isEditing,
                          prefixIcon: Icons.phone,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Stats Card
            FadeInUp(
              delay: Duration(milliseconds: 400),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem('Reservas Totales', '12'),
                          ),
                          Expanded(
                            child: _buildStatItem('Este Mes', '5'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Actions
            FadeInUp(
              delay: Duration(milliseconds: 500),
              child: Column(
                children: [
                  CustomButton(
                    text: 'Mis Reservas',
                    icon: Icons.bookmark,
                    onPressed: () => Navigator.pushNamed(context, '/my-bookings'),
                  ),
                  SizedBox(height: 16),
                  if (authProvider.isAdmin)
                    CustomButton(
                      text: 'Panel de Administración',
                      icon: Icons.admin_panel_settings,
                      backgroundColor: AppColors.primaryDark,
                      onPressed: () => Navigator.pushNamed(context, '/admin'),
                    ),
                  SizedBox(height: 16),
                  CustomButton(
                    text: 'Cerrar Sesión',
                    icon: Icons.logout,
                    backgroundColor: AppColors.error,
                    textColor: AppColors.white,
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.dark.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user!;

      final updatedUser = user.copyWith(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      final success = await authProvider.updateProfile(updatedUser);

      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil actualizado'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar perfil'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}