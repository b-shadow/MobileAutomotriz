import 'package:mobile1_app/features/company/domain/entities/empresa.dart';
import 'package:mobile1_app/features/company/domain/entities/plan.dart';
import 'package:mobile1_app/features/company/domain/entities/subscription.dart';

abstract class CompanyState {
  const CompanyState();
}

class CompanyInitial extends CompanyState {
  const CompanyInitial();
}

class CompanyLoading extends CompanyState {
  const CompanyLoading();
}

class CompanyLoaded extends CompanyState {
  final Empresa empresa;
  final Subscription subscription;
  final List<Plan> plans;
  const CompanyLoaded({
    required this.empresa,
    required this.subscription,
    this.plans = const [],
  });
}

class CompanyError extends CompanyState {
  final String message;
  const CompanyError({required this.message});
}

class CompanyOperationSuccess extends CompanyState {
  final String message;
  final Empresa empresa;
  final Subscription subscription;
  final List<Plan> plans;
  const CompanyOperationSuccess({
    required this.message,
    required this.empresa,
    required this.subscription,
    this.plans = const [],
  });
}

/// Plans list loaded for selection UI
class PlansLoaded extends CompanyState {
  final List<Plan> plans;
  final Empresa empresa;
  final Subscription subscription;
  const PlansLoaded({
    required this.plans,
    required this.empresa,
    required this.subscription,
  });
}

/// Payment is being processed (Stripe flow)
class PaymentProcessing extends CompanyState {
  final String message;
  const PaymentProcessing({this.message = 'Procesando pago...'});
}

/// Payment requires UI action (Stripe Card Form)
class PaymentRequiresAction extends CompanyState {
  final String clientSecret;
  final String paymentIntentId;
  final String planId;
  final String accion;
  final int amountCentavos;
  final String planNombre;

  const PaymentRequiresAction({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.planId,
    required this.accion,
    required this.amountCentavos,
    required this.planNombre,
  });
}

/// Payment flow completed successfully
class PaymentSuccess extends CompanyState {
  final String message;
  const PaymentSuccess({required this.message});
}
