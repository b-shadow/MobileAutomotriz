import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_category.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_item.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_movement.dart';

sealed class InventoryState extends Equatable {
  final List<InventoryItem> items;
  final List<InventoryCategory> categories;
  final List<InventoryMovement> movements;

  const InventoryState({
    this.items = const [],
    this.categories = const [],
    this.movements = const [],
  });

  @override
  List<Object?> get props => [items, categories, movements];
}

final class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

final class InventoryLoading extends InventoryState {
  const InventoryLoading({
    super.items,
    super.categories,
    super.movements,
  });
}

final class InventoryLoaded extends InventoryState {
  const InventoryLoaded({
    required super.items,
    required super.categories,
    required super.movements,
  });
}

final class InventorySuccess extends InventoryState {
  final String message;

  const InventorySuccess({
    required super.items,
    required super.categories,
    required super.movements,
    required this.message,
  });

  @override
  List<Object?> get props => [items, categories, movements, message];
}

final class InventoryError extends InventoryState {
  final String message;

  const InventoryError({
    required super.items,
    required super.categories,
    required super.movements,
    required this.message,
  });

  @override
  List<Object?> get props => [items, categories, movements, message];
}
