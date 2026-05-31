import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/inventory/data/datasources/inventory_remote_data_source.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_category.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_item.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:mobile1_app/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<InventoryCategory>>> getCategories() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getCategories();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<InventoryCategory>> createCategory({
    required String nombre,
    String? descripcion,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'activo': true,
      };
      if (descripcion != null && descripcion.isNotEmpty) {
        body['descripcion'] = descripcion;
      }
      final data = await remoteDataSource.createCategory(body);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<InventoryItem>>> getItems() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getItems();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<InventoryItem>> createItem({
    required String categoria,
    required String codigo,
    required String nombre,
    String? descripcion,
    required String tipoItem,
    required String unidadMedida,
    int stockActual = 0,
    int stockMinimo = 0,
    double costoPromedio = 0,
    double precioVenta = 0,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final body = <String, dynamic>{
        'categoria': categoria,
        'codigo': codigo,
        'nombre': nombre,
        'tipo_item': tipoItem,
        'unidad_medida': unidadMedida,
        'stock_actual': stockActual,
        'stock_minimo': stockMinimo,
        'costo_promedio': costoPromedio,
        'precio_venta': precioVenta,
        'activo': true,
      };
      if (descripcion != null && descripcion.isNotEmpty) {
        body['descripcion'] = descripcion;
      }
      final data = await remoteDataSource.createItem(body);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<InventoryMovement>> adjustStock({
    required String itemId,
    required String tipoMovimiento,
    required int cantidad,
    int? cantidadAjuste,
    String? observacion,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final body = <String, dynamic>{
        'tipo_movimiento': tipoMovimiento,
        'cantidad': cantidad,
      };
      if (cantidadAjuste != null) body['cantidad_ajuste'] = cantidadAjuste;
      if (observacion != null && observacion.isNotEmpty) {
        body['observacion'] = observacion;
      }
      final data = await remoteDataSource.adjustStock(itemId, body);
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<InventoryMovement>>> getMovements() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());
    try {
      final data = await remoteDataSource.getMovements();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
