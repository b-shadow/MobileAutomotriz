import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';
import 'package:mobile1_app/features/workshop_progress/presentation/cubit/workshop_progress_cubit.dart';
import 'package:mobile1_app/features/workshop_progress/presentation/cubit/workshop_progress_state.dart';

class WorkshopProgressDetailPage extends StatefulWidget {
  final String workOrderId;

  const WorkshopProgressDetailPage({super.key, required this.workOrderId});

  @override
  State<WorkshopProgressDetailPage> createState() =>
      _WorkshopProgressDetailPageState();
}

class _WorkshopProgressDetailPageState extends State<WorkshopProgressDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context
        .read<WorkshopProgressCubit>()
        .fetchWorkOrderDetail(widget.workOrderId);
    context
        .read<WorkshopProgressCubit>()
        .fetchProgressHistory(widget.workOrderId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkshopProgressCubit, WorkshopProgressState>(
      listener: (context, state) {
        if (state is WorkshopProgressError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text(state.message),
          ));
        } else if (state is WorkshopProgressSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(state.message),
          ));
        }
      },
      builder: (context, state) {
        if (state is WorkshopProgressLoading && state.activeOrders.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
          );
        }

        WorkOrder? order;
        if (state is WorkshopProgressDetailLoaded) {
          order = state.detail;
        } else if (state is WorkshopProgressHistoryLoaded) {
          order = state.detail;
        } else if (state is WorkshopProgressSuccess) {
          order = state.detail;
        }

        if (order == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(
              child: Text('Cargando orden...',
                  style: TextStyle(color: Colors.white54)),
            ),
          );
        }

        final history = state.history;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bitácora de Taller',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('OT #${order.numero}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF8B5CF6),
              labelColor: const Color(0xFF8B5CF6),
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'Servicios', icon: Icon(Icons.handyman)),
                Tab(text: 'Historial', icon: Icon(Icons.history)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context
                      .read<WorkshopProgressCubit>()
                      .fetchWorkOrderDetail(widget.workOrderId);
                  context
                      .read<WorkshopProgressCubit>()
                      .fetchProgressHistory(widget.workOrderId);
                },
              )
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _ServiciosTab(order: order),
              _HistorialTab(order: order, history: history),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PESTAÑA: SERVICIOS
// ─────────────────────────────────────────────────────────────────────────────
class _ServiciosTab extends StatelessWidget {
  final WorkOrder order;
  const _ServiciosTab({required this.order});

  @override
  Widget build(BuildContext context) {
    final terminados = order.detalles
        .where((d) => d.estado == 'FINALIZADO' || d.estado == 'INNECESARIO')
        .length;
    final todosTerminados =
        order.detalles.isNotEmpty && terminados == order.detalles.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderInfo(order: order),
          const SizedBox(height: 24),
          const Text('Progreso Técnico',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (order.detalles.isEmpty)
            const Text('No hay servicios asignados a esta orden.',
                style: TextStyle(color: Colors.white54))
          else
            ...order.detalles.map((d) => _ServiceProgressItem(
                detalle: d,
                orderId: order.id,
                orderState: order.estado)),
          const SizedBox(height: 24),
          if (todosTerminados &&
              (order.estado == 'EN_PROCESO' || order.estado == 'PAUSADA'))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context
                    .read<WorkshopProgressCubit>()
                    .finishWorkOrder(order.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Finalizar Orden Completamente',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final WorkOrder order;
  const _HeaderInfo({required this.order});

  @override
  Widget build(BuildContext context) {
    final terminados = order.detalles
        .where((d) => d.estado == 'FINALIZADO' || d.estado == 'INNECESARIO')
        .length;
    final total = order.detalles.length;

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
              Text('Estado Global:',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              _EstadoBadge(estado: order.estado),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: total == 0 ? 0 : terminados / total,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            color: const Color(0xFF8B5CF6),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text('$terminados de $total servicios completados',
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ServiceProgressItem extends StatelessWidget {
  final WorkOrderDetail detalle;
  final String orderId;
  final String orderState;

  const _ServiceProgressItem({
    required this.detalle,
    required this.orderId,
    required this.orderState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white54,
          title: Text(detalle.servicioNombre,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  _EstadoBadge(estado: detalle.estado),
                  const SizedBox(width: 8),
                  Text('Est: ${detalle.tiempoEstandarMin} min',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              if (detalle.mecanicoNombres != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Mecánico: ${detalle.mecanicoNombres}',
                      style: const TextStyle(
                          color: Color(0xFF8B5CF6), fontSize: 12)),
                ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildActions(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final cubit = context.read<WorkshopProgressCubit>();
    final List<Widget> actions = [];

    if (orderState == 'CERRADA' || orderState == 'CANCELADA' || orderState == 'FINALIZADA') {
      return [const Text('La orden ya no es modificable', style: TextStyle(color: Colors.white54))];
    }

    if (detalle.estado == 'POR_HACER' || detalle.estado == 'PAUSADO') {
      actions.add(_ActionBtn(
        icon: Icons.play_arrow,
        label: 'Iniciar',
        color: const Color(0xFF3B82F6),
        onTap: () => cubit.startServiceDetail(orderId, detalle.id),
      ));
    }

    if (detalle.estado == 'EN_PROCESO') {
      actions.add(_ActionBtn(
        icon: Icons.pause,
        label: 'Pausar',
        color: const Color(0xFFF59E0B),
        onTap: () => _showDialogPrompt(
          context: context,
          title: 'Pausar Servicio',
          fieldLabel: 'Motivo de pausa',
          onSubmit: (val) =>
              cubit.pauseServiceDetail(orderId, detalle.id, val),
        ),
      ));
      actions.add(_ActionBtn(
        icon: Icons.check,
        label: 'Finalizar',
        color: const Color(0xFF10B981),
        onTap: () => _showFinishDialog(context, cubit),
      ));
    }

    if (detalle.estado != 'FINALIZADO' && detalle.estado != 'INNECESARIO') {
      actions.add(_ActionBtn(
        icon: Icons.cancel_outlined,
        label: 'Anular',
        color: const Color(0xFFEF4444),
        onTap: () => _showDialogPrompt(
          context: context,
          title: 'Marcar como Innecesario',
          fieldLabel: 'Justificación técnica',
          onSubmit: (val) =>
              cubit.markServiceUnnecessary(orderId, detalle.id, val),
        ),
      ));
    }

    if (actions.isEmpty) {
      actions.add(const Text('No hay acciones disponibles',
          style: TextStyle(color: Colors.white54)));
    }

    return actions;
  }

  void _showFinishDialog(BuildContext context, WorkshopProgressCubit cubit) {
    int tiempo = detalle.tiempoEstandarMin;
    String obs = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Finalizar Servicio',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: tiempo.toString(),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tiempo Real (minutos)',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
              ),
              onChanged: (val) => tiempo = int.tryParse(val) ?? tiempo,
            ),
            const SizedBox(height: 12),
            TextFormField(
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Observaciones Técnicas (Opcional)',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
              ),
              onChanged: (val) => obs = val,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () {
                cubit.finishServiceDetail(orderId, detalle.id, tiempo, obs);
                Navigator.pop(ctx);
              },
              child: const Text('Completar',
                  style: TextStyle(color: Color(0xFF10B981)))),
        ],
      ),
    );
  }

  void _showDialogPrompt({
    required BuildContext context,
    required String title,
    required String fieldLabel,
    required Function(String) onSubmit,
  }) {
    String text = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextFormField(
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: fieldLabel,
            labelStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
          ),
          onChanged: (val) => text = val,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () {
                onSubmit(text);
                Navigator.pop(ctx);
              },
              child: const Text('Aceptar')),
        ],
      ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PESTAÑA: HISTORIAL DE AVANCES
// ─────────────────────────────────────────────────────────────────────────────
class _HistorialTab extends StatelessWidget {
  final WorkOrder order;
  final List<ProgressLog> history;

  const _HistorialTab({required this.order, required this.history});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (history.isEmpty)
          const Center(
              child: Text('No hay registros en el historial.',
                  style: TextStyle(color: Colors.white54)))
        else
          ListView.builder(
            padding: const EdgeInsets.all(16).copyWith(bottom: 80),
            itemCount: history.length,
            itemBuilder: (ctx, i) {
              final log = history[i];
              return _HistoryLogItem(log: log);
            },
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF8B5CF6),
            onPressed: () => _showAddProgressSheet(context),
            child: const Icon(Icons.add_comment, color: Colors.white),
          ),
        )
      ],
    );
  }

  void _showAddProgressSheet(BuildContext context) {
    String msg = '';
    int pct = 0;
    final cubit = context.read<WorkshopProgressCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrar Avance Manual',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Mensaje u observación',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
              onChanged: (val) => msg = val,
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Porcentaje actual estimado (0-100)',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
              onChanged: (val) => pct = int.tryParse(val) ?? 0,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cubit.addManualProgressLog(
                    citaId: order.citaId,
                    orderId: order.id,
                    message: msg,
                    percentage: pct,
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Guardar Registro',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HistoryLogItem extends StatelessWidget {
  final ProgressLog log;

  const _HistoryLogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM, HH:mm').format(log.createdAt.toLocal());
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 60,
                color: Colors.white10,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(log.tipo,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(date,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                if (log.estadoNuevo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _EstadoBadge(estado: log.estadoNuevo),
                  ),
                if (log.mensaje.isNotEmpty)
                  Text(log.mensaje,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Por: ${log.registradoPor ?? "Sistema"}',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse the badge builder for consistency inside the detail
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
      'CERRADA' => (const Color(0xFF64748B), 'Cerrada'),
      'POR_HACER' => (const Color(0xFF94A3B8), 'Por Hacer'),
      'FINALIZADO' => (const Color(0xFF10B981), 'Finalizado'),
      'INNECESARIO' => (const Color(0xFFEF4444), 'Anulado'),
      'EN PROCESO' => (const Color(0xFF3B82F6), 'En Proceso'),
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
