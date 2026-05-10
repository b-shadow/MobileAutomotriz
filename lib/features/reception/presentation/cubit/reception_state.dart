import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/reception/domain/entities/reception.dart';

sealed class ReceptionState extends Equatable {
  final List<Reception> receptions;
  final List<Appointment> citasPendientes;

  const ReceptionState({
    this.receptions = const [],
    this.citasPendientes = const [],
  });

  @override
  List<Object?> get props => [receptions, citasPendientes];
}

final class ReceptionInitial extends ReceptionState {
  const ReceptionInitial();
}

final class ReceptionLoading extends ReceptionState {
  const ReceptionLoading({super.receptions, super.citasPendientes});
}

final class ReceptionLoaded extends ReceptionState {
  final Reception? selected;

  const ReceptionLoaded({
    required super.receptions,
    super.citasPendientes,
    this.selected,
  });

  @override
  List<Object?> get props => [receptions, citasPendientes, selected];
}

final class ReceptionSuccess extends ReceptionState {
  final String message;
  final Reception? created;

  const ReceptionSuccess({
    required super.receptions,
    super.citasPendientes,
    required this.message,
    this.created,
  });

  @override
  List<Object?> get props => [receptions, citasPendientes, message, created];
}

final class ReceptionError extends ReceptionState {
  final String message;

  const ReceptionError({
    required super.receptions,
    super.citasPendientes,
    required this.message,
  });

  @override
  List<Object?> get props => [receptions, citasPendientes, message];
}
