import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_event.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_filters.dart';
import 'package:mobile1_app/features/audit/presentation/cubit/audit_cubit.dart';
import 'package:mobile1_app/features/audit/presentation/cubit/audit_state.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({super.key});

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  final _searchController = TextEditingController();
  final _accionController = TextEditingController();
  final _entidadController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _desdeController = TextEditingController();
  final _hastaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuditCubit>().fetchInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _accionController.dispose();
    _entidadController.dispose();
    _usuarioController.dispose();
    _desdeController.dispose();
    _hastaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuditCubit, AuditState>(
      listener: (context, state) {
        if (state is AuditError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
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
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Gestionar Bitacora',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () => context.read<AuditCubit>().fetchInitial(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<AuditCubit, AuditState>(
          builder: (context, state) {
            if (state is AuditInitial || state is AuditLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final events = state is AuditLoaded
                ? state.events
                : state is AuditError
                    ? state.events
                    : <AuditEvent>[];
            final summary = state is AuditLoaded
                ? state.summary
                : state is AuditError
                    ? state.summary
                    : null;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummary(summary),
                const SizedBox(height: 12),
                _buildFilters(),
                const SizedBox(height: 12),
                if (events.isEmpty)
                  const Text(
                    'No hay eventos para mostrar.',
                    style: TextStyle(color: Colors.white70),
                  )
                else
                  ...events.map((event) => _buildEventCard(event)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(dynamic summary) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: summary == null
          ? const Text('Resumen no disponible.', style: TextStyle(color: Colors.white70))
          : Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _summaryItem('Total', '${summary.totalEventos}'),
                _summaryItem('Hoy', '${summary.eventosHoy}'),
                _summaryItem('Semana', '${summary.eventosSemana}'),
                _summaryItem('Usuarios activos', '${summary.usuariosActivos}'),
              ],
            ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
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
          const Text(
            'Filtros',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _field(_searchController, 'Buscar (descripcion)'),
          const SizedBox(height: 8),
          _field(_accionController, 'Accion (ej: SERVICIO_CREADO)'),
          const SizedBox(height: 8),
          _field(_entidadController, 'Entidad tipo (ej: Vehiculo)'),
          const SizedBox(height: 8),
          _field(_usuarioController, 'Usuario ID'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _field(_desdeController, 'Desde (YYYY-MM-DD)')),
              const SizedBox(width: 8),
              Expanded(child: _field(_hastaController, 'Hasta (YYYY-MM-DD)')),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AuditCubit>().applyFilters(
                        AuditFilters(
                          search: _searchController.text.trim(),
                          accion: _accionController.text.trim(),
                          entidadTipo: _entidadController.text.trim(),
                          usuarioId: _usuarioController.text.trim(),
                          createdAtGte: _desdeController.text.trim(),
                          createdAtLte: _hastaController.text.trim(),
                          ordering: '-created_at',
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.filter_alt, size: 16),
                label: const Text('Aplicar'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _accionController.clear();
                  _entidadController.clear();
                  _usuarioController.clear();
                  _desdeController.clear();
                  _hastaController.clear();
                  context.read<AuditCubit>().clearFilters();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Limpiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF26264A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
      ),
    );
  }

  Widget _buildEventCard(AuditEvent event) {
    final date = event.createdAt == null
        ? 'N/A'
        : DateFormat('yyyy-MM-dd HH:mm').format(event.createdAt!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () async {
          final detail = await context.read<AuditCubit>().getDetail(event.id);
          if (!mounted || detail == null) return;

          showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Detalle de evento'),
              content: Text(
                'Usuario: ${detail.usuario}\n'
                'Accion: ${detail.accion}\n'
                'Entidad: ${detail.entidadTipo}\n'
                'Fecha: $date\n\n'
                '${detail.descripcion}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event.accion} - ${event.entidadTipo}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(event.descripcion, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(
                '${event.usuario} • $date',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

