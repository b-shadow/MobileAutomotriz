import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_item.dart';
import 'package:mobile1_app/features/inventory/domain/repositories/inventory_repository.dart';

class CreateInventoryItemParams extends Equatable {
  final String categoria;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String tipoItem;
  final String unidadMedida;
  final int stockActual;
  final int stockMinimo;
  final double costoPromedio;
  final double precioVenta;

  const CreateInventoryItemParams({
    required this.categoria,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.tipoItem,
    required this.unidadMedida,
    this.stockActual = 0,
    this.stockMinimo = 0,
    this.costoPromedio = 0,
    this.precioVenta = 0,
  });

  @override
  List<Object?> get props => [
        categoria,
        codigo,
        nombre,
        descripcion,
        tipoItem,
        unidadMedida,
        stockActual,
        stockMinimo,
        costoPromedio,
        precioVenta,
      ];
}

class CreateInventoryItem
    implements UseCase<InventoryItem, CreateInventoryItemParams> {
  final InventoryRepository repository;
  CreateInventoryItem(this.repository);

  @override
  Future<Result<InventoryItem>> call(CreateInventoryItemParams params) =>
      repository.createItem(
        categoria: params.categoria,
        codigo: params.codigo,
        nombre: params.nombre,
        descripcion: params.descripcion,
        tipoItem: params.tipoItem,
        unidadMedida: params.unidadMedida,
        stockActual: params.stockActual,
        stockMinimo: params.stockMinimo,
        costoPromedio: params.costoPromedio,
        precioVenta: params.precioVenta,
      );
}
