import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/store_sales/data/datasources/store_sales_remote_data_source.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';
import 'package:mobile1_app/features/store_sales/domain/repositories/store_sales_repository.dart';

class StoreSalesRepositoryImpl implements StoreSalesRepository {
  final StoreSalesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const StoreSalesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<StoreSale>>> getSales() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getSales();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<StoreSale>> createSale(StoreSaleInput input) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.createSale(input);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<StoreSale>> confirmSale(String saleId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.confirmSale(saleId);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<void>> markPaymentReceived(String pagoId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      await remoteDataSource.markPaymentReceived(pagoId);
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<void>> createInvoice(String pagoId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      await remoteDataSource.createInvoice(pagoId);
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<String>> createPaymentTaller({
    required String saleId,
    required double total,
    required String metodoPago,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final id = await remoteDataSource.createPaymentTaller(
        saleId: saleId,
        total: total,
        metodoPago: metodoPago,
      );
      return Success(id);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> createQRPayment(Map<String, dynamic> data) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final result = await remoteDataSource.createQRPayment(data);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> simularConfirmacionQR(String pagoId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final result = await remoteDataSource.simularConfirmacionQR(pagoId);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> consultarEstadoQR(String pagoId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final result = await remoteDataSource.consultarEstadoQR(pagoId);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> iniciarPagoTarjeta(Map<String, dynamic> data) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final result = await remoteDataSource.iniciarPagoTarjeta(data);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
