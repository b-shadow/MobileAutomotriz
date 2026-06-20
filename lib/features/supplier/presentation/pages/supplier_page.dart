import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';
import 'package:mobile1_app/features/supplier/presentation/cubit/supplier_cubit.dart';
import 'package:mobile1_app/features/supplier/presentation/cubit/supplier_state.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<SupplierCubit>().fetchSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupplierCubit, SupplierState>(
      listener: (ctx, state) {
        if (state is SupplierError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ));
        } else if (state is SupplierSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.success,
            content: Text(state.message),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Proveedores',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () =>
                  context.read<SupplierCubit>().fetchSuppliers(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.info,
          onPressed: () => _showCreateEditSheet(context, null),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          children: [
            // ── Search bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, contacto, email...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            // ── Stats ──────────────────────────────────
            BlocBuilder<SupplierCubit, SupplierState>(
              builder: (ctx, state) {
                if (state.suppliers.isEmpty) return const SizedBox.shrink();
                final activeCount =
                    state.suppliers.where((s) => s.activo).length;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    children: [
                      _StatChip(
                        icon: Icons.people_alt_rounded,
                        label: '${state.suppliers.length} proveedores',
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.check_circle_outline,
                        label: '$activeCount activos',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── Supplier list ──────────────────────────
            Expanded(
              child: BlocBuilder<SupplierCubit, SupplierState>(
                builder: (ctx, state) {
                  if (state is SupplierLoading && state.suppliers.isEmpty) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.info),
                    );
                  }

                  final filtered = _filter(state.suppliers, _query);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded,
                              size: 64,
                              color:
                                  Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(height: 16),
                          Text(
                            _query.isEmpty
                                ? 'No hay proveedores registrados'
                                : 'Sin resultados para "$_query"',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.info,
                    onRefresh: () =>
                        context.read<SupplierCubit>().fetchSuppliers(),
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) => _SupplierCard(
                        supplier: filtered[i],
                        onEdit: () => _showCreateEditSheet(
                            context, filtered[i]),
                        onDelete: () => _confirmDelete(
                            context, filtered[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Supplier> _filter(List<Supplier> suppliers, String q) {
    if (q.trim().isEmpty) return suppliers;
    final lower = q.toLowerCase();
    return suppliers.where((s) {
      return s.nombre.toLowerCase().contains(lower) ||
          (s.contacto?.toLowerCase().contains(lower) ?? false) ||
          (s.email?.toLowerCase().contains(lower) ?? false) ||
          (s.telefono?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  void _confirmDelete(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar proveedor?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Se eliminará el proveedor "${supplier.nombre}". Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white60, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dlgCtx).pop();
              context.read<SupplierCubit>().deleteSupplier(supplier.id);
            },
            child: const Text('Eliminar',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Supplier Card
// ═══════════════════════════════════════════════════════════════════════════════

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.storefront_rounded,
                    size: 22, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (supplier.contacto != null &&
                        supplier.contacto!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        supplier.contacto!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Active badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: supplier.activo
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: supplier.activo
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  supplier.activo ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    color: supplier.activo
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Contact details
          if (supplier.telefono != null &&
              supplier.telefono!.isNotEmpty)
            _InfoRow(
              icon: Icons.phone_outlined,
              value: supplier.telefono!,
            ),
          if (supplier.email != null && supplier.email!.isNotEmpty)
            _InfoRow(
              icon: Icons.email_outlined,
              value: supplier.email!,
            ),
          if (supplier.direccion != null &&
              supplier.direccion!.isNotEmpty)
            _InfoRow(
              icon: Icons.location_on_outlined,
              value: supplier.direccion!,
            ),

          const SizedBox(height: 10),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: BorderSide(
                        color: AppColors.info.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Editar',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Eliminar',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared Widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon,
              size: 15, color: Colors.white.withValues(alpha: 0.35)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Create / Edit Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════════

void _showCreateEditSheet(BuildContext context, Supplier? existing) {
  final isEdit = existing != null;
  String nombre = existing?.nombre ?? '';
  String telefono = existing?.telefono ?? '';
  String email = existing?.email ?? '';
  String direccion = existing?.direccion ?? '';
  String contacto = existing?.contacto ?? '';
  bool activo = existing?.activo ?? true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (builderCtx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom:
                  MediaQuery.of(builderCtx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    isEdit ? 'Editar Proveedor' : 'Nuevo Proveedor',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _SheetField(
                    label: 'Nombre *',
                    initialValue: nombre,
                    onChanged: (v) => nombre = v,
                  ),
                  const SizedBox(height: 10),

                  _SheetField(
                    label: 'Persona de Contacto',
                    initialValue: contacto,
                    onChanged: (v) => contacto = v,
                  ),
                  const SizedBox(height: 10),

                  _SheetField(
                    label: 'Teléfono',
                    initialValue: telefono,
                    keyboard: TextInputType.phone,
                    onChanged: (v) => telefono = v,
                  ),
                  const SizedBox(height: 10),

                  _SheetField(
                    label: 'Email',
                    initialValue: email,
                    keyboard: TextInputType.emailAddress,
                    onChanged: (v) => email = v,
                  ),
                  const SizedBox(height: 10),

                  _SheetField(
                    label: 'Dirección',
                    initialValue: direccion,
                    onChanged: (v) => direccion = v,
                  ),

                  if (isEdit) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'Estado:',
                          style: TextStyle(
                            color:
                                Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: activo,
                          activeTrackColor: AppColors.success.withValues(alpha: 0.3),
                          thumbColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? AppColors.success
                                : Colors.white54,
                          ),
                          onChanged: (v) =>
                              setSheetState(() => activo = v),
                        ),
                        Text(
                          activo ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: activo
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nombre.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.warning,
                              content: Text(
                                  'El nombre es obligatorio.'),
                            ),
                          );
                          return;
                        }
                        Navigator.of(sheetCtx).pop();

                        if (isEdit) {
                          context
                              .read<SupplierCubit>()
                              .updateSupplier(
                                id: existing.id,
                                nombre: nombre.trim(),
                                telefono: telefono.trim().isEmpty
                                    ? null
                                    : telefono.trim(),
                                email: email.trim().isEmpty
                                    ? null
                                    : email.trim(),
                                direccion: direccion.trim().isEmpty
                                    ? null
                                    : direccion.trim(),
                                contacto: contacto.trim().isEmpty
                                    ? null
                                    : contacto.trim(),
                                activo: activo,
                              );
                        } else {
                          context
                              .read<SupplierCubit>()
                              .createSupplier(
                                nombre: nombre.trim(),
                                telefono: telefono.trim().isEmpty
                                    ? null
                                    : telefono.trim(),
                                email: email.trim().isEmpty
                                    ? null
                                    : email.trim(),
                                direccion: direccion.trim().isEmpty
                                    ? null
                                    : direccion.trim(),
                                contacto: contacto.trim().isEmpty
                                    ? null
                                    : contacto.trim(),
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isEdit
                            ? 'Guardar Cambios'
                            : 'Crear Proveedor',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Reusable Form Field
// ═══════════════════════════════════════════════════════════════════════════════

class _SheetField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final TextInputType? keyboard;
  final ValueChanged<String> onChanged;

  const _SheetField({
    required this.label,
    this.initialValue,
    this.keyboard,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboard,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.info),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
