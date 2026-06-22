import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/report_data.dart';
import '../../data/report_catalog.dart';
import '../../data/report_export_service_explorer.dart';
import '../cubit/explorer_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class ExplorerReportsPage extends StatefulWidget {
  const ExplorerReportsPage({Key? key}) : super(key: key);

  @override
  State<ExplorerReportsPage> createState() => _ExplorerReportsPageState();
}

class _ExplorerReportsPageState extends State<ExplorerReportsPage> {
  String? _selectedGroupId;
  ReportTemplate? _selectedTemplate;
  List<String> _columnasActivas = [];
  List<ExplorerFilter> _filtros = [];

  @override
  void initState() {
    super.initState();
    _selectedGroupId = reportGroups.first.id;
    _selectTemplate(reportTemplatesByGroup[_selectedGroupId]!.first);
  }

  void _selectGroup(String groupId) {
    setState(() {
      _selectedGroupId = groupId;
      _selectTemplate(reportTemplatesByGroup[groupId]!.first);
    });
  }

  void _selectTemplate(ReportTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _columnasActivas = List.from(template.selectedColumns);
      _filtros = [ExplorerFilter()]; // Add one empty filter by default
    });
    // Trigger auto fetch
    context.read<ExplorerCubit>().loadReport(template, _columnasActivas, _filtros);
  }

  void _toggleColumn(String col) {
    setState(() {
      if (_columnasActivas.contains(col)) {
        if (_columnasActivas.length > 1) {
          _columnasActivas.remove(col);
        }
      } else {
        _columnasActivas.add(col);
      }
    });
  }

  void _addFilter() {
    setState(() {
      _filtros.add(ExplorerFilter());
    });
  }

  void _removeFilter(int index) {
    setState(() {
      _filtros.removeAt(index);
    });
  }

  void _updateFilter(int index, ExplorerFilter filter) {
    setState(() {
      _filtros[index] = filter;
    });
  }

  void _generateReport() {
    if (_selectedTemplate == null) return;
    context.read<ExplorerCubit>().loadReport(
          _selectedTemplate!,
          _columnasActivas,
          _filtros,
          chartView: context.read<ExplorerCubit>().state is ExplorerLoaded
              ? (context.read<ExplorerCubit>().state as ExplorerLoaded).chartView
              : false,
        );
  }

  String _formatHeader(String key) {
    return key.replaceAll('__', ' ').replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildConfigSection(),
        Expanded(child: _buildResultsSection()),
      ],
    );
  }

  Widget _buildConfigSection() {
    return Container(
      color: AppColors.darkBackground,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Group Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: reportGroups.map((g) {
                final isSelected = _selectedGroupId == g.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(g.shortLabel),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) _selectGroup(g.id);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // 2. Form content
          if (_selectedTemplate != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<ReportTemplate>(
                    initialValue: _selectedTemplate,
                    dropdownColor: AppColors.darkCard,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Reporte a generar',
                      labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    isExpanded: true,
                    items: reportTemplatesByGroup[_selectedGroupId]!
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.title, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) _selectTemplate(val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Columnas Visibles', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: explorerViews[_selectedTemplate!.view]!.columns.map((col) {
                      final isActive = _columnasActivas.contains(col);
                      return FilterChip(
                        label: Text(_formatHeader(col), style: TextStyle(fontSize: 11, color: isActive ? Colors.white : AppColors.darkTextSecondary)),
                        selected: isActive,
                        onSelected: (_) => _toggleColumn(col),
                        backgroundColor: AppColors.darkCard,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filtros Adicionales', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      TextButton.icon(
                        onPressed: _addFilter,
                        icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                        label: const Text('Agregar', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  ..._filtros.asMap().entries.map((entry) {
                    final index = entry.key;
                    final filter = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.darkCardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: filter.field.isEmpty ? null : filter.field,
                                    hint: const Text('Campo', style: TextStyle(color: AppColors.darkTextSecondary)),
                                    dropdownColor: AppColors.darkCard,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkCardBorder)),
                                    ),
                                    items: explorerViews[_selectedTemplate!.view]!.columns
                                        .map((c) => DropdownMenuItem(value: c, child: Text(_formatHeader(c), style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                                        .toList(),
                                    onChanged: (val) => _updateFilter(index, filter.copyWith(field: val)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: filter.operator,
                                    dropdownColor: AppColors.darkCard,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkCardBorder)),
                                    ),
                                    items: filterOperators
                                        .map((op) => DropdownMenuItem(value: op.value, child: Text(op.label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                                        .toList(),
                                    onChanged: (val) => _updateFilter(index, filter.copyWith(operator: val)),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                  onPressed: () => _removeFilter(index),
                                  padding: const EdgeInsets.only(left: 8),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            if (filter.operator != 'isnull') ...[
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: filter.value,
                                decoration: const InputDecoration(
                                  hintText: 'Valor',
                                  hintStyle: TextStyle(color: AppColors.darkTextSecondary),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkCardBorder)),
                                ),
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                onChanged: (val) => _updateFilter(index, filter.copyWith(value: val)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _generateReport,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('GENERAR REPORTE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ], // closes inner children
              ), // closes inner Column
            ), // closes Padding
        ], // closes outer children
      ), // closes outer Column
    ), // closes outer Padding
  ), // closes SingleChildScrollView
); // closes Container
}

  Widget _buildResultsSection() {
    return BlocBuilder<ExplorerCubit, ExplorerState>(
      builder: (context, state) {
        if (state is ExplorerLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExplorerError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        } else if (state is ExplorerLoaded) {
          final rows = state.reportData.data['resultados'] as List<dynamic>? ?? [];
          if (rows.isEmpty) {
            return const Center(child: Text('No se encontraron resultados para la consulta.', style: TextStyle(color: Colors.white)));
          }

          return Column(
            children: [
              Container(
                color: AppColors.darkSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${rows.length} registros encontrados',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkTextSecondary)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.table_chart, color: state.chartView ? Colors.grey : AppColors.primary),
                          tooltip: 'Vista de Tabla',
                          onPressed: () => context.read<ExplorerCubit>().toggleViewMode(false),
                        ),
                        IconButton(
                          icon: Icon(Icons.bar_chart, color: state.chartView ? AppColors.primary : Colors.grey),
                          tooltip: 'Vista de Gráfico',
                          onPressed: () => context.read<ExplorerCubit>().toggleViewMode(true),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.download, color: AppColors.primary),
                          color: AppColors.darkCard,
                          tooltip: 'Exportar Reporte',
                          onSelected: (format) async {
                            switch (format) {
                              case 'pdf':
                                await ReportExportServiceExplorer.exportPdf(state.template, state.reportData);
                                break;
                              case 'csv':
                                await ReportExportServiceExplorer.exportCsv(state.template, state.reportData);
                                break;
                              case 'excel':
                                await ReportExportServiceExplorer.exportExcel(state.template, state.reportData);
                                break;
                              case 'word':
                                await ReportExportServiceExplorer.exportWord(state.template, state.reportData);
                                break;
                              case 'html':
                                await ReportExportServiceExplorer.exportHtml(state.template, state.reportData);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'pdf', child: Text('Exportar como PDF', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: 'excel', child: Text('Exportar como Excel', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: 'csv', child: Text('Exportar como CSV', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: 'word', child: Text('Exportar como Word', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: 'html', child: Text('Exportar como HTML', style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.chartView
                    ? _buildChart(state.reportData, state.columnasActivas)
                    : _buildTable(state.reportData, state.columnasActivas),
              ),
            ],
          );
        }
        return const Center(child: Text('Seleccione un reporte y haga clic en Generar.'));
      },
    );
  }

  Widget _buildTable(ReportData data, List<String> columnas) {
    final rows = data.data['resultados'] as List<dynamic>? ?? [];
    if (rows.isEmpty) return const SizedBox();
    
    // In mobile, wide tables are tricky. We use SingleChildScrollView for both axes.
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
            dataRowMinHeight: 40,
            dataRowMaxHeight: 56,
            columns: columnas.map((col) => DataColumn(label: Text(_formatHeader(col), style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
            rows: rows.map((r) {
              final row = r as Map<String, dynamic>;
              return DataRow(
                cells: columnas.map((col) {
                  final val = row[col];
                  String text;
                  if (val == null) text = '-';
                  else if (val is bool) text = val ? 'Sí' : 'No';
                  else text = val.toString();
                  return DataCell(Text(text));
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(ReportData data, List<String> columnas) {
    final rows = data.data['resultados'] as List<dynamic>? ?? [];
    if (rows.isEmpty || columnas.length < 2) {
      return const Center(child: Text('El gráfico requiere al menos dos columnas (Categoría y Valor).'));
    }

    // Attempt to parse first column as X (label) and second column as Y (numeric value)
    final xCol = columnas[0];
    final yCol = columnas[1];

    final Map<String, double> aggregated = {};
    for (var r in rows) {
      final row = r as Map<String, dynamic>;
      final xVal = row[xCol]?.toString() ?? 'N/A';
      final yRaw = row[yCol];
      
      double yVal = 0;
      if (yRaw is num) yVal = yRaw.toDouble();
      else if (yRaw is String) yVal = double.tryParse(yRaw) ?? 1; // Default to 1 for counting
      else yVal = 1;

      aggregated[xVal] = (aggregated[xVal] ?? 0) + yVal;
    }

    final barGroups = <BarChartGroupData>[];
    int i = 0;
    double maxY = 0;
    final labels = <String>[];
    aggregated.forEach((key, value) {
      if (value > maxY) maxY = value;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: AppColors.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
      labels.add(key);
      i++;
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${labels[group.x]}\n${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                    final label = labels[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        label.length > 10 ? '${label.substring(0, 10)}...' : label,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
