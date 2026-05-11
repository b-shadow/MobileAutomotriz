import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

import '../../features/company/presentation/pages/company_page.dart';
import '../../features/company/presentation/cubit/company_cubit.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/vehicle/presentation/pages/vehicle_page.dart';
import '../../features/vehicle/presentation/cubit/vehicle_cubit.dart';
import '../../features/service/presentation/pages/service_catalog_page.dart';
import '../../features/service/presentation/cubit/service_cubit.dart';
import '../../features/workspace/presentation/pages/workspace_management_page.dart';
import '../../features/workspace/presentation/cubit/workspace_cubit.dart';
import '../../features/audit/presentation/pages/audit_page.dart';
import '../../features/audit/presentation/cubit/audit_cubit.dart';
import '../../features/user_management/presentation/pages/user_management_page.dart';
import '../../features/user_management/presentation/cubit/user_management_cubit.dart';
import '../../features/vehicle_plan/presentation/pages/vehicle_plan_page.dart';
import '../../features/vehicle_plan/presentation/cubit/vehicle_plan_cubit.dart';
import '../../features/appointment/presentation/pages/appointment_page.dart';
import '../../features/appointment/presentation/cubit/appointment_cubit.dart';
import '../../features/reception/presentation/pages/reception_page.dart';
import '../../features/reception/presentation/cubit/reception_cubit.dart';
import '../../features/budget/presentation/pages/budget_page.dart';
import '../../features/budget/presentation/pages/budget_detail_page.dart';
import '../../features/budget/presentation/cubit/budget_cubit.dart';
import '../../features/work_order/presentation/pages/work_order_page.dart';
import '../../features/work_order/presentation/pages/work_order_detail_page.dart';
import '../../features/work_order/presentation/cubit/work_order_cubit.dart';
import '../../features/workshop_progress/presentation/pages/workshop_progress_page.dart';
import '../../features/workshop_progress/presentation/pages/workshop_progress_detail_page.dart';
import '../../features/workshop_progress/presentation/cubit/workshop_progress_cubit.dart';
import '../../features/vehicle_progress/presentation/pages/vehicle_progress_page.dart';
import '../../features/vehicle_progress/presentation/pages/vehicle_progress_detail_page.dart';
import '../../features/vehicle_progress/presentation/cubit/vehicle_progress_cubit.dart';

import '../../features/ai_assistant/presentation/pages/ai_conversations_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_chat_page.dart';
import '../../features/ai_assistant/presentation/cubit/ai_conversations_cubit.dart';
import '../../features/ai_assistant/presentation/cubit/ai_chat_cubit.dart';

import '../../features/reports/presentation/pages/vehicle_reports_page.dart';
import '../../features/reports/presentation/cubit/vehicle_report_cubit.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../injection_container.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/auth/data/models/usuario_model.dart';

/// Centralized app routing with auth guards.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: _authGuard,
    routes: [
      // ── Splash ───────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => SplashPage(
          onFinished: () {
            final isLoggedIn = sl<SessionStorage>().isLoggedIn;
            if (isLoggedIn) {
              context.go('/home');
            } else {
              context.go('/login');
            }
          },
        ),
      ),

      // ── Auth ─────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Home ─────────────────────────────────────────
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // ── Profile ───────────────────────────────────────
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ProfileCubit>(),
          child: const ProfilePage(),
        ),
      ),

      // ── Company ───────────────────────────────────────
      GoRoute(
        path: '/company-management',
        name: 'company-management',
        redirect: (context, state) {
          final userData = sl<SessionStorage>().userData;
          if (userData != null) {
            final user = UsuarioModel.fromJson(userData);
            if (!user.isAdmin) {
              return '/home'; // fallback if not admin
            }
          }
          return null;
        },
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CompanyCubit>(),
          child: const CompanyPage(),
        ),
      ),

      GoRoute(
        path: '/subscription-management',
        name: 'subscription-management',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CompanyCubit>(),
          child: const SubscriptionPage(),
        ),
      ),

      GoRoute(
        path: '/vehicle-management',
        name: 'vehicle-management',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<VehicleCubit>(),
          child: const VehiclePage(),
        ),
      ),

      GoRoute(
        path: '/service-catalog-management',
        name: 'service-catalog-management',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ServiceCubit>(),
          child: const ServiceCatalogPage(),
        ),
      ),

      GoRoute(
        path: '/workspace-management',
        name: 'workspace-management',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<WorkspaceCubit>(),
          child: const WorkspaceManagementPage(),
        ),
      ),

      GoRoute(
        path: '/audit-management',
        name: 'audit-management',
        redirect: (context, state) {
          final userData = sl<SessionStorage>().userData;
          if (userData != null) {
            final user = UsuarioModel.fromJson(userData);
            if (!user.isAdmin) return '/home';
          }
          return null;
        },
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuditCubit>(),
          child: const AuditPage(),
        ),
      ),

      GoRoute(
        path: '/user-management',
        name: 'user-management',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<UserManagementCubit>(),
          child: const UserManagementPage(),
        ),
      ),

      GoRoute(
        path: '/vehicle-plan-management',
        name: 'vehicle-plan-management',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<VehiclePlanCubit>(),
          child: const VehiclePlanPage(),
        ),
      ),

      GoRoute(
        path: '/appointment-management',
        name: 'appointment-management',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AppointmentCubit>(),
          child: const AppointmentPage(),
        ),
      ),

      GoRoute(
        path: '/reception-management',
        name: 'reception-management',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ReceptionCubit>(),
          child: const ReceptionPage(),
        ),
      ),

      GoRoute(
        path: '/budget-management',
        name: 'budget-management',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<BudgetCubit>()),
            BlocProvider(create: (context) => sl<AppointmentCubit>()),
          ],
          child: const BudgetPage(),
        ),
      ),

      GoRoute(
        path: '/budget-detail/:id',
        name: 'budget-detail',
        builder: (context, state) {
          final budgetId = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) => sl<BudgetCubit>(),
            child: BudgetDetailPage(budgetId: budgetId),
          );
        },
      ),

      GoRoute(
        path: '/work-orders',
        name: 'work-orders',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<WorkOrderCubit>(),
          child: const WorkOrderPage(),
        ),
      ),

      GoRoute(
        path: '/work-order-detail/:id',
        name: 'work-order-detail',
        builder: (context, state) {
          final workOrderId = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) => sl<WorkOrderCubit>(),
            child: WorkOrderDetailPage(workOrderId: workOrderId),
          );
        },
      ),

      GoRoute(
        path: '/workshop-progress',
        name: 'workshop-progress',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<WorkshopProgressCubit>(),
          child: const WorkshopProgressPage(),
        ),
      ),

      GoRoute(
        path: '/workshop-progress-detail/:id',
        name: 'workshop-progress-detail',
        builder: (context, state) {
          final workOrderId = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) => sl<WorkshopProgressCubit>(),
            child: WorkshopProgressDetailPage(workOrderId: workOrderId),
          );
        },
      ),

      GoRoute(
        path: '/vehicle-progress',
        name: 'vehicle-progress',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<VehicleProgressCubit>(),
          child: const VehicleProgressPage(),
        ),
      ),

      GoRoute(
        path: '/vehicle-progress-detail/:id',
        name: 'vehicle-progress-detail',
        builder: (context, state) {
          final citaId = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) => sl<VehicleProgressCubit>(),
            child: VehicleProgressDetailPage(citaId: citaId),
          );
        },
      ),
      GoRoute(
        path: '/ai',
        name: 'ai-conversations',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AiConversationsCubit>(),
          child: const AiConversationsPage(),
        ),
      ),

      GoRoute(
        path: '/ai/chat/:id',
        name: 'ai-chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) => sl<AiChatCubit>(),
            child: AiChatPage(conversationId: conversationId),
          );
        },
      ),

      GoRoute(
        path: '/reports/vehicle',
        name: 'reports-vehicle',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<VehicleReportCubit>(),
          child: const VehicleReportsPage(),
        ),
      ),
    ],
  );

  /// Auth guard — redirects to login if not authenticated.
  static String? _authGuard(BuildContext context, GoRouterState state) {
    final isLoggedIn = sl<SessionStorage>().isLoggedIn;
    final location = state.matchedLocation;

    // These routes don't require auth
    const publicRoutes = ['/splash', '/login', '/register'];
    if (publicRoutes.contains(location)) return null;

    // Everything else requires auth
    if (!isLoggedIn) return '/login';

    return null;
  }
}
