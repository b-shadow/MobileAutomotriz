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

  // ── Recepciones de Vehículo ─────────────────────────────────
  static String recepciones(String slug) =>
      '/api/$slug/recepciones-vehiculo/';
  static String recepcion(String slug, String id) =>
      '/api/$slug/recepciones-vehiculo/$id/';
  static String citasPendientesRecepcion(String slug) =>
      '/api/$slug/recepciones-vehiculo/citas-pendientes/';

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

  // ── Notificaciones ──────────────────────────────────────
  static String notificaciones(String slug) => '/api/$slug/comunicacion-control/notificaciones/';
}
