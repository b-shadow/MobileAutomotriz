/// Centralized API constants for the automotive SaaS backend.
class ApiConstants {
  ApiConstants._();

  /// Base URL — Android emulator uses 10.0.2.2 for host localhost.
  static const String baseUrl = 'https://backendautomotriz.onrender.com';
  static const String prodBaseUrl = 'https://backendautomotriz.onrender.com';

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // ── Auth (Tenant-scoped) ────────────────────────────────
  static String login(String slug) => '/api/tenants/$slug/auth/login/';
  static String register(String slug) => '/api/tenants/$slug/auth/register/';
  static String logout(String slug) => '/api/tenants/$slug/auth/logout/';
  static String resolveTenant(String slug) =>
      '/api/tenants/resolve/?slug=$slug';

  // ── Usuarios ────────────────────────────────────────────
  static String usuarios(String slug) => '/api/$slug/administracion/usuarios/';
  static String usuario(String slug, String id) => '/api/$slug/administracion/usuarios/$id/';
  static String obtenerRoles(String slug) =>
      '/api/$slug/administracion/usuarios/obtener-roles/';
  static String cambiarRol(String slug, String id) =>
      '/api/$slug/administracion/usuarios/$id/cambiar-rol/';
  static String desactivarUsuario(String slug, String id) =>
      '/api/$slug/administracion/usuarios/$id/desactivar/';
  static String activarUsuario(String slug, String id) =>
      '/api/$slug/administracion/usuarios/$id/activar/';
  static String cambiarContrasena(String slug, String id) =>
      '/api/$slug/administracion/usuarios/$id/cambiar-contrasena/';
  static String preferenciasNotificacion(String slug) =>
      '/api/$slug/administracion/usuarios/preferencias-notificacion/';

  // ── Vehículos ───────────────────────────────────────────
  static String vehiculos(String slug) => '/api/$slug/vehiculos-servicios/vehiculos/';
  static String vehiculo(String slug, String id) => '/api/$slug/vehiculos-servicios/vehiculos/$id/';
  static String vehiculoEstado(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/vehiculos/$id/estado/';

  // ── Planes de Vehículo ───────────────────────────────
  static String planesVehiculo(String slug) => '/api/$slug/vehiculos-servicios/planes-vehiculo/';
  static String planVehiculo(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/planes-vehiculo/$id/';
  static String planVehiculoEstado(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/planes-vehiculo/$id/estado/';
  static String planVehiculoDetalles(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/planes-vehiculo/$id/detalles/';
  static String planVehiculoCrearDetalle(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/planes-vehiculo/$id/crear-detalle/';
  static String planVehiculoEditarDetalle(String slug, String detalleId) =>
      '/api/$slug/vehiculos-servicios/planes-vehiculo/detalles/$detalleId/editar/';
  static String planVehiculoDetalleEstado(String slug, String detalleId) =>
      '/api/$slug/vehiculos-servicios/planes-vehiculo/detalles/$detalleId/estado/';

  // ── Citas ───────────────────────────────────────────────
  static String citas(String slug) => '/api/$slug/vehiculos-servicios/citas/';
  static String cita(String slug, String id) => '/api/$slug/vehiculos-servicios/citas/$id/';
  static String cancelarCita(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/citas/$id/cancelar/';
  static String reprogramarCita(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/citas/$id/reprogramar/';
  static String marcarNoShowCita(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/citas/$id/marcar-no-show/';
  static String citasRecepcionOperativa(String slug) =>
      '/api/$slug/vehiculos-servicios/citas/recepcion-operativa/';
  static String citaRegistrarLlegada(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/citas/$id/registrar-llegada/';
  static String citaMarcarEnProceso(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/citas/$id/marcar-en-proceso/';
  static String citaMarcarVehiculoDevuelto(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/citas/$id/marcar-vehiculo-devuelto/';

  // ── Recepciones de Vehículo ─────────────────────────────────
  static String recepciones(String slug) =>
      '/api/$slug/atencion-tecnica/recepciones-vehiculo/';
  static String recepcion(String slug, String id) =>
      '/api/$slug/atencion-tecnica/recepciones-vehiculo/$id/';
  static String citasPendientesRecepcion(String slug) =>
      '/api/$slug/atencion-tecnica/recepciones-vehiculo/citas-pendientes/';

  // ── Presupuestos de Cita ────────────────────────────────────
  static String presupuestos(String slug) =>
      '/api/$slug/atencion-tecnica/presupuestos-cita/';
  static String presupuesto(String slug, String id) =>
      '/api/$slug/atencion-tecnica/presupuestos-cita/$id/';
  static String comunicarPresupuesto(String slug, String id) =>
      '/api/$slug/atencion-tecnica/presupuestos-cita/$id/comunicar/';
  static String aprobarPresupuesto(String slug, String id) =>
      '/api/$slug/atencion-tecnica/presupuestos-cita/$id/aprobar/';
  static String rechazarPresupuesto(String slug, String id) =>
      '/api/$slug/atencion-tecnica/presupuestos-cita/$id/rechazar/';
  static String ajustarPresupuesto(String slug, String id) =>
      '/api/$slug/atencion-tecnica/presupuestos-cita/$id/ajustar/';
  static String cerrarPresupuesto(String slug, String id) =>
      '/api/$slug/atencion-tecnica/presupuestos-cita/$id/cerrar/';

  // ── Órdenes de Trabajo ───────────────────────────────────────
  static String ordenesTrabajo(String slug) =>
      '/api/$slug/atencion-tecnica/ordenes-trabajo/';
  static String ordenTrabajo(String slug, String id) =>
      '/api/$slug/atencion-tecnica/ordenes-trabajo/$id/';
  static String mecanicosDisponibles(String slug) =>
      '/api/$slug/atencion-tecnica/ordenes-trabajo/mecanicos-disponibles/';
  static String asignarMecanicos(String slug, String id) =>
      '/api/$slug/atencion-tecnica/ordenes-trabajo/$id/asignar-mecanicos/';
  static String asignarDetalles(String slug, String id) =>
      '/api/$slug/atencion-tecnica/ordenes-trabajo/$id/asignar-detalles/';
  static String iniciarOrdenTrabajo(String slug, String id) =>
      '/api/$slug/atencion-tecnica/ordenes-trabajo/$id/iniciar/';

  // ── Avance en Taller ─────────────────────────────────────────
  static String avanceTallerList(String slug) =>
      '/api/$slug/atencion-tecnica/avance-taller/';
  static String avanceTallerDetalle(String slug, String id) =>
      '/api/$slug/atencion-tecnica/avance-taller/$id/';
  static String avanceTallerIniciar(String slug, String id) =>
      '/api/$slug/atencion-tecnica/avance-taller/$id/iniciar-detalle/';
  static String avanceTallerPausar(String slug, String id) =>
      '/api/$slug/atencion-tecnica/avance-taller/$id/pausar-detalle/';
  static String avanceTallerFinalizar(String slug, String id) =>
      '/api/$slug/atencion-tecnica/avance-taller/$id/finalizar-detalle/';
  static String avanceTallerInnecesario(String slug, String id) =>
      '/api/$slug/atencion-tecnica/avance-taller/$id/marcar-innecesario/';
  static String avanceTallerFinalizarOrden(String slug, String id) =>
      '/api/$slug/atencion-tecnica/avance-taller/$id/finalizar-orden/';
      
  static String avancesVehiculoList(String slug) =>
      '/api/$slug/atencion-tecnica/avances-vehiculo/';

  // ── Servicios ───────────────────────────────────────────


  static String servicios(String slug) => '/api/$slug/vehiculos-servicios/servicios/';
  static String servicio(String slug, String id) => '/api/$slug/vehiculos-servicios/servicios/$id/';
  static String servicioEstado(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/servicios/$id/estado/';

  // ── Espacios ────────────────────────────────────────────
  static String espacios(String slug) => '/api/$slug/vehiculos-servicios/espacios/';
  static String espacioActivo(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/espacios/$id/activo/';
  static String espacioHorarios(String slug, String id) =>
      '/api/$slug/vehiculos-servicios/espacios/$id/horarios/';
  static String editarHorarioEspacio(
    String slug,
    String espacioId,
    String horarioId,
  ) => '/api/$slug/vehiculos-servicios/espacios/$espacioId/editar_horario/?horario_id=$horarioId';

  // ── Planes (Global) ─────────────────────────────────────
  static const String planes = '/api/planes/';

  // ── Suscripciones ───────────────────────────────────────
  static String suscripcionActual(String slug) =>
      '/api/$slug/administracion/suscripciones/actual/';
  static String cambiarPlan(String slug) =>
      '/api/$slug/administracion/suscripciones/cambiar-plan/';
  static String crearPaymentIntent(String slug) =>
      '/api/$slug/administracion/suscripciones/crear_payment_intent/';
  static String confirmarPago(String slug) =>
      '/api/$slug/administracion/suscripciones/confirmar_pago/';
  static String cancelarCambio(String slug) =>
      '/api/$slug/administracion/suscripciones/cancelar-cambio/';

  // ── Empresa (Tenant) ────────────────────────────────────
  static String miEmpresa(String slug) => '/api/empresas/mi_empresa/';

  // ── Auditoría ───────────────────────────────────────────
  static String auditoria(String slug) => '/api/$slug/administracion/auditoria/';
  static String auditoriaDetalle(String slug, String id) =>
      '/api/$slug/administracion/auditoria/$id/';
  static String auditoriaResumen(String slug) =>
      '/api/$slug/administracion/auditoria/resumen/';

  static String notificaciones(String slug) => '/api/$slug/comunicacion-control/notificaciones/';

  // ── Inteligencia Artificial ─────────────────────────────
  static String iaConversaciones(String slug) => '/api/$slug/comunicacion-control/ia/';
  static String iaConversacion(String slug, String id) => '/api/$slug/comunicacion-control/ia/$id/';
  static String iaArchivar(String slug, String id) => '/api/$slug/comunicacion-control/ia/$id/archivar/';
  static String iaEnviarMensaje(String slug, String id) => '/api/$slug/comunicacion-control/ia/$id/enviar_mensaje/';
  static String iaConfirmarAccion(String slug, String id) => '/api/$slug/comunicacion-control/ia/$id/confirmar_accion/';

  // ── Reportes ────────────────────────────────────────────
  static String reportesVehiculo(String slug) => '/api/$slug/vehiculos-servicios/reportes/vehiculo/';
}
