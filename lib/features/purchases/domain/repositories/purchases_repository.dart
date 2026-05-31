import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/purchases/domain/entities/purchase_entity.dart';

abstract class PurchasesRepository {
  Future<Result<List<Purchase>>> getPurchases();

  Future<Result<Purchase>> createPurchase(PurchaseInput input);

  Future<Result<Purchase>> markAsReceived(String purchaseId);
}
