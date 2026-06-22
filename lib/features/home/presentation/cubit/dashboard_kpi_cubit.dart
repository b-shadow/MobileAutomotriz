import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/reports/data/datasources/reports_remote_data_source.dart';

// ── States ──────────────────────────────────────────────────────────────────

abstract class DashboardKpiState extends Equatable {
  const DashboardKpiState();

  @override
  List<Object?> get props => [];
}

class DashboardKpiInitial extends DashboardKpiState {}

class DashboardKpiLoading extends DashboardKpiState {}

class DashboardKpiLoaded extends DashboardKpiState {
  final String rol;
  final String hoy;
  final List<Map<String, dynamic>> summary;
  final List<Map<String, dynamic>> sections;
  final Map<String, dynamic> rawKpis;

  const DashboardKpiLoaded({
    required this.rol,
    required this.hoy,
    required this.summary,
    required this.sections,
    required this.rawKpis,
  });

  @override
  List<Object?> get props => [rol, hoy, summary, sections, rawKpis];
}

class DashboardKpiError extends DashboardKpiState {
  final String message;

  const DashboardKpiError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────────────────────

class DashboardKpiCubit extends Cubit<DashboardKpiState> {
  final ReportsRemoteDataSource reportsRemoteDataSource;

  DashboardKpiCubit({required this.reportsRemoteDataSource})
      : super(DashboardKpiInitial());

  Future<void> fetchDashboardKpis() async {
    emit(DashboardKpiLoading());
    try {
      final reportData =
          await reportsRemoteDataSource.getReportData('dashboard_kpis', {});
      final data = reportData.data;

      final rol = (data['rol'] as String?) ?? 'USUARIO';
      final hoy = (data['hoy'] as String?) ?? '';

      final summaryRaw = data['summary'] as List<dynamic>? ?? [];
      final summary = summaryRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final sectionsRaw = data['sections'] as List<dynamic>? ?? [];
      final sections = sectionsRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final rawKpis =
          Map<String, dynamic>.from((data['kpis'] as Map?) ?? {});

      emit(DashboardKpiLoaded(
        rol: rol,
        hoy: hoy,
        summary: summary,
        sections: sections,
        rawKpis: rawKpis,
      ));
    } catch (e) {
      emit(DashboardKpiError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
