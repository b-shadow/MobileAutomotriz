import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';

sealed class SupplierState extends Equatable {
  final List<Supplier> suppliers;

  const SupplierState({this.suppliers = const []});

  @override
  List<Object?> get props => [suppliers];
}

final class SupplierInitial extends SupplierState {
  const SupplierInitial();
}

final class SupplierLoading extends SupplierState {
  const SupplierLoading({super.suppliers});
}

final class SupplierLoaded extends SupplierState {
  const SupplierLoaded({required super.suppliers});
}

final class SupplierSuccess extends SupplierState {
  final String message;

  const SupplierSuccess({
    required super.suppliers,
    required this.message,
  });

  @override
  List<Object?> get props => [suppliers, message];
}

final class SupplierError extends SupplierState {
  final String message;

  const SupplierError({
    required super.suppliers,
    required this.message,
  });

  @override
  List<Object?> get props => [suppliers, message];
}
