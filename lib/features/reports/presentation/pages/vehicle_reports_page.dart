import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import '../cubit/vehicle_report_cubit.dart';
import '../../domain/entities/report_entities.dart';
import '../../data/report_export_service.dart';

class VehicleReportsPage extends StatefulWidget {
  const VehicleReportsPage({super.key});

  @override
  State<VehicleReportsPage> createState() => _VehicleReportsPageState();
}

class _VehicleReportsPageState extends State<VehicleReportsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VehicleReportCubit>().fetchTopVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<VehicleReportCubit>().searchVehicle(_searchController.text);
  }

  // ── Export ──────────────────────────────────────────────────────────────────

  void _showExportSheet(VehicleReportDetail detail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportBottomSheet(detail: detail),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Reportes de Vehículo'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocConsumer<VehicleReportCubit, VehicleReportState>(
              listener: (context, state) {
                if (state is VehicleReportError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: AppColors.error,
                    content: Text(state.message),
                  ));
                }
              },
              builder: (context, state) {
                if (state is VehicleReportLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (state is VehicleReportTopLoaded) {
                  return _buildTopVehiclesList(state.topVehicles);
                }

                if (state is VehicleReportDetailLoaded) {
                  return _buildVehicleDetail(state.detail);
                }

                if (state is VehicleReportError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: AppColors.darkTextTertiary),
                        const SizedBox(height: 16),
                        Text(state.message, style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<VehicleReportCubit>().fetchTopVehicles(),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          child: const Text('Volver al Top 10'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar por número de placa...',
          hintStyle: TextStyle(color: AppColors.darkTextTertiary),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: AppColors.darkTextTertiary),
            onPressed: () {
              _searchController.clear();
              _onSearch();
            },
          ),
          filled: true,
          fillColor: AppColors.darkSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _onSearch(),
      ),
    );
  }

  Widget _buildTopVehiclesList(List<TopVehicle> topVehicles) {
    if (topVehicles.isEmpty) {
      return Center(child: Text('No hay vehículos registrados.', style: TextStyle(color: AppColors.darkTextSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topVehicles.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '🏆 Top 10 Vehículos Más Frecuentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          );
        }

        final vehiculo = topVehicles[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.darkCardBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                '$index',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(vehiculo.placa, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text(vehiculo.vehiculo, style: TextStyle(color: AppColors.darkTextSecondary)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Visitas', style: TextStyle(fontSize: 12, color: AppColors.darkTextTertiary)),
                Text(
                  '${vehiculo.visitas}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            onTap: () {
              _searchController.text = vehiculo.placa;
              _onSearch();
            },
          ),
        );
      },
    );
  }

  Widget _buildVehicleDetail(VehicleReportDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tarjeta de Identificación + botón Exportar ──────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + botón exportar en la misma fila
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reporte de Vehículo', style: TextStyle(color: Colors.white70)),
                    _ExportButton(onTap: () => _showExportSheet(detail)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  detail.placa,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${detail.marca} ${detail.modelo}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // KPIs
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Visitas',
                  value: '${detail.totalVisitas}',
                  icon: Icons.history,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  title: 'Última Visita',
                  value: detail.ultimaVisita,
                  icon: Icons.calendar_today,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Historial
          const Text(
            '📋 Historial de Atenciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          if (detail.historial.isEmpty)
            Text('No hay registros en el historial.', style: TextStyle(color: AppColors.darkTextSecondary))
          else
            ...detail.historial.map((h) => _buildHistoryItem(h)),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(VehicleHistory history) {
    Color statusColor;
    switch (history.estado.toUpperCase()) {
      case 'COMPLETADA':
        statusColor = AppColors.success;
        break;
      case 'CANCELADA':
        statusColor = AppColors.error;
        break;
      case 'EN TALLER':
        statusColor = AppColors.info;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        title: Text(history.fecha, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text('Canal: ${history.canal}', style: TextStyle(color: AppColors.darkTextSecondary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            history.estado,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

// ── Export FAB button inside the header card ──────────────────────────────────

class _ExportButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ExportButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text('Exportar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ── Export Bottom Sheet ───────────────────────────────────────────────────────

class _ExportBottomSheet extends StatefulWidget {
  final VehicleReportDetail detail;
  const _ExportBottomSheet({required this.detail});

  @override
  State<_ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<_ExportBottomSheet> {
  bool _exporting = false;
  String? _error;

  Future<void> _export(String format) async {
    setState(() {
      _exporting = true;
      _error = null;
    });
    try {
      if (format == 'pdf') {
        await ReportExportService.exportPdf(widget.detail);
      } else {
        await ReportExportService.exportCsv(widget.detail);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkTextTertiary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Título
          Row(
            children: [
              Icon(Icons.download_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Exportar Reporte',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Vehículo ${widget.detail.placa} — ${widget.detail.marca} ${widget.detail.modelo}',
            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Error
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ),

          if (_exporting)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 12),
                  Text('Generando archivo...', style: TextStyle(color: AppColors.darkTextSecondary)),
                ],
              ),
            )
          else ...[
            // PDF
            _FormatTile(
              icon: Icons.picture_as_pdf_rounded,
              color: AppColors.error,
              title: 'PDF',
              subtitle: 'Documento con tablas y estilos · comparte fácilmente',
              onTap: () => _export('pdf'),
            ),
            const SizedBox(height: 12),
            // CSV
            _FormatTile(
              icon: Icons.table_chart_rounded,
              color: AppColors.success,
              title: 'CSV',
              subtitle: 'Archivo de texto separado por comas · Excel / Sheets',
              onTap: () => _export('csv'),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Format tile ───────────────────────────────────────────────────────────────

class _FormatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FormatTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
