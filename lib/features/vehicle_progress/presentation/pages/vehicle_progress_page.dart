import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/vehicle_progress_cubit.dart';

class VehicleProgressPage extends StatefulWidget {
  const VehicleProgressPage({super.key});

  @override
  State<VehicleProgressPage> createState() => _VehicleProgressPageState();
}

class _VehicleProgressPageState extends State<VehicleProgressPage> {
  @override
  void initState() {
    super.initState();
    context.read<VehicleProgressCubit>().fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Avance del Vehículo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<VehicleProgressCubit, VehicleProgressState>(
        listener: (context, state) {
          if (state is VehicleProgressError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFFEF4444),
              content: Text(state.message),
            ));
          }
        },
        builder: (context, state) {
          if (state is VehicleProgressInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = _getAppointmentsFromState(state);
          final isLoading = state is VehicleProgressLoading;

          if (isLoading && appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No hay vehículos en atención', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<VehicleProgressCubit>().fetchAppointments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => context.push('/vehicle-progress-detail/${appointment.id}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appointment.vehiculoPlaca,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              _buildStatusBadge(appointment.estado),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  appointment.clienteNombres,
                                  style: TextStyle(color: Colors.grey[700]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (appointment.asesorNombres != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.support_agent, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Asesor: ${appointment.asesorNombres}',
                                    style: TextStyle(color: Colors.grey[700]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${appointment.serviciosCount} servicios',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List _getAppointmentsFromState(VehicleProgressState state) {
    if (state is VehicleProgressLoaded) return state.appointments;
    if (state is VehicleProgressLoading) return state.appointments;
    if (state is VehicleProgressDetailLoaded) return state.appointments;
    if (state is VehicleProgressError) return state.appointments;
    if (state is VehicleProgressSuccess) return state.appointments;
    return [];
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'PROGRAMADA':
        color = Colors.orange;
        break;
      case 'EN_ESPERA_INGRESO':
        color = Colors.blue;
        break;
      case 'EN_PROCESO':
        color = Colors.purple;
        break;
      case 'FINALIZADA':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
