import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile1_app/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Formatting helpers
// ─────────────────────────────────────────────────────────────────────────────

final _currencyFmt = NumberFormat.currency(
  locale: 'es_BO',
  symbol: 'Bs.',
  decimalDigits: 2,
);

final _numberFmt = NumberFormat('#,###', 'es_BO');

String _formatValue(dynamic value, String? format) {
  if (value == null) return '-';
  if (format == 'currency') {
    return _currencyFmt.format(num.tryParse(value.toString()) ?? 0);
  }
  if (format == 'percent') {
    return '${value}%';
  }
  if (value is num) {
    if (value == value.toInt()) return _numberFmt.format(value.toInt());
    return value.toStringAsFixed(2);
  }
  return value.toString();
}

String _prettifyKey(String? text) {
  if (text == null || text.isEmpty) return '';
  return text
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
      .join(' ');
}

// ─────────────────────────────────────────────────────────────────────────────
// Chart colors (matching frontend)
// ─────────────────────────────────────────────────────────────────────────────

const _chartColors = [
  Color(0xFFD4572F),
  Color(0xFF10203A),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFF6366F1),
  Color(0xFFEF4444),
  Color(0xFF8B5CF6),
  Color(0xFF00D9FF),
];

// ─────────────────────────────────────────────────────────────────────────────
// Tone → Color mapping
// ─────────────────────────────────────────────────────────────────────────────

Color _toneColor(String? tone) {
  return switch (tone) {
    'success' => AppColors.success,
    'warning' => AppColors.warning,
    'danger' => AppColors.error,
    _ => AppColors.primary,
  };
}

Color _toneBgColor(String? tone) {
  return switch (tone) {
    'success' => AppColors.successLight,
    'warning' => AppColors.warningLight,
    'danger' => AppColors.errorLight,
    _ => AppColors.primary.withValues(alpha: 0.12),
  };
}

IconData _toneIcon(String? tone) {
  return switch (tone) {
    'success' => Icons.check_circle_outline_rounded,
    'warning' => Icons.warning_amber_rounded,
    'danger' => Icons.error_outline_rounded,
    _ => Icons.insights_rounded,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI Card
// ─────────────────────────────────────────────────────────────────────────────

class DashboardKpiCard extends StatelessWidget {
  final Map<String, dynamic> kpi;

  const DashboardKpiCard({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    final label = kpi['label'] as String? ?? _prettifyKey(kpi['key'] as String?);
    final value = kpi['value'];
    final format = kpi['format'] as String?;
    final tone = kpi['tone'] as String?;

    final color = _toneColor(tone);
    final bgColor = _toneBgColor(tone);
    final icon = _toneIcon(tone);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatValue(value, format),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI Summary Grid
// ─────────────────────────────────────────────────────────────────────────────

class DashboardKpiSummaryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> kpis;
  final String? rol;

  const DashboardKpiSummaryGrid({
    super.key,
    required this.kpis,
    this.rol,
  });

  @override
  Widget build(BuildContext context) {
    if (kpis.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.accent.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen Ejecutivo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (rol != null)
                      Text(
                        'KPIs del rol $rol',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 0.2,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
            ),
            itemCount: kpis.length,
            itemBuilder: (context, index) =>
                DashboardKpiCard(kpi: kpis[index]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Chart (fl_chart)
// ─────────────────────────────────────────────────────────────────────────────

class DashboardChartWidget extends StatelessWidget {
  final Map<String, dynamic> chart;

  const DashboardChartWidget({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    final data = (chart['data'] as List<dynamic>?) ?? [];
    if (data.isEmpty) {
      return _EmptyChartPlaceholder(title: chart['title'] as String? ?? '');
    }

    final type = chart['type'] as String? ?? 'bar';
    final title = chart['title'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: switch (type) {
              'pie' => _buildPieChart(data),
              'line' => _buildLineChart(data),
              _ => _buildBarChart(data),
            },
          ),
          if (type == 'pie') ...[
            const SizedBox(height: 12),
            _buildPieLegend(data),
          ],
        ],
      ),
    );
  }

  Widget _buildPieChart(List<dynamic> data) {
    final items = data.take(8).toList();
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: List.generate(items.length, (i) {
          final item = items[i] as Map;
          final value = (num.tryParse(item['value'].toString()) ?? 0).toDouble();
          return PieChartSectionData(
            value: value,
            color: _chartColors[i % _chartColors.length],
            radius: 50,
            showTitle: false,
          );
        }),
      ),
    );
  }

  Widget _buildPieLegend(List<dynamic> data) {
    final items = data.take(8).toList();
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: List.generate(items.length, (i) {
        final item = items[i] as Map;
        final name = (item['name'] ?? '').toString();
        final value = item['value']?.toString() ?? '0';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _chartColors[i % _chartColors.length],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$name ($value)',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBarChart(List<dynamic> data) {
    final xKey = chart['xKey'] as String? ?? 'name';
    final yKey = chart['yKey'] as String? ?? 'value';
    final series = (chart['series'] as List<dynamic>?) ?? [];
    final items = data.take(10).toList();

    if (series.isNotEmpty) {
      return _buildGroupedBarChart(items, xKey, series);
    }

    final maxVal = items.fold<double>(0, (prev, e) {
      final v = (num.tryParse((e as Map)[yKey].toString()) ?? 0).toDouble();
      return v > prev ? v : prev;
    });

    return BarChart(
      BarChartData(
        maxY: maxVal > 0 ? maxVal * 1.15 : 10,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = items[groupIndex] as Map;
              final label = (item[xKey] ?? '').toString();
              return BarTooltipItem(
                '$label\n${rod.toY.toStringAsFixed(0)}',
                const TextStyle(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= items.length) {
                  return const SizedBox.shrink();
                }
                final label = ((items[idx] as Map)[xKey] ?? '').toString();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label.length > 8 ? '${label.substring(0, 8)}…' : label,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(items.length, (i) {
          final item = items[i] as Map;
          final v = (num.tryParse(item[yKey].toString()) ?? 0).toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: v,
                color: _chartColors[i % _chartColors.length],
                width: items.length > 6 ? 12 : 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildGroupedBarChart(
    List<dynamic> items,
    String xKey,
    List<dynamic> series,
  ) {
    double maxVal = 0;
    for (final item in items) {
      for (final s in series) {
        final key = (s as Map)['key'] as String;
        final v = (num.tryParse((item as Map)[key]?.toString() ?? '0') ?? 0)
            .toDouble();
        if (v > maxVal) maxVal = v;
      }
    }

    return BarChart(
      BarChartData(
        maxY: maxVal > 0 ? maxVal * 1.15 : 10,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= items.length) {
                  return const SizedBox.shrink();
                }
                final label = ((items[idx] as Map)[xKey] ?? '').toString();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label.length > 6 ? '${label.substring(0, 6)}…' : label,
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(items.length, (i) {
          final item = items[i] as Map;
          final rods = <BarChartRodData>[];
          for (int s = 0; s < series.length; s++) {
            final key = (series[s] as Map)['key'] as String;
            final v =
                (num.tryParse(item[key]?.toString() ?? '0') ?? 0).toDouble();
            rods.add(BarChartRodData(
              toY: v,
              color: _chartColors[s % _chartColors.length],
              width: series.length > 2 ? 8 : 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ));
          }
          return BarChartGroupData(x: i, barRods: rods);
        }),
      ),
    );
  }

  Widget _buildLineChart(List<dynamic> data) {
    final xKey = chart['xKey'] as String? ?? 'name';
    final series = (chart['series'] as List<dynamic>?) ?? [];
    final items = data.take(30).toList();

    if (series.isEmpty) {
      final yKey = chart['yKey'] as String? ?? 'value';
      final spots = <FlSpot>[];
      for (int i = 0; i < items.length; i++) {
        final v =
            (num.tryParse((items[i] as Map)[yKey]?.toString() ?? '0') ?? 0)
                .toDouble();
        spots.add(FlSpot(i.toDouble(), v));
      }

      return LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(show: spots.length <= 10),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
          titlesData: _lineChartTitles(items, xKey),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      );
    }

    // Multi-series
    final lines = <LineChartBarData>[];
    for (int s = 0; s < series.length; s++) {
      final key = (series[s] as Map)['key'] as String;
      final spots = <FlSpot>[];
      for (int i = 0; i < items.length; i++) {
        final v =
            (num.tryParse((items[i] as Map)[key]?.toString() ?? '0') ?? 0)
                .toDouble();
        spots.add(FlSpot(i.toDouble(), v));
      }
      lines.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: _chartColors[s % _chartColors.length],
        barWidth: 3,
        dotData: FlDotData(show: spots.length <= 10),
        belowBarData: BarAreaData(
          show: true,
          color: _chartColors[s % _chartColors.length].withValues(alpha: 0.06),
        ),
      ));
    }

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              lineBarsData: lines,
              titlesData: _lineChartTitles(items, xKey),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.05),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: List.generate(series.length, (i) {
            final s = series[i] as Map;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _chartColors[i % _chartColors.length],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  s['label'] as String? ?? s['key'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  FlTitlesData _lineChartTitles(List<dynamic> items, String xKey) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: items.length > 8 ? (items.length / 5).ceilToDouble() : 1,
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= items.length) {
              return const SizedBox.shrink();
            }
            final label = ((items[idx] as Map)[xKey] ?? '').toString();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                label.length > 7 ? '${label.substring(0, 7)}…' : label,
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}

class _EmptyChartPlaceholder extends StatelessWidget {
  final String title;

  const _EmptyChartPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Sin datos para mostrar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Table
// ─────────────────────────────────────────────────────────────────────────────

class DashboardTableWidget extends StatelessWidget {
  final Map<String, dynamic> table;

  const DashboardTableWidget({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    final title = table['title'] as String? ?? '';
    final columns = (table['columns'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final rows = (table['rows'] as List<dynamic>?) ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Sin registros',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 40,
                columnSpacing: 16,
                horizontalMargin: 8,
                headingTextStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
                dataTextStyle: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                columns: columns
                    .map((col) => DataColumn(label: Text(col)))
                    .toList(),
                rows: rows.take(8).map((row) {
                  final rowMap = row as Map;
                  return DataRow(
                    cells: rowMap.values
                        .map(
                          (v) => DataCell(
                            Text(
                              v?.toString() ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Section (collapsible)
// ─────────────────────────────────────────────────────────────────────────────

class DashboardSectionWidget extends StatefulWidget {
  final Map<String, dynamic> section;
  final bool initiallyExpanded;

  const DashboardSectionWidget({
    super.key,
    required this.section,
    this.initiallyExpanded = false,
  });

  @override
  State<DashboardSectionWidget> createState() => _DashboardSectionWidgetState();
}

class _DashboardSectionWidgetState extends State<DashboardSectionWidget> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.section['title'] as String? ?? '';
    final description = widget.section['description'] as String? ?? '';
    final kpis = (widget.section['kpis'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    final charts = (widget.section['charts'] as List<dynamic>?) ?? [];
    final tables = (widget.section['tables'] as List<dynamic>?) ?? [];

    final totalItems = kpis.length + charts.length + tables.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        size: 20,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _expanded
                                  ? Colors.white
                                  : Colors.white70,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description.isNotEmpty
                                ? description
                                : '$totalItems indicadores',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // KPIs grid
                  if (kpis.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: kpis.length,
                      itemBuilder: (context, index) =>
                          DashboardKpiCard(kpi: kpis[index]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Charts
                  ...charts.map((chart) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DashboardChartWidget(
                          chart: Map<String, dynamic>.from(chart as Map),
                        ),
                      )),

                  // Tables
                  ...tables.map((table) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DashboardTableWidget(
                          table: Map<String, dynamic>.from(table as Map),
                        ),
                      )),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer loading placeholder
// ─────────────────────────────────────────────────────────────────────────────

class DashboardKpiShimmer extends StatefulWidget {
  const DashboardKpiShimmer({super.key});

  @override
  State<DashboardKpiShimmer> createState() => _DashboardKpiShimmerState();
}

class _DashboardKpiShimmerState extends State<DashboardKpiShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.03, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title shimmer
              Container(
                width: 180,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 120,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 16),
              // KPI cards shimmer
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: List.generate(
                  4,
                  (_) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
