import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Avance General', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
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
              backgroundColor: const Color(0xFFEF4444),
              content: Text(state.message),
            ));
          }
          if (state is VehicleProgressSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFF10B981),
              content: Text(state.message),
            ));
          }
        },
        builder: (context, state) {
          if (state is VehicleProgressInitial || (state is VehicleProgressLoading && _getDetailFromState(state) == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = _getDetailFromState(state);
          final history = _getHistoryFromState(state);

          if (detail == null) {
            return const Center(child: Text('No se pudo cargar el detalle'));
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
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        detail.vehiculoPlaca,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      _buildStatusBadge(detail.estado),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${detail.vehiculoMarca} ${detail.vehiculoModelo}', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                  const Divider(height: 24),
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
          ),
          const SizedBox(height: 24),
          const Text('Acciones Globales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (detail.accionesFlags['puede_registrar_llegada'] == true)
                  _buildActionButton(
                    'Registrar Llegada al Taller',
                    Icons.login,
                    Colors.blue,
                    () => context.read<VehicleProgressCubit>().registerArrival(widget.citaId),
                  ),
                if (detail.accionesFlags['puede_marcar_en_proceso'] == true)
                  _buildActionButton(
                    'Marcar en Proceso (Inicio Trabajos)',
                    Icons.build_circle,
                    Colors.purple,
                    () => context.read<VehicleProgressCubit>().markInProcess(widget.citaId),
                  ),
                if (detail.accionesFlags['puede_marcar_vehiculo_devuelto'] == true)
                  _buildActionButton(
                    'Marcar Vehículo Devuelto',
                    Icons.check_circle,
                    Colors.green,
                    () => _confirmReturnVehicle(),
                  ),
                if (detail.accionesFlags.values.every((element) => element == false))
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 12),
                        Expanded(child: Text('No hay acciones globales disponibles para el estado actual.', style: TextStyle(color: Colors.grey))),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            Text('Servicios (${detail.serviciosCount})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...detail.detalles.map<Widget>((servicio) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.build, color: Colors.grey),
                title: Text(servicio.servicioNombre),
                subtitle: Text('${servicio.tiempoEstandarMin} min'),
                trailing: Text(servicio.estado, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
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
        title: const Text('Vehículo Devuelto'),
        content: const Text('¿Estás seguro de marcar el vehículo como devuelto al cliente? Esta acción finaliza el ciclo de atención.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VehicleProgressCubit>().markReturned(widget.citaId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'PROGRAMADA': color = Colors.orange; break;
      case 'EN_ESPERA_INGRESO': color = Colors.blue; break;
      case 'EN_PROCESO': color = Colors.purple; break;
      case 'FINALIZADA': color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
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
          const Center(child: CircularProgressIndicator())
        else if (history.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No hay registros en el historial', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
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
            backgroundColor: const Color(0xFF3B82F6),
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
                  decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
                ),
                Expanded(child: Container(width: 2, color: Colors.blue.withValues(alpha: 0.3))),
              ],
            ),
          ),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.estadoNuevo.isNotEmpty ? log.estadoNuevo : 'Actualización',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dateFormat.format(log.createdAt.toLocal()),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (log.mensaje.isNotEmpty)
                      Text(log.mensaje, style: TextStyle(color: Colors.grey[800])),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Por: ${log.registradoPorNombre ?? "Sistema"}', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic)),
                        if (log.porcentajeAvance != null)
                          Text('${log.porcentajeAvance}%', style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
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
        title: const Text('Añadir Nota de Avance'),
        content: TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ingrese observaciones o actualización general...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
