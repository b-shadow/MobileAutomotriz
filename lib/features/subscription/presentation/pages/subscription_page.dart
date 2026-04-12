import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/features/company/domain/entities/plan.dart';
import 'package:mobile1_app/features/company/domain/entities/subscription.dart';
import 'package:mobile1_app/features/company/presentation/cubit/company_cubit.dart';
import 'package:mobile1_app/features/company/presentation/cubit/company_state.dart';
import 'package:mobile1_app/features/company/presentation/widgets/change_plan_modal.dart';
import 'package:mobile1_app/features/company/presentation/widgets/renew_subscription_modal.dart';
import 'package:mobile1_app/features/company/presentation/widgets/stripe_payment_modal.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyCubit>().fetchCompany();
  }

  void _showChangePlanModal(
    BuildContext context,
    Subscription subscription,
    List<Plan> plans,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ChangePlanModal(
        plans: plans,
        currentPlanId: subscription.planId,
        currentPlanNombre: subscription.planNombre,
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
              backgroundColor: Colors.red,
              content: Text(state.message),
            ),
          );
        } else if (state is PaymentSuccess || state is CompanyOperationSuccess) {
          final message = state is PaymentSuccess
              ? state.message
              : (state as CompanyOperationSuccess).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(message),
            ),
          );
        } else if (state is PaymentRequiresAction) {
          _showStripePaymentModal(context, state);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 78,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Gestionar Suscripcion',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Administra tu plan y renovaciones',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        body: BlocBuilder<CompanyCubit, CompanyState>(
          builder: (context, state) {
            if (state is CompanyInitial ||
                state is CompanyLoading ||
                state is PaymentProcessing) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (state is PaymentProcessing) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              );
            }

            Subscription? subscription;
            List<Plan> plans = const [];
            if (state is CompanyLoaded) {
              subscription = state.subscription;
              plans = state.plans;
            } else if (state is CompanyOperationSuccess) {
              subscription = state.subscription;
              plans = state.plans;
            } else if (state is PlansLoaded) {
              subscription = state.subscription;
              plans = state.plans;
            }

            if (subscription == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => context.read<CompanyCubit>().fetchCompany(),
                  child: const Text('Reintentar carga'),
                ),
              );
            }

            final currentSubscription = subscription;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 720;
                final planCardWidth = isMobile
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 48) / 2;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCurrentSubscriptionCard(
                        context,
                        currentSubscription,
                        plans,
                        isMobile,
                      ),
                      const SizedBox(height: 16),
                      _buildPlansSection(
                        context,
                        currentSubscription,
                        plans,
                        planCardWidth,
                      ),
                      const SizedBox(height: 16),
                      _buildHistorySection(currentSubscription),
                      const SizedBox(height: 16),
                      _buildFaqSection(),
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

  Widget _buildCurrentSubscriptionCard(
    BuildContext context,
    Subscription subscription,
    List<Plan> plans,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu Suscripcion Actual',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _statusTile('Plan Activo', subscription.planNombre),
              _statusTile('Estado', subscription.estado, accent: Colors.greenAccent),
              _statusTile('Vencimiento', _formatDate(subscription.fin)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showRenewModal(context, subscription),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Renovar Suscripcion'),
              ),
              OutlinedButton.icon(
                onPressed: plans.isEmpty
                    ? null
                    : () => _showChangePlanModal(context, subscription, plans),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: Text(isMobile ? 'Cambiar Plan' : 'Cambiar de Plan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection(
    BuildContext context,
    Subscription subscription,
    List<Plan> plans,
    double cardWidth,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Planes Disponibles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (plans.isEmpty)
            const Text(
              'No hay planes para mostrar.',
              style: TextStyle(color: Colors.white70),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: plans.map((plan) {
                final isCurrent = plan.id == subscription.planId;
                return SizedBox(
                  width: cardWidth,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF0D2A2C)
                          : const Color(0xFF233044),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent
                            ? Colors.greenAccent.withValues(alpha: 0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Suscripcion por ${plan.duracionDias} dias',
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          plan.precioFormateado,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${plan.moneda} / periodo',
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isCurrent
                                ? null
                                : () {
                                    context.read<CompanyCubit>().processChangePlan(
                                          planId: plan.id,
                                          selectedPlanNombre: plan.nombre,
                                          selectedPlanPrecioCentavos:
                                              plan.precioCentavos,
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCurrent
                                  ? const Color(0xFF5B2A99)
                                  : const Color(0xFF8B5CF6),
                              disabledBackgroundColor: const Color(0xFF5B2A99),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isCurrent ? 'Plan Actual' : 'Elegir Plan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(Subscription subscription) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de Cambios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Plan actual: ${subscription.planNombre}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Desde ${_formatDate(subscription.inicio)} hasta ${_formatDate(subscription.fin)}',
            style: const TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preguntas Frecuentes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '¿Que pasa si cambio de plan?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Text(
            'El nuevo plan se aplicara despues del vencimiento del periodo actual.',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 10),
          Text(
            '¿Puedo renovar antes de que venza?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Text(
            'Si. El nuevo periodo se extiende automaticamente.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _statusTile(String label, String value, {Color? accent}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: accent ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('M/d/yyyy').format(date);
  }
}




