import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';
import 'package:mobile1_app/features/supplier/domain/repositories/supplier_repository.dart';

class UpdateSupplierParams extends Equatable {
  final String id;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? contacto;
  final bool activo;

  const UpdateSupplierParams({
    required this.id,
    required this.nombre,
    this.telefono,
    this.email,
    this.direccion,
    this.contacto,
    required this.activo,
  });

  @override
  List<Object?> get props =>
      [id, nombre, telefono, email, direccion, contacto, activo];
}

class UpdateSupplier implements UseCase<Supplier, UpdateSupplierParams> {
  final SupplierRepository repository;
  UpdateSupplier(this.repository);

  @override
  Future<Result<Supplier>> call(UpdateSupplierParams params) =>
      repository.updateSupplier(
        id: params.id,
        nombre: params.nombre,
        telefono: params.telefono,
        email: params.email,
        direccion: params.direccion,
        contacto: params.contacto,
        activo: params.activo,
      );
}
