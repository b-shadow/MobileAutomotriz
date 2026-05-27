import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Reportes de Vehículo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocConsumer<VehicleReportCubit, VehicleReportState>(
              listener: (context, state) {
                if (state is VehicleReportError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: const Color(0xFFEF4444),
                    content: Text(state.message),
                  ));
                }
              },
              builder: (context, state) {
                if (state is VehicleReportLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(state.message,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context
                                  .read<VehicleReportCubit>()
                                  .fetchTopVehicles(),
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
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Buscar por número de placa...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              _onSearch();
            },
          ),
          filled: true,
          fillColor: Colors.white,
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
      return const Center(child: Text('No hay vehículos registrados.'));
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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
          );
        }

        final vehiculo = topVehicles[index - 1];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(
                '$index',
                style: const TextStyle(
                    color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(vehiculo.placa,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(vehiculo.vehiculo),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Visitas',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  '${vehiculo.visitas}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB)),
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
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
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
                      const Text('Reporte de Vehículo',
                          style: TextStyle(color: Colors.white70)),
                      _ExportButton(
                        onTap: () => _showExportSheet(detail),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.placa,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${detail.marca} ${detail.modelo}',
                    style:
                        const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
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
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  title: 'Última Visita',
                  value: detail.ultimaVisita,
                  icon: Icons.calendar_today,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Historial
          const Text(
            '📋 Historial de Atenciones',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          if (detail.historial.isEmpty)
            const Text('No hay registros en el historial.')
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
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(VehicleHistory history) {
    Color statusColor;
    switch (history.estado.toUpperCase()) {
      case 'COMPLETADA':
        statusColor = const Color(0xFF10B981);
        break;
      case 'CANCELADA':
        statusColor = const Color(0xFFEF4444);
        break;
      case 'EN TALLER':
        statusColor = const Color(0xFF3B82F6);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(history.fecha,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Canal: ${history.canal}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            history.estado,
            style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12),
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
            Text('Exportar',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
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
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Título
          const Row(
            children: [
              Icon(Icons.download_rounded, color: Color(0xFF3B82F6), size: 22),
              SizedBox(width: 10),
              Text(
                'Exportar Reporte',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Vehículo ${widget.detail.placa} — ${widget.detail.marca} ${widget.detail.modelo}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Error
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Text(_error!,
                  style:
                      const TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
            ),

          if (_exporting)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFF3B82F6)),
                  SizedBox(height: 12),
                  Text('Generando archivo...',
                      style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          else ...[
            // PDF
            _FormatTile(
              icon: Icons.picture_as_pdf_rounded,
              color: const Color(0xFFEF4444),
              title: 'PDF',
              subtitle: 'Documento con tablas y estilos · comparte fácilmente',
              onTap: () => _export('pdf'),
            ),
            const SizedBox(height: 12),
            // CSV
            _FormatTile(
              icon: Icons.table_chart_rounded,
              color: const Color(0xFF10B981),
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
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
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
