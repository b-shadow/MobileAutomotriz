import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';
import 'package:mobile1_app/features/vehicle_plan/presentation/cubit/vehicle_plan_cubit.dart';
import 'package:mobile1_app/features/vehicle_plan/presentation/cubit/vehicle_plan_state.dart';
import 'package:mobile1_app/injection_container.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';

class VehiclePlanPage extends StatefulWidget {
  const VehiclePlanPage({super.key});

  @override
  State<VehiclePlanPage> createState() => _VehiclePlanPageState();
}

class _VehiclePlanPageState extends State<VehiclePlanPage> {
  UsuarioModel? _user;
  List<_ServiceOption> _serviceOptions = const [];
  bool _loadingServiceOptions = false;

  bool get _canManagePlan => _user?.isAdmin == true || _user?.isAsesor == true;

  String get _slug {
    final data = sl<SessionStorage>().userData;
    if (data != null && data['tenant'] is Map<String, dynamic>) {
      final tenant = data['tenant'] as Map<String, dynamic>;
      final slug = tenant['slug'] as String?;
      if (slug != null && slug.isNotEmpty) return slug;
    }
    return EnvConfig.tenantSlug;
  }

  @override
  void initState() {
    super.initState();
    final userData = sl<SessionStorage>().userData;
    if (userData != null) _user = UsuarioModel.fromJson(userData);
    context.read<VehiclePlanCubit>().fetchInitial();
  }

  Future<bool> _ensureServiceOptionsLoaded() async {
    if (_serviceOptions.isNotEmpty || _loadingServiceOptions) {
      return _serviceOptions.isNotEmpty;
    }

    setState(() => _loadingServiceOptions = true);

    try {
      final response = await sl<ApiClient>().get(ApiConstants.servicios(_slug));
      final data = response.data;

      final List<dynamic> rows;
      if (data is Map<String, dynamic> && data['results'] is List) {
        rows = data['results'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        rows = data;
      } else {
        rows = const [];
      }

      final options = rows
          .whereType<Map<String, dynamic>>()
          .where((row) => row['activo'] as bool? ?? true)
          .map(
            (row) => _ServiceOption(
              id: (row['id'] ?? '').toString(),
              codigo: (row['codigo'] ?? row['código'] ?? '').toString(),
              nombre: (row['nombre'] ?? '').toString(),
            ),
          )
          .where((option) => option.id.isNotEmpty)
          .toList();

      if (!mounted) return options.isNotEmpty;
      setState(() {
        _serviceOptions = options;
        _loadingServiceOptions = false;
      });
      return options.isNotEmpty;
    } catch (_) {
      if (!mounted) return false;
      setState(() => _loadingServiceOptions = false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiclePlanCubit, VehiclePlanState>(
      listener: (context, state) {
        if (state is VehiclePlanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(state.message)),
          );
        }
        if (state is VehiclePlanSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.green, content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Gestionar Plan de Vehiculo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () => context.read<VehiclePlanCubit>().fetchInitial(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<VehiclePlanCubit, VehiclePlanState>(
          builder: (context, state) {
            if (state is VehiclePlanInitial || state is VehiclePlanLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final plans = state is VehiclePlanLoaded
                ? state.plans
                : state is VehiclePlanSuccess
                    ? state.plans
                    : state is VehiclePlanError
                        ? state.plans
                        : <VehiclePlan>[];

            final details = state is VehiclePlanLoaded
                ? state.details
                : state is VehiclePlanSuccess
                    ? state.details
                    : state is VehiclePlanError
                        ? state.details
                        : <VehiclePlanDetail>[];

            final selectedPlanId = state is VehiclePlanLoaded
                ? state.selectedPlanId
                : state is VehiclePlanSuccess
                    ? state.selectedPlanId
                    : state is VehiclePlanError
                        ? state.selectedPlanId
                        : null;

            final selectedPlan = plans.where((plan) => plan.id == selectedPlanId).firstOrNull;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Planes de Vehiculo',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (plans.isEmpty)
                  const Text('No hay planes para mostrar.', style: TextStyle(color: Colors.white70))
                else
                  ...plans.map((plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _planCard(context, plan, plan.id == selectedPlanId),
                      )),
                const SizedBox(height: 14),
                if (selectedPlan != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Detalles del Plan - ${selectedPlan.placa}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showCreateDetailDialog(context, selectedPlan.id),
                        icon: const Icon(Icons.add_circle, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (details.isEmpty)
                    const Text('Sin servicios en el plan.', style: TextStyle(color: Colors.white70))
                  else
                    ...details.map(
                      (detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _detailCard(context, selectedPlan.id, detail),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _planCard(BuildContext context, VehiclePlan plan, bool selected) {
    final created = plan.createdAt == null ? 'N/A' : DateFormat('yyyy-MM-dd').format(plan.createdAt!);

    return InkWell(
      onTap: () => context.read<VehiclePlanCubit>().selectPlan(plan.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A3148) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF8B5CF6) : Colors.white12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${plan.placa} - ${plan.marca} ${plan.modelo}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('Estado: ${plan.estado}', style: const TextStyle(color: Colors.white70)),
            Text('Creado: $created', style: const TextStyle(color: Colors.white60)),
            if ((plan.descripcionGeneral ?? '').isNotEmpty)
              Text(plan.descripcionGeneral!, style: const TextStyle(color: Colors.white54)),
            if (_canManagePlan) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showEditPlanDialog(context, plan),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showChangePlanStatusDialog(context, plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.sync, size: 16),
                    label: const Text('Estado'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailCard(BuildContext context, String planId, VehiclePlanDetail detail) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.servicioNombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Prioridad: ${detail.prioridad}', style: const TextStyle(color: Colors.white70)),
          Text('Estado: ${detail.estado}', style: const TextStyle(color: Colors.white70)),
          if ((detail.observaciones ?? '').isNotEmpty)
            Text(detail.observaciones!, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditDetailDialog(context, detail),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar detalle'),
              ),
              if (_canManagePlan)
                ElevatedButton.icon(
                  onPressed: () => _showChangeDetailStatusDialog(context, detail),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Estado detalle'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPlanDialog(BuildContext context, VehiclePlan plan) async {
    final controller = TextEditingController(text: plan.descripcionGeneral ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar plan'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Descripcion general'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<VehiclePlanCubit>().updatePlanDescription(
                    planId: plan.id,
                    descripcion: controller.text.trim(),
                  );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePlanStatusDialog(BuildContext context, VehiclePlan plan) async {
    String status = plan.estado;
    final motivoController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar estado del plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: status,
              items: const [
                DropdownMenuItem(value: 'LIBRE', child: Text('LIBRE')),
                DropdownMenuItem(value: 'EN_EJECUCION', child: Text('EN_EJECUCION')),
                DropdownMenuItem(value: 'CERRADO', child: Text('CERRADO')),
                DropdownMenuItem(value: 'PROGRAMADO', child: Text('PROGRAMADO')),
              ],
              onChanged: (value) {
                if (value != null) status = value;
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(labelText: 'Motivo (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<VehiclePlanCubit>().updatePlanStatus(
                    planId: plan.id,
                    estado: status,
                    motivo: motivoController.text.trim(),
                  );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDetailDialog(BuildContext context, String planId) async {
    final messenger = ScaffoldMessenger.of(context);

    final loaded = await _ensureServiceOptionsLoaded();
    if (!loaded) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('No se pudieron cargar servicios del catalogo.'),
        ),
      );
      return;
    }

    String? selectedServiceId = _serviceOptions.isNotEmpty ? _serviceOptions.first.id : null;
    String prioridad = 'MEDIA';
    final obsController = TextEditingController();

    if (!mounted) return;
    await showDialog<void>(
      context: this.context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Agregar servicio al plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedServiceId,
                items: _serviceOptions
                    .map(
                      (service) => DropdownMenuItem<String>(
                        value: service.id,
                        child: Text(
                          service.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setLocalState(() => selectedServiceId = value);
                },
                decoration: const InputDecoration(labelText: 'Servicio'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: prioridad,
                items: const [
                  DropdownMenuItem(value: 'BAJA', child: Text('BAJA')),
                  DropdownMenuItem(value: 'MEDIA', child: Text('MEDIA')),
                  DropdownMenuItem(value: 'ALTA', child: Text('ALTA')),
                  DropdownMenuItem(value: 'URGENTE', child: Text('URGENTE')),
                ],
                onChanged: (value) {
                  if (value != null) setLocalState(() => prioridad = value);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: obsController,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if ((selectedServiceId ?? '').isEmpty) return;
                Navigator.of(dialogContext).pop();
                context.read<VehiclePlanCubit>().createDetail(
                      planId: planId,
                      data: {
                        'servicio_catalogo_id': selectedServiceId,
                        'prioridad': prioridad,
                        'observaciones': obsController.text.trim(),
                      },
                    );
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDetailDialog(BuildContext context, VehiclePlanDetail detail) async {
    String prioridad = detail.prioridad;
    final obsController = TextEditingController(text: detail.observaciones ?? '');
    final tiempoController = TextEditingController(text: detail.tiempoEstandarMin?.toString() ?? '');
    final precioController = TextEditingController(text: detail.precioReferencial?.toStringAsFixed(2) ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar detalle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: prioridad,
              items: const [
                DropdownMenuItem(value: 'BAJA', child: Text('BAJA')),
                DropdownMenuItem(value: 'MEDIA', child: Text('MEDIA')),
                DropdownMenuItem(value: 'ALTA', child: Text('ALTA')),
                DropdownMenuItem(value: 'URGENTE', child: Text('URGENTE')),
              ],
              onChanged: (value) {
                if (value != null) prioridad = value;
              },
            ),
            TextField(controller: obsController, decoration: const InputDecoration(labelText: 'Observaciones')),
            TextField(controller: tiempoController, decoration: const InputDecoration(labelText: 'Tiempo estandar min')),
            TextField(controller: precioController, decoration: const InputDecoration(labelText: 'Precio referencial')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<VehiclePlanCubit>().updateDetail(
                    detailId: detail.id,
                    data: {
                      'prioridad': prioridad,
                      'observaciones': obsController.text.trim(),
                      if (int.tryParse(tiempoController.text.trim()) != null)
                        'tiempo_estandar_min': int.parse(tiempoController.text.trim()),
                      if (double.tryParse(precioController.text.trim()) != null)
                        'precio_referencial': double.parse(precioController.text.trim()),
                    },
                  );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangeDetailStatusDialog(BuildContext context, VehiclePlanDetail detail) async {
    String status = detail.estado;
    final motivoController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar estado del detalle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: status,
              items: const [
                DropdownMenuItem(value: 'PENDIENTE', child: Text('PENDIENTE')),
                DropdownMenuItem(value: 'PROGRAMADO', child: Text('PROGRAMADO')),
                DropdownMenuItem(value: 'EN_PROCESO', child: Text('EN_PROCESO')),
                DropdownMenuItem(value: 'FINALIZADO', child: Text('FINALIZADO')),
                DropdownMenuItem(value: 'INNECESARIO', child: Text('INNECESARIO')),
                DropdownMenuItem(value: 'DIFERIDO', child: Text('DIFERIDO')),
              ],
              onChanged: (value) {
                if (value != null) status = value;
              },
            ),
            const SizedBox(height: 10),
            TextField(controller: motivoController, decoration: const InputDecoration(labelText: 'Motivo (opcional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<VehiclePlanCubit>().updateDetailStatus(
                    detailId: detail.id,
                    estado: status,
                    motivo: motivoController.text.trim(),
                  );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _ServiceOption {
  final String id;
  final String codigo;
  final String nombre;

  const _ServiceOption({required this.id, required this.codigo, required this.nombre});

  String get label {
    final code = codigo.trim();
    final name = nombre.trim();
    if (code.isEmpty) return name;
    if (name.isEmpty) return code;
    return '$code - $name';
  }
}






