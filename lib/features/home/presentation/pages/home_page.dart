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

  /// ADMIN, ASESOR DE SERVICIO, ALMACENERO
  bool get canViewInventario => isAdmin || isAsesor || isAlmacenero;

  /// ADMIN, ADMINISTRATIVO
  bool get canViewFacturas => isAdmin || isAdministrativo;
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes for module sections
// ─────────────────────────────────────────────────────────────────────────────

class _ModuleItem {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String route;
  final bool visible;

  const _ModuleItem({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.route,
    required this.visible,
  });
}

class _ModuleSection {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<_ModuleItem> items;

  const _ModuleSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.items,
  });

  List<_ModuleItem> get visibleItems =>
      items.where((item) => item.visible).toList();

  bool get hasVisibleItems => visibleItems.isNotEmpty;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Home page — muestra los módulos visibles según el rol del usuario autenticado.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Track which sections are expanded (first one starts expanded)
  final Map<int, bool> _expandedSections = {0: true};

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
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

  /// Build the list of module sections based on user roles.
  List<_ModuleSection> _buildSections(User user) {
    return [
      _ModuleSection(
        title: 'Gestión de Usuarios',
        icon: Icons.people_rounded,
        accentColor: AppColors.primary,
        items: [
          _ModuleItem(
            label: 'Editar Perfil de Usuario',
            icon: Icons.edit_rounded,
            iconColor: AppColors.primary,
            route: '/profile',
            visible: true,
          ),
          _ModuleItem(
            label: 'Gestionar Empresa',
            icon: Icons.business_rounded,
            iconColor: Colors.blueAccent,
            route: '/company-management',
            visible: user.canManageCompany,
          ),
          _ModuleItem(
            label: 'Gestionar Usuarios y Roles',
            icon: Icons.manage_accounts,
            iconColor: Colors.yellowAccent,
            route: '/user-management',
            visible: user.canManageUsers,
          ),
          _ModuleItem(
            label: 'Gestionar Suscripción',
            icon: Icons.receipt_long,
            iconColor: Colors.amberAccent,
            route: '/subscription-management',
            visible: user.canManageSuscription,
          ),
        ],
      ),
      _ModuleSection(
        title: 'Vehículos, Servicios y Citas',
        icon: Icons.directions_car_rounded,
        accentColor: Colors.greenAccent,
        items: [
          _ModuleItem(
            label: 'Gestionar Vehículos',
            icon: Icons.directions_car,
            iconColor: Colors.greenAccent,
            route: '/vehicle-management',
            visible: user.canViewVehiculos,
          ),
          _ModuleItem(
            label: 'Plan de Vehículo',
            icon: Icons.assignment_turned_in,
            iconColor: Colors.lightBlueAccent,
            route: '/vehicle-plan-management',
            visible: user.canViewPlanVehiculo,
          ),
          _ModuleItem(
            label: 'Catálogo de Servicios',
            icon: Icons.build_circle_outlined,
            iconColor: Colors.orangeAccent,
            route: '/service-catalog-management',
            visible: user.canViewServiciosCatalogo,
          ),
          _ModuleItem(
            label: 'Espacios de Trabajo',
            icon: Icons.warehouse_outlined,
            iconColor: Colors.cyanAccent,
            route: '/workspace-management',
            visible: user.canViewEspaciosTrabajo,
          ),
          _ModuleItem(
            label: 'Gestionar Citas',
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.primary,
            route: '/appointment-management',
            visible: user.canViewCitas,
          ),
        ],
      ),
      _ModuleSection(
        title: 'Atención Técnica',
        icon: Icons.build_rounded,
        accentColor: AppColors.success,
        items: [
          _ModuleItem(
            label: 'Recepción e Inspección',
            icon: Icons.car_repair_rounded,
            iconColor: AppColors.success,
            route: '/reception-management',
            visible: user.canViewRecepcionVehiculo,
          ),
          _ModuleItem(
            label: 'Gestión de Presupuestos',
            icon: Icons.request_quote_rounded,
            iconColor: AppColors.warning,
            route: '/budget-management',
            visible: user.canViewPresupuestos,
          ),
          _ModuleItem(
            label: 'Órdenes de Trabajo',
            icon: Icons.handyman_rounded,
            iconColor: AppColors.success,
            route: '/work-orders',
            visible: user.canViewOrdenesTrabajo,
          ),
          _ModuleItem(
            label: 'Avance en Taller',
            icon: Icons.garage_rounded,
            iconColor: AppColors.primary,
            route: '/workshop-progress',
            visible: user.canViewTallerInterno,
          ),
          _ModuleItem(
            label: 'Avance General Vehículo',
            icon: Icons.directions_car,
            iconColor: AppColors.info,
            route: '/vehicle-progress',
            visible: user.canViewAvanceVehiculo,
          ),
        ],
      ),
      _ModuleSection(
        title: 'Reportes y Estadísticas',
        icon: Icons.analytics_rounded,
        accentColor: const Color(0xFF0F766E),
        items: [
          _ModuleItem(
            label: 'Reportes de Vehículo',
            icon: Icons.analytics_rounded,
            iconColor: const Color(0xFF0F766E),
            route: '/reports',
            visible: true,
          ),
          _ModuleItem(
            label: 'Visualizar Bitácora',
            icon: Icons.history,
            iconColor: Colors.purpleAccent,
            route: '/audit-management',
            visible: user.canViewBitacora,
          ),
        ],
      ),
      _ModuleSection(
        title: 'Inventario y Almacén',
        icon: Icons.inventory_2_rounded,
        accentColor: const Color(0xFFF59E0B),
        items: [
          _ModuleItem(
            label: 'Gestión de Inventario',
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFFF59E0B),
            route: '/inventory-management',
            visible: user.canViewInventario,
          ),
          _ModuleItem(
            label: 'Gestión de Proveedores',
            icon: Icons.storefront_rounded,
            iconColor: const Color(0xFF8B5CF6),
            route: '/supplier-management',
            visible: user.canViewInventario,
          ),
          _ModuleItem(
            label: 'Abastecimiento por Faltante',
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF10B981),
            route: '/spare-parts-management',
            visible: user.canViewInventario,
          ),
          _ModuleItem(
            label: 'Compras de Insumos',
            icon: Icons.receipt_long,
            iconColor: const Color(0xFFE11D48),
            route: '/purchases-management',
            visible: user.canViewInventario,
          ),
          _ModuleItem(
            label: 'Ventas Presenciales',
            icon: Icons.point_of_sale,
            iconColor: const Color(0xFF8B5CF6),
            route: '/store-sales',
            visible: user.canViewInventario,
          ),
          _ModuleItem(
            label: 'Pagos de Taller',
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFF10B981),
            route: '/payments-management',
            visible: user.canViewInventario,
          ),
          _ModuleItem(
            label: 'Facturas y Recibos',
            icon: Icons.receipt_long_rounded,
            iconColor: const Color(0xFFF59E0B),
            route: '/invoices-management',
            visible: user.canViewFacturas,
          ),
        ],
      ),
    ];
  }

  Widget _buildContent(BuildContext context, User user) {
    final sections =
        _buildSections(user).where((s) => s.hasVisibleItems).toList();

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
          const SizedBox(height: 24),

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
          const SizedBox(height: 24),

          // ── Section title ─────────────────────────────
          Text(
            'Módulos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 12),

          // ── Collapsible Module Sections ────────────────
          ...List.generate(sections.length, (index) {
            final section = sections[index];
            final isExpanded = _expandedSections[index] ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSection(
                context,
                section: section,
                isExpanded: isExpanded,
                onToggle: () {
                  setState(() {
                    _expandedSections[index] =
                        !(_expandedSections[index] ?? false);
                  });
                },
              ),
            );
          }),

          // ── Asistente IA (botón directo, no necesita sección) ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/ai'),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Asistente Virtual con IA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds a collapsible module section (like a sidebar group).
  Widget _buildSection(
    BuildContext context, {
    required _ModuleSection section,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final visibleItems = section.visibleItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? section.accentColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Section Header ──────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: section.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        section.icon,
                        size: 20,
                        color: section.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title + item count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: TextStyle(
                              color: isExpanded
                                  ? Colors.white
                                  : Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${visibleItems.length} ${visibleItems.length == 1 ? 'opción' : 'opciones'}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expand/collapse chevron
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Expanded Items ─────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              child: Column(
                children: visibleItems.map((item) {
                  return _buildModuleItem(context, item: item);
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  /// Individual module item inside a section.
  Widget _buildModuleItem(BuildContext context, {required _ModuleItem item}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(item.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: item.iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
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
