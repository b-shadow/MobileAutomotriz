import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile1_app/features/auth/presentation/cubit/auth_state.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/change_password_modal.dart';
import '../widgets/edit_personal_info_modal.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showEditPersonalInfo(BuildContext context, AuthAuthenticated authState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EditPersonalInfoModal(
        user: authState.user,
        onSave: (nombres, apellidos, telefono) {
          context.read<ProfileCubit>().updateInfo(
                id: authState.user.id,
                nombres: nombres,
                apellidos: apellidos,
                telefono: telefono,
              );
        },
      ),
    );
  }

  void _showChangePassword(BuildContext context, AuthAuthenticated authState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ChangePasswordModal(
        onSave: (currentPwd, newPwd) {
          context.read<ProfileCubit>().changePassword(
                id: authState.user.id,
                currentPassword: currentPwd,
                newPassword: newPwd,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoading) {
          // Show loading indication if needed
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        } else if (state is ProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          if (state.updatedUser != null) {
            // Update the global auth session
            context.read<AuthCubit>().updateUser(state.updatedUser!);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text('Editar Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              Text(
                'Actualiza tu información personal',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = authState.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Información Personal
                  _buildCard(
                    title: 'Información Personal',
                    action: ElevatedButton.icon(
                      onPressed: () => _showEditPersonalInfo(context, authState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildInfoItem('Nombres', user.nombres)),
                            Expanded(child: _buildInfoItem('Apellidos', user.apellidos)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildInfoItem('Email (No editable)', user.email)),
                            Expanded(child: _buildInfoItem('Teléfono', user.telefono ?? 'No especificado')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Seguridad
                  _buildCard(
                    title: 'Seguridad',
                    titleIcon: Icons.lock,
                    titleIconColor: Colors.amber,
                    backgroundColor: const Color(0xFF281F1E), // Slightly brownish for security
                    action: OutlinedButton.icon(
                      onPressed: () => _showChangePassword(context, authState),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5CF6),
                        side: const BorderSide(color: Color(0xFF8B5CF6)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.key, size: 16),
                      label: const Text('Cambiar Contraseña'),
                    ),
                    child: const Text(
                      'Actualiza tu contraseña para mantener tu cuenta segura.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Preferencias de Notificación
                  _buildCard(
                    title: 'Preferencias de Notificación',
                    titleIcon: Icons.notifications,
                    titleIconColor: Colors.amber,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Controla cómo deseas recibir notificaciones en el futuro. Estos canales estarán disponibles cuando se implemente el sistema de notificaciones.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        _buildNotificationToggle(
                          icon: Icons.email,
                          title: 'Notificaciones por Email',
                          subtitle: 'Recibe actualizaciones por correo electrónico',
                          value: user.notiEmail,
                          onChanged: (val) {
                            context.read<ProfileCubit>().updatePreferences(
                                  id: user.id,
                                  notiEmail: val,
                                  notiPush: user.notiPush,
                                );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildNotificationToggle(
                          icon: Icons.notifications_active,
                          title: 'Notificaciones Push',
                          subtitle: 'Recibe notificaciones instantáneas en el navegador',
                          value: user.notiPush,
                          onChanged: (val) {
                            context.read<ProfileCubit>().updatePreferences(
                                  id: user.id,
                                  notiEmail: user.notiEmail,
                                  notiPush: val,
                                );
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Nota: Estos son solo tus canales preferidos. El sistema de envío de notificaciones se implementará en el futuro.',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Información Adicional
                  _buildCard(
                    title: 'Información Adicional',
                    titleIcon: Icons.info,
                    titleIconColor: Colors.blueAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rol en ${user.empresaNombre}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(user.rolNombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    IconData? titleIcon,
    Color? titleIconColor,
    Widget? action,
    Color backgroundColor = const Color(0xFF1E293B),
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (titleIcon != null) ...[
                    Icon(titleIcon, color: titleIconColor, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: Colors.blueAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
