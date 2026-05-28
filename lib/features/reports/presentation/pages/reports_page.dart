import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import '../cubit/report_cubit.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _activeTab = 'GLOBAL';
  final _tabs = [
    {'id': 'GLOBAL', 'label': 'Estadísticas Globales', 'icon': Icons.show_chart},
    {'id': 'VEHICULO', 'label': 'Por Vehículo', 'icon': Icons.directions_car},
    {'id': 'PRESUPUESTO', 'label': 'Por Presupuesto', 'icon': Icons.description},
    {'id': 'INVENTARIO', 'label': 'Por Catálogo', 'icon': Icons.inventory},
  ];

  DateTime _fechaDesde = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaHasta = DateTime.now();
  String _vehiculoPlaca = '';
  String _vehiculoMarca = '';
  String _vehiculoModelo = '';
  String _estadoCita = '';
  String _canalOrigen = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final filters = <String, dynamic>{
      'desde': DateFormat('yyyy-MM-dd').format(_fechaDesde),
      'hasta': DateFormat('yyyy-MM-dd').format(_fechaHasta),
    };

    if (_activeTab == 'VEHICULO') {
      if (_vehiculoPlaca.isNotEmpty) filters['placa'] = _vehiculoPlaca;
      if (_vehiculoMarca.isNotEmpty) filters['marca'] = _vehiculoMarca;
      if (_vehiculoModelo.isNotEmpty) filters['modelo'] = _vehiculoModelo;
      if (_estadoCita.isNotEmpty) filters['estado_cita'] = _estadoCita;
      if (_canalOrigen.isNotEmpty) filters['canal_origen'] = _canalOrigen;
    } else if (_activeTab == 'PRESUPUESTO') {
      if (_vehiculoPlaca.isNotEmpty) filters['placa'] = _vehiculoPlaca;
    }

    context.read<ReportCubit>().fetchReport(_activeTab, filters);
  }

  void _setActiveTab(String tabId) {
    setState(() {
      _activeTab = tabId;
    });
    _fetchData();
  }

  Future<void> _selectDate(BuildContext context, bool isDesde) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDesde ? _fechaDesde : _fechaHasta,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.darkCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDesde) {
          _fechaDesde = picked;
        } else {
          _fechaHasta = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Reportes y Estadísticas'),
      ),
      body: Column(
        children: [
          _buildTabs(),
          _buildFilters(),
          Expanded(
            child: BlocBuilder<ReportCubit, ReportState>(
              builder: (context, state) {
                if (state is ReportLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (state is ReportError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
                }
                if (state is ReportLoaded) {
                  final data = state.reportData.data;
                  switch (state.activeTab) {
                    case 'GLOBAL':
                      return _buildGlobalTab(data);
                    case 'VEHICULO':
                      return _buildVehiculoTab(data);
                    case 'PRESUPUESTO':
                      return _buildPresupuestoTab(data);
                    case 'INVENTARIO':
                      return _buildInventarioTab(data);
                    default:
                      return const SizedBox.shrink();
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _tabs.map((tab) {
          final isActive = _activeTab == tab['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => _setActiveTab(tab['id'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withOpacity(0.2) : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.darkCardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isActive ? AppColors.primary : AppColors.darkTextSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        color: isActive ? AppColors.primary : AppColors.darkTextSecondary,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilters() {
    final isVehiculo = _activeTab == 'VEHICULO';
    final isPresupuesto = _activeTab == 'PRESUPUESTO';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateFilter('Desde', _fechaDesde, () => _selectDate(context, true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateFilter('Hasta', _fechaHasta, () => _selectDate(context, false)),
              ),
            ],
          ),
          if (isVehiculo || isPresupuesto) const SizedBox(height: 12),
          if (isVehiculo || isPresupuesto)
            TextField(
              decoration: _inputDecoration('Placa del Vehículo (Ej. ABC-123)'),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => _vehiculoPlaca = val,
              controller: TextEditingController(text: _vehiculoPlaca)..selection = TextSelection.collapsed(offset: _vehiculoPlaca.length),
            ),
          if (isVehiculo) const SizedBox(height: 12),
          if (isVehiculo)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration('Marca (Ej. Toyota)'),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) => _vehiculoMarca = val,
                    controller: TextEditingController(text: _vehiculoMarca)..selection = TextSelection.collapsed(offset: _vehiculoMarca.length),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration('Modelo (Ej. Corolla)'),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) => _vehiculoModelo = val,
                    controller: TextEditingController(text: _vehiculoModelo)..selection = TextSelection.collapsed(offset: _vehiculoModelo.length),
                  ),
                ),
              ],
            ),
          if (isVehiculo) const SizedBox(height: 12),
          if (isVehiculo)
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Estado Cita',
                    _estadoCita,
                    ['', 'PROGRAMADA', 'EN_ESPERA_INGRESO', 'EN_PROCESO', 'FINALIZADA', 'CANCELADA', 'NO_SHOW'],
                    (val) => setState(() => _estadoCita = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    'Canal',
                    _canalOrigen,
                    ['', 'CLIENTE', 'ASESOR'],
                    (val) => setState(() => _canalOrigen = val!),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              label: const Text('Filtrar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkCardBorder),
            ),
            child: Text(
              DateFormat('dd/MM/yyyy').format(date),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.darkTextTertiary, fontSize: 14),
      filled: true,
      fillColor: AppColors.darkSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkCardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkCardBorder),
      ),
    );
  }

  Widget _buildDropdown(String hint, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      dropdownColor: AppColors.darkCard,
      decoration: _inputDecoration(hint),
      style: const TextStyle(color: Colors.white),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item.isEmpty ? 'Todos' : item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // --- REPORT TABS ---
  
  Widget _buildGlobalTab(Map<String, dynamic> data) {
    final kpis = data['kpis'] as Map<String, dynamic>? ?? {};
    final graficoIngresos = data['grafico_ingresos'] as List<dynamic>? ?? [];
    final distribucionEstados = data['distribucion_estados'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          childAspectRatio: 1.5,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildKpiCard('Ingresos Totales', '\$${(kpis['ingresos_totales'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
            _buildKpiCard('Citas Totales', '${kpis['citas_totales'] ?? 0}'),
            _buildKpiCard('Completadas / Canceladas', '${kpis['citas_completadas'] ?? 0} / ${kpis['citas_canceladas'] ?? 0}'),
            _buildKpiCard('Ticket Promedio', '\$${(kpis['ticket_promedio'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
            _buildKpiCard('Vehículos Taller', '${kpis['vehiculos_en_taller'] ?? 0}'),
            _buildKpiCard('% En Taller', '${kpis['ratio_vehiculos_en_taller_pct'] ?? 0}%'),
          ],
        ),
        const SizedBox(height: 24),
        _buildChartCard(
          'Tendencia de Ingresos',
          graficoIngresos.isEmpty ? const Center(child: Text('Sin datos', style: TextStyle(color: Colors.white))) : _buildLineChart(graficoIngresos),
        ),
        const SizedBox(height: 24),
        _buildChartCard(
          'Estado de Citas',
          distribucionEstados.isEmpty ? const Center(child: Text('Sin datos', style: TextStyle(color: Colors.white))) : _buildPieChart(distribucionEstados),
        ),
      ],
    );
  }

  Widget _buildVehiculoTab(Map<String, dynamic> data) {
    final kpis = data['kpis'] as Map<String, dynamic>? ?? {};
    final vehiculo = data['vehiculo'] as Map<String, dynamic>?;
    final historial = data['historial'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vehiculo != null) ...[
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildKpiCard('Placa', vehiculo['placa']?.toString() ?? '-'),
              _buildKpiCard('Modelo', '${vehiculo['marca']} ${vehiculo['modelo']}'),
              _buildKpiCard('Visitas', '${kpis['total_visitas'] ?? 0}'),
              _buildKpiCard('Tasa Completado', '${kpis['tasa_completado_pct'] ?? 0}%'),
              _buildKpiCard('Promedio Atención (h)', '${kpis['tiempo_promedio_atencion_horas'] ?? 'N/A'}'),
              _buildKpiCard('Detalles Resueltos', '${kpis['detalles_resueltos'] ?? 0} / ${kpis['detalles_totales'] ?? 0}'),
            ],
          ),
          const SizedBox(height: 24),
          _buildTableCard('Historial de Visitas', ['ID', 'Fecha', 'Estado'], historial.map((e) => [
            '#${e['id']}', e['fecha']?.toString() ?? '', e['estado']?.toString() ?? ''
          ]).toList()),
        ] else ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Busca una placa para ver su detalle, o sin placa para ver el top', style: TextStyle(color: AppColors.darkTextSecondary)),
            ),
          ),
          if (data['top_vehiculos'] != null)
             _buildChartCard('Top Vehículos', _buildBarChart(data['top_vehiculos'] as List<dynamic>, 'vehiculo', 'visitas')),
        ],
      ],
    );
  }

  Widget _buildPresupuestoTab(Map<String, dynamic> data) {
    final kpis = data['kpis'] as Map<String, dynamic>? ?? {};
    final funnel = data['funnel'] as List<dynamic>? ?? [];
    final porEstado = data['por_estado'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          childAspectRatio: 1.5,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildKpiCard('Total Presupuestos', '${kpis['presupuestos_total'] ?? 0}'),
            _buildKpiCard('Aprobados', '${kpis['presupuestos_aprobados'] ?? 0}'),
            _buildKpiCard('Rechazados', '${kpis['presupuestos_rechazados'] ?? 0}'),
            _buildKpiCard('Monto Total', '\$${(kpis['monto_total_presupuestado'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
            _buildKpiCard('Tasa Aprobación', '${kpis['tasa_aprobacion'] ?? 0}%'),
          ],
        ),
        const SizedBox(height: 24),
        _buildChartCard(
          'Embudo de Ventas (Funnel)',
          funnel.isEmpty ? const Center(child: Text('Sin datos', style: TextStyle(color: Colors.white))) : _buildBarChart(funnel, 'name', 'value', isHorizontal: true),
        ),
        const SizedBox(height: 24),
        _buildChartCard(
          'Distribución por Estado',
          porEstado.isEmpty ? const Center(child: Text('Sin datos', style: TextStyle(color: Colors.white))) : _buildPieChart(porEstado, nameKey: 'name'),
        ),
      ],
    );
  }

  Widget _buildInventarioTab(Map<String, dynamic> data) {
    final topServicios = data['top_servicios'] as List<dynamic>? ?? [];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChartCard(
          'Top Servicios Demandados',
          topServicios.isEmpty ? const Center(child: Text('Sin datos', style: TextStyle(color: Colors.white))) : _buildBarChart(topServicios, 'nombre', 'demanda', isHorizontal: true),
        ),
      ],
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildKpiCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildTableCard(String title, List<String> headers, List<List<String>> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: headers.map((h) => DataColumn(label: Text(h, style: const TextStyle(color: AppColors.darkTextSecondary)))).toList(),
              rows: rows.map((r) => DataRow(
                cells: r.map((c) => DataCell(Text(c, style: const TextStyle(color: Colors.white)))).toList(),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<dynamic> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final val = (data[i]['ingresos'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), val));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1)),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < data.length) {
                final dateStr = data[value.toInt()]['fecha']?.toString() ?? '';
                final parts = dateStr.split('-');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(parts.length > 2 ? '${parts[2]}/${parts[1]}' : dateStr, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 10)),
                );
              }
              return const SizedBox.shrink();
            },
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 10)),
          )),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFFd4572f),
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<dynamic> data, {String nameKey = 'name', String valueKey = 'value'}) {
    final colors = [const Color(0xFFd4572f), const Color(0xFF10203a), const Color(0xFF10b981), const Color(0xFFf59e0b), const Color(0xFF6366f1)];
    
    return PieChart(
      PieChartData(
        sections: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final value = (item[valueKey] as num?)?.toDouble() ?? 0.0;
          return PieChartSectionData(
            color: colors[index % colors.length],
            value: value,
            title: '${value.toInt()}',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> data, String nameKey, String valueKey, {bool isHorizontal = false}) {
    // Para simplificar usaremos barras verticales
    final groupData = <BarChartGroupData>[];
    double maxY = 0;
    
    for (int i = 0; i < data.length; i++) {
      final val = (data[i][valueKey] as num?)?.toDouble() ?? 0.0;
      if (val > maxY) maxY = val;
      groupData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: val,
            color: const Color(0xFF10b981),
            width: 16,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          )
        ],
      ));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1)),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < data.length) {
                final nameStr = data[value.toInt()][nameKey]?.toString() ?? '';
                final shortName = nameStr.length > 8 ? '${nameStr.substring(0, 8)}...' : nameStr;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(shortName, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 9)),
                );
              }
              return const SizedBox.shrink();
            },
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groupData,
      ),
    );
  }
}
