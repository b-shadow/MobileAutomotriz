import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/work_order/presentation/cubit/work_order_cubit.dart';
import 'package:mobile1_app/features/work_order/presentation/cubit/work_order_state.dart';

class WorkOrderPage extends StatefulWidget {
  const WorkOrderPage({super.key});

  @override
  State<WorkOrderPage> createState() => _WorkOrderPageState();
}

class _WorkOrderPageState extends State<WorkOrderPage> {
  @override
  void initState() {
    super.initState();
    context.read<WorkOrderCubit>().fetchWorkOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Órdenes de Trabajo',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WorkOrderCubit>().fetchWorkOrders(),
          ),
        ],
      ),
      body: BlocConsumer<WorkOrderCubit, WorkOrderState>(
        listener: (ctx, state) {
          if (state is WorkOrderError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFFEF4444),
              content: Text(state.message),
            ));
          }
        },
        builder: (ctx, state) {
          if (state is WorkOrderLoading && state.workOrders.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
          }

          if (state.workOrders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build_circle_outlined,
                      size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('No hay órdenes de trabajo activas',
                      style: TextStyle(color: Colors.white54, fontSize: 15)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF3B82F6),
            onRefresh: () => context.read<WorkOrderCubit>().fetchWorkOrders(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.workOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _WorkOrderCard(order: state.workOrders[i]),
            ),
          );
        },
      ),
    );
  }
}

class _WorkOrderCard extends StatelessWidget {
  final WorkOrder order;

  const _WorkOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    return InkWell(
      onTap: () => context.push('/work-order-detail/${order.id}'),
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
                const Icon(Icons.handyman, color: Color(0xFF3B82F6), size: 20),
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
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people_alt_outlined,
                    size: 14, color: Colors.white38),
                const SizedBox(width: 6),
                Text(
                  '${order.mecanicosAsignados.length} mecánicos asignados',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
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
      'ASIGNADA' => (const Color(0xFF8B5CF6), 'Asignada'),
      'EN_PROCESO' => (const Color(0xFF3B82F6), 'En Proceso'),
      'PAUSADA' => (const Color(0xFFEF4444), 'Pausada'),
      'COMPLETADA' => (const Color(0xFF10B981), 'Completada'),
      'CERRADA' => (const Color(0xFF64748B), 'Cerrada'),
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
