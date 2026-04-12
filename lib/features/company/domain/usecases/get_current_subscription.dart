import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/company/domain/entities/subscription.dart';
import 'package:mobile1_app/features/company/domain/repositories/company_repository.dart';

class GetCurrentSubscription implements UseCase<Subscription, NoParams> {
  final CompanyRepository repository;

  const GetCurrentSubscription(this.repository);

  @override
  Future<Result<Subscription>> call(NoParams params) async {
    return await repository.getCurrentSubscription();
  }
}
