import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';
import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';
import 'package:mobile1_app/features/vehicle/presentation/cubit/vehicle_cubit.dart';
import 'package:mobile1_app/features/vehicle/presentation/cubit/vehicle_state.dart';
import 'package:mobile1_app/injection_container.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  UsuarioModel? _currentUser;
  bool get _canAssignOwner =>
      _currentUser?.isAdmin == true || _currentUser?.isAsesor == true;

  bool _loadingOwners = false;
  bool _ownersLoaded = false;
  List<_OwnerOption> _ownerOptions = const [];

  @override
  void initState() {
    super.initState();
    final userData = sl<SessionStorage>().userData;
    if (userData != null) {
      _currentUser = UsuarioModel.fromJson(userData);
    }
    if (_canAssignOwner) {
      unawaited(_ensureOwnerOptionsLoaded());
    }
    context.read<VehicleCubit>().fetchVehicles();
  }

  String get _tenantSlug {
    final userData = sl<SessionStorage>().userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      final slug = tenant['slug'] as String?;
      if (slug != null && slug.isNotEmpty) return slug;
    }
    return EnvConfig.tenantSlug;
  }

  Future<bool> _ensureOwnerOptionsLoaded() async {
    if (_ownersLoaded || _loadingOwners) return _ownersLoaded;

    setState(() {
      _loadingOwners = true;
    });

    try {
      final response = await sl<ApiClient>().get(ApiConstants.usuarios(_tenantSlug));
      final data = response.data;

      final List<dynamic> rawUsers;
      if (data is Map<String, dynamic> && data['results'] is List) {
        rawUsers = data['results'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        rawUsers = data;
      } else {
        rawUsers = const [];
      }

      final owners = rawUsers
          .whereType<Map<String, dynamic>>()
          .map(_mapOwnerOption)
          .whereType<_OwnerOption>()
          .toList();

      if (!mounted) return true;

      setState(() {
        _ownerOptions = owners;
        _ownersLoaded = true;
        _loadingOwners = false;
      });
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _loadingOwners = false;
      });
      return false;
    }
  }

  _OwnerOption? _mapOwnerOption(Map<String, dynamic> json) {
    final role = _extractRoleName(json);
    final normalizedRole = role.toUpperCase();
    final allowAsOwner = normalizedRole.isEmpty ||
        normalizedRole.contains('USUARIO') ||
        normalizedRole.contains('CLIENTE');

    if (!allowAsOwner) return null;

    final id = (json['id'] ?? json['uuid'] ?? '').toString();
    if (id.isEmpty) return null;

    final nombres = (json['nombres'] ?? '').toString().trim();
    final apellidos = (json['apellidos'] ?? '').toString().trim();
    final email = (json['email'] ?? '').toString().trim();
    final label = [nombres, apellidos].where((part) => part.isNotEmpty).join(' ').trim();

    return _OwnerOption(
      id: id,
      label: label.isNotEmpty ? label : email.isNotEmpty ? email : id,
      subtitle: email.isNotEmpty ? email : null,
    );
  }

  String _extractRoleName(Map<String, dynamic> json) {
    final role = json['rol'];
    if (role is Map<String, dynamic>) {
      return (role['nombre'] ?? '').toString();
    }
    return (role ?? json['rol_nombre'] ?? json['rolNombre'] ?? '').toString();
  }

  Future<void> _openVehicleForm({Vehicle? vehicle}) async {
    final messenger = ScaffoldMessenger.of(context);
    final pageContext = context;

    if (vehicle == null && _canAssignOwner) {
      final loaded = await _ensureOwnerOptionsLoaded();
      if (!loaded) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No se pudieron cargar los propietarios.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    // ignore: use_build_context_synchronously
    _showVehicleForm(pageContext, vehicle: vehicle);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleCubit, VehicleState>(
      listener: (context, state) {
        if (state is VehicleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.message),
            ),
          );
        }
        if (state is VehicleOperationSuccess) {
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
            'Gestionar Vehiculos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () => context.read<VehicleCubit>().fetchVehicles(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar',
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loadingOwners ? null : () => _openVehicleForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _loadingOwners
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(_loadingOwners ? 'Cargando...' : 'Agregar vehiculo'),
              ),
            ),
          ),
        ),
        body: BlocBuilder<VehicleCubit, VehicleState>(
          builder: (context, state) {
            if (state is VehicleInitial || state is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Vehicle> vehicles = const [];
            if (state is VehicleLoaded) {
              vehicles = state.vehicles;
            } else if (state is VehicleOperationSuccess) {
              vehicles = state.vehicles;
            }

            if (vehicles.isEmpty) {
              return const Center(
                child: Text(
                  'No hay vehiculos registrados.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<VehicleCubit>().fetchVehicles(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemCount: vehicles.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return _buildVehicleCard(context, vehicle);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
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
                      vehicle.placa,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.marca} ${vehicle.modelo} - ${vehicle.anio}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if ((vehicle.color ?? '').isNotEmpty)
                      Text(
                        'Color: ${vehicle.color}',
                        style: const TextStyle(color: Colors.white60),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: vehicle.isActive
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  vehicle.estado,
                  style: TextStyle(
                    color: vehicle.isActive ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if ((vehicle.kilometraje ?? 0) > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Kilometraje: ${vehicle.kilometraje} km',
              style: const TextStyle(color: Colors.white60),
            ),
          ],
          if ((vehicle.observaciones ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Obs: ${vehicle.observaciones}',
              style: const TextStyle(color: Colors.white60),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openVehicleForm(vehicle: vehicle),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
              ),
              if (_canAssignOwner)
                ElevatedButton.icon(
                  onPressed: () => _showStatusDialog(context, vehicle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vehicle.isActive
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(vehicle.isActive ? Icons.pause : Icons.check, size: 16),
                  label: Text(vehicle.isActive ? 'Inactivar' : 'Activar'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showStatusDialog(BuildContext context, Vehicle vehicle) async {
    final targetStatus = vehicle.isActive ? 'INACTIVO' : 'ACTIVO';
    final motivoController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${vehicle.isActive ? 'Inactivar' : 'Activar'} vehiculo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Placa: ${vehicle.placa}'),
            const SizedBox(height: 12),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
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
              context.read<VehicleCubit>().updateVehicleStatus(
                    id: vehicle.id,
                    estado: targetStatus,
                    motivo: motivoController.text.trim(),
                  );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showVehicleForm(BuildContext context, {Vehicle? vehicle}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => _VehicleFormSheet(
        vehicle: vehicle,
        canAssignOwner: vehicle == null && _canAssignOwner,
        ownerOptions: vehicle == null ? _ownerOptions : const [],
        loadingOwners: _loadingOwners,
        onSubmit: (payload) async {
          Navigator.of(dialogContext).pop();
          if (vehicle == null) {
            await context.read<VehicleCubit>().createVehicle(payload);
          } else {
            await context.read<VehicleCubit>().updateVehicle(
                  id: vehicle.id,
                  data: payload,
                );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _OwnerOption {
  final String id;
  final String label;
  final String? subtitle;

  const _OwnerOption({
    required this.id,
    required this.label,
    this.subtitle,
  });
}

class _VehicleFormSheet extends StatefulWidget {
  final Vehicle? vehicle;
  final bool canAssignOwner;
  final List<_OwnerOption> ownerOptions;
  final bool loadingOwners;
  final Future<void> Function(Map<String, dynamic> payload) onSubmit;

  const _VehicleFormSheet({
    required this.vehicle,
    required this.canAssignOwner,
    required this.ownerOptions,
    required this.loadingOwners,
    required this.onSubmit,
  });

  @override
  State<_VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends State<_VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _placaController;
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _anioController;
  late final TextEditingController _colorController;
  late final TextEditingController _kilometrajeController;
  late final TextEditingController _vinController;
  late final TextEditingController _motorController;
  late final TextEditingController _observacionesController;
  String? _selectedOwnerId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    _placaController = TextEditingController(text: vehicle?.placa ?? '');
    _marcaController = TextEditingController(text: vehicle?.marca ?? '');
    _modeloController = TextEditingController(text: vehicle?.modelo ?? '');
    _anioController = TextEditingController(text: vehicle?.anio.toString() ?? '');
    _colorController = TextEditingController(text: vehicle?.color ?? '');
    _kilometrajeController = TextEditingController(text: vehicle?.kilometraje?.toString() ?? '');
    _vinController = TextEditingController();
    _motorController = TextEditingController();
    _observacionesController = TextEditingController(text: vehicle?.observaciones ?? '');
  }

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _colorController.dispose();
    _kilometrajeController.dispose();
    _vinController.dispose();
    _motorController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.canAssignOwner && widget.vehicle == null && (_selectedOwnerId == null || _selectedOwnerId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un propietario.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final payload = <String, dynamic>{
      'placa': _placaController.text.trim(),
      'marca': _marcaController.text.trim(),
      'modelo': _modeloController.text.trim(),
      'anio': int.parse(_anioController.text.trim()),
      'color': _colorController.text.trim(),
    };

    if (widget.canAssignOwner && widget.vehicle == null && _selectedOwnerId != null) {
      payload['propietario_id'] = _selectedOwnerId;
    }

    final km = int.tryParse(_kilometrajeController.text.trim());
    if (km != null) payload['kilometraje_actual'] = km;

    if (_vinController.text.trim().isNotEmpty) {
      payload['vin_chasis'] = _vinController.text.trim();
    }
    if (_motorController.text.trim().isNotEmpty) {
      payload['motor'] = _motorController.text.trim();
    }
    if (_observacionesController.text.trim().isNotEmpty) {
      payload['observaciones'] = _observacionesController.text.trim();
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
    final isCreate = widget.vehicle == null;

    return FractionallySizedBox(
      heightFactor: 0.94,
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
                isCreate ? 'Agregar vehiculo' : 'Editar vehiculo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.canAssignOwner && isCreate
                    ? 'Completa los datos del auto y selecciona un propietario.'
                    : 'Completa los datos del auto.',
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (widget.canAssignOwner && isCreate) ...[
                        DropdownButtonFormField<String>(
                          initialValue: _selectedOwnerId,
                          dropdownColor: const Color(0xFF1E293B),
                          decoration: _decoration('Propietario'),
                          items: widget.ownerOptions
                              .map(
                                (owner) => DropdownMenuItem<String>(
                                  value: owner.id,
                                  child: Text(
                                    owner.subtitle == null
                                        ? owner.label
                                        : '${owner.label} • ${owner.subtitle}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: widget.loadingOwners
                              ? null
                              : (value) => setState(() => _selectedOwnerId = value),
                          validator: (value) {
                            if (widget.canAssignOwner && isCreate && (value == null || value.isEmpty)) {
                              return 'Selecciona un propietario';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _placaController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Placa'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'La placa es obligatoria'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _marcaController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Marca'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'La marca es obligatoria'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _modeloController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Modelo'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'El modelo es obligatorio'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _anioController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _decoration('Año'),
                        validator: (value) {
                          final parsed = int.tryParse((value ?? '').trim());
                          if (parsed == null || parsed < 1900) {
                            return 'Ingresa un año válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _colorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Color'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'El color es obligatorio'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _kilometrajeController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _decoration('Kilometraje actual (opcional)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _vinController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('VIN / Chasis (opcional)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _motorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Motor (opcional)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _observacionesController,
                        style: const TextStyle(color: Colors.white),
                        minLines: 2,
                        maxLines: 4,
                        decoration: _decoration('Observaciones (opcional)'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(),
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
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isCreate ? 'Crear' : 'Guardar'),
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










