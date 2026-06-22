/// Report catalog — Dart port of the frontend's reportCatalog.js.
///
/// Contains report groups, explorer views (with available columns),
/// report templates with default filters, and quick AI reports.

// ── Report Groups ─────────────────────────────────────────────────────────

class ReportGroup {
  final String id;
  final String label;
  final String shortLabel;
  final String description;

  const ReportGroup({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.description,
  });
}

const reportGroups = <ReportGroup>[
  ReportGroup(
    id: 'global',
    label: 'Reporte global de estadísticas',
    shortLabel: 'Global',
    description: 'Consultas operativas y consolidadas del taller.',
  ),
  ReportGroup(
    id: 'vehiculo',
    label: 'Reporte de vehículo',
    shortLabel: 'Vehículo',
    description: 'Historiales, citas, servicios y trazabilidad por vehículo.',
  ),
  ReportGroup(
    id: 'presupuesto',
    label: 'Reporte de presupuesto',
    shortLabel: 'Presupuesto',
    description: 'Presupuestos, caja y pagos asociados.',
  ),
  ReportGroup(
    id: 'inventario',
    label: 'Reporte de inventario',
    shortLabel: 'Inventario',
    description: 'Inventario, compras y solicitudes de repuesto.',
  ),
];

// ── Column Sets ───────────────────────────────────────────────────────────

const _vehiculosColumns = [
  'id', 'placa', 'marca', 'modelo', 'anio', 'color',
  'kilometraje_actual', 'propietario__email', 'created_at',
];

const _citasColumns = [
  'id', 'estado', 'canal_origen', 'fecha_hora_inicio_programada',
  'fecha_hora_fin_programada', 'motivo_visita', 'vehiculo__placa',
  'vehiculo__marca', 'vehiculo__modelo', 'cliente__email',
  'asesor_responsable__email', 'reprogramaciones_count',
  'created_at', 'finalizada_at', 'vehiculo_devuelto_at',
];

const _citaDetallesColumns = [
  'id', 'cita__id', 'cita__vehiculo__placa',
  'servicio_catalogo__codigo', 'servicio_catalogo__nombre',
  'estado', 'tiempo_estandar_min', 'precio_referencial',
  'observaciones', 'created_at',
];

const _planesDetalleColumns = [
  'id', 'plan_servicio__vehiculo__placa',
  'servicio_catalogo__codigo', 'servicio_catalogo__nombre',
  'estado', 'origen', 'prioridad', 'tiempo_estandar_min',
  'precio_referencial', 'recomendado_por__email',
  'created_at', 'updated_at',
];

const _presupuestosColumns = [
  'id', 'estado', 'subtotal', 'descuento', 'total',
  'cita__id', 'cita__vehiculo__placa', 'cita__vehiculo__marca',
  'cita__vehiculo__modelo', 'cita__cliente__email',
  'cita__asesor_responsable__email', 'comunicado_por__email',
  'comunicado_at', 'observaciones', 'created_at', 'updated_at',
];

const _ordenesGlobalesColumns = [
  'id', 'numero', 'estado', 'cita__vehiculo__placa',
  'cita__vehiculo__marca', 'cita__cliente__email',
  'asesor_responsable__email', 'observaciones',
  'fecha_apertura', 'fecha_cierre', 'created_at',
];

const _ordenesDetalleColumns = [
  'id', 'orden_global__numero', 'orden_global__cita__vehiculo__placa',
  'servicio_catalogo__nombre', 'estado', 'prioridad',
  'mecanico_asignado__email', 'tiempo_estandar_min',
  'tiempo_real_min', 'visible_cliente',
  'inicio_real', 'fin_real', 'created_at',
];

const _recepcionesColumns = [
  'id', 'cita__id', 'cita__vehiculo__placa',
  'cita__vehiculo__marca', 'cita__vehiculo__modelo',
  'asesor_registra__email', 'fecha_recepcion',
  'kilometraje_ingreso', 'nivel_combustible',
  'fecha_recogida', 'recogido_por__email', 'created_at',
];

const _avancesColumns = [
  'id', 'cita__id', 'cita__vehiculo__placa',
  'orden_detalle__id', 'registrado_por__email',
  'tipo', 'estado_nuevo', 'mensaje',
  'porcentaje_avance', 'visible_cliente', 'created_at',
];

const _pagosColumns = [
  'id', 'tipo_origen', 'tipo_destino', 'id_destino',
  'estado', 'proveedor', 'metodo_pago',
  'monto_total', 'monto_real', 'monto_cobrado',
  'referencia', 'descripcion', 'cita__vehiculo__placa',
  'venta__id', 'registrado_por__email',
  'fecha_pago', 'recibido_at', 'created_at',
];

const _itemsColumns = [
  'id', 'codigo', 'nombre', 'categoria__nombre',
  'tipo_item', 'unidad_medida', 'stock_actual',
  'stock_minimo', 'costo_promedio', 'precio_venta',
  'activo', 'created_at',
];

const _movimientosColumns = [
  'id', 'item_inventario__codigo', 'item_inventario__nombre',
  'tipo_movimiento', 'cantidad', 'stock_anterior',
  'stock_posterior', 'referencia_tipo', 'referencia_id',
  'registrado_por__email', 'observacion', 'created_at',
];

const _solicitudesColumns = [
  'id', 'cita__id', 'cita__vehiculo__placa',
  'orden_global__numero', 'solicitado_por__email',
  'aprobado_por_asesor__email', 'estado', 'motivo',
  'observaciones_asesor', 'observaciones_almacen',
  'created_at', 'updated_at',
];

const _solicitudesDetalleColumns = [
  'id', 'solicitud__id', 'solicitud__cita__vehiculo__placa',
  'item_inventario__codigo', 'item_inventario__nombre',
  'cantidad_solicitada', 'cantidad_aprobada',
  'cantidad_entregada', 'cantidad_recibida_taller',
  'estado', 'recibido_taller_at', 'recibido_taller_por__email',
  'observacion', 'created_at',
];

const _comprasColumns = [
  'id', 'numero_documento', 'estado', 'proveedor__nombre',
  'subtotal', 'total', 'fecha_compra',
  'registrado_por__email', 'observaciones', 'created_at',
];

const _proveedoresColumns = [
  'id', 'nombre', 'telefono', 'email',
  'direccion', 'contacto', 'activo', 'created_at',
];

const _ventasColumns = [
  'id', 'cliente_nombre_libre', 'cliente_documento',
  'cliente_usuario__email', 'vendido_por__email',
  'estado', 'subtotal', 'total', 'created_at',
];

const _usuariosColumns = [
  'id', 'email', 'nombres', 'apellidos',
  'is_active', 'rol__nombre', 'created_at',
];

// ── Explorer Views ────────────────────────────────────────────────────────

class ExplorerView {
  final String label;
  final List<String> columns;

  const ExplorerView({required this.label, required this.columns});
}

const explorerViews = <String, ExplorerView>{
  'vehiculos_citas': ExplorerView(label: 'Vehículos con sus citas', columns: _citasColumns),
  'citas_servicios': ExplorerView(label: 'Citas con servicios', columns: _citaDetallesColumns),
  'vehiculos': ExplorerView(label: 'Vehículos', columns: _vehiculosColumns),
  'citas': ExplorerView(label: 'Citas', columns: _citasColumns),
  'cita_detalles': ExplorerView(label: 'Detalles de cita', columns: _citaDetallesColumns),
  'planes_detalle': ExplorerView(label: 'Servicios del plan', columns: _planesDetalleColumns),
  'presupuestos': ExplorerView(label: 'Presupuestos', columns: _presupuestosColumns),
  'pagos_taller': ExplorerView(label: 'Pagos de taller', columns: _pagosColumns),
  'ordenes_globales': ExplorerView(label: 'Órdenes de trabajo', columns: _ordenesGlobalesColumns),
  'ordenes_detalle': ExplorerView(label: 'Servicios en órdenes de trabajo', columns: _ordenesDetalleColumns),
  'recepciones': ExplorerView(label: 'Recepciones de vehículo', columns: _recepcionesColumns),
  'avances': ExplorerView(label: 'Avances de vehículo', columns: _avancesColumns),
  'usuarios': ExplorerView(label: 'Usuarios', columns: _usuariosColumns),
  'ventas': ExplorerView(label: 'Ventas de mostrador', columns: _ventasColumns),
  'compras': ExplorerView(label: 'Compras', columns: _comprasColumns),
  'proveedores': ExplorerView(label: 'Proveedores', columns: _proveedoresColumns),
  'items_inventario': ExplorerView(label: 'Items de inventario', columns: _itemsColumns),
  'movimientos_inventario': ExplorerView(label: 'Movimientos de inventario', columns: _movimientosColumns),
  'solicitudes_repuesto': ExplorerView(label: 'Solicitudes de repuesto', columns: _solicitudesColumns),
  'solicitudes_repuesto_detalle': ExplorerView(label: 'Items de solicitudes de repuesto', columns: _solicitudesDetalleColumns),
  'vehiculos_en_taller': ExplorerView(label: 'Vehículos en taller', columns: _citasColumns),
  'items_stock_bajo': ExplorerView(label: 'Items con stock bajo', columns: _itemsColumns),
  'solicitudes_repuesto_activas': ExplorerView(label: 'Solicitudes de repuesto activas', columns: _solicitudesColumns),
  'solicitudes_detalle_pendientes': ExplorerView(label: 'Items pendientes de entrega', columns: _solicitudesDetalleColumns),
};

// ── Report Templates ──────────────────────────────────────────────────────

class ReportTemplate {
  final String group;
  final String id;
  final String title;
  final String view;
  final List<String> selectedColumns;
  final Map<String, dynamic> defaultFilters;
  final String description;

  const ReportTemplate({
    required this.group,
    required this.id,
    required this.title,
    required this.view,
    required this.selectedColumns,
    this.defaultFilters = const {},
    this.description = '',
  });
}

// ── Global Templates ──

const _globalTemplates = <ReportTemplate>[
  ReportTemplate(group: 'global', id: 'global_historial_citas', title: 'Historial general de citas', view: 'citas', selectedColumns: ['id', 'estado', 'fecha_hora_inicio_programada', 'vehiculo__placa', 'cliente__email', 'canal_origen']),
  ReportTemplate(group: 'global', id: 'global_vehiculos_con_citas', title: 'Vehículos con sus citas', view: 'vehiculos_citas', selectedColumns: ['vehiculo__placa', 'vehiculo__marca', 'vehiculo__modelo', 'estado', 'fecha_hora_inicio_programada', 'motivo_visita']),
  ReportTemplate(group: 'global', id: 'global_historial_presupuestos', title: 'Historial general de presupuestos', view: 'presupuestos', selectedColumns: ['id', 'estado', 'total', 'cita__vehiculo__placa', 'cita__cliente__email', 'created_at']),
  ReportTemplate(group: 'global', id: 'global_historial_pagos', title: 'Historial general de pagos', view: 'pagos_taller', selectedColumns: ['id', 'estado', 'metodo_pago', 'monto_total', 'cita__vehiculo__placa', 'created_at']),
  ReportTemplate(group: 'global', id: 'global_historial_ordenes', title: 'Historial general de órdenes de trabajo', view: 'ordenes_globales', selectedColumns: ['numero', 'estado', 'cita__vehiculo__placa', 'asesor_responsable__email', 'fecha_apertura']),
  ReportTemplate(group: 'global', id: 'global_historial_servicios_orden', title: 'Historial general de servicios en órdenes', view: 'ordenes_detalle', selectedColumns: ['orden_global__numero', 'servicio_catalogo__nombre', 'estado', 'prioridad', 'mecanico_asignado__email']),
  ReportTemplate(group: 'global', id: 'global_historial_recepciones', title: 'Historial general de recepciones', view: 'recepciones', selectedColumns: ['cita__vehiculo__placa', 'asesor_registra__email', 'fecha_recepcion', 'kilometraje_ingreso', 'fecha_recogida']),
  ReportTemplate(group: 'global', id: 'global_historial_avances', title: 'Historial general de avances de vehículo', view: 'avances', selectedColumns: ['cita__vehiculo__placa', 'tipo', 'estado_nuevo', 'porcentaje_avance', 'visible_cliente', 'created_at']),
  ReportTemplate(group: 'global', id: 'global_historial_solicitudes', title: 'Historial general de solicitudes de repuesto', view: 'solicitudes_repuesto', selectedColumns: ['cita__vehiculo__placa', 'estado', 'solicitado_por__email', 'aprobado_por_asesor__email', 'created_at']),
  ReportTemplate(group: 'global', id: 'global_historial_items_solicitados', title: 'Historial general de items solicitados', view: 'solicitudes_repuesto_detalle', selectedColumns: ['solicitud__cita__vehiculo__placa', 'item_inventario__nombre', 'cantidad_solicitada', 'estado', 'created_at']),
  ReportTemplate(group: 'global', id: 'global_historial_compras', title: 'Historial general de compras', view: 'compras', selectedColumns: ['numero_documento', 'estado', 'proveedor__nombre', 'total', 'fecha_compra', 'registrado_por__email']),
  ReportTemplate(group: 'global', id: 'global_historial_ventas', title: 'Historial general de ventas de mostrador', view: 'ventas', selectedColumns: ['id', 'estado', 'cliente_nombre_libre', 'vendido_por__email', 'total', 'created_at']),
  ReportTemplate(group: 'global', id: 'global_historial_movimientos', title: 'Historial general de movimientos de inventario', view: 'movimientos_inventario', selectedColumns: ['item_inventario__nombre', 'tipo_movimiento', 'cantidad', 'stock_posterior', 'registrado_por__email', 'created_at']),
  ReportTemplate(group: 'global', id: 'global_citas_canceladas', title: 'Listado general de citas canceladas', view: 'citas', selectedColumns: ['id', 'vehiculo__placa', 'cliente__email', 'motivo_visita', 'fecha_hora_inicio_programada', 'created_at'], defaultFilters: {'estado': 'CANCELADA'}),
  ReportTemplate(group: 'global', id: 'global_citas_no_show', title: 'Listado general de citas no show', view: 'citas', selectedColumns: ['id', 'vehiculo__placa', 'cliente__email', 'fecha_hora_inicio_programada', 'no_show_marcado_at'], defaultFilters: {'estado': 'NO_SHOW'}),
  ReportTemplate(group: 'global', id: 'global_vehiculos_en_taller', title: 'Vehículos actualmente en taller', view: 'vehiculos_en_taller', selectedColumns: ['vehiculo__placa', 'vehiculo__marca', 'cliente__email', 'estado', 'fecha_hora_inicio_programada']),
  ReportTemplate(group: 'global', id: 'global_presupuestos_aprobados', title: 'Presupuestos aprobados del sistema', view: 'presupuestos', selectedColumns: ['id', 'total', 'cita__vehiculo__placa', 'cita__cliente__email', 'comunicado_at', 'updated_at'], defaultFilters: {'estado': 'APROBADO'}),
  ReportTemplate(group: 'global', id: 'global_ordenes_abiertas', title: 'Órdenes abiertas del sistema', view: 'ordenes_globales', selectedColumns: ['numero', 'estado', 'cita__vehiculo__placa', 'asesor_responsable__email', 'fecha_apertura'], defaultFilters: {'estado': ['ABIERTA', 'ASIGNADA', 'EN_PROCESO', 'PAUSADA']}),
  ReportTemplate(group: 'global', id: 'global_pagos_pendientes', title: 'Pagos pendientes o procesando', view: 'pagos_taller', selectedColumns: ['id', 'estado', 'metodo_pago', 'monto_total', 'cita__vehiculo__placa', 'created_at'], defaultFilters: {'estado': ['PENDIENTE', 'PROCESANDO', 'REGISTRADO']}),
  ReportTemplate(group: 'global', id: 'global_solicitudes_activas', title: 'Solicitudes de repuesto activas', view: 'solicitudes_repuesto_activas', selectedColumns: ['cita__vehiculo__placa', 'estado', 'solicitado_por__email', 'aprobado_por_asesor__email', 'updated_at']),
];

// ── Vehiculo Templates ──

const _vehiculoTemplates = <ReportTemplate>[
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_solo_vehiculos', title: 'Solo vehículos', view: 'vehiculos', selectedColumns: ['placa', 'marca', 'modelo', 'anio', 'color', 'kilometraje_actual']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_citas', title: 'Historial de citas por vehículo', view: 'citas', selectedColumns: ['vehiculo__placa', 'estado', 'fecha_hora_inicio_programada', 'canal_origen', 'motivo_visita', 'cliente__email']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_detalles_cita', title: 'Historial de detalles de cita por vehículo', view: 'cita_detalles', selectedColumns: ['cita__vehiculo__placa', 'servicio_catalogo__nombre', 'estado', 'tiempo_estandar_min', 'precio_referencial', 'created_at']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_plan', title: 'Historial de servicios del plan por vehículo', view: 'planes_detalle', selectedColumns: ['plan_servicio__vehiculo__placa', 'servicio_catalogo__nombre', 'estado', 'prioridad', 'tiempo_estandar_min', 'updated_at']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_presupuestos', title: 'Historial de presupuestos por vehículo', view: 'presupuestos', selectedColumns: ['cita__vehiculo__placa', 'estado', 'subtotal', 'descuento', 'total', 'created_at']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_pagos', title: 'Historial de pagos por vehículo', view: 'pagos_taller', selectedColumns: ['cita__vehiculo__placa', 'estado', 'metodo_pago', 'monto_total', 'fecha_pago', 'created_at']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_ordenes', title: 'Historial de órdenes por vehículo', view: 'ordenes_globales', selectedColumns: ['cita__vehiculo__placa', 'numero', 'estado', 'asesor_responsable__email', 'fecha_apertura']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_servicios_ot', title: 'Historial de servicios en órdenes por vehículo', view: 'ordenes_detalle', selectedColumns: ['orden_global__cita__vehiculo__placa', 'servicio_catalogo__nombre', 'estado', 'prioridad', 'mecanico_asignado__email']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_recepciones', title: 'Historial de recepciones por vehículo', view: 'recepciones', selectedColumns: ['cita__vehiculo__placa', 'fecha_recepcion', 'kilometraje_ingreso', 'nivel_combustible', 'fecha_recogida']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_avances', title: 'Historial de avances por vehículo', view: 'avances', selectedColumns: ['cita__vehiculo__placa', 'tipo', 'estado_nuevo', 'mensaje', 'porcentaje_avance', 'created_at']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_solicitudes', title: 'Historial de solicitudes de repuesto por vehículo', view: 'solicitudes_repuesto', selectedColumns: ['cita__vehiculo__placa', 'estado', 'motivo', 'solicitado_por__email', 'created_at']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_historial_items_solicitados', title: 'Historial de items solicitados por vehículo', view: 'solicitudes_repuesto_detalle', selectedColumns: ['solicitud__cita__vehiculo__placa', 'item_inventario__nombre', 'cantidad_solicitada', 'cantidad_entregada', 'estado']),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_citas_programadas', title: 'Citas programadas por vehículo', view: 'citas', selectedColumns: ['vehiculo__placa', 'cliente__email', 'fecha_hora_inicio_programada', 'motivo_visita', 'created_at'], defaultFilters: {'estado': 'PROGRAMADA'}),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_citas_en_proceso', title: 'Citas en proceso por vehículo', view: 'citas', selectedColumns: ['vehiculo__placa', 'cliente__email', 'fecha_hora_inicio_programada', 'motivo_visita', 'created_at'], defaultFilters: {'estado': 'EN_PROCESO'}),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_citas_finalizadas', title: 'Citas finalizadas por vehículo', view: 'citas', selectedColumns: ['vehiculo__placa', 'cliente__email', 'fecha_hora_inicio_programada', 'finalizada_at', 'vehiculo_devuelto_at'], defaultFilters: {'estado': 'FINALIZADA'}),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_citas_canceladas', title: 'Citas canceladas por vehículo', view: 'citas', selectedColumns: ['vehiculo__placa', 'cliente__email', 'fecha_hora_inicio_programada', 'created_at'], defaultFilters: {'estado': 'CANCELADA'}),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_citas_no_show', title: 'Citas no show por vehículo', view: 'citas', selectedColumns: ['vehiculo__placa', 'cliente__email', 'fecha_hora_inicio_programada', 'no_show_marcado_at'], defaultFilters: {'estado': 'NO_SHOW'}),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_presupuestos_aprobados', title: 'Presupuestos aprobados por vehículo', view: 'presupuestos', selectedColumns: ['cita__vehiculo__placa', 'total', 'cita__cliente__email', 'comunicado_at', 'updated_at'], defaultFilters: {'estado': 'APROBADO'}),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_pagos_pendientes', title: 'Pagos pendientes por vehículo', view: 'pagos_taller', selectedColumns: ['cita__vehiculo__placa', 'estado', 'metodo_pago', 'monto_total', 'created_at'], defaultFilters: {'estado': ['PENDIENTE', 'PROCESANDO', 'REGISTRADO']}),
  ReportTemplate(group: 'vehiculo', id: 'vehiculo_avances_visibles', title: 'Avances visibles para cliente por vehículo', view: 'avances', selectedColumns: ['cita__vehiculo__placa', 'estado_nuevo', 'mensaje', 'porcentaje_avance', 'created_at'], defaultFilters: {'visible_cliente': true}),
];

// ── Presupuesto Templates ──

const _presupuestoTemplates = <ReportTemplate>[
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_general', title: 'Listado general de presupuestos', view: 'presupuestos', selectedColumns: ['id', 'estado', 'subtotal', 'descuento', 'total', 'cita__vehiculo__placa', 'cita__cliente__email', 'created_at']),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_borrador', title: 'Presupuestos en borrador', view: 'presupuestos', selectedColumns: ['id', 'subtotal', 'total', 'cita__vehiculo__placa', 'cita__cliente__email', 'created_at'], defaultFilters: {'estado': 'BORRADOR'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_comunicado', title: 'Presupuestos comunicados', view: 'presupuestos', selectedColumns: ['id', 'total', 'cita__vehiculo__placa', 'cita__cliente__email', 'comunicado_por__email', 'comunicado_at'], defaultFilters: {'estado': 'COMUNICADO'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_ajustado', title: 'Presupuestos ajustados', view: 'presupuestos', selectedColumns: ['id', 'subtotal', 'descuento', 'total', 'cita__vehiculo__placa', 'updated_at'], defaultFilters: {'estado': 'AJUSTADO'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_aprobado', title: 'Presupuestos aprobados', view: 'presupuestos', selectedColumns: ['id', 'total', 'cita__vehiculo__placa', 'cita__cliente__email', 'updated_at'], defaultFilters: {'estado': 'APROBADO'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_rechazado', title: 'Presupuestos rechazados', view: 'presupuestos', selectedColumns: ['id', 'total', 'cita__vehiculo__placa', 'cita__cliente__email', 'updated_at'], defaultFilters: {'estado': 'RECHAZADO'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_cerrado', title: 'Presupuestos cerrados', view: 'presupuestos', selectedColumns: ['id', 'total', 'cita__vehiculo__placa', 'cita__cliente__email', 'updated_at'], defaultFilters: {'estado': 'CERRADO'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_con_descuento', title: 'Presupuestos con descuento aplicado', view: 'presupuestos', selectedColumns: ['id', 'subtotal', 'descuento', 'total', 'cita__vehiculo__placa', 'updated_at'], defaultFilters: {'descuento__gt': 0}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_por_cliente', title: 'Presupuestos por cliente', view: 'presupuestos', selectedColumns: ['cita__cliente__email', 'cita__vehiculo__placa', 'estado', 'total', 'created_at']),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_por_vehiculo', title: 'Presupuestos por vehículo', view: 'presupuestos', selectedColumns: ['cita__vehiculo__placa', 'cita__cliente__email', 'estado', 'total', 'created_at']),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_por_asesor', title: 'Presupuestos por asesor', view: 'presupuestos', selectedColumns: ['cita__asesor_responsable__email', 'cita__vehiculo__placa', 'estado', 'total', 'created_at']),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_pagos_general', title: 'Pagos asociados a presupuestos', view: 'pagos_taller', selectedColumns: ['id', 'tipo_destino', 'id_destino', 'estado', 'metodo_pago', 'monto_total', 'cita__vehiculo__placa', 'created_at']),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_pagos_qr', title: 'Pagos QR de presupuesto', view: 'pagos_taller', selectedColumns: ['id', 'proveedor', 'estado', 'monto_total', 'cita__vehiculo__placa', 'created_at'], defaultFilters: {'proveedor': 'LIBELULA_QR'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_pagos_tarjeta', title: 'Pagos con tarjeta de presupuesto', view: 'pagos_taller', selectedColumns: ['id', 'proveedor', 'estado', 'monto_total', 'cita__vehiculo__placa', 'created_at'], defaultFilters: {'proveedor': 'STRIPE'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_pagos_efectivo', title: 'Pagos en efectivo o manuales', view: 'pagos_taller', selectedColumns: ['id', 'metodo_pago', 'estado', 'monto_total', 'cita__vehiculo__placa', 'created_at'], defaultFilters: {'metodo_pago': 'EFECTIVO'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_pagos_pendientes', title: 'Pagos pendientes de presupuesto', view: 'pagos_taller', selectedColumns: ['id', 'estado', 'metodo_pago', 'monto_total', 'cita__vehiculo__placa', 'created_at'], defaultFilters: {'estado': ['PENDIENTE', 'PROCESANDO', 'REGISTRADO']}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_pagos_confirmados', title: 'Pagos confirmados o recibidos', view: 'pagos_taller', selectedColumns: ['id', 'estado', 'metodo_pago', 'monto_total', 'cita__vehiculo__placa', 'recibido_at'], defaultFilters: {'estado': ['CONFIRMADO', 'RECIBIDO']}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_pagos_facturados', title: 'Pagos facturados', view: 'pagos_taller', selectedColumns: ['id', 'estado', 'metodo_pago', 'monto_total', 'cita__vehiculo__placa', 'created_at'], defaultFilters: {'estado': 'FACTURADO'}),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_pagos_con_referencia', title: 'Pagos con referencia registrada', view: 'pagos_taller', selectedColumns: ['id', 'referencia', 'metodo_pago', 'monto_total', 'cita__vehiculo__placa', 'created_at']),
  ReportTemplate(group: 'presupuesto', id: 'presupuesto_caja_por_metodo', title: 'Caja y pagos por método', view: 'pagos_taller', selectedColumns: ['metodo_pago', 'estado', 'monto_total', 'monto_cobrado', 'registrado_por__email', 'created_at']),
];

// ── Inventario Templates ──

const _inventarioTemplates = <ReportTemplate>[
  ReportTemplate(group: 'inventario', id: 'inventario_items_general', title: 'Listado general de items de inventario', view: 'items_inventario', selectedColumns: ['codigo', 'nombre', 'categoria__nombre', 'tipo_item', 'stock_actual', 'precio_venta']),
  ReportTemplate(group: 'inventario', id: 'inventario_items_activos', title: 'Items activos de inventario', view: 'items_inventario', selectedColumns: ['codigo', 'nombre', 'categoria__nombre', 'tipo_item', 'stock_actual', 'precio_venta'], defaultFilters: {'activo': true}),
  ReportTemplate(group: 'inventario', id: 'inventario_items_inactivos', title: 'Items inactivos de inventario', view: 'items_inventario', selectedColumns: ['codigo', 'nombre', 'categoria__nombre', 'tipo_item', 'stock_actual', 'precio_venta'], defaultFilters: {'activo': false}),
  ReportTemplate(group: 'inventario', id: 'inventario_items_sin_stock', title: 'Items sin stock', view: 'items_inventario', selectedColumns: ['codigo', 'nombre', 'categoria__nombre', 'tipo_item', 'stock_actual', 'stock_minimo'], defaultFilters: {'stock_actual': 0}),
  ReportTemplate(group: 'inventario', id: 'inventario_items_stock_bajo', title: 'Items con stock bajo', view: 'items_stock_bajo', selectedColumns: ['codigo', 'nombre', 'categoria__nombre', 'tipo_item', 'stock_actual', 'stock_minimo']),
  ReportTemplate(group: 'inventario', id: 'inventario_items_por_categoria', title: 'Items de inventario por categoría', view: 'items_inventario', selectedColumns: ['categoria__nombre', 'codigo', 'nombre', 'tipo_item', 'stock_actual', 'precio_venta']),
  ReportTemplate(group: 'inventario', id: 'inventario_items_por_tipo', title: 'Items de inventario por tipo', view: 'items_inventario', selectedColumns: ['tipo_item', 'codigo', 'nombre', 'categoria__nombre', 'stock_actual', 'precio_venta']),
  ReportTemplate(group: 'inventario', id: 'inventario_movimientos_general', title: 'Historial general de movimientos de inventario', view: 'movimientos_inventario', selectedColumns: ['item_inventario__nombre', 'tipo_movimiento', 'cantidad', 'stock_anterior', 'stock_posterior', 'created_at']),
  ReportTemplate(group: 'inventario', id: 'inventario_entradas_compra', title: 'Entradas por compra', view: 'movimientos_inventario', selectedColumns: ['item_inventario__nombre', 'cantidad', 'stock_posterior', 'registrado_por__email', 'created_at'], defaultFilters: {'tipo_movimiento': 'ENTRADA_COMPRA'}),
  ReportTemplate(group: 'inventario', id: 'inventario_salidas_taller', title: 'Salidas al taller', view: 'movimientos_inventario', selectedColumns: ['item_inventario__nombre', 'cantidad', 'stock_posterior', 'registrado_por__email', 'created_at'], defaultFilters: {'tipo_movimiento': 'SALIDA_TALLER'}),
  ReportTemplate(group: 'inventario', id: 'inventario_salidas_venta', title: 'Salidas por venta', view: 'movimientos_inventario', selectedColumns: ['item_inventario__nombre', 'cantidad', 'stock_posterior', 'registrado_por__email', 'created_at'], defaultFilters: {'tipo_movimiento': 'SALIDA_VENTA'}),
  ReportTemplate(group: 'inventario', id: 'inventario_ajustes_stock', title: 'Ajustes manuales de stock', view: 'movimientos_inventario', selectedColumns: ['item_inventario__nombre', 'cantidad', 'stock_anterior', 'stock_posterior', 'observacion', 'created_at'], defaultFilters: {'tipo_movimiento': 'AJUSTE'}),
  ReportTemplate(group: 'inventario', id: 'inventario_compras_general', title: 'Listado general de compras', view: 'compras', selectedColumns: ['numero_documento', 'estado', 'proveedor__nombre', 'total', 'fecha_compra', 'created_at']),
  ReportTemplate(group: 'inventario', id: 'inventario_compras_confirmadas', title: 'Compras confirmadas', view: 'compras', selectedColumns: ['numero_documento', 'proveedor__nombre', 'total', 'fecha_compra', 'created_at'], defaultFilters: {'estado': 'CONFIRMADA'}),
  ReportTemplate(group: 'inventario', id: 'inventario_compras_anuladas', title: 'Compras anuladas', view: 'compras', selectedColumns: ['numero_documento', 'proveedor__nombre', 'total', 'fecha_compra', 'created_at'], defaultFilters: {'estado': 'ANULADA'}),
  ReportTemplate(group: 'inventario', id: 'inventario_proveedores_registrados', title: 'Proveedores registrados', view: 'proveedores', selectedColumns: ['nombre', 'telefono', 'email', 'contacto', 'activo', 'created_at']),
  ReportTemplate(group: 'inventario', id: 'inventario_solicitudes_general', title: 'Listado general de solicitudes de repuesto', view: 'solicitudes_repuesto', selectedColumns: ['cita__vehiculo__placa', 'estado', 'solicitado_por__email', 'aprobado_por_asesor__email', 'created_at']),
  ReportTemplate(group: 'inventario', id: 'inventario_solicitudes_activas', title: 'Solicitudes de repuesto activas', view: 'solicitudes_repuesto_activas', selectedColumns: ['cita__vehiculo__placa', 'estado', 'solicitado_por__email', 'updated_at']),
  ReportTemplate(group: 'inventario', id: 'inventario_solicitudes_revision_almacen', title: 'Solicitudes en revisión de almacén', view: 'solicitudes_repuesto', selectedColumns: ['cita__vehiculo__placa', 'solicitado_por__email', 'aprobado_por_asesor__email', 'updated_at'], defaultFilters: {'estado': 'EN_REVISION_ALMACEN'}),
  ReportTemplate(group: 'inventario', id: 'inventario_items_solicitud_pendientes', title: 'Items pendientes de entrega al taller', view: 'solicitudes_detalle_pendientes', selectedColumns: ['solicitud__cita__vehiculo__placa', 'item_inventario__nombre', 'cantidad_aprobada', 'cantidad_entregada', 'estado', 'updated_at']),
];

// ── All Templates ─────────────────────────────────────────────────────────

const allReportTemplates = <ReportTemplate>[
  ..._globalTemplates,
  ..._vehiculoTemplates,
  ..._presupuestoTemplates,
  ..._inventarioTemplates,
];

/// Templates indexed by group id.
final reportTemplatesByGroup = <String, List<ReportTemplate>>{
  for (final group in reportGroups)
    group.id: allReportTemplates.where((t) => t.group == group.id).toList(),
};

// ── Filter Operators ──────────────────────────────────────────────────────

class FilterOperator {
  final String value;
  final String label;

  const FilterOperator({required this.value, required this.label});
}

const filterOperators = <FilterOperator>[
  FilterOperator(value: 'eq', label: 'Es igual a'),
  FilterOperator(value: 'contains', label: 'Contiene'),
  FilterOperator(value: 'gt', label: 'Mayor que'),
  FilterOperator(value: 'gte', label: 'Mayor o igual'),
  FilterOperator(value: 'lt', label: 'Menor que'),
  FilterOperator(value: 'lte', label: 'Menor o igual'),
  FilterOperator(value: 'in', label: 'Está en lista'),
  FilterOperator(value: 'isnull', label: 'Es nulo'),
];

/// A user-defined filter row.
class ExplorerFilter {
  String field;
  String operator;
  String value;

  ExplorerFilter({this.field = '', this.operator = 'eq', this.value = ''});

  ExplorerFilter copyWith({String? field, String? operator, String? value}) {
    return ExplorerFilter(
      field: field ?? this.field,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }
}

/// Builds the filter suffix map for an operator.
String filterSuffix(String op) {
  switch (op) {
    case 'eq':
      return '';
    case 'contains':
      return '__icontains';
    case 'gt':
      return '__gt';
    case 'gte':
      return '__gte';
    case 'lt':
      return '__lt';
    case 'lte':
      return '__lte';
    case 'in':
      return '__in';
    case 'isnull':
      return '__isnull';
    default:
      return '';
  }
}

/// Parses a user-typed filter value into the right type for the backend.
dynamic parseFilterValue(String value, String operator) {
  if (operator == 'isnull') {
    return value.toLowerCase() == 'true';
  }
  if (operator == 'in') {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .map((item) {
      if (item.toLowerCase() == 'true') return true;
      if (item.toLowerCase() == 'false') return false;
      if (item.toLowerCase() == 'null') return null;
      final n = num.tryParse(item);
      if (n != null) return n;
      return item;
    }).toList();
  }
  if (value.toLowerCase() == 'true') return true;
  if (value.toLowerCase() == 'false') return false;
  if (value.toLowerCase() == 'null') return null;
  final n = num.tryParse(value.trim());
  if (n != null) return n;
  return value.trim();
}

/// Builds a JSON-serialisable filter map from user-defined filters.
Map<String, dynamic> buildUserFilters(List<ExplorerFilter> filters) {
  final result = <String, dynamic>{};
  for (final f in filters) {
    if (f.field.isEmpty) continue;
    if (f.operator != 'isnull' && f.value.trim().isEmpty) continue;
    final key = '${f.field}${filterSuffix(f.operator)}';
    result[key] = parseFilterValue(f.value, f.operator);
  }
  return result;
}
