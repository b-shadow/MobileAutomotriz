import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/invoices/data/datasources/invoices_remote_data_source.dart';
import 'package:mobile1_app/features/invoices/domain/entities/invoice_entity.dart';
import 'package:mobile1_app/features/invoices/domain/repositories/invoices_repository.dart';

class InvoicesRepositoryImpl implements InvoicesRepository {
  final InvoicesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const InvoicesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<InvoiceEntity>>> getInvoices() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getInvoices();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
