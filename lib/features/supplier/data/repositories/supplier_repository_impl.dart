import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/supplier/data/datasources/supplier_remote_data_source.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';
import 'package:mobile1_app/features/supplier/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const SupplierRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<Supplier>>> getSuppliers() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getSuppliers();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Supplier>> createSupplier({
    required String nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? contacto,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'activo': true,
      };
      if (telefono != null && telefono.isNotEmpty) body['telefono'] = telefono;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (direccion != null && direccion.isNotEmpty) {
        body['direccion'] = direccion;
      }
      if (contacto != null && contacto.isNotEmpty) {
        body['contacto'] = contacto;
      }
      final data = await remoteDataSource.createSupplier(body);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Supplier>> updateSupplier({
    required String id,
    required String nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? contacto,
    required bool activo,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'activo': activo,
        'telefono': telefono ?? '',
        'email': email ?? '',
        'direccion': direccion ?? '',
        'contacto': contacto ?? '',
      };
      final data = await remoteDataSource.updateSupplier(id, body);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<void>> deleteSupplier(String id) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      await remoteDataSource.deleteSupplier(id);
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
