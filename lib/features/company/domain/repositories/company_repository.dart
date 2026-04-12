import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/company/domain/entities/empresa.dart';
import 'package:mobile1_app/features/company/domain/entities/plan.dart';
import 'package:mobile1_app/features/company/domain/entities/subscription.dart';

abstract class CompanyRepository {
  Future<Result<Empresa>> getMyCompany();

  Future<Result<Empresa>> updateMyCompany({
    String? nombre,
    String? estado,
  });

  Future<Result<Subscription>> getCurrentSubscription();

  Future<Result<List<Plan>>> getAvailablePlans();

  Future<Result<Map<String, dynamic>>> changePlan(String planId);

  Future<Result<Map<String, dynamic>>> createPaymentIntent({
    required String planId,
    required String accion,
  });

  Future<Result<Map<String, dynamic>>> confirmPayment({
    required String paymentIntentId,
    required String planId,
    required String accion,
  });

  Future<Result<Map<String, dynamic>>> cancelScheduledChange();
}
