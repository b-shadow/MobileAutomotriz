import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/company/domain/entities/empresa.dart';
import 'package:mobile1_app/features/company/domain/entities/plan.dart';
import 'package:mobile1_app/features/company/domain/entities/subscription.dart';
import 'package:mobile1_app/features/company/domain/usecases/get_company_profile.dart';
import 'package:mobile1_app/features/company/domain/usecases/update_company_profile.dart';
import 'package:mobile1_app/features/company/domain/usecases/get_current_subscription.dart';
import 'package:mobile1_app/features/company/domain/usecases/get_available_plans.dart';
import 'package:mobile1_app/features/company/domain/usecases/change_plan.dart';
import 'package:mobile1_app/features/company/domain/usecases/create_payment_intent.dart';
import 'package:mobile1_app/features/company/domain/usecases/confirm_payment.dart';
import 'package:mobile1_app/features/company/domain/usecases/cancel_scheduled_change.dart';

import 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final GetCompanyProfile _getCompanyProfile;
  final UpdateCompanyProfile _updateCompanyProfile;
  final GetCurrentSubscription _getCurrentSubscription;
  final GetAvailablePlans _getAvailablePlans;
  final ChangePlan _changePlan;
  final CreatePaymentIntent _createPaymentIntent;
  final ConfirmPayment _confirmPayment;
  final CancelScheduledChange _cancelScheduledChange;

  Subscription? _lastSubscription;
  Empresa? _lastEmpresa;
  List<Plan> _lastPlans = const [];

  CompanyCubit({
    required GetCompanyProfile getCompanyProfile,
    required UpdateCompanyProfile updateCompanyProfile,
    required GetCurrentSubscription getCurrentSubscription,
    required GetAvailablePlans getAvailablePlans,
    required ChangePlan changePlan,
    required CreatePaymentIntent createPaymentIntent,
    required ConfirmPayment confirmPayment,
    required CancelScheduledChange cancelScheduledChange,
  })  : _getCompanyProfile = getCompanyProfile,
        _updateCompanyProfile = updateCompanyProfile,
        _getCurrentSubscription = getCurrentSubscription,
        _getAvailablePlans = getAvailablePlans,
        _changePlan = changePlan,
        _createPaymentIntent = createPaymentIntent,
        _confirmPayment = confirmPayment,
        _cancelScheduledChange = cancelScheduledChange,
        super(const CompanyInitial());

  Future<void> fetchCompany() async {
    emit(const CompanyLoading());

    final results = await Future.wait([
      _getCompanyProfile(const NoParams()),
      _getCurrentSubscription(const NoParams()),
    ]);

    final companyResult = results[0];
    final subResult = results[1] as Result<Subscription>;

    if (companyResult is Success<Empresa> && subResult is Success<Subscription>) {
      _lastSubscription = subResult.data;
      _lastEmpresa = companyResult.data;

      final plansResult = await _getAvailablePlans(const NoParams());
      if (plansResult is Success<List<Plan>>) {
        _lastPlans = plansResult.data;
      }

      emit(CompanyLoaded(
        empresa: companyResult.data,
        subscription: subResult.data,
          plans: _lastPlans,
      ));
    } else {
      final errorMessage = companyResult is Err
          ? (companyResult as Err).failure.message
          : (subResult as Err).failure.message;
      emit(CompanyError(message: errorMessage));
    }
  }

  Future<void> updateCompany({String? nombre, String? estado}) async {
    emit(const CompanyLoading());

    final result = await _updateCompanyProfile(
      UpdateCompanyProfileParams(nombre: nombre, estado: estado),
    );

    switch (result) {
      case Success(:final data):
        _lastEmpresa = data;
        if (_lastSubscription != null) {
          emit(CompanyOperationSuccess(
            message: 'Información de empresa actualizada',
            empresa: data,
            subscription: _lastSubscription!,
            plans: _lastPlans,
          ));
          emit(
            CompanyLoaded(
              empresa: data,
              subscription: _lastSubscription!,
              plans: _lastPlans,
            ),
          );
        }
      case Err(:final failure):
        emit(CompanyError(message: failure.message));
    }
  }

  /// Load available plans for the change plan modal.
  Future<void> loadPlans() async {
    if (_lastEmpresa == null || _lastSubscription == null) return;

    emit(const CompanyLoading());
    final result = await _getAvailablePlans(const NoParams());

    switch (result) {
      case Success(:final data):
        _lastPlans = data;
        emit(PlansLoaded(
          plans: data,
          empresa: _lastEmpresa!,
          subscription: _lastSubscription!,
        ));
      case Err(:final failure):
        emit(CompanyError(message: failure.message));
    }
  }

  /// Full flow: schedule change → (optional) create payment intent → confirm payment.
  Future<void> processChangePlan({
    required String planId,
    required String selectedPlanNombre,
    required int selectedPlanPrecioCentavos,
  }) async {
    emit(const PaymentProcessing(message: 'Programando cambio de plan...'));

    // Step 1: Schedule the plan change
    final changeResult = await _changePlan(ChangePlanParams(planId: planId));

    if (changeResult is Err) {
      emit(CompanyError(message: (changeResult as Err).failure.message));
      return;
    }

    // Downgrade / same-price changes may not require immediate Stripe payment.
    final currentPrice = _lastSubscription?.planPrecioCentavos ?? 0;
    final requiresPayment = selectedPlanPrecioCentavos > currentPrice;
    if (!requiresPayment) {
      emit(PaymentSuccess(
        message:
            'Cambio a $selectedPlanNombre programado sin pago inmediato.',
      ));
      await fetchCompany();
      return;
    }

    // Step 2: Create Payment Intent
    emit(const PaymentProcessing(message: 'Creando intento de pago...'));
    final piResult = await _createPaymentIntent(
      CreatePaymentIntentParams(planId: planId, accion: 'cambiar'),
    );

    if (piResult is! Success<Map<String, dynamic>>) {
      emit(CompanyError(message: (piResult as Err).failure.message));
      return;
    }

    final piData = piResult.data;
    final paymentIntentId = piData['id'] as String? ?? '';
    final clientSecret = piData['client_secret'] as String? ?? '';

    if (paymentIntentId.isEmpty || clientSecret.isEmpty) {
      emit(const CompanyError(message: 'Error al crear el intento de pago'));
      return;
    }

    // Step 3: Pide UI action
    emit(PaymentRequiresAction(
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
      planId: planId,
      accion: 'cambiar',
      amountCentavos: piData['amount'] as int? ?? 0,
      planNombre: piData['plan_nombre'] as String? ?? selectedPlanNombre,
    ));
  }

  /// Full flow for renewing: create payment intent → wait for UI → confirm
  Future<void> processRenewal() async {
    if (_lastSubscription == null) return;

    emit(const PaymentProcessing(message: 'Creando intento de pago...'));

    final currentPlanId = _lastSubscription!.planId;

    if (currentPlanId.isEmpty) {
      emit(const CompanyError(
        message: 'No se pudo identificar el plan actual para renovar',
      ));
      return;
    }

    final piResult = await _createPaymentIntent(
      CreatePaymentIntentParams(planId: currentPlanId, accion: 'renovar'),
    );

    if (piResult is! Success<Map<String, dynamic>>) {
      emit(CompanyError(message: (piResult as Err).failure.message));
      return;
    }

    final piData = piResult.data;
    final paymentIntentId = piData['id'] as String? ?? '';
    final clientSecret = piData['client_secret'] as String? ?? '';

    if (paymentIntentId.isEmpty || clientSecret.isEmpty) {
      emit(const CompanyError(message: 'Error al crear el intento de pago'));
      return;
    }

    emit(PaymentRequiresAction(
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
      planId: currentPlanId,
      accion: 'renovar',
      amountCentavos: piData['amount'] as int? ?? 0,
      planNombre: piData['plan_nombre'] as String? ?? 'Renovación',
    ));
  }

  Future<void> handleChangePaymentCancelledOrFailed() async {
    emit(const PaymentProcessing(message: 'Limpiando cambio pendiente...'));

    final cancelResult = await _cancelScheduledChange(const NoParams());
    if (cancelResult is Err) {
      emit(CompanyError(message: (cancelResult as Err).failure.message));
    }

    await fetchCompany();
  }

  /// Confirm payment with backend after successful Stripe frontend processing
  Future<void> confirmPaymentWithBackend({
    required String paymentIntentId,
    required String planId,
    required String accion,
  }) async {
    emit(const PaymentProcessing(message: 'Confirmando pago en el servidor...'));

    final confirmResult = await _confirmPayment(
      ConfirmPaymentParams(
        paymentIntentId: paymentIntentId,
        planId: planId,
        accion: accion,
      ),
    );

    switch (confirmResult) {
      case Success(:final data):
        final message = data['mensaje'] as String? ?? 'Operación exitosa';
        emit(PaymentSuccess(message: message));
        await fetchCompany();
      case Err(:final failure):
        emit(CompanyError(message: failure.message));
    }
  }
}
