import 'package:flutter/material.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/features/appointment/presentation/cubit/appointment_cubit.dart';
import 'package:mobile1_app/injection_container.dart';

/// Bottom sheet para crear una nueva cita.
/// Carga dinámicamente vehículos, detalles del plan, espacios de trabajo.
class AppointmentFormSheet extends StatefulWidget {
  const AppointmentFormSheet({super.key});

  @override
  State<AppointmentFormSheet> createState() => _AppointmentFormSheetState();
}

class _AppointmentFormSheetState extends State<AppointmentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  // Datos cargados desde el backend
  List<Map<String, dynamic>> _vehiculos = [];
  List<Map<String, dynamic>> _planDetalles = [];
  Set<String> _planDetallesInhabilitados = {};
  List<Map<String, dynamic>> _espacios = [];

  // Selecciones
  String? _vehiculoId;
  String? _planServicioId;
  final List<String> _serviciosSeleccionados = [];
  String? _espacioId;
  DateTime _fechaInicio = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _horaInicio = const TimeOfDay(hour: 9, minute: 0);

  bool _loading = false;
  bool _submitting = false;
  String? _error;

  // ── Helpers ─────────────────────────────────────────────────────────────

  String get _slug {
    final userData = sl<SessionStorage>().userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final t = userData['tenant'] as Map<String, dynamic>;
      final s = t['slug'] as String?;
      if (s != null && s.isNotEmpty) return s;
    }
    return EnvConfig.tenantSlug;
  }

  ApiClient get _api => sl<ApiClient>();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadVehiculos();
    _loadEspacios();
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  // ── Data Loading ─────────────────────────────────────────────────────────

  Future<void> _loadVehiculos() async {
    setState(() => _loading = true);
    try {
      final resp = await _api.get(ApiConstants.vehiculos(_slug));
      final data = resp.data;
      List<dynamic> rows = [];
      if (data is Map && data['results'] is List) {
        rows = data['results'] as List;
      } else if (data is List) {
        rows = data;
      }
      setState(() {
        _vehiculos = rows.whereType<Map<String, dynamic>>().toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudieron cargar los vehículos.';
        _loading = false;
      });
    }
  }

  Future<void> _loadPlanDetalles(String planId) async {
    setState(() {
      _planDetalles = [];
      _planDetallesInhabilitados = {};
      _serviciosSeleccionados.clear();
    });
    try {
      // Usamos el endpoint del plan completo (igual que el frontend),
      // que devuelve { id, detalles: [...] } con todos los servicios incluidos.
      final resp = await _api.get(ApiConstants.planVehiculo(_slug, planId));
      final data = resp.data;

      List<dynamic> rows = [];
      if (data is Map<String, dynamic>) {
        // El plan trae sus detalles directamente o en un campo "detalles"
        final detalles = data['detalles'];
        if (detalles is List) {
          rows = detalles;
        }
      } else if (data is List) {
        rows = data;
      }

      // Si el endpoint del plan no devolvió detalles, caemos al endpoint /detalles/
      if (rows.isEmpty) {
        final resp2 = await _api.get(ApiConstants.planVehiculoDetalles(_slug, planId));
        final data2 = resp2.data;
        if (data2 is Map && data2['results'] is List) {
          rows = data2['results'] as List;
        } else if (data2 is List) {
          rows = data2;
        }
      }

      final all = rows.whereType<Map<String, dynamic>>().toList();

      // Estados que no se pueden seleccionar (ya usados o terminados)
      const inhabilitados = {'PROGRAMADO', 'EN_PROCESO', 'COMPLETADO', 'CANCELADO'};

      // Mostramos todos excepto COMPLETADO y CANCELADO (esos ya no son útiles)
      const ocultos = {'COMPLETADO', 'CANCELADO'};

      final visibles = all.where((d) {
        final estado = (d['estado'] ?? '').toString().toUpperCase();
        return !ocultos.contains(estado);
      }).toList();

      final inhabilitadosSet = <String>{};
      for (final d in visibles) {
        final estado = (d['estado'] ?? '').toString().toUpperCase();
        if (inhabilitados.contains(estado)) {
          inhabilitadosSet.add(d['id']?.toString() ?? '');
        }
      }

      setState(() {
        _planDetalles = visibles;
        _planDetallesInhabilitados = inhabilitadosSet;
      });
    } catch (e) {
      setState(() => _error = 'No se pudieron cargar los servicios del plan.');
    }
  }

  Future<void> _loadEspacios() async {
    try {
      final resp = await _api.get(ApiConstants.espacios(_slug));
      final data = resp.data;
      List<dynamic> rows = [];
      if (data is Map && data['results'] is List) {
        rows = data['results'] as List;
      } else if (data is List) {
        rows = data;
      }
      setState(() {
        _espacios = rows.whereType<Map<String, dynamic>>()
            .where((e) => e['activo'] == true)
            .toList();
      });
    } catch (_) {}
  }

  // ── On Vehículo Selected ─────────────────────────────────────────────────

  void _onVehiculoChanged(String? id) {
    if (id == null) return;
    setState(() {
      _vehiculoId = id;
      _planDetalles = [];
      _planDetallesInhabilitados = {};
      _serviciosSeleccionados.clear();
      _planServicioId = null;
    });

    // Buscar el plan del vehículo:
    // El backend puede devolver plan_servicio_id (UUID string directo) o
    // plan_servicio como objeto anidado { id, ... } — manejamos ambos casos.
    final vehiculo = _vehiculos.firstWhere(
      (v) => v['id']?.toString() == id,
      orElse: () => {},
    );

    String? planId;

    // 1. Campo directo: plan_servicio_id (igual al frontend: vehiculo.plan_servicio_id)
    final directId = vehiculo['plan_servicio_id'];
    if (directId != null && directId.toString().isNotEmpty) {
      planId = directId.toString();
    }

    // 2. Campo anidado: plan_servicio: { id: ... }
    if (planId == null) {
      final planObj = vehiculo['plan_servicio'];
      if (planObj is Map<String, dynamic>) {
        final nested = planObj['id']?.toString();
        if (nested != null && nested.isNotEmpty) {
          planId = nested;
        }
      } else if (planObj is String && planObj.isNotEmpty) {
        planId = planObj;
      }
    }

    if (planId != null) {
      setState(() => _planServicioId = planId);
      _loadPlanDetalles(planId);
    }
  }

  // ── Date/Time Pickers ────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF8B5CF6),
            surface: AppColors.darkCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fechaInicio = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaInicio,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF8B5CF6),
            surface: AppColors.darkCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _horaInicio = picked);
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vehiculoId == null) {
      setState(() => _error = 'Selecciona un vehículo.');
      return;
    }
    if (_serviciosSeleccionados.isEmpty) {
      setState(() => _error = 'Selecciona al menos un servicio.');
      return;
    }
    if (_espacioId == null) {
      setState(() => _error = 'Selecciona un espacio de trabajo.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    // Construir la fecha-hora como ISO 8601
    final dt = DateTime(
      _fechaInicio.year,
      _fechaInicio.month,
      _fechaInicio.day,
      _horaInicio.hour,
      _horaInicio.minute,
    );

    final payload = <String, dynamic>{
      'vehiculo_id': _vehiculoId,
      'servicios_plan_detalle_ids': _serviciosSeleccionados,
      'canal_origen': 'CLIENTE',
      'espacio_id': _espacioId,
      'fecha_inicio': '${_fechaInicio.year.toString().padLeft(4, '0')}-'
          '${_fechaInicio.month.toString().padLeft(2, '0')}-'
          '${_fechaInicio.day.toString().padLeft(2, '0')}',
      'hora_inicio':
          '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}',
      'fecha_hora_inicio_programada': dt.toUtc().toIso8601String(),
      if (_planServicioId != null) 'plan_servicio_id': _planServicioId,
    };

    if (_motivoCtrl.text.trim().isNotEmpty) {
      payload['motivo_visita'] = _motivoCtrl.text.trim();
    }
    if (_obsCtrl.text.trim().isNotEmpty) {
      payload['observaciones_cliente'] = _obsCtrl.text.trim();
    }

    try {
      await context.read<AppointmentCubit>().createAppointment(payload);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Color(0xFF8B5CF6), size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Nueva Cita',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                  ),
                ),
              ),
            // Body
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          8,
                          20,
                          MediaQuery.of(context).viewInsets.bottom + 16,
                        ),
                        children: [
                          // ── Vehículo ──────────────────────────────
                          const _SectionTitle('1. Vehículo'),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            hint: 'Selecciona un vehículo',
                            value: _vehiculoId,
                            items: _vehiculos.map((v) {
                              final placa = v['placa']?.toString() ?? '';
                              final marca = v['marca']?.toString() ?? '';
                              final modelo = v['modelo']?.toString() ?? '';
                              return DropdownMenuItem<String>(
                                value: v['id']?.toString(),
                                child: Text(
                                  '$placa — $marca $modelo',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: _onVehiculoChanged,
                          ),

                          // ── Servicios del Plan ───────────────────
                          if (_vehiculoId != null) ...[
                            const SizedBox(height: 16),
                            const _SectionTitle('2. Servicios a Realizar'),
                            const SizedBox(height: 8),
                            if (_planDetalles.isEmpty && _planServicioId == null)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Este vehículo no tiene un plan de servicios asignado. Debes asignarle un plan primero para agendar una cita.',
                                  style: TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                              )
                            else if (_planDetalles.isEmpty && _planServicioId != null)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'El plan asociado a este vehículo no tiene servicios.',
                                  style: TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                              )
                            else
                              ..._planDetalles.map((d) {
                                final id = d['id']?.toString() ?? '';
                                // El backend puede retornar el nombre en varios campos:
                                // - servicio_nombre (campo aplanado del frontend)
                                // - servicio_catalogo.nombre (objeto anidado)
                                // - nombre (campo directo)
                                final nombre = d['servicio_nombre']?.toString() ??
                                    (d['servicio_catalogo'] is Map
                                        ? (d['servicio_catalogo'] as Map)['nombre']?.toString()
                                        : null) ??
                                    d['nombre']?.toString() ??
                                    'Servicio';
                                final tiempo = d['tiempo_estandar_min']?.toString() ?? '0';
                                // precio_referencial puede venir como String ("0.00") o num
                                final precioRaw = d['precio_referencial'];
                                final precio = precioRaw is num
                                    ? precioRaw.toDouble()
                                    : double.tryParse(precioRaw?.toString() ?? '0') ?? 0.0;
                                final inhabilitado = _planDetallesInhabilitados.contains(id);
                                final estado = (d['estado'] ?? '').toString().toUpperCase();
                                final selected = _serviciosSeleccionados.contains(id);
                                return _ServiceCheckTile(
                                  id: id,
                                  nombre: nombre,
                                  tiempo: tiempo,
                                  precio: precio,
                                  selected: selected,
                                  inhabilitado: inhabilitado,
                                  estado: estado,
                                  onChanged: inhabilitado
                                      ? null
                                      : (v) {
                                          setState(() {
                                            if (v == true) {
                                              _serviciosSeleccionados.add(id);
                                            } else {
                                              _serviciosSeleccionados.remove(id);
                                            }
                                          });
                                        },
                                );
                              }),
                          ],

                          // ── Espacio de trabajo ───────────────────
                          const SizedBox(height: 16),
                          const _SectionTitle('3. Espacio de Trabajo'),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            hint: 'Selecciona un espacio',
                            value: _espacioId,
                            items: _espacios.map((e) {
                              final nombre = e['nombre']?.toString() ?? '';
                              final tipo = e['tipo']?.toString() ?? '';
                              return DropdownMenuItem<String>(
                                value: e['id']?.toString(),
                                child: Text(
                                  '$nombre ($tipo)',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _espacioId = v),
                          ),

                          // ── Fecha y Hora ─────────────────────────
                          const SizedBox(height: 16),
                          const _SectionTitle('4. Fecha y Hora de Inicio'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _PickerTile(
                                  icon: Icons.calendar_today,
                                  label: '${_fechaInicio.day.toString().padLeft(2, '0')}/'
                                      '${_fechaInicio.month.toString().padLeft(2, '0')}/'
                                      '${_fechaInicio.year}',
                                  onTap: _pickDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PickerTile(
                                  icon: Icons.access_time,
                                  label:
                                      '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}',
                                  onTap: _pickTime,
                                ),
                              ),
                            ],
                          ),

                          // ── Motivo y Observaciones ───────────────
                          const SizedBox(height: 16),
                          const _SectionTitle('5. Detalles Adicionales'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _motivoCtrl,
                            label: 'Motivo de la visita',
                            minLines: 2,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _obsCtrl,
                            label: 'Observaciones adicionales (opcional)',
                            minLines: 2,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // ── Botón de envío ───────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _submitting
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white54,
                                    side: const BorderSide(color: Colors.white24),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _submitting ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Text(
                                          'Crear Cita',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: AppColors.darkCard,
          hint: Text(hint, style: const TextStyle(color: Colors.white38)),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppColors.darkCard,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF8B5CF6),
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ServiceCheckTile extends StatelessWidget {
  final String id;
  final String nombre;
  final String tiempo;
  final double precio;
  final bool selected;
  final bool inhabilitado;
  final String estado;
  final ValueChanged<bool?>? onChanged;

  const _ServiceCheckTile({
    required this.id,
    required this.nombre,
    required this.tiempo,
    required this.precio,
    required this.selected,
    this.inhabilitado = false,
    this.estado = 'PENDIENTE',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: inhabilitado
            ? Colors.white.withValues(alpha: 0.03)
            : selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: inhabilitado
              ? Colors.white12
              : selected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.white12,
        ),
      ),
      child: CheckboxListTile(
        value: inhabilitado ? false : selected,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        checkColor: Colors.white,
        title: Text(
          nombre,
          style: TextStyle(
            color: inhabilitado ? Colors.white30 : Colors.white,
            fontSize: 14,
            decoration: inhabilitado ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              '$tiempo min · Bs. ${precio.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            if (inhabilitado) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  estado == 'EN_PROCESO' ? 'en proceso' : 'programado',
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
