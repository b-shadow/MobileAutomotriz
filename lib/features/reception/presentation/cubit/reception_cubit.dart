import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/reception/domain/entities/reception.dart';
import 'package:mobile1_app/features/reception/domain/usecases/create_reception.dart';
import 'package:mobile1_app/features/reception/domain/usecases/get_citas_pendientes.dart';
import 'package:mobile1_app/features/reception/domain/usecases/get_receptions.dart';
import 'reception_state.dart';

class ReceptionCubit extends Cubit<ReceptionState> {
  final GetReceptions _getReceptions;
  final GetCitasPendientesRecepcion _getCitasPendientes;
  final CreateReception _createReception;

  List<Reception> _receptions = const [];

  ReceptionCubit({
    required GetReceptions getReceptions,
    required GetCitasPendientesRecepcion getCitasPendientes,
    required CreateReception createReception,
  })  : _getReceptions = getReceptions,
        _getCitasPendientes = getCitasPendientes,
        _createReception = createReception,
        super(const ReceptionInitial());

  /// Carga la lista de recepciones registradas.
  Future<void> fetchReceptions() async {
    emit(ReceptionLoading(
        receptions: _receptions,
        citasPendientes: state.citasPendientes));
    final result = await _getReceptions(const NoParams());
    switch (result) {
      case Success(:final data):
        _receptions = data;
        emit(ReceptionLoaded(
          receptions: _receptions,
          citasPendientes: state.citasPendientes,
        ));
      case Err(:final failure):
        emit(ReceptionError(
          receptions: _receptions,
          citasPendientes: state.citasPendientes,
          message: failure.message,
        ));
    }
  }

  /// Carga las citas pendientes de recepción (PROGRAMADA / EN_ESPERA_INGRESO sin recepción).
  Future<void> fetchCitasPendientes() async {
    emit(ReceptionLoading(
        receptions: _receptions,
        citasPendientes: state.citasPendientes));
    final result = await _getCitasPendientes(const NoParams());
    switch (result) {
      case Success(:final data):
        emit(ReceptionLoaded(
          receptions: _receptions,
          citasPendientes: data,
        ));
      case Err(:final failure):
        emit(ReceptionError(
          receptions: _receptions,
          citasPendientes: state.citasPendientes,
          message: failure.message,
        ));
    }
  }

  /// Registra una nueva recepción de vehículo.
  Future<void> createReception({
    required String citaId,
    required int kilometrajeIngreso,
    required String nivelCombustible,
    String? observaciones,
  }) async {
    emit(ReceptionLoading(
        receptions: _receptions,
        citasPendientes: state.citasPendientes));
    final result = await _createReception(CreateReceptionParams(
      citaId: citaId,
      kilometrajeIngreso: kilometrajeIngreso,
      nivelCombustible: nivelCombustible,
      observaciones: observaciones,
    ));
    switch (result) {
      case Success(:final data):
        _receptions = [data, ..._receptions];
        emit(ReceptionSuccess(
          receptions: _receptions,
          citasPendientes: state.citasPendientes,
          message: 'Recepción registrada. La cita pasó a EN PROCESO.',
          created: data,
        ));
        // Recarga las listas para reflejar el cambio de estado
        await fetchCitasPendientes();
        await fetchReceptions();
      case Err(:final failure):
        emit(ReceptionError(
          receptions: _receptions,
          citasPendientes: state.citasPendientes,
          message: failure.message,
        ));
    }
  }
}
