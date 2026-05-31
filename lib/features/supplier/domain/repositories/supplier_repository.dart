import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';

abstract class SupplierRepository {
  Future<Result<List<Supplier>>> getSuppliers();

  Future<Result<Supplier>> createSupplier({
    required String nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? contacto,
  });

  Future<Result<Supplier>> updateSupplier({
    required String id,
    required String nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? contacto,
    required bool activo,
  });

  Future<Result<void>> deleteSupplier(String id);
}
