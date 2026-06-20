import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/purchases/domain/entities/purchase_entity.dart';
import 'package:mobile1_app/features/purchases/presentation/cubit/purchases_cubit.dart';
import 'package:mobile1_app/features/purchases/presentation/cubit/purchases_state.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  String _filterEstado = 'TODOS';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<PurchasesCubit>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchasesCubit, PurchasesState>(
      listener: (ctx, state) {
        if (state is PurchasesError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ));
        } else if (state is PurchasesSuccess) {
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
            'Compras de Insumos',
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
              onPressed: () => context.read<PurchasesCubit>().fetchAll(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFE11D48),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Nueva Compra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () => context.push('/purchases-management/new'),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterBar(),
            Expanded(
              child: BlocBuilder<PurchasesCubit, PurchasesState>(
                builder: (ctx, state) {
                  if (state is PurchasesLoading && state.purchases.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.info),
                    );
                  }

                  final filtered = _applyFilter(state.purchases);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64, color: Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay compras registradas',
                            style: TextStyle(color: Colors.white54, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.info,
                    onRefresh: () => context.read<PurchasesCubit>().fetchAll(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _PurchaseCard(purchase: filtered[i]),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Buscar por documento o proveedor...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.4)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    const estados = [
      'TODOS',
      'BORRADOR',
      'CONFIRMADA',
      'RECIBIDA',
      'CANCELADA',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
              onSelected: (_) => setState(() => _filterEstado = e),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Purchase> _applyFilter(List<Purchase> list) {
    var filtered = list;
    if (_filterEstado != 'TODOS') {
      filtered = filtered.where((s) => s.estado == _filterEstado).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) {
        final doc = s.numeroDocumento.toLowerCase();
        final prov = (s.proveedorNombre ?? '').toLowerCase();
        return doc.contains(_searchQuery) || prov.contains(_searchQuery);
      }).toList();
    }
    return filtered;
  }

  (String, Color) _estadoChipData(String estado) => switch (estado) {
        'TODOS' => ('Todos', Colors.white70),
        'BORRADOR' => ('Borrador', Colors.blueGrey),
        'CONFIRMADA' => ('Confirmada', AppColors.warning),
        'RECIBIDA' => ('Recibida', AppColors.success),
        'CANCELADA' => ('Cancelada', AppColors.error),
        _ => (estado, Colors.grey),
      };
}

class _PurchaseCard extends StatelessWidget {
  final Purchase purchase;

  const _PurchaseCard({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM/yyyy');
    final fmtMoney = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _estadoColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_estadoIcon, size: 20, color: _estadoColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.proveedorNombre ?? 'Sin Proveedor',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Doc: ${purchase.numeroDocumento} • ${fmtDate.format(purchase.fechaCompra.toLocal())}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _EstadoBadge(estado: purchase.estado),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${purchase.detalles.length} ítems',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              Text(
                fmtMoney.format(purchase.total),
                style: const TextStyle(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (purchase.detalles.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetallesSection(detalles: purchase.detalles),
          ],
          if (purchase.estado == 'CONFIRMADA' || purchase.estado == 'BORRADOR') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmReceive(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.inventory_rounded, size: 18),
                label: const Text('Marcar como Recibida'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmReceive(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Marcar como Recibida', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro que deseas marcar esta compra como recibida? Esto incrementará el stock en el inventario de manera automática.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              context.read<PurchasesCubit>().markReceived(purchase.id);
            },
            child: const Text('Confirmar', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color get _estadoColor => switch (purchase.estado) {
        'BORRADOR' => Colors.blueGrey,
        'CONFIRMADA' => AppColors.warning,
        'RECIBIDA' => AppColors.success,
        'CANCELADA' => AppColors.error,
        _ => Colors.grey,
      };

  IconData get _estadoIcon => switch (purchase.estado) {
        'BORRADOR' => Icons.edit_document,
        'CONFIRMADA' => Icons.local_shipping_outlined,
        'RECIBIDA' => Icons.inventory_rounded,
        'CANCELADA' => Icons.cancel_outlined,
        _ => Icons.receipt_long,
      };
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (estado) {
      'BORRADOR' => ('Borrador', Colors.blueGrey),
      'CONFIRMADA' => ('Confirmada', AppColors.warning),
      'RECIBIDA' => ('Recibida', AppColors.success),
      'CANCELADA' => ('Cancelada', AppColors.error),
      _ => (estado, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _DetallesSection extends StatefulWidget {
  final List<PurchaseDetail> detalles;
  const _DetallesSection({required this.detalles});

  @override
  State<_DetallesSection> createState() => _DetallesSectionState();
}

class _DetallesSectionState extends State<_DetallesSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final fmtMoney = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Text(
                  'Ver ítems',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 6),
          ...widget.detalles.map((d) => Padding(
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
                        d.itemNombre ?? 'Item desconocido',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                      ),
                    ),
                    Text(
                      '${d.cantidad}x ${fmtMoney.format(d.costoUnitario)}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fmtMoney.format(d.subtotal),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}
