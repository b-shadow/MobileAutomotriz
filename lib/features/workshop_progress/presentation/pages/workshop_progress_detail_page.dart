import 'package:flutter/material.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile1_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ));
        } else if (state is WorkshopProgressSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.success,
            content: Text(state.message),
          ));
        }
      },
      builder: (context, state) {
        if (state is WorkshopProgressLoading && state.activeOrders.isEmpty) {
          return const Scaffold(
            backgroundColor: AppColors.darkBackground,
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
            backgroundColor: AppColors.darkBackground,
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(
              child: Text('Cargando orden...',
                  style: TextStyle(color: Colors.white54)),
            ),
          );
        }

        final history = state.history;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: AppColors.darkCard,
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
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'Servicios', icon: Icon(Icons.handyman)),
                Tab(text: 'Repuestos', icon: Icon(Icons.build)),
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
              _RepuestosTab(
                  order: order, solicitudes: state.sparePartRequests),
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
                  backgroundColor: AppColors.success,
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
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estado Global:',
                  style: TextStyle(
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
            color: AppColors.primary,
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

class _ServiceProgressItem extends StatefulWidget {
  final WorkOrderDetail detalle;
  final String orderId;
  final String orderState;

  const _ServiceProgressItem({
    required this.detalle,
    required this.orderId,
    required this.orderState,
  });

  @override
  State<_ServiceProgressItem> createState() => _ServiceProgressItemState();
}

class _ServiceProgressItemState extends State<_ServiceProgressItem> {
  late TextEditingController _tiempoRealCtrl;
  late TextEditingController _motivoPausaCtrl;
  late TextEditingController _motivoInnecesarioCtrl;
  late TextEditingController _observacionesCtrl;

  @override
  void initState() {
    super.initState();
    _tiempoRealCtrl = TextEditingController(
        text: widget.detalle.tiempoEstandarMin.toString());
    _motivoPausaCtrl = TextEditingController();
    _motivoInnecesarioCtrl = TextEditingController();
    _observacionesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tiempoRealCtrl.dispose();
    _motivoPausaCtrl.dispose();
    _motivoInnecesarioCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detalle;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(d.servicioNombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
              _EstadoBadge(estado: d.estado),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text('Est: ${d.tiempoEstandarMin} min',
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(width: 16),
              const Icon(Icons.person_outline,
                  size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  d.mecanicoNombres ?? 'Sin mecánico asignado',
                  style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Campos inline
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _tiempoRealCtrl,
                  label: 'Tiempo Real (min)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _motivoPausaCtrl,
                  label: 'Motivo Pausa',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motivoInnecesarioCtrl,
                  label: 'Motivo Innecesario',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _observacionesCtrl,
                  label: 'Obs. Mecánico',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Botones de acción inline
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final cubit = context.read<WorkshopProgressCubit>();
    final d = widget.detalle;
    final List<Widget> actions = [];

    if (widget.orderState == 'CERRADA' ||
        widget.orderState == 'CANCELADA' ||
        widget.orderState == 'FINALIZADA') {
      return [
        const Text('La orden ya no es modificable',
            style: TextStyle(color: Colors.white54))
      ];
    }

    if (d.estado == 'POR_HACER' || d.estado == 'PAUSADO') {
      actions.add(_buildActionBtn(
        label: 'Iniciar',
        color: AppColors.info,
        onTap: () => cubit.startServiceDetail(widget.orderId, d.id),
      ));
    }

    if (d.estado == 'EN_PROCESO') {
      actions.add(_buildActionBtn(
        label: 'Pausar',
        color: AppColors.warning,
        onTap: () => cubit.pauseServiceDetail(
            widget.orderId, d.id, _motivoPausaCtrl.text),
      ));
      actions.add(_buildActionBtn(
        label: 'Finalizar',
        color: AppColors.success,
        onTap: () => cubit.finishServiceDetail(
          widget.orderId,
          d.id,
          int.tryParse(_tiempoRealCtrl.text) ?? d.tiempoEstandarMin,
          _observacionesCtrl.text,
        ),
      ));
    }

    if (d.estado != 'FINALIZADO' && d.estado != 'INNECESARIO') {
      actions.add(_buildActionBtn(
        label: 'Innecesario',
        color: AppColors.darkTextTertiary,
        onTap: () => cubit.markServiceUnnecessary(
            widget.orderId, d.id, _motivoInnecesarioCtrl.text),
      ));
    }

    if (actions.isEmpty) {
      actions.add(const Text('No hay acciones disponibles',
          style: TextStyle(color: Colors.white54, fontSize: 13)));
    }

    return actions;
  }

  Widget _buildActionBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PESTAÑA: REPUESTOS
// ─────────────────────────────────────────────────────────────────────────────
class _RepuestosTab extends StatelessWidget {
  final WorkOrder order;
  final List<SparePartRequest> solicitudes;

  const _RepuestosTab({required this.order, required this.solicitudes});

  @override
  Widget build(BuildContext context) {
    // Aplanar todas las líneas de detalles de las solicitudes de esta orden
    final detalles = solicitudes
        .expand((s) => s.detalles.map(
              (d) => _DetalleRepuestoExt(d, s.id, s.estado),
            ))
        .toList();

    final pendientes = detalles.where((d) => d.detalle.pendienteRecibir).toList();
    final recibidos = detalles.where((d) => d.detalle.cantidadRecibidaTaller > 0).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Repuestos Pendientes de Recibir',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (pendientes.isEmpty)
                const Text('No hay repuestos pendientes.',
                    style: TextStyle(color: Colors.white54, fontSize: 13))
              else
                ...pendientes.map((d) => _buildRepuestoCard(context, d, isPendiente: true)),
              const SizedBox(height: 24),
              const Text('Repuestos Recibidos',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (recibidos.isEmpty)
                const Text('No hay repuestos recibidos.',
                    style: TextStyle(color: Colors.white54, fontSize: 13))
              else
                ...recibidos.map((d) => _buildRepuestoCard(context, d, isPendiente: false)),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                if (user.isAdmin || user.isAsesor) {
                  return FloatingActionButton.extended(
                    backgroundColor: AppColors.error,
                    onPressed: () => _showSolicitarRepuestosSheet(context),
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                    label: const Text('Solicitar Repuestos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRepuestoCard(BuildContext context, _DetalleRepuestoExt ext, {required bool isPendiente}) {
    final d = ext.detalle;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.itemNombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  isPendiente
                      ? 'Entregado: ${d.cantidadEntregada} | Recibido: ${d.cantidadRecibidaTaller}'
                      : 'Cantidad Recibida: ${d.cantidadRecibidaTaller}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isPendiente)
            ElevatedButton(
              onPressed: () {
                context.read<WorkshopProgressCubit>().markSparePartReceived(
                      solicitudId: ext.solicitudId,
                      detalleId: d.id,
                      cantidadEntregada: d.cantidadEntregada,
                      ordenGlobalId: order.id,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Marcar recibido',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  void _showSolicitarRepuestosSheet(BuildContext context) {
    context.read<WorkshopProgressCubit>().loadInventoryItems();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SolicitarRepuestosForm(order: order, cubitContext: context),
    );
  }
}

class _DetalleRepuestoExt {
  final SparePartDetail detalle;
  final String solicitudId;
  final String solicitudEstado;
  _DetalleRepuestoExt(this.detalle, this.solicitudId, this.solicitudEstado);
}

class _SolicitarRepuestosForm extends StatefulWidget {
  final WorkOrder order;
  final BuildContext cubitContext;

  const _SolicitarRepuestosForm({required this.order, required this.cubitContext});

  @override
  State<_SolicitarRepuestosForm> createState() => _SolicitarRepuestosFormState();
}

class _SolicitarRepuestosFormState extends State<_SolicitarRepuestosForm> {
  String _motivo = '';
  List<SparePartRequestLine> _lineas = [SparePartRequestLine()];

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
          const Text('Nueva solicitud de repuestos',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Motivo general',
            onChanged: (val) => _motivo = val,
          ),
          const SizedBox(height: 16),
          const Text('Repuestos:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(_lineas.length, (index) {
                  return _buildLineaForm(index);
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _lineas.add(SparePartRequestLine());
              });
            },
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Agregar línea'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white54)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.cubitContext.read<WorkshopProgressCubit>().createSparePartRequest(
                          citaId: widget.order.citaId,
                          ordenGlobalId: widget.order.id,
                          motivo: _motivo,
                          lineas: _lineas,
                        );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error),
                  child: const Text('Crear Solicitud',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLineaForm(int index) {
    final linea = _lineas[index];
    final inventoryItems = widget.cubitContext.read<WorkshopProgressCubit>().state.inventoryItems;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: linea.itemInventarioId.isEmpty ? null : linea.itemInventarioId,
                    hint: const Text('Seleccionar ítem...', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    isExpanded: true,
                    dropdownColor: AppColors.darkCard,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: inventoryItems.map((item) {
                      return DropdownMenuItem(
                        value: item.id,
                        child: Text(item.label, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        linea.itemInventarioId = val ?? '';
                      });
                    },
                  ),
                ),
              ),
              if (_lineas.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () {
                    setState(() {
                      _lineas.removeAt(index);
                    });
                  },
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildTextField(
                  label: 'Cant.',
                  initialValue: linea.cantidadSolicitada.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => linea.cantidadSolicitada = int.tryParse(val) ?? 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildTextField(
                  label: 'Observación',
                  initialValue: linea.observacion,
                  onChanged: (val) => linea.observacion = val,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF8B5CF6))),
      ),
      onChanged: onChanged,
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
            backgroundColor: AppColors.primary,
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
      backgroundColor: AppColors.darkCard,
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
                fillColor: AppColors.darkBackground,
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
                fillColor: AppColors.darkBackground,
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
                    backgroundColor: AppColors.primary,
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

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (estado) {
      'ABIERTA' => (AppColors.warning, 'Abierta'),
      'ASIGNADA' => (const Color(0xFF6366F1), 'Asignada'),
      'EN_PROCESO' => (AppColors.info, 'En Proceso'),
      'PAUSADA' => (AppColors.error, 'Pausada'),
      'FINALIZADA' => (AppColors.success, 'Finalizada'),
      'CERRADA' => (AppColors.darkTextTertiary, 'Cerrada'),
      'POR_HACER' => (AppColors.darkTextTertiary, 'Por Hacer'),
      'FINALIZADO' => (AppColors.success, 'Finalizado'),
      'INNECESARIO' => (AppColors.error, 'Anulado'),
      'EN PROCESO' => (AppColors.info, 'En Proceso'),
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
