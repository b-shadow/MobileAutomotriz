import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/spare_parts/domain/entities/spare_part_request_entity.dart';
import 'package:mobile1_app/features/spare_parts/presentation/cubit/spare_parts_cubit.dart';
import 'package:mobile1_app/features/spare_parts/presentation/cubit/spare_parts_state.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';

class SparePartsPage extends StatefulWidget {
  const SparePartsPage({super.key});

  @override
  State<SparePartsPage> createState() => _SparePartsPageState();
}

class _SparePartsPageState extends State<SparePartsPage> {
  String _filterEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    context.read<SparePartsCubit>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SparePartsCubit, SparePartsState>(
      listener: (ctx, state) {
        if (state is SparePartsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ));
        } else if (state is SparePartsSuccess) {
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
            'Abastecimiento por Faltante',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () =>
                  context.read<SparePartsCubit>().fetchAll(),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Filter chips ─────────────────────────
            _buildFilterBar(),

            // ── Solicitudes list ─────────────────────
            Expanded(
              child: BlocBuilder<SparePartsCubit, SparePartsState>(
                builder: (ctx, state) {
                  if (state is SparePartsLoading &&
                      state.solicitudes.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.info),
                    );
                  }

                  final filtered = _applyFilter(state.solicitudes);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 64,
                              color: Colors.white.withValues(
                                  alpha: 0.15)),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay solicitudes de repuestos',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.info,
                    onRefresh: () =>
                        context.read<SparePartsCubit>().fetchAll(),
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 30),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) => _SolicitudCard(
                        solicitud: filtered[i],
                        proveedores: state.proveedores,
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

  Widget _buildFilterBar() {
    const estados = [
      'TODOS',
      'CREADA',
      'APROBADA_POR_ASESOR',
      'EN_REVISION_ALMACEN',
      'ENTREGADA',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: estados.map((e) {
          final isSelected = _filterEstado == e;
          final (label, color) = _estadoChipData(e);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : color)),
              selectedColor: color.withValues(alpha: 0.3),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              side: BorderSide(color: isSelected ? color : Colors.white.withValues(alpha: 0.1)),
              checkmarkColor: Colors.white,
              onSelected: (_) =>
                  setState(() => _filterEstado = e),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<SparePartRequestEntity> _applyFilter(
      List<SparePartRequestEntity> list) {
    if (_filterEstado == 'TODOS') return list;
    return list.where((s) => s.estado == _filterEstado).toList();
  }

  (String, Color) _estadoChipData(String estado) => switch (estado) {
        'TODOS' => ('Todos', AppColors.info),
        'CREADA' => ('Creada', Colors.blueGrey),
        'APROBADA_POR_ASESOR' => ('Aprobada', AppColors.success),
        'EN_REVISION_ALMACEN' => ('En Almacén', AppColors.warning),
        'ENTREGADA' => ('Entregada', const Color(0xFF3B82F6)),
        _ => (estado, Colors.grey),
      };
}

// ═══════════════════════════════════════════════════════════════════════════════
// Solicitud Card
// ═══════════════════════════════════════════════════════════════════════════════

class _SolicitudCard extends StatelessWidget {
  final SparePartRequestEntity solicitud;
  final List<Supplier> proveedores;

  const _SolicitudCard({
    required this.solicitud,
    required this.proveedores,
  });

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _estadoColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(_estadoIcon, size: 20, color: _estadoColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitud #${solicitud.id.substring(0, 8)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmtDate.format(solicitud.createdAt.toLocal()),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _EstadoBadge(estado: solicitud.estado),
            ],
          ),
          const SizedBox(height: 10),

          // Info
          if (solicitud.motivo != null &&
              solicitud.motivo!.isNotEmpty)
            _InfoRow(
              icon: Icons.description_outlined,
              value: solicitud.motivo!,
            ),
          _InfoRow(
            icon: Icons.inventory_2_outlined,
            value:
                '${solicitud.totalItems} items — ${solicitud.totalSolicitado} unidades solicitadas',
          ),
          if (solicitud.totalEntregado > 0)
            _InfoRow(
              icon: Icons.local_shipping_outlined,
              value: '${solicitud.totalEntregado} unidades entregadas',
            ),
          if (solicitud.observacionesAlmacen != null &&
              solicitud.observacionesAlmacen!.isNotEmpty)
            _InfoRow(
              icon: Icons.warehouse_outlined,
              value: solicitud.observacionesAlmacen!,
            ),

          // Details expandable
          if (solicitud.detalles.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetallesSection(detalles: solicitud.detalles),
          ],

          const SizedBox(height: 10),

          // Action buttons
          _ActionButtons(
            solicitud: solicitud,
            proveedores: proveedores,
          ),
        ],
      ),
    );
  }

  Color get _estadoColor => switch (solicitud.estado) {
        'CREADA' => Colors.blueGrey,
        'APROBADA_POR_ASESOR' => AppColors.success,
        'RECHAZADA_POR_ASESOR' => AppColors.error,
        'EN_REVISION_ALMACEN' => AppColors.warning,
        'PARCIALMENTE_DISPONIBLE' => const Color(0xFFF59E0B),
        'ENTREGADA' => const Color(0xFF3B82F6),
        'CERRADA' => Colors.grey,
        _ => Colors.grey,
      };

  IconData get _estadoIcon => switch (solicitud.estado) {
        'CREADA' => Icons.fiber_new_rounded,
        'APROBADA_POR_ASESOR' => Icons.check_circle_outline,
        'EN_REVISION_ALMACEN' => Icons.warehouse_rounded,
        'ENTREGADA' => Icons.local_shipping_rounded,
        'CERRADA' => Icons.lock_outline,
        _ => Icons.assignment_outlined,
      };
}

// ═══════════════════════════════════════════════════════════════════════════════
// Detalles Section (expandable)
// ═══════════════════════════════════════════════════════════════════════════════

class _DetallesSection extends StatefulWidget {
  final List<SparePartRequestDetail> detalles;
  const _DetallesSection({required this.detalles});

  @override
  State<_DetallesSection> createState() => _DetallesSectionState();
}

class _DetallesSectionState extends State<_DetallesSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Text(
                  'Ver detalles (${widget.detalles.length})',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 6),
          ...widget.detalles.map((d) => _DetalleRow(detalle: d)),
        ],
      ],
    );
  }
}

class _DetalleRow extends StatelessWidget {
  final SparePartRequestDetail detalle;
  const _DetalleRow({required this.detalle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              detalle.itemNombre ?? 'Item desconocido',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            'Sol: ${detalle.cantidadSolicitada}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
          if (detalle.cantidadEntregada > 0) ...[
            const SizedBox(width: 8),
            Text(
              'Ent: ${detalle.cantidadEntregada}',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (detalle.cantidadRecibidaTaller > 0) ...[
            const SizedBox(width: 8),
            Text(
              'Rec: ${detalle.cantidadRecibidaTaller}',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Action Buttons per estado
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButtons extends StatelessWidget {
  final SparePartRequestEntity solicitud;
  final List<Supplier> proveedores;

  const _ActionButtons({
    required this.solicitud,
    required this.proveedores,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (solicitud.estado == 'CREADA') {
      actions.add(_ActionBtn(
        icon: Icons.check_rounded,
        label: 'Aprobar',
        color: AppColors.success,
        onTap: () => _showAprobarDialog(context),
      ));
    }

    if (solicitud.estado == 'APROBADA_POR_ASESOR') {
      actions.add(_ActionBtn(
        icon: Icons.warehouse_rounded,
        label: 'En Proceso',
        color: AppColors.warning,
        onTap: () => _showEnProcesoDialog(context),
      ));
      actions.add(const SizedBox(width: 8));
      actions.add(_ActionBtn(
        icon: Icons.storefront_rounded,
        label: 'Asignar Prov.',
        color: const Color(0xFF8B5CF6),
        onTap: () =>
            _showAsignarProveedorDialog(context, proveedores),
      ));
    }

    if (solicitud.estado == 'EN_REVISION_ALMACEN' ||
        solicitud.estado == 'APROBADA_POR_ASESOR') {
      actions.add(const SizedBox(width: 8));
      actions.add(_ActionBtn(
        icon: Icons.local_shipping_rounded,
        label: 'Entregar',
        color: const Color(0xFF3B82F6),
        onTap: () => _showEntregarSheet(context),
      ));
    }

    if (solicitud.estado == 'ENTREGADA') {
      actions.add(_ActionBtn(
        icon: Icons.check_circle_rounded,
        label: 'Recibir en Taller',
        color: const Color(0xFF10B981),
        onTap: () => _showRecibirTallerSheet(context),
      ));
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: actions),
    );
  }

  void _showAprobarDialog(BuildContext context) {
    String obs = '';
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Aprobar Solicitud',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: _SheetField(
          label: 'Observaciones (opcional)',
          onChanged: (v) => obs = v,
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
              context.read<SparePartsCubit>().aprobar(
                    solicitud.id,
                    observaciones:
                        obs.isEmpty ? 'Aprobada por asesor' : obs,
                  );
            },
            child: const Text('Aprobar',
                style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEnProcesoDialog(BuildContext context) {
    String obs = '';
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Marcar En Proceso',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: _SheetField(
          label: 'Observaciones almacén (opcional)',
          onChanged: (v) => obs = v,
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
              context.read<SparePartsCubit>().enProceso(
                    solicitud.id,
                    observaciones:
                        obs.isEmpty ? 'En preparación' : obs,
                  );
            },
            child: const Text('Confirmar',
                style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAsignarProveedorDialog(
      BuildContext context, List<Supplier> proveedores) {
    final activeProveedores =
        proveedores.where((p) => p.activo).toList();
    if (activeProveedores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: AppColors.warning,
        content: Text('No hay proveedores activos.'),
      ));
      return;
    }

    String? selectedId = activeProveedores.first.id;
    String eta = '';
    String obs = '';

    showDialog(
      context: context,
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setDlgState) {
            return AlertDialog(
              backgroundColor: AppColors.darkCard,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Asignar Proveedor',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SheetDropdown<String>(
                      label: 'Proveedor *',
                      value: selectedId,
                      items: activeProveedores
                          .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.nombre)))
                          .toList(),
                      onChanged: (v) =>
                          setDlgState(() => selectedId = v),
                    ),
                    const SizedBox(height: 10),
                    _SheetField(
                      label: 'ETA estimado',
                      onChanged: (v) => eta = v,
                    ),
                    const SizedBox(height: 10),
                    _SheetField(
                      label: 'Observaciones',
                      onChanged: (v) => obs = v,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dlgCtx).pop(),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedId == null) return;
                    Navigator.of(dlgCtx).pop();
                    context.read<SparePartsCubit>().asignarProveedor(
                          solicitud.id,
                          selectedId!,
                          eta: eta.isEmpty ? null : eta,
                          observaciones: obs.isEmpty ? null : obs,
                        );
                  },
                  child: const Text('Asignar',
                      style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEntregarSheet(BuildContext context) {
    final cantidades = <String, int>{};
    for (final d in solicitud.detalles) {
      cantidades[d.id] = d.cantidadSolicitada;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(builderCtx)
                        .viewInsets
                        .bottom +
                    20,
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
                          color: Colors.white
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Marcar Entrega',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...solicitud.detalles.map((d) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.itemNombre ??
                                        'Item desconocido',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Solicitado: ${d.cantidadSolicitada}',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(
                                              alpha: 0.4),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue:
                                    '${cantidades[d.id]}',
                                keyboardType:
                                    TextInputType.number,
                                onChanged: (v) =>
                                    setSheetState(() {
                                  cantidades[d.id] =
                                      int.tryParse(v) ?? 0;
                                }),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white
                                      .withValues(
                                          alpha: 0.07),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                    borderSide: BorderSide(
                                        color: Colors.white
                                            .withValues(
                                                alpha:
                                                    0.1)),
                                  ),
                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                    borderSide: BorderSide(
                                        color: Colors.white
                                            .withValues(
                                                alpha:
                                                    0.1)),
                                  ),
                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                    borderSide:
                                        const BorderSide(
                                            color: AppColors
                                                .info),
                                  ),
                                  contentPadding:
                                      const EdgeInsets
                                          .symmetric(
                                          vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final detalles = solicitud.detalles
                              .map((d) => {
                                    'detalle_id': d.id,
                                    'cantidad_entregada':
                                        cantidades[d.id] ?? 0,
                                  })
                              .toList();
                          Navigator.of(sheetCtx).pop();
                          context
                              .read<SparePartsCubit>()
                              .entregar(
                                solicitud.id,
                                detalles,
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                        ),
                        child: const Text(
                          'Confirmar Entrega',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
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

  void _showRecibirTallerSheet(BuildContext context) {
    final cantidades = <String, int>{};
    for (final d in solicitud.detalles) {
      cantidades[d.id] = d.cantidadEntregada;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(builderCtx)
                        .viewInsets
                        .bottom +
                    20,
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
                          color: Colors.white
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Confirmar Recepción en Taller',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confirme las cantidades recibidas para cada item.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...solicitud.detalles.where((d) => d.cantidadEntregada > 0).map((d) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.itemNombre ??
                                        'Item desconocido',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Entregado: ${d.cantidadEntregada}',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(
                                              alpha: 0.4),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue:
                                    '${cantidades[d.id]}',
                                keyboardType:
                                    TextInputType.number,
                                onChanged: (v) =>
                                    setSheetState(() {
                                  cantidades[d.id] =
                                      int.tryParse(v) ?? 0;
                                }),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white
                                      .withValues(
                                          alpha: 0.07),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                    borderSide: BorderSide(
                                        color: Colors.white
                                            .withValues(
                                                alpha:
                                                    0.1)),
                                  ),
                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                    borderSide: BorderSide(
                                        color: Colors.white
                                            .withValues(
                                                alpha:
                                                    0.1)),
                                  ),
                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                    borderSide:
                                        const BorderSide(
                                            color: Color(0xFF10B981)),
                                  ),
                                  contentPadding:
                                      const EdgeInsets
                                          .symmetric(
                                          vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final detalles = solicitud.detalles
                              .where((d) => d.cantidadEntregada > 0)
                              .map((d) => {
                                    'detalle_id': d.id,
                                    'cantidad_recibida':
                                        cantidades[d.id] ?? 0,
                                  })
                              .toList();
                          Navigator.of(sheetCtx).pop();
                          context
                              .read<SparePartsCubit>()
                              .marcarRecibidaTaller(
                                solicitud.id,
                                detalles,
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                        ),
                        child: const Text(
                          'Confirmar Recepción',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared Widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (estado) {
      'CREADA' => ('Creada', Colors.blueGrey),
      'APROBADA_POR_ASESOR' => ('Aprobada', AppColors.success),
      'RECHAZADA_POR_ASESOR' => ('Rechazada', AppColors.error),
      'EN_REVISION_ALMACEN' => ('En Almacén', AppColors.warning),
      'PARCIALMENTE_DISPONIBLE' =>
        ('Parcial', const Color(0xFFF59E0B)),
      'ENTREGADA' => ('Entregada', const Color(0xFF3B82F6)),
      'CERRADA' => ('Cerrada', Colors.grey),
      _ => (estado, Colors.grey),
    };

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label,
          style:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: Colors.white.withValues(alpha: 0.35)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final ValueChanged<String> onChanged;

  const _SheetField({
    required this.label,
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

class _SheetDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.items,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.darkCard,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14),
              iconEnabledColor: Colors.white38,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
