import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/work_order/presentation/cubit/work_order_cubit.dart';
import 'package:mobile1_app/features/work_order/presentation/cubit/work_order_state.dart';

class WorkOrderDetailPage extends StatefulWidget {
  final String workOrderId;

  const WorkOrderDetailPage({super.key, required this.workOrderId});

  @override
  State<WorkOrderDetailPage> createState() => _WorkOrderDetailPageState();
}

class _WorkOrderDetailPageState extends State<WorkOrderDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<WorkOrderCubit>().fetchWorkOrderDetail(widget.workOrderId);
    context.read<WorkOrderCubit>().fetchAvailableMechanics();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkOrderCubit, WorkOrderState>(
      listener: (context, state) {
        if (state is WorkOrderError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text(state.message),
          ));
        } else if (state is WorkOrderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(state.message),
          ));
          context
              .read<WorkOrderCubit>()
              .fetchWorkOrderDetail(widget.workOrderId);
        }
      },
      builder: (context, state) {
        if (state is WorkOrderLoading && state.workOrders.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
          );
        }

        WorkOrder? order;
        if (state is WorkOrderDetailLoaded) {
          order = state.detail;
        } else if (state is WorkOrderSuccess) {
          order = state.detail;
        }

        if (order == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(
              child: Text('Cargando o no se encontró la orden',
                  style: TextStyle(color: Colors.white54)),
            ),
          );
        }

        final mechanicsList = state.mechanics;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Detalle de Orden',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context
                      .read<WorkOrderCubit>()
                      .fetchWorkOrderDetail(widget.workOrderId);
                  context.read<WorkOrderCubit>().fetchAvailableMechanics();
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderInfo(order: order),
                const SizedBox(height: 24),
                if (order.estado == 'ABIERTA' || order.estado == 'ASIGNADA')
                  _StartOrderButton(order: order),
                const SizedBox(height: 24),
                _MechanicsSection(order: order, available: mechanicsList),
                const SizedBox(height: 24),
                _DetailsSection(order: order, available: mechanicsList),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final WorkOrder order;
  const _HeaderInfo({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('OT #${order.numero}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              _EstadoBadge(estado: order.estado),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          _InfoRow(
              icon: Icons.directions_car,
              label: 'Vehículo',
              value: order.vehiculoPlaca ?? 'N/A'),
          const SizedBox(height: 8),
          _InfoRow(
              icon: Icons.person_outline,
              label: 'Cliente',
              value: order.clienteNombre ?? 'N/A'),
        ],
      ),
    );
  }
}

class _StartOrderButton extends StatelessWidget {
  final WorkOrder order;
  const _StartOrderButton({required this.order});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.read<WorkOrderCubit>().startWorkOrder(order.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.15),
          foregroundColor: const Color(0xFF10B981),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
          ),
        ),
        icon: const Icon(Icons.play_circle_fill, size: 22),
        label: const Text('Iniciar Orden de Trabajo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _MechanicsSection extends StatelessWidget {
  final WorkOrder order;
  final List<Mechanic> available;
  const _MechanicsSection({required this.order, required this.available});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mecánicos Asignados',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            if (order.estado == 'ABIERTA' || order.estado == 'ASIGNADA')
              TextButton.icon(
                onPressed: () => _showAssignMechanicSheet(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Asignar'),
              )
          ],
        ),
        const SizedBox(height: 12),
        if (order.mecanicosAsignados.isEmpty)
          const Text('No hay mecánicos asignados.',
              style: TextStyle(color: Colors.white54))
        else
          ...order.mecanicosAsignados.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white54, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(m.mecanicoNombres,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                    if (m.esPrincipal)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Principal',
                            style: TextStyle(
                                color: Color(0xFF3B82F6), fontSize: 10)),
                      )
                  ],
                ),
              )),
      ],
    );
  }

  void _showAssignMechanicSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AssignMechanicSheet(
        orderId: order.id,
        available: available,
        currentAssignations: order.mecanicosAsignados,
        cubit: context.read<WorkOrderCubit>(),
      ),
    );
  }
}

class _AssignMechanicSheet extends StatefulWidget {
  final String orderId;
  final List<Mechanic> available;
  final List<WorkOrderMechanic> currentAssignations;
  final WorkOrderCubit cubit;

  const _AssignMechanicSheet({
    required this.orderId,
    required this.available,
    required this.currentAssignations,
    required this.cubit,
  });

  @override
  State<_AssignMechanicSheet> createState() => _AssignMechanicSheetState();
}

class _AssignMechanicSheetState extends State<_AssignMechanicSheet> {
  String? selectedMechanicId;
  bool esPrincipal = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Asignar Mecánico',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (widget.available.isEmpty)
            const Text('No hay mecánicos disponibles.',
                style: TextStyle(color: Colors.white54))
          else
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1E293B),
              value: selectedMechanicId,
              hint: const Text('Seleccione un mecánico',
                  style: TextStyle(color: Colors.white38)),
              items: widget.available
                  .map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.nombre,
                          style: const TextStyle(color: Colors.white))))
                  .toList(),
              onChanged: (val) => setState(() => selectedMechanicId = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Mecánico Principal',
                style: TextStyle(color: Colors.white)),
            value: esPrincipal,
            onChanged: (val) => setState(() => esPrincipal = val),
            activeColor: const Color(0xFF3B82F6),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedMechanicId == null
                  ? null
                  : () {
                      final currentIds = widget.currentAssignations
                          .map((e) => e.mecanico)
                          .toList();
                      if (!currentIds.contains(selectedMechanicId)) {
                        currentIds.add(selectedMechanicId!);
                      }
                      
                      // Preparamos payload para todos los asignados (el backend reemplaza la lista completa)
                      // Como la UI simple solo agrega, vamos a mandar el nuevo y mantener los demas, 
                      // OJO: solo puede haber 1 principal. Si asignamos otro principal, pasamos los demás a secundario.
                      final mechanicsPayload = <Map<String, dynamic>>[];
                      
                      for (var ca in widget.currentAssignations) {
                        bool princ = ca.esPrincipal;
                        if (esPrincipal && ca.mecanico != selectedMechanicId) {
                          princ = false; // Solo 1 principal
                        }
                        if (ca.mecanico != selectedMechanicId) {
                          mechanicsPayload.add({
                            'mecanico_id': ca.mecanico,
                            'es_principal': princ,
                          });
                        }
                      }
                      mechanicsPayload.add({
                        'mecanico_id': selectedMechanicId,
                        'es_principal': esPrincipal,
                      });

                      widget.cubit.assignMechanics(
                          id: widget.orderId, mechanics: mechanicsPayload);
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Guardar Asignación',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final WorkOrder order;
  final List<Mechanic> available;
  const _DetailsSection({required this.order, required this.available});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Servicios a Realizar',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (order.detalles.isEmpty)
          const Text('No hay servicios registrados.',
              style: TextStyle(color: Colors.white54))
        else
          ...order.detalles.map((d) => _DetalleItem(d)),
      ],
    );
  }
}

class _DetalleItem extends StatelessWidget {
  final WorkOrderDetail detalle;

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
                Text(detalle.servicioNombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text('Tiempo est.: ${detalle.tiempoEstandarMin} min',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                if (detalle.mecanicoNombres != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Mecánico: ${detalle.mecanicoNombres}',
                        style: const TextStyle(
                            color: Color(0xFF3B82F6), fontSize: 12)),
                  ),
              ],
            ),
          ),
          _EstadoBadge(estado: detalle.estado),
        ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(color: Colors.white38, fontSize: 14)),
        Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 14))),
      ],
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
      'POR_HACER' => (const Color(0xFF94A3B8), 'Por Hacer'),
      'FINALIZADO' => (const Color(0xFF10B981), 'Finalizado'),
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
