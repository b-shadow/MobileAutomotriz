import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/company/data/datasources/company_remote_data_source.dart';
import 'package:mobile1_app/features/company/domain/entities/empresa.dart';
import 'package:mobile1_app/features/company/domain/entities/plan.dart';
import 'package:mobile1_app/features/company/domain/entities/subscription.dart';
import 'package:mobile1_app/features/company/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const CompanyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<Empresa>> getMyCompany() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final empresa = await remoteDataSource.getMyCompany();
      return Success(empresa);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Empresa>> updateMyCompany({
    String? nombre,
    String? estado,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final empresa = await remoteDataSource.updateMyCompany(
        nombre: nombre,
        estado: estado,
      );
      return Success(empresa);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Subscription>> getCurrentSubscription() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final subscription = await remoteDataSource.getCurrentSubscription();
      return Success(subscription);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<Plan>>> getAvailablePlans() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final plans = await remoteDataSource.getAvailablePlans();
      return Success(plans);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> changePlan(String planId) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.changePlan(planId);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> createPaymentIntent({
    required String planId,
    required String accion,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.createPaymentIntent(
        planId: planId,
        accion: accion,
      );
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> confirmPayment({
    required String paymentIntentId,
    required String planId,
    required String accion,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.confirmPayment(
        paymentIntentId: paymentIntentId,
        planId: planId,
        accion: accion,
      );
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> cancelScheduledChange() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.cancelScheduledChange();
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
