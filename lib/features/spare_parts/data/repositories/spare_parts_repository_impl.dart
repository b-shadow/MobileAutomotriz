import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/spare_parts/data/datasources/spare_parts_remote_data_source.dart';
import 'package:mobile1_app/features/spare_parts/domain/entities/spare_part_request_entity.dart';
import 'package:mobile1_app/features/spare_parts/domain/repositories/spare_parts_repository.dart';

class SparePartsRepositoryImpl implements SparePartsRepository {
  final SparePartsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const SparePartsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<SparePartRequestEntity>>> getSolicitudes() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getSolicitudes();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<SparePartRequestEntity>> aprobarSolicitud({
    required String solicitudId,
    String? observacionesAsesor,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.aprobarSolicitud(solicitudId, {
        'observaciones_asesor': observacionesAsesor ?? '',
      });
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<SparePartRequestEntity>> enProcesoAlmacen({
    required String solicitudId,
    String? observacionesAlmacen,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.enProcesoAlmacen(solicitudId, {
        'observaciones_almacen': observacionesAlmacen ?? '',
      });
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<SparePartRequestEntity>> marcarEntregada({
    required String solicitudId,
    required List<Map<String, dynamic>> detalles,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.marcarEntregada(solicitudId, {
        'detalles': detalles,
      });
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<SparePartRequestEntity>> asignarProveedorEta({
    required String solicitudId,
    required String proveedorId,
    String? eta,
    String? observaciones,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data =
          await remoteDataSource.asignarProveedorEta(solicitudId, {
        'proveedor_id': proveedorId,
        'eta': eta ?? '',
        'observaciones': observaciones ?? '',
      });
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
