import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_category.dart';
import 'package:mobile1_app/features/inventory/domain/repositories/inventory_repository.dart';

class CreateCategoryParams extends Equatable {
  final String nombre;
  final String? descripcion;

  const CreateCategoryParams({required this.nombre, this.descripcion});

  @override
  List<Object?> get props => [nombre, descripcion];
}

class CreateCategory implements UseCase<InventoryCategory, CreateCategoryParams> {
  final InventoryRepository repository;
  CreateCategory(this.repository);

  @override
  Future<Result<InventoryCategory>> call(CreateCategoryParams params) =>
      repository.createCategory(
        nombre: params.nombre,
        descripcion: params.descripcion,
      );
}
