import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:mobile1_app/features/budget/presentation/cubit/budget_state.dart';

class BudgetDetailPage extends StatefulWidget {
  final String budgetId;

  const BudgetDetailPage({super.key, required this.budgetId});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetCubit>().fetchBudgetDetail(widget.budgetId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BudgetCubit, BudgetState>(
      listener: (context, state) {
        if (state is BudgetError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text(state.message),
          ));
        } else if (state is BudgetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(state.message),
          ));
          context.read<BudgetCubit>().fetchBudgetDetail(widget.budgetId);
        }
      },
      builder: (context, state) {
        if (state is BudgetLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
          );
        }

        Budget? budget;
        if (state is BudgetDetailLoaded) {
          budget = state.detail;
        } else if (state is BudgetSuccess) {
          budget = state.budget;
        }

        if (budget == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            appBar: AppBar(
                backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(
              child: Text('Cargando o no se encontró el presupuesto',
                  style: TextStyle(color: Colors.white54)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Detalle Presupuesto',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context
                    .read<BudgetCubit>()
                    .fetchBudgetDetail(widget.budgetId),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen general
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estado',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)),
                          _EstadoBadge(estado: budget.estado),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      _TotalesRow('Subtotal', budget.subtotal),
                      const SizedBox(height: 8),
                      _TotalesRow('Descuento', budget.descuento,
                          color: const Color(0xFFF59E0B)),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white10, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total a Pagar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('Bs ${budget.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Botones de acción según estado
                _AccionesPresupuesto(budget: budget),
                const SizedBox(height: 24),
                // Lista de servicios (detalles)
                const Text('Servicios y Repuestos',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (budget.detalles.isEmpty)
                  const Text('No hay detalles registrados.',
                      style: TextStyle(color: Colors.white54))
                else
                  ...budget.detalles.map((d) => _DetalleItem(d)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _TotalesRow(String label, double value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        Text('Bs ${value.toStringAsFixed(2)}',
            style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DetalleItem extends StatelessWidget {
  final BudgetDetail detalle;

  const _DetalleItem(this.detalle);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.build_circle_outlined,
                color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detalle.descripcion,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                    'Cant: ${detalle.cantidad}  ·  Precio: Bs ${detalle.precioUnitario.toStringAsFixed(2)}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text('Bs ${detalle.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

class _AccionesPresupuesto extends StatelessWidget {
  final Budget budget;

  const _AccionesPresupuesto({required this.budget});

  @override
  Widget build(BuildContext context) {
    final estado = budget.estado;
    final cubit = context.read<BudgetCubit>();

    return Column(
      children: [
        if (estado == 'BORRADOR' || estado == 'AJUSTADO')
          _ActionButton(
            icon: Icons.send,
            label: 'Comunicar al Cliente',
            color: const Color(0xFF3B82F6),
            onPressed: () =>
                cubit.changeStatus(id: budget.id, action: 'comunicar'),
          ),
        if (estado == 'COMUNICADO' || estado == 'AJUSTADO') ...[
          _ActionButton(
            icon: Icons.thumb_up,
            label: 'Aprobar Presupuesto',
            color: const Color(0xFF10B981),
            onPressed: () =>
                cubit.changeStatus(id: budget.id, action: 'aprobar'),
          ),
          _ActionButton(
            icon: Icons.thumb_down,
            label: 'Rechazar Presupuesto',
            color: const Color(0xFFEF4444),
            onPressed: () => _mostrarDialogoRechazo(context, cubit),
          ),
        ],
        if (estado == 'COMUNICADO' || estado == 'RECHAZADO')
          _ActionButton(
            icon: Icons.tune,
            label: 'Ajustar Presupuesto',
            color: const Color(0xFF8B5CF6),
            onPressed: () =>
                cubit.changeStatus(id: budget.id, action: 'ajustar'),
          ),
      ],
    );
  }

  void _mostrarDialogoRechazo(BuildContext context, BudgetCubit cubit) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Rechazar Presupuesto',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Motivo del rechazo',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.changeStatus(
                  id: budget.id, action: 'rechazar', motivo: ctrl.text);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Confirmar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.15),
            foregroundColor: color,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: color.withValues(alpha: 0.5)),
            ),
          ),
          icon: Icon(icon, size: 20),
          label: Text(label,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (estado) {
      'BORRADOR' => (const Color(0xFF94A3B8), 'Borrador'),
      'COMUNICADO' => (const Color(0xFFF59E0B), 'Comunicado'),
      'APROBADO' => (const Color(0xFF10B981), 'Aprobado'),
      'RECHAZADO' => (const Color(0xFFEF4444), 'Rechazado'),
      'AJUSTADO' => (const Color(0xFF8B5CF6), 'Ajustado'),
      'CERRADO' => (const Color(0xFF3B82F6), 'Cerrado'),
      _ => (Colors.grey, estado),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
