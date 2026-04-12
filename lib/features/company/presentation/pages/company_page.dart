import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/features/company/domain/entities/empresa.dart';
import 'package:mobile1_app/features/company/domain/entities/subscription.dart';

import '../cubit/company_cubit.dart';
import '../cubit/company_state.dart';
import '../widgets/edit_company_modal.dart';
import '../widgets/change_plan_modal.dart';
import '../widgets/renew_subscription_modal.dart';
import '../widgets/stripe_payment_modal.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<CompanyCubit>().fetchCompany();
  }

  void _showEditModal(BuildContext context, Empresa empresa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EditCompanyModal(
        empresa: empresa,
        onSave: (nombre, estado) {
          context.read<CompanyCubit>().updateCompany(
                nombre: nombre,
                estado: estado,
              );
        },
      ),
    );
  }

  void _showChangePlanModal(BuildContext context, PlansLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ChangePlanModal(
        plans: state.plans,
        currentPlanId: state.subscription.planId,
        currentPlanNombre: state.subscription.planNombre,
        onConfirm: (plan) {
          context.read<CompanyCubit>().processChangePlan(
                planId: plan.id,
                selectedPlanNombre: plan.nombre,
                selectedPlanPrecioCentavos: plan.precioCentavos,
              );
        },
      ),
    );
  }

  void _showRenewModal(BuildContext context, Subscription subscription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => RenewSubscriptionModal(
        subscription: subscription,
        onConfirm: () {
          context.read<CompanyCubit>().processRenewal();
        },
      ),
    );
  }

  void _showStripePaymentModal(BuildContext context, PaymentRequiresAction state) {
    final companyCubit = context.read<CompanyCubit>();

    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StripePaymentModal(
        clientSecret: state.clientSecret,
        planNombre: state.planNombre,
        amountCentavos: state.amountCentavos,
      ),
    ).then((success) {
      if (!mounted) return;

      if (success == true) {
        companyCubit.confirmPaymentWithBackend(
              paymentIntentId: state.paymentIntentId,
              planId: state.planId,
              accion: state.accion,
            );
      } else {
        if (state.accion == 'cambiar') {
          companyCubit.handleChangePaymentCancelledOrFailed();
        } else {
          companyCubit.fetchCompany();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyCubit, CompanyState>(
      listener: (context, state) {
        if (state is CompanyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CompanyOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is PlansLoaded) {
          _showChangePlanModal(context, state);
        } else if (state is PaymentRequiresAction) {
          _showStripePaymentModal(context, state);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 84,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.business, color: Colors.blueGrey, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Gestionar Empresa',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              Text(
                'Información y configuración de tu empresa',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        body: BlocBuilder<CompanyCubit, CompanyState>(
          builder: (context, state) {
            if (state is CompanyLoading || state is CompanyInitial || state is PaymentProcessing) {
              final message = state is PaymentProcessing
                  ? state.message
                  : null;
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message, style: const TextStyle(color: Colors.white70)),
                    ],
                  ],
                ),
              );
            }

            if (state is CompanyError) {
              // Usually handled by listener but display a friendly error as fallback
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
                    const SizedBox(height: 16),
                    const Text('Error cargando empresa', style: TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: () => context.read<CompanyCubit>().fetchCompany(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final Empresa empresa;
            final Subscription subscription;
            if (state is CompanyLoaded) {
              empresa = state.empresa;
              subscription = state.subscription;
            } else if (state is CompanyOperationSuccess) {
              empresa = state.empresa;
              subscription = state.subscription;
            } else if (state is PlansLoaded) {
              empresa = state.empresa;
              subscription = state.subscription;
            } else {
              return const SizedBox();
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 720;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  // 1. Información General
                  _buildCard(
                    title: 'Información General',
                    action: ElevatedButton.icon(
                      onPressed: () => _showEditModal(context, empresa),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMobile)
                          Column(
                            children: [
                              _buildInfoItem('Nombre de Empresa', empresa.nombre),
                              const SizedBox(height: 16),
                              _buildInfoItem(
                                'Slug (URL)',
                                empresa.slug,
                                subtitle: 'No se puede cambiar',
                                subtitleColor: Colors.amber,
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(child: _buildInfoItem('Nombre de Empresa', empresa.nombre)),
                              Expanded(
                                  child: _buildInfoItem(
                                      'Slug (URL)', empresa.slug,
                                      subtitle: 'No se puede cambiar',
                                      subtitleColor: Colors.amber)),
                            ],
                          ),
                        const SizedBox(height: 16),
                        if (isMobile)
                          Column(
                            children: [
                              _buildStatusItem('Estado', empresa.estadoDisplay ?? empresa.estado, empresa.isActive),
                              const SizedBox(height: 16),
                              _buildInfoItem('Fecha de Creación', _formatDate(empresa.createdAt)),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                  child: _buildStatusItem('Estado', empresa.estadoDisplay ?? empresa.estado, empresa.isActive)),
                              Expanded(
                                  child: _buildInfoItem('Fecha de Creación', _formatDate(empresa.createdAt))),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Suscripción Actual
                  _buildCard(
                    title: 'Suscripción Actual',
                    titleIcon: Icons.receipt_long,
                    titleIconColor: Colors.amber,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMobile)
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF281C30), // Very dark purple
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subscription.diasRestantes > 0
                                          ? 'Plan Activo (${subscription.diasRestantes} días restantes)'
                                          : 'Plan Activo',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subscription.planNombre,
                                      style: const TextStyle(color: Color(0xFFD8B4FE), fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _buildStatusItem('Estado', subscription.estado, subscription.isActive),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF281C30), // Very dark purple
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subscription.diasRestantes > 0
                                            ? 'Plan Activo (${subscription.diasRestantes} días restantes)'
                                            : 'Plan Activo',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        subscription.planNombre,
                                        style: const TextStyle(color: Color(0xFFD8B4FE), fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatusItem('Estado', subscription.estado, subscription.isActive),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        if (isMobile)
                          Column(
                            children: [
                              _buildInfoItem('Fecha de Inicio', _formatDate(subscription.inicio)),
                              const SizedBox(height: 12),
                              _buildInfoItem('Fecha de Vencimiento', _formatDate(subscription.fin)),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(child: _buildInfoItem('Fecha de Inicio', _formatDate(subscription.inicio))),
                              Expanded(child: _buildInfoItem('Fecha de Vencimiento', _formatDate(subscription.fin))),
                            ],
                          ),
                        const SizedBox(height: 16),
                        _buildInfoItem('Precio', '\$${(subscription.planPrecioCentavos / 100).toStringAsFixed(2)} USD'),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<CompanyCubit>().loadPlans();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.autorenew, size: 16),
                              label: const Text('Cambiar Plan'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _showRenewModal(context, subscription);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.greenAccent,
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Renovar Suscripción'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Información Info Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21152a), // Purplish dark
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF332042)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blueAccent, size: 18),
                            SizedBox(width: 8),
                            Text('Información', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 12),
                        _InfoBullet('Aquí puedes ver los datos principales de tu empresa'),
                        _InfoBullet('Tu suscripción define las funciones disponibles'),
                        _InfoBullet('Puedes cambiar a un plan diferente en cualquier momento'),
                        _InfoBullet('Si renuevas antes de que venza, el nuevo periodo comienza cuando acabe el actual'),
                      ],
                    ),
                  )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('M/d/yyyy').format(date);
  }

  Widget _buildCard({
    required String title,
    IconData? titleIcon,
    Color? titleIconColor,
    Widget? action,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (titleIcon != null) ...[
                    Icon(titleIcon, color: titleIconColor, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {String? subtitle, Color? subtitleColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Text(subtitle, style: TextStyle(color: subtitleColor ?? Colors.grey, fontSize: 10)),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildStatusItem(String label, String status, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (isActive) const Icon(Icons.check, color: Colors.greenAccent, size: 16),
            if (!isActive) const Icon(Icons.close, color: Colors.redAccent, size: 16),
            const SizedBox(width: 4),
            Text(
              status,
              style: TextStyle(
                color: isActive ? Colors.greenAccent : Colors.redAccent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String text;
  const _InfoBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}
