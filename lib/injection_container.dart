import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/storage/session_storage.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/change_password.dart';
import 'features/profile/domain/usecases/update_notification_prefs.dart';
import 'features/profile/domain/usecases/update_personal_info.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

import 'features/company/data/datasources/company_remote_data_source.dart';
import 'features/company/data/repositories/company_repository_impl.dart';
import 'features/company/domain/repositories/company_repository.dart';
import 'features/company/domain/usecases/get_company_profile.dart';
import 'features/company/domain/usecases/get_current_subscription.dart';
import 'features/company/domain/usecases/get_available_plans.dart';
import 'features/company/domain/usecases/change_plan.dart';
import 'features/company/domain/usecases/create_payment_intent.dart';
import 'features/company/domain/usecases/confirm_payment.dart';
import 'features/company/domain/usecases/cancel_scheduled_change.dart';
import 'features/company/domain/usecases/update_company_profile.dart';
import 'features/company/presentation/cubit/company_cubit.dart';

import 'features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'features/vehicle/domain/repositories/vehicle_repository.dart';
import 'features/vehicle/domain/usecases/create_vehicle.dart';
import 'features/vehicle/domain/usecases/get_vehicles.dart';
import 'features/vehicle/domain/usecases/update_vehicle.dart';
import 'features/vehicle/domain/usecases/update_vehicle_status.dart';
import 'features/vehicle/presentation/cubit/vehicle_cubit.dart';

import 'features/service/data/datasources/service_remote_data_source.dart';
import 'features/service/data/repositories/service_repository_impl.dart';
import 'features/service/domain/repositories/service_repository.dart';
import 'features/service/domain/usecases/create_service.dart';
import 'features/service/domain/usecases/get_services.dart';
import 'features/service/domain/usecases/update_service.dart';
import 'features/service/domain/usecases/update_service_status.dart';
import 'features/service/presentation/cubit/service_cubit.dart';

import 'features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'features/workspace/data/repositories/workspace_repository_impl.dart';
import 'features/workspace/domain/repositories/workspace_repository.dart';
import 'features/workspace/domain/usecases/create_space.dart';
import 'features/workspace/domain/usecases/create_space_schedule.dart';
import 'features/workspace/domain/usecases/get_space_schedules.dart';
import 'features/workspace/domain/usecases/get_spaces.dart';
import 'features/workspace/domain/usecases/update_space_active.dart';
import 'features/workspace/domain/usecases/update_space_schedule.dart';
import 'features/workspace/presentation/cubit/workspace_cubit.dart';

import 'features/audit/data/datasources/audit_remote_data_source.dart';
import 'features/audit/data/repositories/audit_repository_impl.dart';
import 'features/audit/domain/repositories/audit_repository.dart';
import 'features/audit/domain/usecases/get_audit_detail.dart';
import 'features/audit/domain/usecases/get_audit_logs.dart';
import 'features/audit/domain/usecases/get_audit_summary.dart';
import 'features/audit/presentation/cubit/audit_cubit.dart';

import 'features/user_management/data/datasources/user_management_remote_data_source.dart';
import 'features/user_management/data/repositories/user_management_repository_impl.dart';
import 'features/user_management/domain/repositories/user_management_repository.dart';
import 'features/user_management/domain/usecases/activate_user.dart';
import 'features/user_management/domain/usecases/change_user_role.dart';
import 'features/user_management/domain/usecases/create_user.dart';
import 'features/user_management/domain/usecases/deactivate_user.dart';
import 'features/user_management/domain/usecases/get_roles.dart';
import 'features/user_management/domain/usecases/get_user_detail.dart';
import 'features/user_management/domain/usecases/get_users.dart';
import 'features/user_management/presentation/cubit/user_management_cubit.dart';

import 'features/vehicle_plan/data/datasources/vehicle_plan_remote_data_source.dart';
import 'features/vehicle_plan/data/repositories/vehicle_plan_repository_impl.dart';
import 'features/vehicle_plan/domain/repositories/vehicle_plan_repository.dart';
import 'features/vehicle_plan/domain/usecases/create_vehicle_plan_detail.dart';
import 'features/vehicle_plan/domain/usecases/get_vehicle_plan_details.dart';
import 'features/vehicle_plan/domain/usecases/get_vehicle_plans.dart';
import 'features/vehicle_plan/domain/usecases/update_vehicle_plan.dart';
import 'features/vehicle_plan/domain/usecases/update_vehicle_plan_detail.dart';
import 'features/vehicle_plan/domain/usecases/update_vehicle_plan_detail_status.dart';
import 'features/vehicle_plan/domain/usecases/update_vehicle_plan_status.dart';
import 'features/vehicle_plan/presentation/cubit/vehicle_plan_cubit.dart';

import 'features/appointment/data/datasources/appointment_remote_data_source.dart';
import 'features/appointment/data/repositories/appointment_repository_impl.dart';
import 'features/appointment/domain/repositories/appointment_repository.dart';
import 'features/appointment/domain/usecases/get_appointments.dart';
import 'features/appointment/domain/usecases/get_appointment_detail.dart';
import 'features/appointment/domain/usecases/create_appointment.dart';
import 'features/appointment/domain/usecases/cancel_appointment.dart';
import 'features/appointment/domain/usecases/reschedule_appointment.dart';
import 'features/appointment/domain/usecases/mark_no_show_appointment.dart';
import 'features/appointment/presentation/cubit/appointment_cubit.dart';

import 'features/reception/data/datasources/reception_remote_data_source.dart';
import 'features/reception/data/repositories/reception_repository_impl.dart';
import 'features/reception/domain/repositories/reception_repository.dart';
import 'features/reception/domain/usecases/create_reception.dart';
import 'features/reception/domain/usecases/get_receptions.dart';
import 'features/reception/domain/usecases/get_citas_pendientes.dart';
import 'features/reception/presentation/cubit/reception_cubit.dart';

import 'features/budget/data/datasources/budget_remote_data_source.dart';
import 'features/budget/data/repositories/budget_repository_impl.dart';
import 'features/budget/domain/repositories/budget_repository.dart';
import 'features/budget/domain/usecases/create_budget.dart';
import 'features/budget/domain/usecases/get_budgets.dart';
import 'features/budget/domain/usecases/get_budget_detail.dart';
import 'features/budget/domain/usecases/update_budget.dart';
import 'features/budget/domain/usecases/change_budget_status.dart';
import 'features/budget/presentation/cubit/budget_cubit.dart';

import 'features/work_order/data/datasources/work_order_remote_data_source.dart';
import 'features/work_order/data/repositories/work_order_repository_impl.dart';
import 'features/work_order/domain/repositories/work_order_repository.dart';
import 'features/work_order/domain/usecases/work_order_usecases.dart';
import 'features/work_order/presentation/cubit/work_order_cubit.dart';

import 'features/vehicle_progress/data/datasources/vehicle_progress_remote_data_source.dart';
import 'features/vehicle_progress/data/repositories/vehicle_progress_repository_impl.dart';
import 'features/vehicle_progress/domain/repositories/vehicle_progress_repository.dart';
import 'features/vehicle_progress/domain/usecases/vehicle_progress_usecases.dart';
import 'features/vehicle_progress/presentation/cubit/vehicle_progress_cubit.dart';
import 'features/ai_assistant/data/datasources/ai_remote_data_source.dart';
import 'features/ai_assistant/data/repositories/ai_repository_impl.dart';
import 'features/ai_assistant/domain/repositories/ai_repository.dart';
import 'features/ai_assistant/domain/usecases/ai_usecases.dart';
import 'features/ai_assistant/presentation/cubit/ai_conversations_cubit.dart';
import 'features/ai_assistant/presentation/cubit/ai_chat_cubit.dart';

import 'features/workshop_progress/data/datasources/workshop_progress_remote_data_source.dart';
import 'features/workshop_progress/data/repositories/workshop_progress_repository_impl.dart';
import 'features/workshop_progress/domain/repositories/workshop_progress_repository.dart';
import 'features/workshop_progress/domain/usecases/workshop_progress_usecases.dart';
import 'features/workshop_progress/presentation/cubit/workshop_progress_cubit.dart';

import 'features/reports/data/datasources/reports_remote_data_source.dart';
import 'features/reports/data/repositories/reports_repository_impl.dart';
import 'features/reports/domain/repositories/reports_repository.dart';
import 'features/reports/domain/usecases/reports_usecases.dart';
import 'features/reports/presentation/cubit/vehicle_report_cubit.dart';

final sl = GetIt.instance;

/// Initialize all dependencies.
///
/// Must be called in main() with the SharedPreferences instance.
Future<void> initDependencies(SharedPreferences prefs) async {
  // ── Core ──────────────────────────────────────────────
  sl.registerLazySingleton<SessionStorage>(() => SessionStorage(prefs));
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: Connectivity()),
  );

  // ── Auth Feature ──────────────────────────────────────

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      sessionStorage: sl(),
      apiClient: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => Logout(sl()));

  // Cubit — singleton since it's app-wide
  sl.registerLazySingleton(
    () => AuthCubit(
      login: sl(),
      registerUser: sl(),
      logout: sl(),
      sessionStorage: sl(),
      apiClient: sl(),
    ),
  );

  // ── Profile Feature ───────────────────────────────────

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => UpdatePersonalInfo(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => UpdateNotificationPrefs(sl()));

  // Cubit — we use factory because profile screen can be created/destroyed
  sl.registerFactory(
    () => ProfileCubit(
      updatePersonalInfo: sl(),
      changePassword: sl(),
      updateNotificationPrefs: sl(),
    ),
  );

  // ── Company Feature ───────────────────────────────────

  // Usecases
  sl.registerLazySingleton(() => GetCompanyProfile(sl()));
  sl.registerLazySingleton(() => UpdateCompanyProfile(sl()));
  sl.registerLazySingleton(() => GetCurrentSubscription(sl()));
  sl.registerLazySingleton(() => GetAvailablePlans(sl()));
  sl.registerLazySingleton(() => ChangePlan(sl()));
  sl.registerLazySingleton(() => CreatePaymentIntent(sl()));
  sl.registerLazySingleton(() => ConfirmPayment(sl()));
  sl.registerLazySingleton(() => CancelScheduledChange(sl()));

  // Repository
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );

  // Bloc / Cubit
  sl.registerFactory(
    () => CompanyCubit(
      getCompanyProfile: sl(),
      updateCompanyProfile: sl(),
      getCurrentSubscription: sl(),
      getAvailablePlans: sl(),
      changePlan: sl(),
      createPaymentIntent: sl(),
      confirmPayment: sl(),
      cancelScheduledChange: sl(),
    ),
  );

  // ── Vehicle Feature ───────────────────────────────────

  // Usecases
  sl.registerLazySingleton(() => GetVehicles(sl()));
  sl.registerLazySingleton(() => CreateVehicle(sl()));
  sl.registerLazySingleton(() => UpdateVehicle(sl()));
  sl.registerLazySingleton(() => UpdateVehicleStatus(sl()));

  // Repository
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data source
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );

  // Cubit
  sl.registerFactory(
    () => VehicleCubit(
      getVehicles: sl(),
      createVehicle: sl(),
      updateVehicle: sl(),
      updateVehicleStatus: sl(),
    ),
  );

  // ── Service Catalog Feature ───────────────────────────

  // Usecases
  sl.registerLazySingleton(() => GetServices(sl()));
  sl.registerLazySingleton(() => CreateService(sl()));
  sl.registerLazySingleton(() => UpdateService(sl()));
  sl.registerLazySingleton(() => UpdateServiceStatus(sl()));

  // Repository
  sl.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data source
  sl.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );

  // Cubit
  sl.registerFactory(
    () => ServiceCubit(
      getServices: sl(),
      createService: sl(),
      updateService: sl(),
      updateServiceStatus: sl(),
    ),
  );

  // ── Workspace Feature ─────────────────────────────────

  // Usecases
  sl.registerLazySingleton(() => GetSpaces(sl()));
  sl.registerLazySingleton(() => CreateSpace(sl()));
  sl.registerLazySingleton(() => UpdateSpaceActive(sl()));
  sl.registerLazySingleton(() => GetSpaceSchedules(sl()));
  sl.registerLazySingleton(() => CreateSpaceSchedule(sl()));
  sl.registerLazySingleton(() => UpdateSpaceSchedule(sl()));

  // Repository
  sl.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data source
  sl.registerLazySingleton<WorkspaceRemoteDataSource>(
    () => WorkspaceRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );

  // Cubit
  sl.registerFactory(
    () => WorkspaceCubit(
      getSpaces: sl(),
      createSpace: sl(),
      updateSpaceActive: sl(),
      getSpaceSchedules: sl(),
      createSpaceSchedule: sl(),
      updateSpaceSchedule: sl(),
    ),
  );

  // ── Audit Feature ─────────────────────────────────────

  sl.registerLazySingleton(() => GetAuditLogs(sl()));
  sl.registerLazySingleton(() => GetAuditDetail(sl()));
  sl.registerLazySingleton(() => GetAuditSummary(sl()));

  sl.registerLazySingleton<AuditRepository>(
    () => AuditRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<AuditRemoteDataSource>(
    () => AuditRemoteDataSourceImpl(apiClient: sl(), sessionStorage: sl()),
  );

  sl.registerFactory(
    () => AuditCubit(
      getAuditLogs: sl(),
      getAuditDetail: sl(),
      getAuditSummary: sl(),
    ),
  );

  // ── User Management Feature ───────────────────────────

  sl.registerLazySingleton(() => GetUsers(sl()));
  sl.registerLazySingleton(() => CreateUser(sl()));
  sl.registerLazySingleton(() => GetUserDetail(sl()));
  sl.registerLazySingleton(() => ChangeUserRole(sl()));
  sl.registerLazySingleton(() => DeactivateUser(sl()));
  sl.registerLazySingleton(() => ActivateUser(sl()));
  sl.registerLazySingleton(() => GetRoles(sl()));

  sl.registerLazySingleton<UserManagementRepository>(
    () => UserManagementRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<UserManagementRemoteDataSource>(
    () => UserManagementRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );

  sl.registerFactory(
    () => UserManagementCubit(
      getUsers: sl(),
      getRoles: sl(),
      createUser: sl(),
      changeUserRole: sl(),
      activateUser: sl(),
      deactivateUser: sl(),
    ),
  );

  // ── Vehicle Plan Feature ─────────────────────────────

  sl.registerLazySingleton(() => GetVehiclePlans(sl()));
  sl.registerLazySingleton(() => GetVehiclePlanDetails(sl()));
  sl.registerLazySingleton(() => UpdateVehiclePlan(sl()));
  sl.registerLazySingleton(() => UpdateVehiclePlanStatus(sl()));
  sl.registerLazySingleton(() => CreateVehiclePlanDetail(sl()));
  sl.registerLazySingleton(() => UpdateVehiclePlanDetail(sl()));
  sl.registerLazySingleton(() => UpdateVehiclePlanDetailStatus(sl()));

  sl.registerLazySingleton<VehiclePlanRepository>(
    () => VehiclePlanRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<VehiclePlanRemoteDataSource>(
    () => VehiclePlanRemoteDataSourceImpl(apiClient: sl(), sessionStorage: sl()),
  );

  sl.registerFactory(
    () => VehiclePlanCubit(
      getVehiclePlans: sl(),
      getVehiclePlanDetails: sl(),
      updateVehiclePlan: sl(),
      updateVehiclePlanStatus: sl(),
      createVehiclePlanDetail: sl(),
      updateVehiclePlanDetail: sl(),
      updateVehiclePlanDetailStatus: sl(),
    ),
  );

  // ── Appointment Feature ───────────────────────────────

  sl.registerLazySingleton(() => GetAppointments(sl()));
  sl.registerLazySingleton(() => GetAppointmentDetail(sl()));
  sl.registerLazySingleton(() => CreateAppointment(sl()));
  sl.registerLazySingleton(() => CancelAppointment(sl()));
  sl.registerLazySingleton(() => RescheduleAppointment(sl()));
  sl.registerLazySingleton(() => MarkNoShowAppointment(sl()));

  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );

  sl.registerFactory(
    () => AppointmentCubit(
      getAppointments: sl(),
      getAppointmentDetail: sl(),
      createAppointment: sl(),
      cancelAppointment: sl(),
      rescheduleAppointment: sl(),
      markNoShow: sl(),
    ),
  );

  // ── Reception ─────────────────────────────────────────
  sl.registerLazySingleton<ReceptionRemoteDataSource>(
    () => ReceptionRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );
  sl.registerLazySingleton<ReceptionRepository>(
    () => ReceptionRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetReceptions(sl()));
  sl.registerLazySingleton(() => GetCitasPendientesRecepcion(sl()));
  sl.registerLazySingleton(() => CreateReception(sl()));
  sl.registerFactory(
    () => ReceptionCubit(
      getReceptions: sl(),
      getCitasPendientes: sl(),
      createReception: sl(),
    ),
  );

  // ── Budget (Presupuestos) ─────────────────────────────
  sl.registerLazySingleton<BudgetRemoteDataSource>(
    () => BudgetRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetBudgets(sl()));
  sl.registerLazySingleton(() => GetBudgetDetail(sl()));
  sl.registerLazySingleton(() => CreateBudget(sl()));
  sl.registerLazySingleton(() => UpdateBudget(sl()));
  sl.registerLazySingleton(() => ChangeBudgetStatus(sl()));
  sl.registerFactory(
    () => BudgetCubit(
      getBudgets: sl(),
      getBudgetDetail: sl(),
      createBudget: sl(),
      updateBudget: sl(),
      changeBudgetStatus: sl(),
    ),
  );

  // ── Work Orders (Órdenes de Trabajo) ─────────────────────────────
  sl.registerLazySingleton<WorkOrderRemoteDataSource>(
    () => WorkOrderRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );
  sl.registerLazySingleton<WorkOrderRepository>(
    () => WorkOrderRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetWorkOrders(sl()));
  sl.registerLazySingleton(() => GetWorkOrderDetail(sl()));
  sl.registerLazySingleton(() => GetAvailableMechanics(sl()));
  sl.registerLazySingleton(() => AssignMechanics(sl()));
  sl.registerLazySingleton(() => AssignDetails(sl()));
  sl.registerLazySingleton(() => StartWorkOrder(sl()));
  sl.registerFactory(
    () => WorkOrderCubit(
      getWorkOrders: sl(),
      getWorkOrderDetail: sl(),
      getAvailableMechanics: sl(),
      assignMechanics: sl(),
      assignDetails: sl(),
      startWorkOrder: sl(),
    ),
  );

  // ── Workshop Progress (Avance en Taller) ─────────────────────────────
  sl.registerLazySingleton<WorkshopProgressRemoteDataSource>(
    () => WorkshopProgressRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );
  sl.registerLazySingleton<WorkshopProgressRepository>(
    () => WorkshopProgressRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetActiveWorkOrders(sl()));
  sl.registerLazySingleton(() => GetProgressWorkOrderDetail(sl()));
  sl.registerLazySingleton(() => GetProgressHistory(sl()));
  sl.registerLazySingleton(() => StartService(sl()));
  sl.registerLazySingleton(() => PauseService(sl()));
  sl.registerLazySingleton(() => FinishService(sl()));
  sl.registerLazySingleton(() => MarkServiceUnnecessary(sl()));
  sl.registerLazySingleton(() => FinishWorkOrder(sl()));
  sl.registerLazySingleton(() => AddManualProgress(sl()));
  sl.registerFactory(
    () => WorkshopProgressCubit(
      getActiveWorkOrders: sl(),
      getWorkOrderDetail: sl(),
      getProgressHistory: sl(),
      startService: sl(),
      pauseService: sl(),
      finishService: sl(),
      markServiceUnnecessary: sl(),
      finishWorkOrder: sl(),
      addManualProgress: sl(),
    ),
  );
  // ── VEHICLE PROGRESS MODULE ──

  // Usecases
  sl.registerLazySingleton(() => GetOperativeAppointments(sl()));
  sl.registerLazySingleton(() => GetVehicleProgressDetail(sl()));
  sl.registerLazySingleton(() => RegisterVehicleArrival(sl()));
  sl.registerLazySingleton(() => MarkVehicleInProcess(sl()));
  sl.registerLazySingleton(() => MarkVehicleReturned(sl()));
  sl.registerLazySingleton(() => GetVehicleProgressHistory(sl()));
  sl.registerLazySingleton(() => AddManualGeneralProgress(sl()));

  // Repository
  sl.registerLazySingleton<VehicleProgressRepository>(
    () => VehicleProgressRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // DataSource
  sl.registerLazySingleton<VehicleProgressRemoteDataSource>(
    () => VehicleProgressRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );

  // Cubit
  sl.registerFactory(
    () => VehicleProgressCubit(
      getAppointments: sl(),
      getDetail: sl(),
      registerArrival: sl(),
      markInProcess: sl(),
      markReturned: sl(),
      getHistory: sl(),
      addManualProgress: sl(),
    ),
  );

  // ── AI Assistant ──────────────────────────────────────

  // Cubits
  sl.registerFactory(
    () => AiConversationsCubit(
      getAiConversations: sl(),
      createAiConversation: sl(),
      archiveAiConversation: sl(),
    ),
  );

  sl.registerFactory(
    () => AiChatCubit(
      getAiConversationDetail: sl(),
      sendAiMessage: sl(),
      confirmAiAction: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAiConversations(sl()));
  sl.registerLazySingleton(() => CreateAiConversation(sl()));
  sl.registerLazySingleton(() => GetAiConversationDetail(sl()));
  sl.registerLazySingleton(() => ArchiveAiConversation(sl()));
  sl.registerLazySingleton(() => SendAiMessage(sl()));
  sl.registerLazySingleton(() => ConfirmAiAction(sl()));

  // Repository
  sl.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // DataSource
  sl.registerLazySingleton<AiRemoteDataSource>(
    () => AiRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );

  // ── Reports ───────────────────────────────────────────

  // Cubits
  sl.registerFactory(
    () => VehicleReportCubit(
      getTopVehicles: sl(),
      getVehicleReport: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetTopVehicles(sl()));
  sl.registerLazySingleton(() => GetVehicleReport(sl()));

  // Repository
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // DataSource
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(
      apiClient: sl(),
      sessionStorage: sl(),
    ),
  );
}
