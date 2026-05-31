import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/purchases/domain/entities/purchase_entity.dart';
import 'package:mobile1_app/features/purchases/domain/repositories/purchases_repository.dart';

class GetPurchases implements UseCase<List<Purchase>, NoParams> {
  final PurchasesRepository repository;
  GetPurchases(this.repository);

  @override
  Future<Result<List<Purchase>>> call(NoParams params) => repository.getPurchases();
}

class CreatePurchase implements UseCase<Purchase, PurchaseInput> {
  final PurchasesRepository repository;
  CreatePurchase(this.repository);

  @override
  Future<Result<Purchase>> call(PurchaseInput params) => repository.createPurchase(params);
}

class MarkPurchaseReceived {
  final PurchasesRepository repository;
  MarkPurchaseReceived(this.repository);

  Future<Result<Purchase>> call(String purchaseId) => repository.markAsReceived(purchaseId);
}
