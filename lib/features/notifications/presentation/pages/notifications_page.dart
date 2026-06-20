import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/notifications/domain/entities/app_notification.dart';
import 'package:mobile1_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mobile1_app/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().fetchInitial();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsCubit, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Centro de Notificaciones',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () => context.read<NotificationsCubit>().refresh(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsInitial || state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final notifications = state is NotificationsLoaded
                ? state.notifications
                : state is NotificationsError
                    ? state.notifications
                    : <AppNotification>[];

            final summary = state is NotificationsLoaded
                ? state.summary
                : state is NotificationsError
                    ? state.summary
                    : null;

            final soloNoLeidas = state is NotificationsLoaded
                ? state.soloNoLeidas
                : state is NotificationsError
                    ? state.soloNoLeidas
                    : false;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummary(summary?.total ?? 0, summary?.noLeidas ?? 0),
                const SizedBox(height: 12),
                _buildToolbar(context, soloNoLeidas),
                const SizedBox(height: 12),
                if (notifications.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text(
                      'No hay notificaciones para mostrar.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  ...notifications.map(_buildNotificationCard),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(int total, int noLeidas) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard('Total', total.toString()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard('No leídas', noLeidas.toString()),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, bool soloNoLeidas) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: soloNoLeidas,
          onSelected: (value) =>
              context.read<NotificationsCubit>().toggleSoloNoLeidas(value),
          label: const Text('Solo no leídas'),
          labelStyle: const TextStyle(color: Colors.white),
          selectedColor: AppColors.primary.withValues(alpha: 0.35),
          backgroundColor: AppColors.darkCard,
          side: const BorderSide(color: Colors.white12),
        ),
        ElevatedButton.icon(
          onPressed: () => context.read<NotificationsCubit>().marcarTodasLeidas(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.done_all, size: 18),
          label: const Text('Marcar todas leídas'),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final formattedDate = notification.createdAt == null
        ? 'Sin fecha'
        : DateFormat('dd/MM/yyyy HH:mm').format(notification.createdAt!.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.leida
              ? AppColors.darkCard
              : const Color(0xFF1B2843),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.leida
                ? Colors.white12
                : AppColors.primary.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (!notification.leida)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Nueva',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification.mensaje,
              style: const TextStyle(color: Colors.white70, height: 1.45),
            ),
            const SizedBox(height: 10),
            Text(
              '${notification.tipo.toLowerCase()} • $formattedDate',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            if (!notification.leida) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () =>
                      context.read<NotificationsCubit>().marcarLeida(notification.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: const Text('Marcar leída'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
