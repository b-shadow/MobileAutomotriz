import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/payments/data/datasources/payments_remote_data_source.dart';
import 'package:mobile1_app/features/payments/domain/entities/payment_taller_entity.dart';
import 'package:mobile1_app/features/payments/domain/repositories/payments_repository.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const PaymentsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<PaymentTallerEntity>>> getPayments() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getPayments();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<PaymentTallerEntity>> createPayment(
      Map<String, dynamic> data) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final result = await remoteDataSource.createPayment(data);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<PaymentTallerEntity>> markReceived(String paymentId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final result = await remoteDataSource.markReceived(paymentId);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
