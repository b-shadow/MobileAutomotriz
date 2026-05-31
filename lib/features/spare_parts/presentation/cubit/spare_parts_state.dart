import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/spare_parts/domain/entities/spare_part_request_entity.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';

sealed class SparePartsState extends Equatable {
  final List<SparePartRequestEntity> solicitudes;
  final List<Supplier> proveedores;

  const SparePartsState({
    this.solicitudes = const [],
    this.proveedores = const [],
  });

  @override
  List<Object?> get props => [solicitudes, proveedores];
}

final class SparePartsInitial extends SparePartsState {
  const SparePartsInitial();
}

final class SparePartsLoading extends SparePartsState {
  const SparePartsLoading({super.solicitudes, super.proveedores});
}

final class SparePartsLoaded extends SparePartsState {
  const SparePartsLoaded({required super.solicitudes, required super.proveedores});
}

final class SparePartsSuccess extends SparePartsState {
  final String message;

  const SparePartsSuccess({
    required super.solicitudes,
    required super.proveedores,
    required this.message,
  });

  @override
  List<Object?> get props => [solicitudes, proveedores, message];
}

final class SparePartsError extends SparePartsState {
  final String message;

  const SparePartsError({
    required super.solicitudes,
    required super.proveedores,
    required this.message,
  });

  @override
  List<Object?> get props => [solicitudes, proveedores, message];
}
