import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
        title: const Text('Cargando Asistente...'),
      ),
      body: BlocConsumer<AiConversationsCubit, AiConversationsState>(
        listener: (context, state) {
          if (state is AiConversationsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: AppColors.error,
              content: Text(state.message),
            ));
          }
          if (state is AiConversationsLoaded) {
            if (state.conversations.isNotEmpty) {
              context.replace('/ai/chat/${state.conversations.first.id}');
            } else {
              context.read<AiConversationsCubit>().createConversation();
            }
          }
        },
        builder: (context, state) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 24),
                Text(
                  'Conectando con IA...',
                  style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
