import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/usecases/reports_usecases.dart';

abstract class VehicleReportState extends Equatable {
  const VehicleReportState();
  @override
  List<Object?> get props => [];
}

class VehicleReportInitial extends VehicleReportState {}

class VehicleReportLoading extends VehicleReportState {}

class VehicleReportTopLoaded extends VehicleReportState {
  final List<TopVehicle> topVehicles;
  const VehicleReportTopLoaded(this.topVehicles);
  @override
  List<Object?> get props => [topVehicles];
}

class VehicleReportDetailLoaded extends VehicleReportState {
  final VehicleReportDetail detail;
  const VehicleReportDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class VehicleReportError extends VehicleReportState {
  final String message;
  const VehicleReportError(this.message);
  @override
  List<Object?> get props => [message];
}

class VehicleReportCubit extends Cubit<VehicleReportState> {
  final GetTopVehicles getTopVehicles;
  final GetVehicleReport getVehicleReport;

  VehicleReportCubit({
    required this.getTopVehicles,
    required this.getVehicleReport,
  }) : super(VehicleReportInitial());

  Future<void> fetchTopVehicles() async {
    emit(VehicleReportLoading());
    final result = await getTopVehicles();
    switch (result) {
      case Success(:final data):
        emit(VehicleReportTopLoaded(data));
      case Err(:final failure):
        emit(VehicleReportError(failure.message));
    }
  }

  Future<void> searchVehicle(String placa) async {
    if (placa.trim().isEmpty) {
      await fetchTopVehicles();
      return;
    }
    
    emit(VehicleReportLoading());
    final result = await getVehicleReport(placa.trim());
    switch (result) {
      case Success(:final data):
        emit(VehicleReportDetailLoaded(data));
      case Err(:final failure):
        emit(VehicleReportError(failure.message));
    }
  }
}
