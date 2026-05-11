import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/presentation/cubit/workshop_progress_cubit.dart';
import 'package:mobile1_app/features/workshop_progress/presentation/cubit/workshop_progress_state.dart';

class WorkshopProgressPage extends StatefulWidget {
  const WorkshopProgressPage({super.key});

  @override
  State<WorkshopProgressPage> createState() => _WorkshopProgressPageState();
}

class _WorkshopProgressPageState extends State<WorkshopProgressPage> {
  @override
  void initState() {
    super.initState();
    context.read<WorkshopProgressCubit>().fetchActiveWorkOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Avance en Taller',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<WorkshopProgressCubit>().fetchActiveWorkOrders(),
          ),
        ],
      ),
      body: BlocConsumer<WorkshopProgressCubit, WorkshopProgressState>(
        listener: (ctx, state) {
          if (state is WorkshopProgressError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFFEF4444),
              content: Text(state.message),
            ));
          }
        },
        builder: (ctx, state) {
          if (state is WorkshopProgressLoading && state.activeOrders.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
          }

          if (state.activeOrders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.garage_outlined, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('No hay órdenes activas en el taller.',
                      style: TextStyle(color: Colors.white54, fontSize: 15)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF8B5CF6),
            onRefresh: () =>
                context.read<WorkshopProgressCubit>().fetchActiveWorkOrders(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.activeOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  _ActiveOrderCard(order: state.activeOrders[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final WorkOrder order;

  const _ActiveOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    // Calculamos progreso localmente basado en detalles
    final total = order.detalles.length;
    final terminados = order.detalles
        .where((d) => d.estado == 'FINALIZADO' || d.estado == 'INNECESARIO')
        .length;
    final pct = total == 0 ? 0 : ((terminados / total) * 100).toInt();

    return InkWell(
      onTap: () => context.push('/workshop-progress-detail/${order.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.handyman, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'OT #${order.numero}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                _EstadoBadge(estado: order.estado),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
                icon: Icons.directions_car,
                label: 'Vehículo',
                value: order.vehiculoPlaca ?? 'N/A'),
            _InfoRow(
                icon: Icons.person_outline,
                label: 'Cliente',
                value: order.clienteNombre ?? 'N/A'),
            _InfoRow(
                icon: Icons.calendar_today,
                label: 'Apertura',
                value: fmtDate.format(order.fechaApertura.toLocal())),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progreso de Servicios',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('$terminados/$total ($pct%)',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: total == 0 ? 0 : terminados / total,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: const Color(0xFF8B5CF6),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 6),
          Text('$label: ',
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
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
      'ABIERTA' => (const Color(0xFFF59E0B), 'Abierta'),
      'ASIGNADA' => (const Color(0xFF6366F1), 'Asignada'),
      'EN_PROCESO' => (const Color(0xFF3B82F6), 'En Proceso'),
      'PAUSADA' => (const Color(0xFFEF4444), 'Pausada'),
      'FINALIZADA' => (const Color(0xFF10B981), 'Finalizada'),
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
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
