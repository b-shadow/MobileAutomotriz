import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import '../cubit/ia_report_cubit.dart';
import '../../data/models/ia_report_result.dart';
import '../../data/report_export_service_ia.dart';

// ─────────────────────────────────────────────────────────────────────────────

class _QuickReport {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String prompt;

  const _QuickReport({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.prompt,
  });
}

const _quickReports = <_QuickReport>[
  _QuickReport(
    title: 'Ingresos del Mes',
    description: 'Total facturado por día',
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF10B981),
    prompt: '¿Cuáles son los ingresos totales agrupados por día de este mes en un gráfico de barras?',
  ),
  _QuickReport(
    title: 'Servicios Rentables',
    description: 'Top 5 que más generan',
    icon: Icons.trending_up_rounded,
    color: Color(0xFF3B82F6),
    prompt: '¿Cuáles son los servicios más rentables este mes?',
  ),
  _QuickReport(
    title: 'Estado de Citas',
    description: 'Completadas vs Canceladas',
    icon: Icons.event_available_rounded,
    color: Color(0xFF8B5CF6),
    prompt: 'Muéstrame la cantidad de citas agrupadas por estado en un gráfico circular',
  ),
  _QuickReport(
    title: 'Mejores Clientes',
    description: 'Clientes con más visitas',
    icon: Icons.people_rounded,
    color: Color(0xFFF59E0B),
    prompt: 'Lista los 5 clientes con más citas finalizadas en el sistema',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class IaReportsPage extends StatefulWidget {
  const IaReportsPage({super.key});

  @override
  State<IaReportsPage> createState() => _IaReportsPageState();
}

class _IaReportsPageState extends State<IaReportsPage> {
  final TextEditingController _promptController = TextEditingController();
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String _viewMode = 'chart'; // 'chart' or 'data'

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _submitPrompt(String prompt) {
    if (prompt.trim().isEmpty) return;
    _promptController.text = prompt;
    context.read<IaReportCubit>().ask(prompt.trim());
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/report_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: path,
        );

        setState(() {
          _isRecording = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permiso de micrófono denegado'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null && mounted) {
        // Transcribe only — don't auto-ask so user can review
        context.read<IaReportCubit>().transcribe(path);
      }
    } catch (e) {
      debugPrint('Error stopping record: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IaReportCubit, IaReportState>(
      listener: (context, state) {
        if (state is IaReportTranscribed) {
          _promptController.text = state.text;
        }
        if (state is IaReportLoaded) {
          // Auto-select best view mode
          if (state.result.hasChart) {
            setState(() => _viewMode = 'chart');
          } else if (state.result.hasData) {
            setState(() => _viewMode = 'data');
          }
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reportes con IA',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Consulta tus datos con lenguaje natural o por voz',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Omnibox ─────────────────────────────────
              _buildOmnibox(state),

              const SizedBox(height: 20),

              // ── Quick Reports ───────────────────────────
              if (state is IaReportInitial || state is IaReportTranscribed) ...[
                Text(
                  'Reportes Rápidos',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                _buildQuickReports(),
                const SizedBox(height: 20),
              ],

              // ── Results ────────────────────────────────
              if (state is IaReportLoading) _buildLoading(),
              if (state is IaReportTranscribing) _buildTranscribing(),
              if (state is IaReportError) _buildError(state.message),
              if (state is IaReportLoaded) _buildResults(state.result, state.prompt),
            ],
          ),
        );
      },
    );
  }

  // ── Omnibox ───────────────────────────────────────────────────────────────

  Widget _buildOmnibox(IaReportState state) {
    final isProcessing = state is IaReportLoading || state is IaReportTranscribing;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            const Color(0xFF6366F1).withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // AI icon
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: _promptController,
              enabled: !isProcessing,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: _isRecording
                    ? 'Escuchando...'
                    : 'Ej: Muéstrame los ingresos del mes',
                hintStyle: TextStyle(
                  color: _isRecording
                      ? AppColors.error
                      : Colors.white.withValues(alpha: 0.3),
                  fontStyle: _isRecording ? FontStyle.italic : FontStyle.normal,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (text) => _submitPrompt(text),
            ),
          ),

          // Send button
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: Material(
              color: isProcessing
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: isProcessing
                    ? null
                    : () => _submitPrompt(_promptController.text),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white54,
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),

          // Mic button
          const SizedBox(width: 4),
          GestureDetector(
            onTapDown: (_) => isProcessing ? null : _startRecording(),
            onTapUp: (_) => isProcessing ? null : _stopRecording(),
            onTapCancel: () => isProcessing ? null : _stopRecording(),
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: _isRecording
                    ? AppColors.error
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                _isRecording ? Icons.mic_off : Icons.mic,
                color: _isRecording ? Colors.white : AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Reports Grid ─────────────────────────────────────────────────────

  Widget _buildQuickReports() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      childAspectRatio: 1.6,
      physics: const NeverScrollableScrollPhysics(),
      children: _quickReports.map((qr) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _submitPrompt(qr.prompt),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: qr.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: qr.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: qr.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(qr.icon, size: 18, color: qr.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    qr.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    qr.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── State Widgets ─────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Generando reporte con IA...',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscribing() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.mic, size: 48, color: AppColors.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text(
            'Transcribiendo audio...',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Results ───────────────────────────────────────────────────────────────

  Widget _buildResults(IaReportResult result, String prompt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt echo
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prompt,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // View mode toggle & export
        Row(
          children: [
            // Chart / Data toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _viewToggleButton('chart', Icons.bar_chart_rounded, 'Gráfico', result.hasChart),
                  _viewToggleButton('data', Icons.table_chart_rounded, 'Datos', result.hasData),
                ],
              ),
            ),

            const Spacer(),

            // Export buttons
            if (result.hasData) ...[
              _exportButton(Icons.picture_as_pdf, 'PDF', () => _exportPdf(result)),
              const SizedBox(width: 6),
              _exportButton(Icons.description, 'CSV', () => _exportCsv(result)),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Content
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkCardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: _viewMode == 'chart' && result.hasChart
              ? _buildChart(result)
              : result.hasData
                  ? _buildDataTable(result)
                  : _buildNoData(),
        ),

        const SizedBox(height: 12),

        // SQL Debug
        if (result.sql != null && result.sql!.isNotEmpty) _buildSqlDebug(result.sql!),
      ],
    );
  }

  Widget _viewToggleButton(String mode, IconData icon, String label, bool enabled) {
    final isActive = _viewMode == mode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () => setState(() => _viewMode = mode)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: isActive ? AppColors.primary : Colors.white54),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.primary : Colors.white54,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _exportButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Chart ─────────────────────────────────────────────────────────────────

  Widget _buildChart(IaReportResult result) {
    final plotly = result.plotlyFig!;
    final traces = plotly['data'] as List<dynamic>? ?? [];

    if (traces.isEmpty) return _buildNoData();

    final firstTrace = traces.first as Map<String, dynamic>;
    final traceType = (firstTrace['type'] as String?)?.toLowerCase() ?? 'bar';

    Widget chart;

    if (traceType == 'pie') {
      chart = _buildPieFromPlotly(traces);
    } else if (traceType == 'scatter' || traceType == 'line') {
      chart = _buildLineFromPlotly(traces);
    } else {
      chart = _buildBarFromPlotly(traces);
    }

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: chart,
      ),
    );
  }

  Widget _buildBarFromPlotly(List<dynamic> traces) {
    final trace = traces.first as Map<String, dynamic>;
    final xVals = (trace['x'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final yVals = (trace['y'] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble() ?? 0.0).toList() ?? [];

    if (xVals.isEmpty) return _buildNoData();

    double maxY = 0;
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < yVals.length; i++) {
      if (yVals[i] > maxY) maxY = yVals[i];
      groups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: yVals[i],
            color: AppColors.primary,
            width: 14,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < xVals.length) {
                  final label = xVals[idx];
                  final shortLabel = label.length > 6 ? '${label.substring(0, 6)}..' : label;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(shortLabel, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 9)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 10),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
    );
  }

  Widget _buildLineFromPlotly(List<dynamic> traces) {
    final trace = traces.first as Map<String, dynamic>;
    final yVals = (trace['y'] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble() ?? 0.0).toList() ?? [];

    if (yVals.isEmpty) return _buildNoData();

    final spots = <FlSpot>[];
    for (int i = 0; i < yVals.length; i++) {
      spots.add(FlSpot(i.toDouble(), yVals[i]));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildPieFromPlotly(List<dynamic> traces) {
    final trace = traces.first as Map<String, dynamic>;
    final labels = (trace['labels'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final values = (trace['values'] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble() ?? 0.0).toList() ?? [];

    if (labels.isEmpty) return _buildNoData();

    final colors = [
      const Color(0xFFd4572f),
      const Color(0xFF10203a),
      const Color(0xFF10b981),
      const Color(0xFFf59e0b),
      const Color(0xFF6366f1),
      const Color(0xFF8B5CF6),
      const Color(0xFFF43F5E),
    ];

    return PieChart(
      PieChartData(
        sections: List.generate(labels.length, (i) {
          return PieChartSectionData(
            color: colors[i % colors.length],
            value: values[i],
            title: labels[i].length > 10
                ? '${labels[i].substring(0, 10)}..'
                : labels[i],
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            radius: 60,
          );
        }),
      ),
    );
  }

  // ── Data Table ─────────────────────────────────────────────────────────────

  Widget _buildDataTable(IaReportResult result) {
    final rows = result.data;
    if (rows.isEmpty) return _buildNoData();

    final keys = rows.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          Colors.white.withValues(alpha: 0.04),
        ),
        columns: keys.map((k) {
          return DataColumn(
            label: Text(
              k.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: keys.map((k) {
              final val = row[k];
              return DataCell(
                Text(
                  val != null ? val.toString() : '-',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  // ── No Data ───────────────────────────────────────────────────────────────

  Widget _buildNoData() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storage_rounded, size: 48, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 12),
            Text(
              'No se encontraron datos para esta consulta',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── SQL Debug ─────────────────────────────────────────────────────────────

  Widget _buildSqlDebug(String sql) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(Icons.code, size: 18, color: Colors.white.withValues(alpha: 0.4)),
          title: Text(
            'Ver Consulta SQL Generada (Debug)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                sql,
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Export ─────────────────────────────────────────────────────────────────

  Future<void> _exportPdf(IaReportResult result) async {
    try {
      await IaReportExportService.exportPdf(result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _exportCsv(IaReportResult result) async {
    try {
      await IaReportExportService.exportCsv(result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar CSV: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
