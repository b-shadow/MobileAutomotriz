/// Centralized API constants for the automotive SaaS backend.
class ApiConstants {
  ApiConstants._();

  /// Base URL — Android emulator uses 10.0.2.2 for host localhost.
  static const String baseUrl = 'http://localhost:8000';
  static const String prodBaseUrl = 'https://your-production-api.com';

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
  static String usuarios(String slug) => '/api/$slug/usuarios/';
  static String usuario(String slug, String id) =>
      '/api/$slug/usuarios/$id/';
  static String obtenerRoles(String slug) =>
      '/api/$slug/usuarios/obtener-roles/';
  static String cambiarRol(String slug, String id) =>
      '/api/$slug/usuarios/$id/cambiar-rol/';
  static String desactivarUsuario(String slug, String id) =>
      '/api/$slug/usuarios/$id/desactivar/';
  static String activarUsuario(String slug, String id) =>
      '/api/$slug/usuarios/$id/activar/';
  static String cambiarContrasena(String slug, String id) =>
      '/api/$slug/usuarios/$id/cambiar-contrasena/';
  static String preferenciasNotificacion(String slug) =>
      '/api/$slug/usuarios/preferencias-notificacion/';

  // ── Vehículos ───────────────────────────────────────────
  static String vehiculos(String slug) => '/api/$slug/vehiculos/';
  static String vehiculo(String slug, String id) =>
      '/api/$slug/vehiculos/$id/';
  static String vehiculoEstado(String slug, String id) =>
      '/api/$slug/vehiculos/$id/estado/';

  // ── Planes de Vehículo ───────────────────────────────
  static String planesVehiculo(String slug) => '/api/$slug/planes-vehiculo/';
  static String planVehiculo(String slug, String id) =>
      '/api/$slug/planes-vehiculo/$id/';
  static String planVehiculoEstado(String slug, String id) =>
      '/api/$slug/planes-vehiculo/$id/estado/';
  static String planVehiculoDetalles(String slug, String id) =>
      '/api/$slug/planes-vehiculo/$id/detalles/';
  static String planVehiculoCrearDetalle(String slug, String id) =>
      '/api/$slug/planes-vehiculo/$id/crear-detalle/';
  static String planVehiculoEditarDetalle(String slug, String detalleId) =>
      '/api/$slug/planes-vehiculo/detalles/$detalleId/editar/';
  static String planVehiculoDetalleEstado(String slug, String detalleId) =>
      '/api/$slug/planes-vehiculo/detalles/$detalleId/estado/';

  // ── Citas ───────────────────────────────────────────────
  static String citas(String slug) => '/api/$slug/citas/';
  static String cita(String slug, String id) => '/api/$slug/citas/$id/';
  static String cancelarCita(String slug, String id) =>
      '/api/$slug/citas/$id/cancelar/';
  static String reprogramarCita(String slug, String id) =>
      '/api/$slug/citas/$id/reprogramar/';

  // ── Servicios ───────────────────────────────────────────
  static String servicios(String slug) => '/api/$slug/servicios/';
  static String servicio(String slug, String id) =>
      '/api/$slug/servicios/$id/';
  static String servicioEstado(String slug, String id) =>
      '/api/$slug/servicios/$id/estado/';

  // ── Espacios ────────────────────────────────────────────
  static String espacios(String slug) => '/api/$slug/espacios/';
  static String espacioActivo(String slug, String id) =>
      '/api/$slug/espacios/$id/activo/';
  static String espacioHorarios(String slug, String id) =>
      '/api/$slug/espacios/$id/horarios/';
  static String editarHorarioEspacio(
    String slug,
    String espacioId,
    String horarioId,
  ) =>
      '/api/$slug/espacios/$espacioId/editar_horario/?horario_id=$horarioId';

  // ── Planes (Global) ─────────────────────────────────────
  static const String planes = '/api/planes/';

  // ── Suscripciones ───────────────────────────────────────
  static String suscripcionActual(String slug) =>
      '/api/$slug/suscripciones/actual/';
  static String cambiarPlan(String slug) =>
      '/api/$slug/suscripciones/cambiar-plan/';
  static String crearPaymentIntent(String slug) =>
      '/api/$slug/suscripciones/crear_payment_intent/';
  static String confirmarPago(String slug) =>
      '/api/$slug/suscripciones/confirmar_pago/';
  static String cancelarCambio(String slug) =>
      '/api/$slug/suscripciones/cancelar-cambio/';

  // ── Empresa (Tenant) ────────────────────────────────────
  static String miEmpresa(String slug) => '/api/empresas/mi_empresa/';

  // ── Auditoría ───────────────────────────────────────────
  static String auditoria(String slug) => '/api/$slug/auditoria/';
  static String auditoriaDetalle(String slug, String id) =>
      '/api/$slug/auditoria/$id/';
  static String auditoriaResumen(String slug) =>
      '/api/$slug/auditoria/resumen/';

  // ── Notificaciones ──────────────────────────────────────
  static String notificaciones(String slug) => '/api/$slug/notificaciones/';
}
