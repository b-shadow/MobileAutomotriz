import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/auth/domain/entities/user.dart';
import 'package:mobile1_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile1_app/features/auth/presentation/cubit/auth_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Role-based visibility helpers  (mirror de roleHelper.js del frontend)
// ─────────────────────────────────────────────────────────────────────────────

extension _RoleHelpers on User {
  /// ADMIN, ASESOR DE SERVICIO, USUARIO
  bool get canViewVehiculos => isAdmin || isAsesor || isUsuario;

  /// ADMIN, ASESOR DE SERVICIO, USUARIO, MECÁNICO
  bool get canViewServiciosCatalogo =>
      isAdmin || isAsesor || isUsuario || isMecanico;

  /// Todos los roles autenticados
  bool get canViewEspaciosTrabajo => true;

  /// ADMIN, ASESOR DE SERVICIO, USUARIO, MECÁNICO
  bool get canViewPlanVehiculo =>
      isAdmin || isAsesor || isUsuario || isMecanico;

  /// ADMIN, ASESOR DE SERVICIO, USUARIO
  bool get canViewCitas => isAdmin || isAsesor || isUsuario;

  /// ADMIN, ASESOR DE SERVICIO
  bool get canViewRecepcionVehiculo => isAdmin || isAsesor;

  /// ADMIN, ASESOR DE SERVICIO
  bool get canViewPresupuestos => isAdmin || isAsesor;

  /// ADMIN, ASESOR DE SERVICIO
  bool get canViewOrdenesTrabajo => isAdmin || isAsesor;

  /// ADMIN, ASESOR DE SERVICIO, MECÁNICO
  bool get canViewTallerInterno => isAdmin || isAsesor || isMecanico;

  /// Avance General Vehículo: todos los roles (visible para todos en el frontend)
  bool get canViewAvanceVehiculo => true;

  /// ADMIN solamente
  bool get canManageUsers => isAdmin;

  /// ADMIN solamente
  bool get canManageCompany => isAdmin;

  /// ADMIN solamente
  bool get canManageSuscription => isAdmin;

  /// ADMIN solamente
  bool get canViewBitacora => isAdmin;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Home page — muestra los módulos visibles según el rol del usuario autenticado.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate handled by router redirect
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkBackground,
                AppColors.darkSurface,
              ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is! AuthAuthenticated) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  );
                }

                final user = state.user;
                return _buildContent(context, user);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${user.nombres}!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.empresaNombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),

              // Logout button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white70,
                  ),
                  tooltip: 'Cerrar sesión',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── User Info Card ──────────────────────────
          _buildInfoCard(
            context,
            icon: Icons.person_rounded,
            title: 'Información de Cuenta',
            items: [
              _InfoItem('Nombre', user.fullName),
              _InfoItem('Email', user.email),
              _InfoItem('Teléfono', user.telefono ?? 'No registrado'),
              _InfoItem('Rol', user.rolNombre),
            ],
          ),
          const SizedBox(height: 20),

          // ── Quick Stats ─────────────────────────────
          _buildInfoCard(
            context,
            icon: Icons.dashboard_rounded,
            title: 'Panel Principal',
            items: [
              _InfoItem('Empresa', user.empresaNombre),
              _InfoItem('Estado', user.isActive ? 'Activo' : 'Inactivo'),
              _InfoItem('Tipo', user.isAdmin ? 'Administrador' : 'Usuario'),
            ],
          ),
          const SizedBox(height: 32),

          // ── Módulos de Gestión de Usuarios (solo ADMIN) ─
          if (user.canManageCompany) ...[
            _buildModuleButton(
              context,
              label: 'Gestionar Empresa',
              icon: Icons.business_rounded,
              iconColor: Colors.blueAccent,
              route: '/company-management',
            ),
            const SizedBox(height: 12),
          ],

          if (user.canManageSuscription) ...[
            _buildModuleButton(
              context,
              label: 'Gestionar Suscripcion',
              icon: Icons.receipt_long,
              iconColor: Colors.amberAccent,
              route: '/subscription-management',
            ),
            const SizedBox(height: 12),
          ],

          if (user.canManageUsers) ...[
            _buildModuleButton(
              context,
              label: 'Gestionar Usuarios y Roles',
              icon: Icons.manage_accounts,
              iconColor: Colors.yellowAccent,
              route: '/user-management',
            ),
            const SizedBox(height: 12),
          ],

          if (user.canViewBitacora) ...[
            _buildModuleButton(
              context,
              label: 'Gestionar Bitacora',
              icon: Icons.history,
              iconColor: Colors.purpleAccent,
              route: '/audit-management',
            ),
            const SizedBox(height: 12),
          ],

          // ── Editar Perfil (todos) ────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text(
                'Editar Perfil de Usuario',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Vehículos y Servicios ────────────────────
          if (user.canViewVehiculos) ...[
            _buildModuleButton(
              context,
              label: 'Gestionar Vehiculos',
              icon: Icons.directions_car,
              iconColor: Colors.greenAccent,
              route: '/vehicle-management',
            ),
            const SizedBox(height: 12),
          ],

          if (user.canViewServiciosCatalogo) ...[
            _buildModuleButton(
              context,
              label: 'Gestionar Catalogo de Servicios',
              icon: Icons.build_circle_outlined,
              iconColor: Colors.orangeAccent,
              route: '/service-catalog-management',
            ),
            const SizedBox(height: 12),
          ],

          if (user.canViewEspaciosTrabajo) ...[
            _buildModuleButton(
              context,
              label: 'Configurar Espacios de Trabajo',
              icon: Icons.warehouse_outlined,
              iconColor: Colors.cyanAccent,
              route: '/workspace-management',
            ),
            const SizedBox(height: 12),
          ],

          if (user.canViewPlanVehiculo) ...[
            _buildModuleButton(
              context,
              label: 'Gestionar Plan de Vehiculo',
              icon: Icons.assignment_turned_in,
              iconColor: Colors.lightBlueAccent,
              route: '/vehicle-plan-management',
            ),
            const SizedBox(height: 12),
          ],

          if (user.canViewCitas) ...[
            _buildModuleButton(
              context,
              label: 'Gestionar Citas',
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.primary,
              route: '/appointment-management',
              borderColor: AppColors.primary,
            ),
            const SizedBox(height: 12),
          ],

          // ── Atención Técnica ─────────────────────────
          if (user.canViewRecepcionVehiculo) ...[
            _buildModuleButton(
              context,
              label: 'Recepción e Inspección',
              icon: Icons.car_repair_rounded,
              iconColor: AppColors.success,
              route: '/reception-management',
              borderColor: AppColors.success,
            ),
            const SizedBox(height: 12),
          ],

          if (user.canViewPresupuestos) ...[
            _buildModuleButton(
              context,
              label: 'Gestión de Presupuestos',
              icon: Icons.request_quote_rounded,
              iconColor: AppColors.warning,
              route: '/budget-management',
              borderColor: AppColors.warning,
            ),
            const SizedBox(height: 12),
          ],

          if (user.canViewOrdenesTrabajo) ...[
            _buildModuleButton(
              context,
              label: 'Órdenes de Trabajo',
              icon: Icons.handyman_rounded,
              iconColor: AppColors.success,
              route: '/work-orders',
              borderColor: AppColors.success,
            ),
            const SizedBox(height: 12),
          ],

          if (user.canViewTallerInterno) ...[
            _buildModuleButton(
              context,
              label: 'Avance en Taller',
              icon: Icons.garage_rounded,
              iconColor: AppColors.primary,
              route: '/workshop-progress',
              borderColor: AppColors.primary,
            ),
            const SizedBox(height: 12),
          ],

          if (user.canViewAvanceVehiculo) ...[
            _buildModuleButton(
              context,
              label: 'Avance General Vehículo',
              icon: Icons.directions_car,
              iconColor: AppColors.info,
              route: '/vehicle-progress',
              borderColor: AppColors.info,
            ),
            const SizedBox(height: 12),
          ],

          // ── Inteligencia Artificial (todos) ──────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/ai'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.smart_toy,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                'Asistente Virtual con IA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Reportes (todos) ─────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/reports/vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.analytics_rounded,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                'Reportes de Vehículo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Placeholder message ─────────────────────
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.build_rounded,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Módulos en desarrollo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los módulos de vehículos, citas, inventario y más se irán agregando próximamente.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botón de módulo genérico con restricción de rol.
  Widget _buildModuleButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color iconColor,
    required String route,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.push(route),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkCard,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: borderColor != null
                  ? borderColor.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        icon: Icon(icon, size: 20, color: iconColor),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        item.value,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tu sesión actual se cerrará y deberás iniciar sesión nuevamente.',
          style: TextStyle(color: Colors.white60, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthCubit>().logoutUser();
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}
