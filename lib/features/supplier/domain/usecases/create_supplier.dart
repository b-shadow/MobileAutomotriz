import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';
import 'package:mobile1_app/features/supplier/domain/repositories/supplier_repository.dart';

class CreateSupplierParams extends Equatable {
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? contacto;

  const CreateSupplierParams({
    required this.nombre,
    this.telefono,
    this.email,
    this.direccion,
    this.contacto,
  });

  @override
  List<Object?> get props => [nombre, telefono, email, direccion, contacto];
}

class CreateSupplier implements UseCase<Supplier, CreateSupplierParams> {
  final SupplierRepository repository;
  CreateSupplier(this.repository);

  @override
  Future<Result<Supplier>> call(CreateSupplierParams params) =>
      repository.createSupplier(
        nombre: params.nombre,
        telefono: params.telefono,
        email: params.email,
        direccion: params.direccion,
        contacto: params.contacto,
      );
}
