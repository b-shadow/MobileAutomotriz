import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/report_data.dart';
import '../../domain/usecases/get_explorer_data.dart';
import '../../data/report_catalog.dart';
import '../../../../core/error/result.dart';

// ── State ──────────────────────────────────────────────────────────────────

abstract class ExplorerState extends Equatable {
  const ExplorerState();

  @override
  List<Object?> get props => [];
}

class ExplorerInitial extends ExplorerState {}

class ExplorerLoading extends ExplorerState {}

class ExplorerLoaded extends ExplorerState {
  final ReportData reportData;
  final ReportTemplate template;
  final List<String> columnasActivas;
  final List<ExplorerFilter> filtros;
  final bool chartView;

  const ExplorerLoaded({
    required this.reportData,
    required this.template,
    required this.columnasActivas,
    required this.filtros,
    required this.chartView,
  });

  @override
  List<Object?> get props => [
        reportData,
        template,
        columnasActivas,
        filtros,
        chartView,
      ];

  ExplorerLoaded copyWith({
    ReportData? reportData,
    ReportTemplate? template,
    List<String>? columnasActivas,
    List<ExplorerFilter>? filtros,
    bool? chartView,
  }) {
    return ExplorerLoaded(
      reportData: reportData ?? this.reportData,
      template: template ?? this.template,
      columnasActivas: columnasActivas ?? this.columnasActivas,
      filtros: filtros ?? this.filtros,
      chartView: chartView ?? this.chartView,
    );
  }
}

class ExplorerError extends ExplorerState {
  final String message;

  const ExplorerError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ── Cubit ──────────────────────────────────────────────────────────────────

class ExplorerCubit extends Cubit<ExplorerState> {
  final GetExplorerData getExplorerData;

  ExplorerCubit({required this.getExplorerData}) : super(ExplorerInitial());

  Future<void> loadReport(
    ReportTemplate template,
    List<String> columnasActivas,
    List<ExplorerFilter> filtros, {
    bool chartView = false,
  }) async {
    emit(ExplorerLoading());

    // Convert UI filters to API format
    final finalFilters = Map<String, dynamic>.from(template.defaultFilters);
    final userFilters = buildUserFilters(filtros);
    finalFilters.addAll(userFilters);

    final result = await getExplorerData(
      template.view,
      columnasActivas,
      finalFilters,
    );

    switch (result) {
      case Success(:final data):
        emit(ExplorerLoaded(
          reportData: data,
          template: template,
          columnasActivas: columnasActivas,
          filtros: filtros,
          chartView: chartView,
        ));
        break;
      case Err(:final failure):
        emit(ExplorerError(message: failure.message));
        break;
    }
  }

  void toggleViewMode(bool chartView) {
    if (state is ExplorerLoaded) {
      final current = state as ExplorerLoaded;
      emit(current.copyWith(chartView: chartView));
    }
  }

  void reset() {
    emit(ExplorerInitial());
  }
}
