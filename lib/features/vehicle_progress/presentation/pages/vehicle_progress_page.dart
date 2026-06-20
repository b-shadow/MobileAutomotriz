import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
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
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Avance del Vehículo'),
      ),
      body: BlocConsumer<VehicleProgressCubit, VehicleProgressState>(
        listener: (context, state) {
          if (state is VehicleProgressError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: AppColors.error,
              content: Text(state.message),
            ));
          }
        },
        builder: (context, state) {
          if (state is VehicleProgressInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final appointments = _getAppointmentsFromState(state);
          final isLoading = state is VehicleProgressLoading;

          if (isLoading && appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined, size: 64, color: AppColors.darkTextTertiary),
                  SizedBox(height: 16),
                  Text('No hay vehículos en atención', style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<VehicleProgressCubit>().fetchAppointments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.darkCardBorder),
                  ),
                  child: InkWell(
                    onTap: () => context.push('/vehicle-progress-detail/${appointment.id}'),
                    borderRadius: BorderRadius.circular(14),
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                              ),
                              _buildStatusBadge(appointment.estado),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: AppColors.darkTextTertiary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  appointment.clienteNombres,
                                  style: const TextStyle(color: AppColors.darkTextSecondary),
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
                                const Icon(Icons.support_agent, size: 16, color: AppColors.darkTextTertiary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Asesor: ${appointment.asesorNombres}',
                                    style: const TextStyle(color: AppColors.darkTextSecondary),
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
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.darkTextTertiary),
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
        color = AppColors.warning;
        break;
      case 'EN_ESPERA_INGRESO':
        color = AppColors.info;
        break;
      case 'EN_PROCESO':
        color = AppColors.primary;
        break;
      case 'FINALIZADA':
        color = AppColors.success;
        break;
      default:
        color = AppColors.darkTextTertiary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
