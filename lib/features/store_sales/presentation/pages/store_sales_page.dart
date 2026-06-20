import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';
import 'package:mobile1_app/features/store_sales/presentation/cubit/store_sales_cubit.dart';
import 'package:mobile1_app/features/store_sales/presentation/cubit/store_sales_state.dart';

class StoreSalesPage extends StatefulWidget {
  const StoreSalesPage({super.key});

  @override
  State<StoreSalesPage> createState() => _StoreSalesPageState();
}

class _StoreSalesPageState extends State<StoreSalesPage> {
  String _filterEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    context.read<StoreSalesCubit>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreSalesCubit, StoreSalesState>(
      listener: (ctx, state) {
        if (state is StoreSalesError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ));
        } else if (state is StoreSalesSuccess) {
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
            'Ventas Presenciales',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () => context.read<StoreSalesCubit>().fetchAll(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF8B5CF6),
          icon: const Icon(Icons.point_of_sale, color: Colors.white),
          label: const Text('Nueva Venta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () => context.push('/store-sales/new'),
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: BlocBuilder<StoreSalesCubit, StoreSalesState>(
                builder: (ctx, state) {
                  if (state is StoreSalesLoading && state.sales.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.info),
                    );
                  }

                  final filtered = _applyFilter(state.sales);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.point_of_sale_outlined, size: 64, color: Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay ventas de mostrador registradas',
                            style: TextStyle(color: Colors.white54, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.info,
                    onRefresh: () => context.read<StoreSalesCubit>().fetchAll(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _SaleCard(sale: filtered[i]),
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
    const estados = ['TODOS', 'BORRADOR', 'CONFIRMADA', 'PAGADA', 'CANCELADA'];

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

  List<StoreSale> _applyFilter(List<StoreSale> list) {
    if (_filterEstado == 'TODOS') return list;
    return list.where((s) => s.estado == _filterEstado).toList();
  }

  (String, Color) _estadoChipData(String estado) => switch (estado) {
        'TODOS' => ('Todos', Colors.white70),
        'BORRADOR' => ('Borrador', Colors.blueGrey),
        'CONFIRMADA' => ('Confirmada', const Color(0xFF3B82F6)),
        'PAGADA' => ('Pagada', AppColors.success),
        'CANCELADA' => ('Cancelada', AppColors.error),
        _ => (estado, Colors.grey),
      };
}

class _SaleCard extends StatelessWidget {
  final StoreSale sale;

  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
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
                child: Icon(Icons.point_of_sale, size: 20, color: _estadoColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.clienteNombreLibre ?? 'Cliente General',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmtDate.format(sale.createdAt.toLocal()),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              _EstadoBadge(estado: sale.estado),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sale.detalles.length} ítems',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
              Text(
                fmtMoney.format(sale.total),
                style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          if (sale.detalles.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetallesSection(detalles: sale.detalles),
          ],
          if (sale.estado == 'BORRADOR') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmSale(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: BorderSide(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Confirmar Venta'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmSale(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar Venta', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Al confirmar la venta, se descontará automáticamente el stock del inventario. ¿Deseas continuar?',
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
              context.read<StoreSalesCubit>().confirm(sale.id);
            },
            child: const Text('Confirmar', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color get _estadoColor => switch (sale.estado) {
        'BORRADOR' => Colors.blueGrey,
        'CONFIRMADA' => const Color(0xFF3B82F6),
        'PAGADA' => AppColors.success,
        'CANCELADA' => AppColors.error,
        _ => Colors.grey,
      };
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (estado) {
      'BORRADOR' => ('Borrador', Colors.blueGrey),
      'CONFIRMADA' => ('Confirmada', const Color(0xFF3B82F6)),
      'PAGADA' => ('Pagada', AppColors.success),
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
  final List<StoreSaleDetail> detalles;
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
                      '${d.cantidad}x ${fmtMoney.format(d.precioUnitario)}',
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
