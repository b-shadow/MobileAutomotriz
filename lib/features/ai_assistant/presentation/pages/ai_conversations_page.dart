import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import '../cubit/ai_conversations_cubit.dart';

class AiConversationsPage extends StatefulWidget {
  const AiConversationsPage({super.key});

  @override
  State<AiConversationsPage> createState() => _AiConversationsPageState();
}

class _AiConversationsPageState extends State<AiConversationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AiConversationsCubit>().fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Asistente IA'),
      ),
      body: BlocConsumer<AiConversationsCubit, AiConversationsState>(
        listener: (context, state) {
          if (state is AiConversationsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: AppColors.error,
              content: Text(state.message),
            ));
          }
        },
        builder: (context, state) {
          if (state is AiConversationsLoading && state is! AiConversationsLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is AiConversationsLoaded) {
            final conversations = state.conversations;
            if (conversations.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return _buildConversationCard(conv, context);
              },
            );
          }
          return Center(child: Text('Error al cargar conversaciones', style: TextStyle(color: AppColors.darkTextSecondary)));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewConversation(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: const Text('Nuevo Chat', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy, size: 80, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          const Text(
            '¡Hola! Soy tu Asistente Inteligente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Inicia un nuevo chat para consultarme sobre citas,\nvehículos, presupuestos y más.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(dynamic conv, BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: InkWell(
        onTap: () {
          context.push('/ai/chat/${conv.id}');
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Conversación',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          dateFormat.format(conv.updatedAt.toLocal()),
                          style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${conv.numMensajes} mensajes',
                      style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                color: AppColors.darkCard,
                onSelected: (value) {
                  if (value == 'archivar') {
                    context.read<AiConversationsCubit>().archive(conv.id);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'archivar',
                    child: Row(
                      children: [
                        Icon(Icons.archive, size: 20, color: AppColors.darkTextTertiary),
                        const SizedBox(width: 8),
                        Text('Archivar', style: TextStyle(color: AppColors.darkTextPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startNewConversation(BuildContext context) {
    // Escuchamos el estado cargando y cuando se crea, navegamos
    context.read<AiConversationsCubit>().createConversation();
    // Navegación se maneja idealmente con el estado, pero aquí para simplificar
    // esperamos un breve instante o mostramos un loader si fuera muy necesario,
    // pero como el Cubit actualizará el estado, la lista se refrescará
    // y el usuario podrá tocarla. O podemos navegar al último creado.
  }
}
