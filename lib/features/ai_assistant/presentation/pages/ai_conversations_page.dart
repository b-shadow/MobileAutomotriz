import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Asistente IA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF4F46E5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<AiConversationsCubit, AiConversationsState>(
        listener: (context, state) {
          if (state is AiConversationsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFFEF4444),
              content: Text(state.message),
            ));
          }
        },
        builder: (context, state) {
          if (state is AiConversationsLoading && state is! AiConversationsLoaded) {
            return const Center(child: CircularProgressIndicator());
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
          return const Center(child: Text('Error al cargar conversaciones'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewConversation(context),
        backgroundColor: const Color(0xFF4F46E5),
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
          Icon(Icons.smart_toy, size: 80, color: Colors.indigo[200]),
          const SizedBox(height: 24),
          const Text(
            '¡Hola! Soy tu Asistente Inteligente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Inicia un nuevo chat para consultarme sobre citas,\nvehículos, presupuestos y más.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(dynamic conv, BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/ai/chat/${conv.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy, color: Colors.indigo),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          dateFormat.format(conv.updatedAt.toLocal()),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${conv.numMensajes} mensajes',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'archivar') {
                    context.read<AiConversationsCubit>().archive(conv.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'archivar',
                    child: Row(
                      children: [
                        Icon(Icons.archive, size: 20, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Archivar'),
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
