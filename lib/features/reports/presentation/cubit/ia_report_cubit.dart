import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/ia_report_result.dart';
import '../../domain/usecases/ask_ia_report.dart';
import '../../domain/usecases/transcribe_report_audio.dart';
import '../../../../core/error/result.dart';

// ── States ──────────────────────────────────────────────────────────────────

abstract class IaReportState extends Equatable {
  const IaReportState();

  @override
  List<Object?> get props => [];
}

class IaReportInitial extends IaReportState {}

class IaReportLoading extends IaReportState {}

class IaReportTranscribing extends IaReportState {}

class IaReportTranscribed extends IaReportState {
  final String text;

  const IaReportTranscribed({required this.text});

  @override
  List<Object?> get props => [text];
}

class IaReportLoaded extends IaReportState {
  final IaReportResult result;
  final String prompt;

  const IaReportLoaded({required this.result, required this.prompt});

  @override
  List<Object?> get props => [result, prompt];
}

class IaReportError extends IaReportState {
  final String message;

  const IaReportError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────────────────────

class IaReportCubit extends Cubit<IaReportState> {
  final AskIaReport askIaReport;
  final TranscribeReportAudio transcribeReportAudio;

  IaReportCubit({
    required this.askIaReport,
    required this.transcribeReportAudio,
  }) : super(IaReportInitial());

  /// Sends a natural-language prompt and loads the AI-generated report.
  Future<void> ask(String prompt) async {
    emit(IaReportLoading());

    final result = await askIaReport(prompt);

    switch (result) {
      case Success(:final data):
        emit(IaReportLoaded(result: data, prompt: prompt));
        break;
      case Err(:final failure):
        emit(IaReportError(message: failure.message));
        break;
    }
  }

  /// Transcribes an audio file to text (updates state so UI can show text).
  Future<void> transcribe(String audioPath) async {
    emit(IaReportTranscribing());

    final result = await transcribeReportAudio(audioPath);

    switch (result) {
      case Success(:final data):
        if (data.trim().isEmpty) {
          emit(const IaReportError(
            message: 'No se detectó texto en el audio. Habla más cerca del micrófono.',
          ));
        } else {
          emit(IaReportTranscribed(text: data.trim()));
        }
        break;
      case Err(:final failure):
        emit(IaReportError(message: failure.message));
        break;
    }
  }

  /// Convenience: transcribe audio then auto-ask the resulting text.
  Future<void> transcribeAndAsk(String audioPath) async {
    emit(IaReportTranscribing());

    final transcribeResult = await transcribeReportAudio(audioPath);

    switch (transcribeResult) {
      case Success(:final data):
        if (data.trim().isEmpty) {
          emit(const IaReportError(
            message: 'No se detectó texto en el audio. Habla más cerca del micrófono.',
          ));
          return;
        }
        // Now ask with the transcribed text
        await ask(data.trim());
        break;
      case Err(:final failure):
        emit(IaReportError(message: failure.message));
        break;
    }
  }

  /// Resets to initial empty state.
  void reset() {
    emit(IaReportInitial());
  }
}
