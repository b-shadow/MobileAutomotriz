import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import '../cubit/vehicle_progress_cubit.dart';
import 'package:intl/intl.dart';

class VehicleProgressDetailPage extends StatefulWidget {
  final String citaId;

  const VehicleProgressDetailPage({super.key, required this.citaId});

  @override
  State<VehicleProgressDetailPage> createState() => _VehicleProgressDetailPageState();
}

class _VehicleProgressDetailPageState extends State<VehicleProgressDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<VehicleProgressCubit>().fetchDetail(widget.citaId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Avance General'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.darkTextTertiary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'ESTADO GLOBAL', icon: Icon(Icons.dashboard)),
            Tab(text: 'HISTORIAL', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: BlocConsumer<VehicleProgressCubit, VehicleProgressState>(
        listener: (context, state) {
          if (state is VehicleProgressError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: AppColors.error,
              content: Text(state.message),
            ));
          }
          if (state is VehicleProgressSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: AppColors.success,
              content: Text(state.message),
            ));
          }
        },
        builder: (context, state) {
          if (state is VehicleProgressInitial || (state is VehicleProgressLoading && _getDetailFromState(state) == null)) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final detail = _getDetailFromState(state);
          final history = _getHistoryFromState(state);

          if (detail == null) {
            return Center(child: Text('No se pudo cargar el detalle', style: TextStyle(color: AppColors.darkTextSecondary)));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralStateTab(detail, state is VehicleProgressLoading),
              _buildHistoryTab(history, state is VehicleProgressLoading),
            ],
          );
        },
      ),
    );
  }

  dynamic _getDetailFromState(VehicleProgressState state) {
    if (state is VehicleProgressDetailLoaded) return state.detail;
    if (state is VehicleProgressSuccess) return state.detail;
    if (state is VehicleProgressLoading) return context.read<VehicleProgressCubit>().state is VehicleProgressDetailLoaded ? (context.read<VehicleProgressCubit>().state as VehicleProgressDetailLoaded).detail : null;
    return null;
  }

  List _getHistoryFromState(VehicleProgressState state) {
    if (state is VehicleProgressDetailLoaded) return state.history;
    if (state is VehicleProgressSuccess) return state.history;
    if (state is VehicleProgressLoading) return state.history;
    return [];
  }

  Widget _buildGeneralStateTab(dynamic detail, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkCardBorder),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detail.vehiculoPlaca,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    _buildStatusBadge(detail.estado),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${detail.vehiculoMarca} ${detail.vehiculoModelo}', style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 16)),
                Divider(height: 24, color: AppColors.darkSurfaceVariant),
                _buildInfoRow(Icons.person, 'Cliente', detail.clienteNombres),
                if (detail.asesorNombres != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.support_agent, 'Asesor', detail.asesorNombres!),
                ],
                const SizedBox(height: 8),
                _buildInfoRow(Icons.timer, 'Duración Estimada', '${detail.duracionEstimadaMin} min'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Acciones Globales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          
          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: AppColors.primary)))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (detail.accionesFlags['puede_registrar_llegada'] == true)
                  _buildActionButton(
                    'Registrar Llegada al Taller',
                    Icons.login,
                    AppColors.info,
                    () => context.read<VehicleProgressCubit>().registerArrival(widget.citaId),
                  ),
                if (detail.accionesFlags['puede_marcar_en_proceso'] == true)
                  _buildActionButton(
                    'Marcar en Proceso (Inicio Trabajos)',
                    Icons.build_circle,
                    AppColors.primary,
                    () => context.read<VehicleProgressCubit>().markInProcess(widget.citaId),
                  ),
                if (detail.accionesFlags['puede_marcar_vehiculo_devuelto'] == true)
                  _buildActionButton(
                    'Marcar Vehículo Devuelto',
                    Icons.check_circle,
                    AppColors.success,
                    () => _confirmReturnVehicle(),
                  ),
                if (detail.accionesFlags.values.every((element) => element == false))
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.darkTextTertiary),
                        const SizedBox(width: 12),
                        Expanded(child: Text('No hay acciones globales disponibles para el estado actual.', style: TextStyle(color: AppColors.darkTextSecondary))),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            Text('Servicios (${detail.serviciosCount})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            ...detail.detalles.map<Widget>((servicio) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: ListTile(
                leading: Icon(Icons.build, color: AppColors.darkTextTertiary),
                title: Text(servicio.servicioNombre, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${servicio.tiempoEstandarMin} min', style: TextStyle(color: AppColors.darkTextSecondary)),
                trailing: Text(servicio.estado, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary)),
              ),
            )).toList(),
        ],
      ),
    );
  }

  void _confirmReturnVehicle() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Vehículo Devuelto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de marcar el vehículo como devuelto al cliente? Esta acción finaliza el ciclo de atención.', style: TextStyle(color: AppColors.darkTextSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar', style: TextStyle(color: AppColors.darkTextTertiary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VehicleProgressCubit>().markReturned(widget.citaId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.darkTextTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'PROGRAMADA': color = AppColors.warning; break;
      case 'EN_ESPERA_INGRESO': color = AppColors.info; break;
      case 'EN_PROCESO': color = AppColors.primary; break;
      case 'FINALIZADA': color = AppColors.success; break;
      default: color = AppColors.darkTextTertiary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHistoryTab(List history, bool isLoading) {
    return Stack(
      children: [
        if (isLoading && history.isEmpty)
          const Center(child: CircularProgressIndicator(color: AppColors.primary))
        else if (history.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 64, color: AppColors.darkTextTertiary),
                const SizedBox(height: 16),
                Text('No hay registros en el historial', style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 16)),
              ],
            ),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final log = history[index];
              return _buildHistoryItem(log);
            },
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddNoteDialog(),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_comment, color: Colors.white),
            label: const Text('Añadir Nota', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(dynamic log) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
                Expanded(child: Container(width: 2, color: AppColors.primary.withValues(alpha: 0.3))),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        log.estadoNuevo.isNotEmpty ? log.estadoNuevo : 'Actualización',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        dateFormat.format(log.createdAt.toLocal()),
                        style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (log.mensaje.isNotEmpty)
                    Text(log.mensaje, style: TextStyle(color: AppColors.darkTextSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Por: ${log.registradoPorNombre ?? "Sistema"}', style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12, fontStyle: FontStyle.italic)),
                      if (log.porcentajeAvance != null)
                        Text('${log.porcentajeAvance}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog() {
    _noteController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Añadir Nota de Avance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _noteController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ingrese observaciones o actualización general...',
            hintStyle: TextStyle(color: AppColors.darkTextTertiary),
            filled: true,
            fillColor: AppColors.darkSurfaceVariant,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.darkCardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar', style: TextStyle(color: AppColors.darkTextTertiary))),
          ElevatedButton(
            onPressed: () {
              if (_noteController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                context.read<VehicleProgressCubit>().addManualProgressLog(
                  citaId: widget.citaId,
                  message: _noteController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
