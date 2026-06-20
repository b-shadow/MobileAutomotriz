import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/payments/domain/entities/payment_taller_entity.dart';
import 'package:mobile1_app/features/payments/presentation/cubit/payments_cubit.dart';
import 'package:mobile1_app/features/payments/presentation/cubit/payments_state.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String _filterEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    context.read<PaymentsCubit>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentsCubit, PaymentsState>(
      listener: (ctx, state) {
        if (state is PaymentsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ));
        } else if (state is PaymentsSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.success,
            content: Text(state.message),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Pagos de Taller',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () => context.read<PaymentsCubit>().fetchAll(),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: BlocBuilder<PaymentsCubit, PaymentsState>(
                builder: (ctx, state) {
                  if (state is PaymentsLoading && state.payments.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.info),
                    );
                  }

                  final filtered = _applyFilter(state.payments);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment_outlined,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay pagos registrados',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.info,
                    onRefresh: () =>
                        context.read<PaymentsCubit>().fetchAll(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _PaymentCard(payment: filtered[i]),
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

  Widget _buildFilterBar() {
    const estados = ['TODOS', 'PENDIENTE', 'CONFIRMADO', 'FACTURADO', 'ANULADO'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: estados.map((e) {
          final isSelected = _filterEstado == e;
          final (label, color) = _estadoChipData(e);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : color)),
              selectedColor: color.withValues(alpha: 0.3),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              side: BorderSide(
                  color: isSelected
                      ? color
                      : Colors.white.withValues(alpha: 0.1)),
              checkmarkColor: Colors.white,
              onSelected: (selected) => setState(() => _filterEstado = e),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<PaymentTallerEntity> _applyFilter(List<PaymentTallerEntity> list) {
    if (_filterEstado == 'TODOS') return list;
    return list.where((p) => p.estado == _filterEstado).toList();
  }

  (String, Color) _estadoChipData(String estado) => switch (estado) {
        'TODOS' => ('Todos', AppColors.info),
        'PENDIENTE' => ('Pendiente', const Color(0xFFF59E0B)),
        'CONFIRMADO' => ('Confirmado', AppColors.success),
        'FACTURADO' => ('Facturado', const Color(0xFF3B82F6)),
        'ANULADO' => ('Anulado', AppColors.error),
        _ => (estado, Colors.grey),
      };
}

// ═══════════════════════════════════════════════════════════════════════════════
// Payment Card
// ═══════════════════════════════════════════════════════════════════════════════

class _PaymentCard extends StatelessWidget {
  final PaymentTallerEntity payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    final fmtMoney = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _estadoColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_estadoIcon, size: 20, color: _estadoColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.codigoPago ?? 'Pago #${payment.id.substring(0, 8)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmtDate.format(payment.createdAt.toLocal()),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _EstadoBadge(estado: payment.estado, label: payment.estadoLabel),
            ],
          ),
          const SizedBox(height: 12),

          // Money row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _MoneyCol(
                    label: 'Total', value: fmtMoney.format(payment.montoTotal)),
                const SizedBox(width: 16),
                _MoneyCol(
                    label: 'Pagado',
                    value: fmtMoney.format(payment.montoPagado ?? 0)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _metodoPagoColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_metodoPagoIcon, size: 14, color: _metodoPagoColor),
                      const SizedBox(width: 4),
                      Text(
                        payment.metodoPago,
                        style: TextStyle(
                          color: _metodoPagoColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Info rows
          _InfoRow(
              icon: Icons.category_outlined,
              value: 'Origen: ${payment.origenDisplay ?? payment.tipoOrigen}'),
          if (payment.descripcion != null && payment.descripcion!.isNotEmpty)
            _InfoRow(icon: Icons.description_outlined, value: payment.descripcion!),
          if (payment.fechaPago != null)
            _InfoRow(
                icon: Icons.schedule_outlined,
                value: 'Pagado: ${fmtDate.format(payment.fechaPago!.toLocal())}'),
          if (payment.recibidoAt != null)
            _InfoRow(
                icon: Icons.check_circle_outline,
                value:
                    'Recibido: ${fmtDate.format(payment.recibidoAt!.toLocal())}'),

          // Actions
          if (payment.canMarkReceived) ...[
            const SizedBox(height: 10),
            _buildActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => _confirmMarkReceived(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.success,
            side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: const Icon(Icons.check_circle_rounded, size: 16),
          label: const Text('Marcar Recibido',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _confirmMarkReceived(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Marcar Pago como Recibido',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Confirmar que recibiste Bs ${payment.montoTotal.toStringAsFixed(2)} por método ${payment.metodoPago}?',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dlgCtx).pop();
              context.read<PaymentsCubit>().markReceived(payment.id);
            },
            child: const Text('Confirmar',
                style: TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color get _estadoColor => switch (payment.estado) {
        'PENDIENTE' => const Color(0xFFF59E0B),
        'CONFIRMADO' => AppColors.success,
        'RECIBIDO' => AppColors.success,
        'FACTURADO' => const Color(0xFF3B82F6),
        'ANULADO' => AppColors.error,
        'CANCELADO' => AppColors.error,
        'VENCIDO' => Colors.grey,
        'RECHAZADO' => AppColors.error,
        _ => Colors.grey,
      };

  IconData get _estadoIcon => switch (payment.estado) {
        'PENDIENTE' => Icons.hourglass_top_rounded,
        'CONFIRMADO' => Icons.check_circle_outline,
        'RECIBIDO' => Icons.done_all_rounded,
        'FACTURADO' => Icons.receipt_long_rounded,
        'ANULADO' => Icons.cancel_outlined,
        'CANCELADO' => Icons.block_rounded,
        _ => Icons.payment_outlined,
      };

  Color get _metodoPagoColor => switch (payment.metodoPago.toUpperCase()) {
        'EFECTIVO' => const Color(0xFF10B981),
        'QR' => const Color(0xFF8B5CF6),
        'TARJETA' => const Color(0xFF3B82F6),
        _ => Colors.grey,
      };

  IconData get _metodoPagoIcon => switch (payment.metodoPago.toUpperCase()) {
        'EFECTIVO' => Icons.attach_money_rounded,
        'QR' => Icons.qr_code_2_rounded,
        'TARJETA' => Icons.credit_card_rounded,
        _ => Icons.payment_rounded,
      };
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared Widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _EstadoBadge extends StatelessWidget {
  final String estado;
  final String label;
  const _EstadoBadge({required this.estado, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (estado) {
      'PENDIENTE' => const Color(0xFFF59E0B),
      'CONFIRMADO' => AppColors.success,
      'FACTURADO' => const Color(0xFF3B82F6),
      'ANULADO' || 'CANCELADO' => AppColors.error,
      _ => Colors.grey,
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

class _MoneyCol extends StatelessWidget {
  final String label;
  final String value;
  const _MoneyCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.35)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
