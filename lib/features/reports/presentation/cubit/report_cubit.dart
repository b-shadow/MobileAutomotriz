import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/usecases/get_report_data.dart';
import '../../../../core/error/result.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {
  final String activeTab;

  const ReportLoading({required this.activeTab});

  @override
  List<Object?> get props => [activeTab];
}

class ReportLoaded extends ReportState {
  final ReportData reportData;
  final String activeTab;
  final Map<String, dynamic> filters;

  const ReportLoaded({
    required this.reportData,
    required this.activeTab,
    required this.filters,
  });

  @override
  List<Object?> get props => [reportData, activeTab, filters];
}

class ReportError extends ReportState {
  final String message;
  final String activeTab;

  const ReportError({required this.message, required this.activeTab});

  @override
  List<Object?> get props => [message, activeTab];
}

class ReportCubit extends Cubit<ReportState> {
  final GetReportData getReportData;

  ReportCubit({required this.getReportData}) : super(ReportInitial());

  Future<void> fetchReport(String tab, Map<String, dynamic> filters) async {
    emit(ReportLoading(activeTab: tab));
    
    String endpoint = '';
    switch (tab) {
      case 'GLOBAL':
        endpoint = 'global_stats';
        break;
      case 'VEHICULO':
        endpoint = 'vehiculo';
        break;
      case 'PRESUPUESTO':
        endpoint = 'presupuesto';
        break;
      case 'INVENTARIO':
        endpoint = 'inventario';
        break;
      default:
        endpoint = 'global_stats';
    }

    final result = await getReportData(endpoint, filters);

    switch (result) {
      case Success(:final data):
        emit(ReportLoaded(reportData: data, activeTab: tab, filters: filters));
        break;
      case Err(:final failure):
        emit(ReportError(message: failure.message, activeTab: tab));
        break;
    }
  }
}
