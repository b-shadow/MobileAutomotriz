import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_category.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_item.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:mobile1_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:mobile1_app/features/inventory/presentation/cubit/inventory_state.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    context.read<InventoryCubit>().fetchAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryCubit, InventoryState>(
      listener: (ctx, state) {
        if (state is InventoryError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ));
        } else if (state is InventorySuccess) {
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
            'Inventario',
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
              onPressed: () => context.read<InventoryCubit>().fetchAll(),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: AppColors.info,
            labelColor: AppColors.info,
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(text: 'Items'),
              Tab(text: 'Categorías'),
              Tab(text: 'Movimientos'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _ItemsTab(
              query: _query,
              searchController: _searchController,
              onQueryChanged: (v) => setState(() => _query = v),
            ),
            const _CategoriesTab(),
            const _MovementsTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1: Items de Inventario
// ═══════════════════════════════════════════════════════════════════════════════

class _ItemsTab extends StatelessWidget {
  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;

  const _ItemsTab({
    required this.query,
    required this.searchController,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (ctx, state) {
        if (state is InventoryLoading && state.items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.info),
          );
        }

        final items = _filterItems(state.items, query);
        final lowStockCount = state.items.where((i) => i.isLowStock).length;

        return Column(
          children: [
            // ── Search + Create ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
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
                        controller: searchController,
                        onChanged: onQueryChanged,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Buscar por código o nombre...',
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
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: Icons.add_rounded,
                    label: 'Item',
                    color: AppColors.info,
                    onTap: () => _showCreateItemSheet(context, state),
                  ),
                ],
              ),
            ),

            // ── Stock summary bar ─────────────────────
            if (state.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.inventory_2_outlined,
                      label: '${state.items.length} items',
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    if (lowStockCount > 0)
                      _StatChip(
                        icon: Icons.warning_amber_rounded,
                        label: '$lowStockCount bajo mínimo',
                        color: AppColors.warning,
                      ),
                  ],
                ),
              ),

            // ── Item list ────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(height: 16),
                          Text(
                            query.isEmpty
                                ? 'No hay items de inventario'
                                : 'Sin resultados para "$query"',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.info,
                      onRefresh: () =>
                          context.read<InventoryCubit>().fetchAll(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _ItemCard(item: items[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items, String q) {
    if (q.trim().isEmpty) return items;
    final lower = q.toLowerCase();
    return items.where((i) {
      return i.codigo.toLowerCase().contains(lower) ||
          i.nombre.toLowerCase().contains(lower) ||
          i.tipoItem.toLowerCase().contains(lower);
    }).toList();
  }
}

class _ItemCard extends StatelessWidget {
  final InventoryItem item;
  const _ItemCard({required this.item});

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
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon, size: 20, color: _typeColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.codigo,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _TipoBadge(tipo: item.tipoItem),
            ],
          ),
          const SizedBox(height: 12),

          // Info rows
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Stock',
                  value: '${item.stockActual}',
                  color: item.isLowStock ? AppColors.error : AppColors.success,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Mínimo',
                  value: '${item.stockMinimo}',
                  color: Colors.white54,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Precio',
                  value: 'Bs ${item.precioVenta.toStringAsFixed(2)}',
                  color: AppColors.info,
                ),
              ),
            ],
          ),

          if (item.categoriaNombre != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category_outlined,
                    size: 13, color: Colors.white.withValues(alpha: 0.3)),
                const SizedBox(width: 4),
                Text(
                  item.categoriaNombre!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // Adjust stock button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAdjustStockDialog(context, item),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: BorderSide(
                    color: AppColors.info.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.swap_vert_rounded, size: 18),
              label: const Text('Ajustar Stock',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Color get _typeColor => switch (item.tipoItem) {
        'REPUESTO' => const Color(0xFF3B82F6),
        'INSUMO' => const Color(0xFF10B981),
        'PRODUCTO' => const Color(0xFFF59E0B),
        _ => Colors.grey,
      };

  IconData get _typeIcon => switch (item.tipoItem) {
        'REPUESTO' => Icons.build_rounded,
        'INSUMO' => Icons.water_drop_rounded,
        'PRODUCTO' => Icons.shopping_bag_rounded,
        _ => Icons.inventory_2_outlined,
      };
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2: Categorías
// ═══════════════════════════════════════════════════════════════════════════════

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (ctx, state) {
        if (state is InventoryLoading && state.categories.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.info),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  _StatChip(
                    icon: Icons.category_rounded,
                    label: '${state.categories.length} categorías',
                    color: AppColors.primary,
                  ),
                  const Spacer(),
                  _ActionButton(
                    icon: Icons.add_rounded,
                    label: 'Categoría',
                    color: AppColors.primary,
                    onTap: () => _showCreateCategoryDialog(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(height: 16),
                          const Text('No hay categorías',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 15)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.info,
                      onRefresh: () =>
                          context.read<InventoryCubit>().fetchAll(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                        itemCount: state.categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) =>
                            _CategoryCard(cat: state.categories[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final InventoryCategory cat;
  const _CategoryCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.category_rounded,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (cat.descripcion != null &&
                    cat.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    cat.descripcion!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: cat.activo
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cat.activo
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.error.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              cat.activo ? 'Activo' : 'Inactivo',
              style: TextStyle(
                color: cat.activo ? AppColors.success : AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 3: Movimientos
// ═══════════════════════════════════════════════════════════════════════════════

class _MovementsTab extends StatelessWidget {
  const _MovementsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (ctx, state) {
        if (state is InventoryLoading && state.movements.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.info),
          );
        }

        if (state.movements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_vert_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.15)),
                const SizedBox(height: 16),
                const Text('No hay movimientos registrados',
                    style: TextStyle(color: Colors.white54, fontSize: 15)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.info,
          onRefresh: () => context.read<InventoryCubit>().fetchAll(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            itemCount: state.movements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _MovementCard(mov: state.movements[i]),
          ),
        );
      },
    );
  }
}

class _MovementCard extends StatelessWidget {
  final InventoryMovement mov;
  const _MovementCard({required this.mov});

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    final isPositive = mov.cantidad >= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPositive
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 20,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mov.itemNombre ?? 'Item desconocido',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _movementLabel(mov.tipoMovimiento),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fmtDate.format(mov.createdAt.toLocal()),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${mov.cantidad}',
                style: TextStyle(
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${mov.stockAnterior} → ${mov.stockPosterior}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _movementLabel(String tipo) => switch (tipo) {
        'ENTRADA_COMPRA' => 'Entrada por compra',
        'SALIDA_TALLER' => 'Salida al taller',
        'SALIDA_VENTA' => 'Salida por venta',
        'AJUSTE' => 'Ajuste manual',
        _ => tipo,
      };
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared UI Components
// ═══════════════════════════════════════════════════════════════════════════════

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
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipoBadge extends StatelessWidget {
  final String tipo;
  const _TipoBadge({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (tipo) {
      'REPUESTO' => (const Color(0xFF3B82F6), 'Repuesto'),
      'INSUMO' => (const Color(0xFF10B981), 'Insumo'),
      'PRODUCTO' => (const Color(0xFFF59E0B), 'Producto'),
      _ => (Colors.grey, tipo),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Dialogs & Bottom Sheets
// ═══════════════════════════════════════════════════════════════════════════════

String _generateItemCode() {
  final now = DateTime.now();
  final y = now.year;
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  final r = (1000 + Random().nextInt(9000)).toString();
  return 'ITM-$y$m$d-$r';
}

void _showCreateItemSheet(BuildContext context, InventoryState state) {
  final categories = state.categories;
  String? selectedCategory = categories.isNotEmpty ? categories.first.id : null;
  String codigo = _generateItemCode();
  String nombre = '';
  String descripcion = '';
  String tipoItem = 'REPUESTO';
  String unidadMedida = 'pieza';
  String stockActual = '0';
  String stockMinimo = '0';
  String costoPromedio = '0';
  String precioVenta = '0';

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
              bottom: MediaQuery.of(builderCtx).viewInsets.bottom + 20,
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

                  const Text('Crear Item de Inventario',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Category dropdown
                  _SheetDropdown(
                    label: 'Categoría *',
                    value: selectedCategory,
                    items: categories
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text(c.nombre)))
                        .toList(),
                    onChanged: (v) =>
                        setSheetState(() => selectedCategory = v),
                  ),
                  const SizedBox(height: 10),

                  // Code
                  _SheetField(
                    label: 'Código *',
                    initialValue: codigo,
                    onChanged: (v) => codigo = v,
                  ),
                  const SizedBox(height: 10),

                  // Name
                  _SheetField(
                    label: 'Nombre *',
                    onChanged: (v) => nombre = v,
                  ),
                  const SizedBox(height: 10),

                  // Description
                  _SheetField(
                    label: 'Descripción',
                    onChanged: (v) => descripcion = v,
                  ),
                  const SizedBox(height: 10),

                  // Type dropdown
                  _SheetDropdown(
                    label: 'Tipo de Item *',
                    value: tipoItem,
                    items: const [
                      DropdownMenuItem(
                          value: 'REPUESTO', child: Text('Repuesto')),
                      DropdownMenuItem(
                          value: 'INSUMO', child: Text('Insumo')),
                      DropdownMenuItem(
                          value: 'PRODUCTO', child: Text('Producto')),
                    ],
                    onChanged: (v) =>
                        setSheetState(() => tipoItem = v ?? 'REPUESTO'),
                  ),
                  const SizedBox(height: 10),

                  // Unit
                  _SheetField(
                    label: 'Unidad de Medida *',
                    initialValue: unidadMedida,
                    onChanged: (v) => unidadMedida = v,
                  ),
                  const SizedBox(height: 10),

                  // Numbers row
                  Row(
                    children: [
                      Expanded(
                        child: _SheetField(
                          label: 'Stock Inicial',
                          keyboard: TextInputType.number,
                          initialValue: stockActual,
                          onChanged: (v) => stockActual = v,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SheetField(
                          label: 'Stock Mínimo',
                          keyboard: TextInputType.number,
                          initialValue: stockMinimo,
                          onChanged: (v) => stockMinimo = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _SheetField(
                          label: 'Costo Promedio',
                          keyboard:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          initialValue: costoPromedio,
                          onChanged: (v) => costoPromedio = v,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SheetField(
                          label: 'Precio Venta',
                          keyboard:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          initialValue: precioVenta,
                          onChanged: (v) => precioVenta = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedCategory == null || nombre.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.warning,
                              content: Text(
                                  'Categoría y nombre son obligatorios.'),
                            ),
                          );
                          return;
                        }
                        Navigator.of(sheetCtx).pop();
                        context.read<InventoryCubit>().createItem(
                              categoria: selectedCategory!,
                              codigo: codigo,
                              nombre: nombre,
                              descripcion: descripcion.isEmpty
                                  ? null
                                  : descripcion,
                              tipoItem: tipoItem,
                              unidadMedida: unidadMedida,
                              stockActual:
                                  int.tryParse(stockActual) ?? 0,
                              stockMinimo:
                                  int.tryParse(stockMinimo) ?? 0,
                              costoPromedio:
                                  double.tryParse(costoPromedio) ?? 0,
                              precioVenta:
                                  double.tryParse(precioVenta) ?? 0,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Crear Item',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
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

void _showCreateCategoryDialog(BuildContext context) {
  String nombre = '';
  String descripcion = '';

  showDialog(
    context: context,
    builder: (dlgCtx) {
      return AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nueva Categoría',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetField(
              label: 'Nombre *',
              onChanged: (v) => nombre = v,
            ),
            const SizedBox(height: 12),
            _SheetField(
              label: 'Descripción',
              onChanged: (v) => descripcion = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (nombre.trim().isEmpty) return;
              Navigator.of(dlgCtx).pop();
              context.read<InventoryCubit>().createCategory(
                    nombre: nombre.trim(),
                    descripcion:
                        descripcion.trim().isEmpty ? null : descripcion.trim(),
                  );
            },
            child: const Text('Crear',
                style: TextStyle(
                    color: AppColors.info, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

void _showAdjustStockDialog(BuildContext context, InventoryItem item) {
  String tipoMovimiento = 'ENTRADA_COMPRA';
  String cantidad = '1';
  String cantidadAjuste = '0';
  String observacion = '';

  showDialog(
    context: context,
    builder: (dlgCtx) {
      return StatefulBuilder(
        builder: (builderCtx, setDlgState) {
          return AlertDialog(
            backgroundColor: AppColors.darkCard,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text('Ajustar Stock: ${item.nombre}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current stock info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Stock actual: ',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 14)),
                        Text('${item.stockActual}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        Text(' ${item.unidadMedida}',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Movement type
                  _SheetDropdown<String>(
                    label: 'Tipo de Movimiento',
                    value: tipoMovimiento,
                    items: const [
                      DropdownMenuItem(
                          value: 'ENTRADA_COMPRA',
                          child: Text('Entrada por compra')),
                      DropdownMenuItem(
                          value: 'SALIDA_TALLER',
                          child: Text('Salida al taller')),
                      DropdownMenuItem(
                          value: 'SALIDA_VENTA',
                          child: Text('Salida por venta')),
                      DropdownMenuItem(
                          value: 'AJUSTE', child: Text('Ajuste manual')),
                    ],
                    onChanged: (v) =>
                        setDlgState(() => tipoMovimiento = v ?? tipoMovimiento),
                  ),
                  const SizedBox(height: 10),

                  // Quantity
                  _SheetField(
                    label: 'Cantidad',
                    keyboard: TextInputType.number,
                    initialValue: cantidad,
                    onChanged: (v) => cantidad = v,
                  ),

                  // Adjustment amount (only for AJUSTE)
                  if (tipoMovimiento == 'AJUSTE') ...[
                    const SizedBox(height: 10),
                    _SheetField(
                      label: 'Cantidad Ajuste (+/-)',
                      keyboard: const TextInputType.numberWithOptions(
                          signed: true),
                      initialValue: cantidadAjuste,
                      onChanged: (v) => cantidadAjuste = v,
                    ),
                  ],
                  const SizedBox(height: 10),

                  _SheetField(
                    label: 'Observación',
                    onChanged: (v) => observacion = v,
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
                  final qty = int.tryParse(cantidad) ?? 0;
                  if (qty <= 0) return;
                  Navigator.of(dlgCtx).pop();
                  context.read<InventoryCubit>().adjustStock(
                        itemId: item.id,
                        tipoMovimiento: tipoMovimiento,
                        cantidad: qty,
                        cantidadAjuste: tipoMovimiento == 'AJUSTE'
                            ? int.tryParse(cantidadAjuste)
                            : null,
                        observacion: observacion.isEmpty ? null : observacion,
                      );
                },
                child: const Text('Confirmar',
                    style: TextStyle(
                        color: AppColors.info, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Reusable form widgets for bottom sheets / dialogs
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
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.info),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.darkCard,
              style: const TextStyle(color: Colors.white, fontSize: 14),
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
