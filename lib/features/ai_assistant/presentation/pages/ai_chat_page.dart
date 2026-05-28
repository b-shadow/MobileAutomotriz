import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../cubit/ai_chat_cubit.dart';

class AiChatPage extends StatefulWidget {
  final String conversationId;

  const AiChatPage({super.key, required this.conversationId});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Audio & TTS
  late final AudioRecorder _audioRecorder;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isRecording = false;
  bool _isVoiceEnabled = true;
  String? _lastSpokenMessageId;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _initTts();
    context.read<AiChatCubit>().fetchDetail(widget.conversationId);
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage([String? text]) {
    final message = text ?? _textController.text.trim();
    if (message.isNotEmpty) {
      context.read<AiChatCubit>().sendMessage(widget.conversationId, message);
      _textController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _recordingPath = '${dir.path}/voice_input_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: _recordingPath!,
        );

        setState(() {
          _isRecording = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de micrófono denegado', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        context.read<AiChatCubit>().sendAudioMessage(widget.conversationId, path);
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    } catch (e) {
      debugPrint('Error stopping record: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _toggleVoice() {
    setState(() {
      _isVoiceEnabled = !_isVoiceEnabled;
    });
    if (!_isVoiceEnabled) {
      _flutterTts.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 8),
            Text('Asistente Virtual'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isVoiceEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleVoice,
            tooltip: _isVoiceEnabled ? 'Desactivar Voz' : 'Activar Voz',
          ),
          PopupMenuButton<String>(
            color: AppColors.darkCard,
            onSelected: (value) async {
              if (value == 'clear') {
                final success = await context.read<AiChatCubit>().clearChat(widget.conversationId);
                if (success && context.mounted) {
                  context.replace('/ai');
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services, size: 20, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('Limpiar Chat', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (context, state) {
          if (state is AiChatError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: AppColors.error,
              content: Text(state.message),
            ));
          }
          if (state is AiChatLoaded) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
            
            // Speak if voice enabled, it's a new message from AI, and not waiting for AI
            if (!state.isWaitingForAi && state.conversation.mensajes.isNotEmpty) {
              final lastMsg = state.conversation.mensajes.last;
              if (lastMsg.sender == 'ai' && _lastSpokenMessageId != lastMsg.id) {
                _lastSpokenMessageId = lastMsg.id;
                if (_isVoiceEnabled) {
                  _flutterTts.speak(lastMsg.text);
                }
              }
            }
          }
        },
        builder: (context, state) {
          if (state is AiChatInitial || (state is AiChatLoading && state is! AiChatLoaded)) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is AiChatLoaded) {
            final mensajes = state.conversation.mensajes;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: mensajes.length + (state.isWaitingForAi ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == mensajes.length && state.isWaitingForAi) {
                        return _buildTypingIndicator();
                      }
                      final msg = mensajes[index];
                      final isMe = msg.sender == 'user';
                      return _buildChatBubble(msg.text, isMe, msg.createdAt);
                    },
                  ),
                ),
                if (state.currentSuggestedActions.isNotEmpty)
                  _buildSuggestedActions(state.currentSuggestedActions),
                _buildMessageInput(state.isWaitingForAi),
              ],
            );
          }

          return Center(child: Text('Error al cargar la conversación', style: TextStyle(color: AppColors.darkTextSecondary)));
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text('Escribiendo...', style: TextStyle(color: AppColors.darkTextTertiary, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, DateTime time) {
    final dateFormat = DateFormat('HH:mm');

    final Color bubbleColor;
    final Color textColor;
    final Color timeColor;

    if (isMe) {
      bubbleColor = AppColors.primary;
      textColor = Colors.white;
      timeColor = Colors.white70;
    } else {
      bubbleColor = AppColors.darkCard;
      textColor = AppColors.darkTextPrimary;
      timeColor = AppColors.darkTextTertiary;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(time.toLocal()),
              style: TextStyle(color: timeColor, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedActions(List<String> actions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(action, style: const TextStyle(color: AppColors.primary)),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              onPressed: () => _sendMessage(action),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageInput(bool isWaiting) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !isWaiting,
                style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: _isRecording ? 'Escuchando...' : 'Escribe un mensaje...',
                  hintStyle: TextStyle(
                    color: _isRecording ? AppColors.error : AppColors.darkTextTertiary,
                    fontStyle: _isRecording ? FontStyle.italic : FontStyle.normal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.darkSurfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                onChanged: (text) {
                  setState(() {}); // For rebuilding to switch icon if text is present
                },
              ),
            ),
            const SizedBox(width: 8),
            _textController.text.isNotEmpty
              ? CircleAvatar(
                  backgroundColor: isWaiting ? AppColors.darkTextTertiary : AppColors.primary,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: isWaiting ? null : _sendMessage,
                  ),
                )
              : GestureDetector(
                  onTapDown: (_) => isWaiting ? null : _startRecording(),
                  onTapUp: (_) => isWaiting ? null : _stopRecording(),
                  onTapCancel: () => isWaiting ? null : _stopRecording(),
                  child: CircleAvatar(
                    backgroundColor: _isRecording ? AppColors.error : (isWaiting ? AppColors.darkTextTertiary : AppColors.darkSurfaceVariant),
                    radius: 24,
                    child: Icon(
                      Icons.mic, 
                      color: _isRecording ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
