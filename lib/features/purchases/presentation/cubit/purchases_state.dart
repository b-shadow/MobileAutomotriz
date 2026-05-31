import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/purchases/domain/entities/purchase_entity.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';

sealed class PurchasesState extends Equatable {
  final List<Purchase> purchases;
  final List<Supplier> suppliers;
  final List<InventoryItem> items;

  const PurchasesState({
    this.purchases = const [],
    this.suppliers = const [],
    this.items = const [],
  });

  @override
  List<Object?> get props => [purchases, suppliers, items];
}

final class PurchasesInitial extends PurchasesState {
  const PurchasesInitial();
}

final class PurchasesLoading extends PurchasesState {
  const PurchasesLoading({super.purchases, super.suppliers, super.items});
}

final class PurchasesLoaded extends PurchasesState {
  const PurchasesLoaded({
    required super.purchases,
    required super.suppliers,
    required super.items,
  });
}

final class PurchasesSuccess extends PurchasesState {
  final String message;

  const PurchasesSuccess({
    required super.purchases,
    required super.suppliers,
    required super.items,
    required this.message,
  });

  @override
  List<Object?> get props => [purchases, suppliers, items, message];
}

final class PurchasesError extends PurchasesState {
  final String message;

  const PurchasesError({
    required super.purchases,
    required super.suppliers,
    required super.items,
    required this.message,
  });

  @override
  List<Object?> get props => [purchases, suppliers, items, message];
}
