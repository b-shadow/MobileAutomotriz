import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/presentation/cubit/appointment_cubit.dart';
import 'package:mobile1_app/features/appointment/presentation/cubit/appointment_state.dart';
import 'package:mobile1_app/features/budget/domain/entities/budget.dart';
import 'package:mobile1_app/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:mobile1_app/features/budget/presentation/cubit/budget_state.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    context.read<BudgetCubit>().fetchBudgets();
    context.read<AppointmentCubit>().fetchAppointments();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetCubit, BudgetState>(
      listener: (ctx, state) {
        if (state is BudgetError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text(state.message),
          ));
        } else if (state is BudgetSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(state.message),
          ));
          if (state.budget != null) {
            _tabs.animateTo(0);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Presupuestos',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () {
                context.read<BudgetCubit>().fetchBudgets();
                context.read<AppointmentCubit>().fetchAppointments();
              },
            )
          ],
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: const Color(0xFF3B82F6),
            labelColor: const Color(0xFF3B82F6),
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(text: 'Historial'),
              Tab(text: 'Generar Nuevo'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _HistorialTab(),
            _GenerarTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Pestaña Historial ────────────────────────────────────────────────────────
class _HistorialTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (ctx, state) {
        if (state is BudgetLoading && state.budgets.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
        }
        if (state.budgets.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.request_quote_outlined,
                    size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text('No hay presupuestos registrados',
                    style: TextStyle(color: Colors.white54, fontSize: 15)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF3B82F6),
          onRefresh: () => context.read<BudgetCubit>().fetchBudgets(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            itemCount: state.budgets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _BudgetCard(budget: state.budgets[i]),
          ),
        );
      },
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;

  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    return InkWell(
      onTap: () => context.push('/budget-detail/${budget.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long,
                    color: Color(0xFF3B82F6), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Presupuesto Cita #${budget.citaId.substring(0, 8)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
                _EstadoBadge(estado: budget.estado),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(
                icon: Icons.calendar_today,
                label: 'Creado',
                value: fmtDate.format(budget.createdAt.toLocal())),
            _InfoRow(
                icon: Icons.attach_money,
                label: 'Total',
                value: 'Bs ${budget.total.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

// ─── Pestaña Generar Nuevo ───────────────────────────────────────────────────
class _GenerarTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (ctx, state) {
        if (state is AppointmentLoading && state.appointments.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
        }

        // Filtramos citas activas
        final citas = state.appointments
            .where((c) =>
                c.estado != 'CANCELADA' && c.estado != 'FINALIZADA')
            .toList();

        if (citas.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text('No hay citas activas para presupuestar',
                    style: TextStyle(color: Colors.white54, fontSize: 15)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF3B82F6),
          onRefresh: () =>
              context.read<AppointmentCubit>().fetchAppointments(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            itemCount: citas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _CitaCard(cita: citas[i]),
          ),
        );
      },
    );
  }
}

class _CitaCard extends StatelessWidget {
  final Appointment cita;

  const _CitaCard({required this.cita});

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car,
                  color: Color(0xFF3B82F6), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${cita.vehiculoPlaca} · ${cita.vehiculoMarca} ${cita.vehiculoModelo}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(cita.estado,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
              icon: Icons.person_outline,
              label: 'Cliente',
              value: cita.clienteNombre ?? 'Desconocido'),
          _InfoRow(
              icon: Icons.schedule,
              label: 'Programada',
              value: fmtDate.format(cita.fechaHoraInicio.toLocal())),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<BudgetCubit, BudgetState>(
              builder: (ctx, state) {
                final loading = state is BudgetLoading;
                return ElevatedButton.icon(
                  onPressed: loading
                      ? null
                      : () => _generateBudget(context, cita.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add_card, size: 18),
                  label: const Text('Generar Presupuesto',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _generateBudget(BuildContext context, String citaId) {
    context.read<BudgetCubit>().createBudget(citaId: citaId, descuento: 0);
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
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
          Icon(icon, size: 14, color: Colors.white38),
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

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (estado) {
      'BORRADOR' => (const Color(0xFF94A3B8), 'Borrador'),
      'COMUNICADO' => (const Color(0xFFF59E0B), 'Comunicado'),
      'APROBADO' => (const Color(0xFF10B981), 'Aprobado'),
      'RECHAZADO' => (const Color(0xFFEF4444), 'Rechazado'),
      'AJUSTADO' => (const Color(0xFF8B5CF6), 'Ajustado'),
      'CERRADO' => (const Color(0xFF3B82F6), 'Cerrado'),
      _ => (Colors.grey, estado),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
