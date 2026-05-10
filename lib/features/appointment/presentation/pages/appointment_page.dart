import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/presentation/cubit/appointment_cubit.dart';
import 'package:mobile1_app/features/appointment/presentation/cubit/appointment_state.dart';
import 'package:mobile1_app/features/appointment/presentation/pages/appointment_form_page.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';
import 'package:mobile1_app/injection_container.dart';

// ─── Estados disponibles para filtrar ────────────────────────────────────────
const _kEstados = [
  (null, 'Todos'),
  ('PROGRAMADA', 'Programada'),
  ('PENDIENTE_APROBACION', 'Pendiente'),
  ('EN_ESPERA_INGRESO', 'En espera'),
  ('EN_PROCESO', 'En proceso'),
  ('FINALIZADA', 'Finalizada'),
  ('CANCELADA', 'Cancelada'),
  ('REPROGRAMADA', 'Reprogramada'),
];

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  UsuarioModel? _user;

  bool get _canManage =>
      _user?.isAdmin == true || _user?.isAsesor == true || _user?.isUsuario == true;

  @override
  void initState() {
    super.initState();
    final userData = sl<SessionStorage>().userData;
    if (userData != null) _user = UsuarioModel.fromJson(userData);
    context.read<AppointmentCubit>().fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentCubit, AppointmentState>(
      listener: (ctx, state) {
        if (state is AppointmentError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text(state.message),
          ));
        }
        if (state is AppointmentSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(state.message),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Gestión de Citas',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () =>
                  context.read<AppointmentCubit>().fetchAppointments(),
              icon: const Icon(Icons.refresh, color: Colors.white70),
            ),
          ],
        ),
        floatingActionButton: _canManage
            ? FloatingActionButton.extended(
                onPressed: () => _openCreateForm(context),
                backgroundColor: const Color(0xFF8B5CF6),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nueva Cita',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            : null,
        body: Column(
          children: [
            // ── Filtro de estado ─────────────────────────────────────────
            _EstadoFilterBar(),
            // ── Lista de citas ───────────────────────────────────────────
            Expanded(
              child: BlocBuilder<AppointmentCubit, AppointmentState>(
                builder: (ctx, state) {
                  if (state is AppointmentInitial || state is AppointmentLoading) {
                    return const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF8B5CF6)));
                  }

                  final appointments = state.appointments;

                  if (appointments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          const Text('No hay citas para mostrar',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 16)),
                          if (_canManage) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => _openCreateForm(context),
                              child: const Text('Crear primera cita',
                                  style:
                                      TextStyle(color: Color(0xFF8B5CF6))),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF8B5CF6),
                    onRefresh: () =>
                        context.read<AppointmentCubit>().fetchAppointments(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: appointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) => _AppointmentCard(
                        appointment: appointments[i],
                        canManage: _canManage,
                        onCancel:
                            _canManage && ['PROGRAMADA', 'EN_ESPERA_INGRESO']
                                    .contains(appointments[i].estado)
                                ? () => _confirmCancel(context, appointments[i])
                                : null,
                        onReschedule:
                            _canManage && ['PROGRAMADA', 'EN_ESPERA_INGRESO']
                                    .contains(appointments[i].estado)
                                ? () =>
                                    _openRescheduleDialog(context, appointments[i])
                                : null,
                        onNoShow:
                            (_user?.isAdmin == true || _user?.isAsesor == true) &&
                                    ['PROGRAMADA', 'EN_ESPERA_INGRESO']
                                        .contains(appointments[i].estado)
                                ? () => _confirmNoShow(context, appointments[i])
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateForm(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AppointmentCubit>(),
        child: const AppointmentFormSheet(),
      ),
    );
  }

  Future<void> _confirmNoShow(BuildContext context, Appointment cita) async {
    final obsCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlg) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(Icons.person_off_outlined,
                color: Color(0xFF64748B), size: 22),
            const SizedBox(width: 10),
            const Text('Marcar Inasistencia',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${cita.vehiculoPlaca} — ${cita.vehiculoMarca} ${cita.vehiculoModelo}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF64748B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Solo disponible si ya pasó el tiempo de tolerancia (15 min)',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
            const SizedBox(height: 14),
            _DarkTextField(
              controller: obsCtrl,
              label: 'Observaciones (opcional)',
              minLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64748B)),
            icon: const Icon(Icons.person_off_outlined,
                size: 16, color: Colors.white),
            onPressed: () => Navigator.of(dlg).pop(true),
            label: const Text('Confirmar No-Show',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppointmentCubit>().markNoShow(
            id: cita.id,
            observacion: obsCtrl.text.trim().isEmpty ? null : obsCtrl.text.trim(),
          );
    }
  }

  Future<void> _confirmCancel(BuildContext context, Appointment cita) async {
    final motivoCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlg) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Cancelar Cita',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${cita.vehiculoPlaca} — ${cita.vehiculoMarca} ${cita.vehiculoModelo}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            _DarkTextField(controller: motivoCtrl, label: 'Motivo (obligatorio)', minLines: 2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(false),
            child: const Text('Volver', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(dlg).pop(true),
            child: const Text('Cancelar Cita',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppointmentCubit>().cancelAppointment(
            id: cita.id,
            motivo: motivoCtrl.text.trim(),
          );
    }
  }

  Future<void> _openRescheduleDialog(
      BuildContext context, Appointment cita) async {
    DateTime fechaInicio =
        cita.fechaHoraInicio.toLocal().add(const Duration(days: 1));
    TimeOfDay horaInicio = TimeOfDay.fromDateTime(fechaInicio);
    final motivoCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dlg) => StatefulBuilder(
        builder: (dlgCtx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Reprogramar Cita',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cita.vehiculoPlaca} — ${cita.vehiculoMarca} ${cita.vehiculoModelo}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                // Fecha
                const Text('Nueva fecha:',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dlgCtx,
                      initialDate: fechaInicio,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (c, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF8B5CF6),
                            surface: Color(0xFF1E293B),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setDlgState(() {
                        fechaInicio = DateTime(picked.year, picked.month,
                            picked.day, horaInicio.hour, horaInicio.minute);
                      });
                    }
                  },
                  child: _PickerRow(
                    icon: Icons.calendar_today,
                    label:
                        '${fechaInicio.day.toString().padLeft(2, '0')}/${fechaInicio.month.toString().padLeft(2, '0')}/${fechaInicio.year}',
                  ),
                ),
                const SizedBox(height: 10),
                // Hora
                const Text('Nueva hora:',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: dlgCtx,
                      initialTime: horaInicio,
                      builder: (c, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF8B5CF6),
                            surface: Color(0xFF1E293B),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setDlgState(() {
                        horaInicio = picked;
                        fechaInicio = DateTime(
                            fechaInicio.year,
                            fechaInicio.month,
                            fechaInicio.day,
                            picked.hour,
                            picked.minute);
                      });
                    }
                  },
                  child: _PickerRow(
                    icon: Icons.access_time,
                    label:
                        '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(height: 12),
                _DarkTextField(
                    controller: motivoCtrl,
                    label: 'Motivo de reprogramación',
                    minLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlg).pop(),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6)),
              onPressed: () {
                Navigator.of(dlg).pop();
                final duracion = cita.duracionEstimadaMin;
                final fechaFin =
                    fechaInicio.add(Duration(minutes: duracion > 0 ? duracion : 60));
                context.read<AppointmentCubit>().rescheduleAppointment(
                      id: cita.id,
                      fechaHoraInicio: fechaInicio.toUtc(),
                      fechaHoraFin: fechaFin.toUtc(),
                      motivo: motivoCtrl.text.trim(),
                    );
              },
              child: const Text('Reprogramar',
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Bar ───────────────────────────────────────────────────────────────

class _EstadoFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (ctx, state) {
        final filtroActual = state is AppointmentLoaded
            ? state.estadoFiltro
            : state is AppointmentSuccess
                ? state.estadoFiltro
                : null;

        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _kEstados.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final (valor, label) = _kEstados[i];
              final selected = filtroActual == valor;
              return GestureDetector(
                onTap: () =>
                    ctx.read<AppointmentCubit>().filtrarPorEstado(valor),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF8B5CF6)
                          : Colors.white12,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Appointment Card ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool canManage;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onNoShow;

  const _AppointmentCard({
    required this.appointment,
    required this.canManage,
    this.onCancel,
    this.onReschedule,
    this.onNoShow,
  });

  @override
  Widget build(BuildContext context) {
    final estado = appointment.estado;
    final (color, _) = _estadoColor(estado);
    final fmt = DateFormat('dd/MM/yyyy  HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${appointment.vehiculoPlaca}  ·  ${appointment.vehiculoMarca} ${appointment.vehiculoModelo}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
                _StatusChip(estado: estado),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Inicio',
                    value: fmt.format(appointment.fechaHoraInicio.toLocal())),
                const SizedBox(height: 6),
                _InfoRow(
                    icon: Icons.timer_outlined,
                    label: 'Duración est.',
                    value: '${appointment.duracionEstimadaMin} min'),
                if ((appointment.motivoVisita ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                      icon: Icons.notes,
                      label: 'Motivo',
                      value: appointment.motivoVisita!),
                ],
                if ((appointment.clienteNombre ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Cliente',
                      value: appointment.clienteNombre!),
                ],
                if (appointment.reprogramacionesCount > 0) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                      icon: Icons.history,
                      label: 'Reprogramaciones',
                      value: '${appointment.reprogramacionesCount}'),
                ],
                // Servicios
                if (appointment.detalles.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 6),
                  Text('Servicios (${appointment.detalles.length})',
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: appointment.detalles
                        .map((d) => _ServiceBadge(
                            label: d.servicioNombre ??
                                d.servicioCodigo ??
                                'Servicio'))
                        .toList(),
                  ),
                ],
                // Acciones
                if (onCancel != null || onReschedule != null || onNoShow != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: [
                      if (onNoShow != null)
                        OutlinedButton.icon(
                          onPressed: onNoShow,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF94A3B8),
                            side: const BorderSide(
                                color: Color(0xFF94A3B8), width: 1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                          ),
                          icon: const Icon(Icons.person_off_outlined, size: 14),
                          label: const Text('No-Show',
                              style: TextStyle(fontSize: 11)),
                        ),
                      if (onReschedule != null)
                        OutlinedButton.icon(
                          onPressed: onReschedule,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6366F1),
                            side: const BorderSide(
                                color: Color(0xFF6366F1), width: 1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                          ),
                          icon: const Icon(Icons.event_repeat, size: 14),
                          label: const Text('Reprogramar',
                              style: TextStyle(fontSize: 11)),
                        ),
                      if (onCancel != null)
                        OutlinedButton.icon(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(
                                color: Color(0xFFEF4444), width: 1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                          ),
                          icon: const Icon(Icons.cancel_outlined, size: 14),
                          label: const Text('Cancelar',
                              style: TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _estadoColor(String estado) => switch (estado) {
        'PROGRAMADA' => (const Color(0xFF3B82F6), 'Programada'),
        'PENDIENTE_APROBACION' => (const Color(0xFFF59E0B), 'Pendiente'),
        'EN_ESPERA_INGRESO' => (const Color(0xFFA78BFA), 'En espera'),
        'EN_PROCESO' => (const Color(0xFFF97316), 'En proceso'),
        'FINALIZADA' => (const Color(0xFF10B981), 'Finalizada'),
        'CANCELADA' => (const Color(0xFFEF4444), 'Cancelada'),
        'REPROGRAMADA' => (const Color(0xFF6366F1), 'Reprogramada'),
        'NO_SHOW' => (const Color(0xFF64748B), 'No se presentó'),
        _ => (const Color(0xFF64748B), estado),
      };
}

// ─── Small helpers ────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String estado;
  const _StatusChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _color(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  (Color, String) _color(String e) => switch (e) {
        'PROGRAMADA' => (const Color(0xFF3B82F6), 'Programada'),
        'PENDIENTE_APROBACION' => (const Color(0xFFF59E0B), 'Pendiente'),
        'EN_ESPERA_INGRESO' => (const Color(0xFFA78BFA), 'En espera'),
        'EN_PROCESO' => (const Color(0xFFF97316), 'En proceso'),
        'FINALIZADA' => (const Color(0xFF10B981), 'Finalizada'),
        'CANCELADA' => (const Color(0xFFEF4444), 'Cancelada'),
        'REPROGRAMADA' => (const Color(0xFF6366F1), 'Reprogramada'),
        'NO_SHOW' => (const Color(0xFF64748B), 'No se presentó'),
        _ => (const Color(0xFF64748B), e),
      };
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
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white70, fontSize: 13))),
      ],
    );
  }
}

class _ServiceBadge extends StatelessWidget {
  final String label;
  const _ServiceBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int minLines;

  const _DarkTextField(
      {required this.controller, required this.label, this.minLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      minLines: minLines,
      maxLines: minLines + 2,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PickerRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
