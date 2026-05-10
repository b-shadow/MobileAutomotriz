import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/reception/domain/entities/reception.dart';
import 'package:mobile1_app/features/reception/presentation/cubit/reception_cubit.dart';
import 'package:mobile1_app/features/reception/presentation/cubit/reception_state.dart';

/// Página principal de Recepción e Inspección de Vehículos.
/// Solo visible para ADMIN y ASESOR DE SERVICIO.
class ReceptionPage extends StatefulWidget {
  const ReceptionPage({super.key});

  @override
  State<ReceptionPage> createState() => _ReceptionPageState();
}

class _ReceptionPageState extends State<ReceptionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final cubit = context.read<ReceptionCubit>();
    cubit.fetchCitasPendientes();
    cubit.fetchReceptions();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceptionCubit, ReceptionState>(
      listener: (ctx, state) {
        if (state is ReceptionError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text(state.message),
          ));
        }
        if (state is ReceptionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(state.message),
          ));
          _tabs.animateTo(1); // salta a "Registradas"
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Recepción e Inspección',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () {
                context.read<ReceptionCubit>().fetchCitasPendientes();
                context.read<ReceptionCubit>().fetchReceptions();
              },
              icon: const Icon(Icons.refresh, color: Colors.white70),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: const Color(0xFF10B981),
            labelColor: const Color(0xFF10B981),
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(text: 'Citas Pendientes'),
              Tab(text: 'Registradas'),
            ],
          ),
        ),
        body: BlocBuilder<ReceptionCubit, ReceptionState>(
          builder: (ctx, state) {
            if (state is ReceptionInitial || state is ReceptionLoading) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF10B981)));
            }
            return TabBarView(
              controller: _tabs,
              children: [
                _PendientesTab(
                  citas: state.citasPendientes,
                  onRegistrar: (cita) => _openRegistroForm(context, cita),
                ),
                _RegistradasTab(receptions: state.receptions),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openRegistroForm(
      BuildContext context, Appointment cita) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ReceptionCubit>(),
        child: _RegistroRecepcionSheet(cita: cita),
      ),
    );
  }
}

// ─── Tab: Citas Pendientes ────────────────────────────────────────────────────

class _PendientesTab extends StatelessWidget {
  final List<Appointment> citas;
  final void Function(Appointment) onRegistrar;

  const _PendientesTab({required this.citas, required this.onRegistrar});

  @override
  Widget build(BuildContext context) {
    if (citas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No hay citas pendientes de recepción',
                style: TextStyle(color: Colors.white54, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF10B981),
      onRefresh: () =>
          context.read<ReceptionCubit>().fetchCitasPendientes(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        itemCount: citas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _CitaPendienteCard(
          cita: citas[i],
          onRegistrar: () => onRegistrar(citas[i]),
        ),
      ),
    );
  }
}

class _CitaPendienteCard extends StatelessWidget {
  final Appointment cita;
  final VoidCallback onRegistrar;

  const _CitaPendienteCard(
      {required this.cita, required this.onRegistrar});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car,
                  color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${cita.vehiculoPlaca}  ·  ${cita.vehiculoMarca} ${cita.vehiculoModelo}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              _EstadoBadge(estado: cita.estado),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
              icon: Icons.schedule,
              label: 'Programada',
              value: fmt.format(cita.fechaHoraInicio.toLocal())),
          if ((cita.clienteNombre ?? '').isNotEmpty)
            _InfoRow(
                icon: Icons.person_outline,
                label: 'Cliente',
                value: cita.clienteNombre!),
          if (cita.detalles.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('${cita.detalles.length} servicio(s) programados',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRegistrar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text('Registrar Recepción',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab: Recepciones Registradas ─────────────────────────────────────────────

class _RegistradasTab extends StatelessWidget {
  final List<Reception> receptions;

  const _RegistradasTab({required this.receptions});

  @override
  Widget build(BuildContext context) {
    if (receptions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No hay recepciones registradas',
                style: TextStyle(color: Colors.white54, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF10B981),
      onRefresh: () => context.read<ReceptionCubit>().fetchReceptions(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        itemCount: receptions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _RecepcionCard(reception: receptions[i]),
      ),
    );
  }
}

class _RecepcionCard extends StatelessWidget {
  final Reception reception;

  const _RecepcionCard({required this.reception});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final color = reception.yaRecogido
        ? const Color(0xFF64748B)
        : const Color(0xFF10B981);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.car_repair,
                  color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${reception.vehiculoPlaca}  ·  ${reception.vehiculoMarca} ${reception.vehiculoModelo}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              if (reception.yaRecogido)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF64748B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Recogido',
                      style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
              icon: Icons.calendar_today,
              label: 'Recepcionado',
              value: fmt.format(reception.fechaRecepcion.toLocal())),
          _InfoRow(
              icon: Icons.speed,
              label: 'Kilometraje',
              value: '${reception.kilometrajeIngreso} km'),
          _InfoRow(
              icon: Icons.local_gas_station,
              label: 'Combustible',
              value: _combustibleLabel(reception.nivelCombustible)),
          if (reception.asesorNombre != null)
            _InfoRow(
                icon: Icons.badge_outlined,
                label: 'Asesor',
                value: reception.asesorNombre!),
          if ((reception.observaciones ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            _InfoRow(
                icon: Icons.notes,
                label: 'Obs.',
                value: reception.observaciones!),
          ],
        ],
      ),
    );
  }

  String _combustibleLabel(String val) => switch (val) {
        '1/4' => '1/4 de tanque',
        '1/2' => '1/2 de tanque',
        '3/4' => '3/4 de tanque',
        'LLENO' => 'Lleno',
        _ => val,
      };
}

// ─── Formulario de Registro de Recepción ─────────────────────────────────────

class _RegistroRecepcionSheet extends StatefulWidget {
  final Appointment cita;

  const _RegistroRecepcionSheet({required this.cita});

  @override
  State<_RegistroRecepcionSheet> createState() =>
      _RegistroRecepcionSheetState();
}

class _RegistroRecepcionSheetState extends State<_RegistroRecepcionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _kmCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  String _nivelCombustible = '1/2';
  bool _submitting = false;

  static const _nivelesLabel = {
    '1/4': '1/4 de tanque',
    '1/2': '1/2 de tanque',
    '3/4': '3/4 de tanque',
    'LLENO': 'Lleno',
  };

  @override
  void dispose() {
    _kmCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPad),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.fact_check_outlined,
                        color: Color(0xFF10B981), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Registrar Recepción',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                        Text(
                          '${widget.cita.vehiculoPlaca}  ·  ${widget.cita.vehiculoMarca} ${widget.cita.vehiculoModelo}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Aviso
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Al registrar la recepción, la cita pasará automáticamente a estado EN PROCESO y se generará una Orden de Trabajo.',
                        style: TextStyle(
                            color: const Color(0xFF10B981).withValues(alpha: 0.9),
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Kilometraje
              _SectionLabel('Kilometraje de ingreso *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _kmCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Ej. 45000'),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingrese el kilometraje';
                  }
                  final km = int.tryParse(v);
                  if (km == null || km < 0) {
                    return 'Kilometraje inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Nivel de combustible
              _SectionLabel('Nivel de combustible *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _nivelesLabel.entries.map((e) {
                  final selected = _nivelCombustible == e.key;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _nivelCombustible = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF10B981)
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF10B981)
                              : Colors.white24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_gas_station,
                              size: 14,
                              color:
                                  selected ? Colors.white : Colors.white38),
                          const SizedBox(width: 6),
                          Text(
                            e.value,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.white54,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Observaciones
              _SectionLabel('Observaciones generales'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _obsCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                    'Condición visual, ruidos, daños previos…'),
              ),
              const SizedBox(height: 24),
              // Botón
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<ReceptionCubit, ReceptionState>(
                  builder: (ctx, state) {
                    final loading = state is ReceptionLoading || _submitting;
                    return ElevatedButton.icon(
                      onPressed: loading ? null : () => _submit(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        disabledBackgroundColor:
                            const Color(0xFF10B981).withValues(alpha: 0.4),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline,
                              size: 20),
                      label: Text(
                        loading ? 'Registrando…' : 'Confirmar Recepción',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await context.read<ReceptionCubit>().createReception(
          citaId: widget.cita.id,
          kilometrajeIngreso: int.parse(_kmCtrl.text.trim()),
          nivelCombustible: _nivelCombustible,
          observaciones: _obsCtrl.text.trim().isEmpty
              ? null
              : _obsCtrl.text.trim(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Widget _SectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        errorStyle: const TextStyle(color: Color(0xFFEF4444)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}

// ─── Pequeños helpers ─────────────────────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (estado) {
      'PROGRAMADA' => (const Color(0xFF3B82F6), 'Programada'),
      'EN_ESPERA_INGRESO' => (const Color(0xFFA78BFA), 'En espera'),
      _ => (const Color(0xFF64748B), estado),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: Colors.white38),
          const SizedBox(width: 6),
          Text('$label: ',
              style:
                  const TextStyle(color: Colors.white38, fontSize: 12)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}
