import '../../../../core/error/result.dart';
import '../repositories/reports_repository.dart';

class TranscribeReportAudio {
  final ReportsRepository repository;

  TranscribeReportAudio(this.repository);

  Future<Result<String>> call(String filePath) {
    return repository.transcribeAudioForReport(filePath);
  }
}
