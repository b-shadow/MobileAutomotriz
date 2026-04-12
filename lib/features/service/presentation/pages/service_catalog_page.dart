import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';
import 'package:mobile1_app/features/service/domain/entities/service_item.dart';
import 'package:mobile1_app/features/service/presentation/cubit/service_cubit.dart';
import 'package:mobile1_app/features/service/presentation/cubit/service_state.dart';
import 'package:mobile1_app/injection_container.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';

class ServiceCatalogPage extends StatefulWidget {
  const ServiceCatalogPage({super.key});

  @override
  State<ServiceCatalogPage> createState() => _ServiceCatalogPageState();
}

class _ServiceCatalogPageState extends State<ServiceCatalogPage> {
  UsuarioModel? _user;

  bool get _canManage => _user?.isAdmin == true || _user?.isAsesor == true;

  @override
  void initState() {
    super.initState();
    final userData = sl<SessionStorage>().userData;
    if (userData != null) {
      _user = UsuarioModel.fromJson(userData);
    }
    context.read<ServiceCubit>().fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceCubit, ServiceState>(
      listener: (context, state) {
        if (state is ServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.message),
            ),
          );
        }
        if (state is ServiceOperationSuccess) {
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
            'Gestionar Catalogo de Servicios',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () => context.read<ServiceCubit>().fetchServices(),
              icon: const Icon(Icons.refresh),
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
                      onPressed: () => _openServiceForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar servicio'),
                    ),
                  ),
                ),
              )
            : null,
        body: BlocBuilder<ServiceCubit, ServiceState>(
          builder: (context, state) {
            if (state is ServiceInitial || state is ServiceLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<ServiceItem> services = const [];
            if (state is ServiceLoaded) {
              services = state.services;
            } else if (state is ServiceOperationSuccess) {
              services = state.services;
            }

            if (!_canManage) {
              services = services.where((item) => item.activo).toList();
            }

            if (services.isEmpty) {
              return const Center(
                child: Text(
                  'No hay servicios para mostrar.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<ServiceCubit>().fetchServices(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  _canManage ? 120 : 24,
                ),
                itemCount: services.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = services[index];
                  return _buildServiceCard(context, item);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceItem item) {
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
                      item.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Codigo: ${item.codigo}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.activo
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  item.activo ? 'ACTIVO' : 'INACTIVO',
                  style: TextStyle(
                    color: item.activo ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Precio: \$${item.precio.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white60),
          ),
          Text(
            'Tiempo estimado: ${item.tiempo} min',
            style: const TextStyle(color: Colors.white60),
          ),
          if ((item.descripcion ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.descripcion!,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
          if (_canManage) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openServiceForm(context, item: item),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showStatusDialog(context, item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        item.activo ? Colors.orange.shade700 : Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(item.activo ? Icons.pause : Icons.check, size: 16),
                  label: Text(item.activo ? 'Desactivar' : 'Activar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showStatusDialog(BuildContext context, ServiceItem item) async {
    final motivoController = TextEditingController();
    final targetStatus = !item.activo;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(targetStatus ? 'Activar servicio' : 'Desactivar servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.nombre),
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
              context.read<ServiceCubit>().updateServiceStatus(
                    id: item.id,
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

  Future<void> _openServiceForm(BuildContext context, {ServiceItem? item}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => _ServiceFormSheet(
        item: item,
        onSubmit: (payload) async {
          Navigator.of(dialogContext).pop();
          if (item == null) {
            await context.read<ServiceCubit>().createService(payload);
          } else {
            await context.read<ServiceCubit>().updateService(
                  id: item.id,
                  data: payload,
                );
          }
        },
      ),
    );
  }
}

class _ServiceFormSheet extends StatefulWidget {
  final ServiceItem? item;
  final Future<void> Function(Map<String, dynamic> payload) onSubmit;

  const _ServiceFormSheet({required this.item, required this.onSubmit});

  @override
  State<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<_ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _codigoController;
  late final TextEditingController _precioController;
  late final TextEditingController _tiempoController;
  late final TextEditingController _descripcionController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nombreController = TextEditingController(text: item?.nombre ?? '');
    _codigoController = TextEditingController(text: item?.codigo ?? '');
    _precioController = TextEditingController(
      text: item != null ? item.precio.toStringAsFixed(2) : '',
    );
    _tiempoController = TextEditingController(
      text: item != null ? item.tiempo.toString() : '',
    );
    _descripcionController = TextEditingController(text: item?.descripcion ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _precioController.dispose();
    _tiempoController.dispose();
    _descripcionController.dispose();
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

    final descripcion = _descripcionController.text.trim();

    final payload = <String, dynamic>{
      'nombre': _nombreController.text.trim(),
      'codigo': _codigoController.text.trim(),
      'precio_base': double.parse(_precioController.text.trim()),
      'tiempo_estandar_min': int.parse(_tiempoController.text.trim()),
    };

    if (descripcion.isNotEmpty) {
      payload['descripcion'] = descripcion;
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
    final isCreate = widget.item == null;

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
                isCreate ? 'Agregar servicio' : 'Editar servicio',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nombreController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Nombre'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Nombre obligatorio'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _codigoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Codigo'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Codigo obligatorio'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _precioController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _decoration('Precio'),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').trim());
                          if (parsed == null || parsed < 0) {
                            return 'Precio invalido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tiempoController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _decoration('Tiempo (minutos)'),
                        validator: (value) {
                          final parsed = int.tryParse((value ?? '').trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Tiempo invalido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descripcionController,
                        style: const TextStyle(color: Colors.white),
                        minLines: 2,
                        maxLines: 4,
                        decoration: _decoration('Descripcion'),
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

