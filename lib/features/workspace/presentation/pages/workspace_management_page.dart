import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_schedule.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_space.dart';
import 'package:mobile1_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:mobile1_app/features/workspace/presentation/cubit/workspace_state.dart';
import 'package:mobile1_app/injection_container.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';

class WorkspaceManagementPage extends StatefulWidget {
  const WorkspaceManagementPage({super.key});

  @override
  State<WorkspaceManagementPage> createState() => _WorkspaceManagementPageState();
}

class _WorkspaceManagementPageState extends State<WorkspaceManagementPage> {
  UsuarioModel? _user;

  bool get _canManage => _user?.isAdmin == true || _user?.isAsesor == true;

  @override
  void initState() {
    super.initState();
    final userData = sl<SessionStorage>().userData;
    if (userData != null) {
      _user = UsuarioModel.fromJson(userData);
    }
    context.read<WorkspaceCubit>().fetchSpaces();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceCubit, WorkspaceState>(
      listener: (context, state) {
        if (state is WorkspaceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.message),
            ),
          );
        }

        if (state is WorkspaceOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Configurar Espacios de Trabajo',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () => context.read<WorkspaceCubit>().fetchSpaces(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar',
            ),
          ],
        ),
        bottomNavigationBar: _canManage
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateSpaceSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_business),
                      label: const Text('Agregar espacio'),
                    ),
                  ),
                ),
              )
            : null,
        body: BlocBuilder<WorkspaceCubit, WorkspaceState>(
          builder: (context, state) {
            final cubit = context.read<WorkspaceCubit>();

            if ((state is WorkspaceInitial || state is WorkspaceLoading) &&
                cubit.currentSpaces.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            List<WorkspaceSpace> spaces = cubit.currentSpaces;
            List<WorkspaceSchedule> schedules = cubit.currentSchedules;
            String? selectedSpaceId = cubit.currentSelectedSpaceId;

            if (state is WorkspaceLoaded) {
              spaces = state.spaces;
              schedules = state.schedules;
              selectedSpaceId = state.selectedSpaceId;
            } else if (state is WorkspaceOperationSuccess) {
              spaces = state.spaces;
              schedules = state.schedules;
              selectedSpaceId = state.selectedSpaceId;
            }

            if (spaces.isEmpty) {
              return const Center(
                child: Text(
                  'No hay espacios registrados.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final selectedSpace = spaces.where((space) => space.id == selectedSpaceId).firstOrNull;

            return RefreshIndicator(
              onRefresh: () => context.read<WorkspaceCubit>().fetchSpaces(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  _canManage ? 120 : 24,
                ),
                children: [
                  const Text(
                    'Espacios del Taller',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...spaces.map(
                    (space) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildSpaceCard(context, space, space.id == selectedSpaceId),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (selectedSpace != null) ...[
                    _buildSchedulesHeader(context, selectedSpace),
                    const SizedBox(height: 10),
                    if (schedules.isEmpty)
                      const Text(
                        'No hay horarios para este espacio.',
                        style: TextStyle(color: Colors.white60),
                      )
                    else
                      ...schedules.map(
                        (schedule) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildScheduleCard(context, selectedSpace, schedule),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpaceCard(
    BuildContext context,
    WorkspaceSpace space,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => context.read<WorkspaceCubit>().selectSpace(space.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A3148) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.white12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        space.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Codigo: ${space.codigo}  |  Tipo: ${space.tipo}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: space.activo
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    space.activo ? 'ACTIVO' : 'INACTIVO',
                    style: TextStyle(
                      color: space.activo ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estado: ${space.estado}',
              style: const TextStyle(color: Colors.white60),
            ),
            if ((space.observaciones ?? '').isNotEmpty)
              Text(
                space.observaciones!,
                style: const TextStyle(color: Colors.white54),
              ),
            if (_canManage) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () => _showToggleSpaceDialog(context, space),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        space.activo ? Colors.orange.shade700 : Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(space.activo ? Icons.pause : Icons.check, size: 16),
                  label: Text(space.activo ? 'Desactivar' : 'Activar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesHeader(BuildContext context, WorkspaceSpace selectedSpace) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Horarios - ${selectedSpace.nombre}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_canManage)
          IconButton(
            onPressed: () => _showScheduleSheet(context, spaceId: selectedSpace.id),
            icon: const Icon(Icons.add_circle, color: Colors.white),
            tooltip: 'Agregar horario',
          ),
      ],
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    WorkspaceSpace selectedSpace,
    WorkspaceSchedule schedule,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dayName(schedule.diaSemana),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_shortTime(schedule.horaInicio)} - ${_shortTime(schedule.horaFin)}',
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: schedule.activo
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              schedule.activo ? 'ACTIVO' : 'INACTIVO',
              style: TextStyle(
                color: schedule.activo ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          if (_canManage) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => _showScheduleSheet(
                context,
                spaceId: selectedSpace.id,
                schedule: schedule,
              ),
              icon: const Icon(Icons.edit, color: Colors.white70),
              tooltip: 'Editar horario',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCreateSpaceSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CreateSpaceSheet(
        onSubmit: (payload) async {
          Navigator.of(sheetContext).pop();
          await context.read<WorkspaceCubit>().createSpace(payload);
        },
      ),
    );
  }

  Future<void> _showToggleSpaceDialog(
    BuildContext context,
    WorkspaceSpace space,
  ) async {
    final motivoController = TextEditingController();
    final targetStatus = !space.activo;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(targetStatus ? 'Activar espacio' : 'Desactivar espacio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(space.nombre),
            const SizedBox(height: 10),
            TextField(
              controller: motivoController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<WorkspaceCubit>().updateSpaceActive(
                    spaceId: space.id,
                    activo: targetStatus,
                    motivo: motivoController.text.trim(),
                  );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showScheduleSheet(
    BuildContext context, {
    required String spaceId,
    WorkspaceSchedule? schedule,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ScheduleFormSheet(
        schedule: schedule,
        onSubmit: (payload) async {
          Navigator.of(sheetContext).pop();
          if (schedule == null) {
            await context.read<WorkspaceCubit>().createSchedule(
                  spaceId: spaceId,
                  data: payload,
                );
          } else {
            await context.read<WorkspaceCubit>().updateSchedule(
                  spaceId: spaceId,
                  scheduleId: schedule.id,
                  data: payload,
                );
          }
        },
      ),
    );
  }

  String _dayName(int day) {
    return switch (day) {
      0 => 'Lunes',
      1 => 'Martes',
      2 => 'Miercoles',
      3 => 'Jueves',
      4 => 'Viernes',
      5 => 'Sabado',
      6 => 'Domingo',
      _ => 'Dia $day',
    };
  }

  String _shortTime(String value) {
    final split = value.split(':');
    if (split.length >= 2) return '${split[0]}:${split[1]}';
    return value;
  }
}

class _CreateSpaceSheet extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> payload) onSubmit;

  const _CreateSpaceSheet({required this.onSubmit});

  @override
  State<_CreateSpaceSheet> createState() => _CreateSpaceSheetState();
}

class _CreateSpaceSheetState extends State<_CreateSpaceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _obsController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _tipoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'codigo': _codigoController.text.trim(),
      'nombre': _nombreController.text.trim(),
      'tipo': _tipoController.text.trim(),
      'observaciones': _obsController.text.trim(),
    };

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(payload);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'Agregar espacio',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _styledField(
              controller: _codigoController,
              label: 'Codigo',
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Codigo obligatorio'
                  : null,
            ),
            const SizedBox(height: 12),
            _styledField(
              controller: _nombreController,
              label: 'Nombre',
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Nombre obligatorio'
                  : null,
            ),
            const SizedBox(height: 12),
            _styledField(
              controller: _tipoController,
              label: 'Tipo',
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Tipo obligatorio'
                  : null,
            ),
            const SizedBox(height: 12),
            _styledField(
              controller: _obsController,
              label: 'Observaciones',
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
      ),
      submitting: _submitting,
      onSubmit: _submit,
    );
  }
}

class _ScheduleFormSheet extends StatefulWidget {
  final WorkspaceSchedule? schedule;
  final Future<void> Function(Map<String, dynamic> payload) onSubmit;

  const _ScheduleFormSheet({required this.schedule, required this.onSubmit});

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _horaInicioController = TextEditingController();
  final _horaFinController = TextEditingController();
  int _diaSemana = 0;
  bool _activo = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    if (schedule != null) {
      _diaSemana = schedule.diaSemana;
      _horaInicioController.text = _asShort(schedule.horaInicio);
      _horaFinController.text = _asShort(schedule.horaFin);
      _activo = schedule.activo;
    }
  }

  @override
  void dispose() {
    _horaInicioController.dispose();
    _horaFinController.dispose();
    super.dispose();
  }

  String _asShort(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    return '${parts[0]}:${parts[1]}';
  }

  String _asApiTime(String value) {
    final trimmed = value.trim();
    final parts = trimmed.split(':');
    if (parts.length == 2) return '$trimmed:00';
    return trimmed;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'dia_semana': _diaSemana,
      'hora_inicio': _asApiTime(_horaInicioController.text),
      'hora_fin': _asApiTime(_horaFinController.text),
    };

    if (widget.schedule != null) {
      payload['activo'] = _activo;
    }

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(payload);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;

    return _BaseSheet(
      title: isEditing ? 'Editar horario' : 'Agregar horario',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<int>(
              initialValue: _diaSemana,
              dropdownColor: const Color(0xFF1E293B),
              decoration: _inputDecoration('Dia de la semana'),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Lunes')),
                DropdownMenuItem(value: 1, child: Text('Martes')),
                DropdownMenuItem(value: 2, child: Text('Miercoles')),
                DropdownMenuItem(value: 3, child: Text('Jueves')),
                DropdownMenuItem(value: 4, child: Text('Viernes')),
                DropdownMenuItem(value: 5, child: Text('Sabado')),
                DropdownMenuItem(value: 6, child: Text('Domingo')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _diaSemana = value);
                }
              },
            ),
            const SizedBox(height: 12),
            _styledField(
              controller: _horaInicioController,
              label: 'Hora inicio (HH:MM)',
              validator: _validateHour,
            ),
            const SizedBox(height: 12),
            _styledField(
              controller: _horaFinController,
              label: 'Hora fin (HH:MM)',
              validator: _validateHour,
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                value: _activo,
                onChanged: (value) => setState(() => _activo = value),
                title: const Text('Activo', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
      submitting: _submitting,
      onSubmit: _submit,
    );
  }

  String? _validateHour(String? value) {
    final raw = (value ?? '').trim();
    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)(:[0-5]\d)?$');
    if (!regex.hasMatch(raw)) {
      return 'Formato invalido. Usa HH:MM';
    }
    return null;
  }
}

class _BaseSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final bool submitting;
  final VoidCallback onSubmit;

  const _BaseSheet({
    required this.title,
    required this.child,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: child),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: submitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: submitting ? null : onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFF26264A),
    labelStyle: const TextStyle(color: Colors.white70),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.white12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}

Widget _styledField({
  required TextEditingController controller,
  required String label,
  String? Function(String?)? validator,
  int minLines = 1,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(color: Colors.white),
    minLines: minLines,
    maxLines: maxLines,
    decoration: _inputDecoration(label),
    validator: validator,
  );
}

