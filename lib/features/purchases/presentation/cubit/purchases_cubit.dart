import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/purchases/domain/entities/purchase_entity.dart';
import 'package:mobile1_app/features/purchases/domain/usecases/purchases_usecases.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';
import 'package:mobile1_app/features/supplier/domain/usecases/get_suppliers.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';
import 'package:mobile1_app/features/inventory/domain/usecases/get_inventory_items.dart';
import 'purchases_state.dart';

class PurchasesCubit extends Cubit<PurchasesState> {
  final GetPurchases _getPurchases;
  final CreatePurchase _createPurchase;
  final MarkPurchaseReceived _markPurchaseReceived;
  final GetSuppliers _getSuppliers;
  final GetInventoryItems _getInventoryItems;

  List<Purchase> _purchases = const [];
  List<Supplier> _suppliers = const [];
  List<InventoryItem> _items = const [];

  PurchasesCubit({
    required GetPurchases getPurchases,
    required CreatePurchase createPurchase,
    required MarkPurchaseReceived markPurchaseReceived,
    required GetSuppliers getSuppliers,
    required GetInventoryItems getInventoryItems,
  })  : _getPurchases = getPurchases,
        _createPurchase = createPurchase,
        _markPurchaseReceived = markPurchaseReceived,
        _getSuppliers = getSuppliers,
        _getInventoryItems = getInventoryItems,
        super(const PurchasesInitial());

  Future<void> fetchAll() async {
    emit(PurchasesLoading(
        purchases: _purchases, suppliers: _suppliers, items: _items));

    final results = await Future.wait<dynamic>([
      _getPurchases(const NoParams()),
      _getSuppliers(const NoParams()),
      _getInventoryItems(const NoParams()),
    ]);

    final purchResult = results[0] as Result<List<Purchase>>;
    final suppResult = results[1] as Result<List<Supplier>>;
    final invResult = results[2] as Result<List<dynamic>>;

    if (purchResult is Success<List<Purchase>>) {
      _purchases = purchResult.data;
    } else if (purchResult is Err<List<Purchase>>) {
      emit(PurchasesError(
        purchases: _purchases,
        suppliers: _suppliers,
        items: _items,
        message: purchResult.failure.message,
      ));
      return;
    }

    if (suppResult is Success<List<Supplier>>) {
      _suppliers = suppResult.data;
    }

    if (invResult is Success<List<dynamic>>) {
      // Mapping the general inventory entities to InventoryItem needed for selection
      // Since GetInventory returns List<InventoryItemEntity>, we convert it.
      // But actually InventoryItemEntity and InventoryItem from spare_part_entities are similar.
      // We'll just fetch from API or map it.
      // Let's assume we map it.
      _items = invResult.data.map((e) {
        return InventoryItem(
          id: e.id,
          codigo: e.codigo,
          nombre: e.nombre,
          stockActual: e.stockActual,
          activo: e.activo,
        );
      }).toList();
    }

    emit(PurchasesLoaded(
      purchases: _purchases,
      suppliers: _suppliers,
      items: _items,
    ));
  }

  void _replaceInList(Purchase updated) {
    _purchases = _purchases.map((s) => s.id == updated.id ? updated : s).toList();
  }

  Future<void> create(PurchaseInput input) async {
    emit(PurchasesLoading(
        purchases: _purchases, suppliers: _suppliers, items: _items));

    final result = await _createPurchase(input);

    switch (result) {
      case Success(:final data):
        _purchases = [data, ..._purchases];
        emit(PurchasesSuccess(
          purchases: _purchases,
          suppliers: _suppliers,
          items: _items,
          message: 'Compra creada exitosamente.',
        ));
      case Err(:final failure):
        emit(PurchasesError(
          purchases: _purchases,
          suppliers: _suppliers,
          items: _items,
          message: failure.message,
        ));
    }
  }

  Future<void> markReceived(String purchaseId) async {
    emit(PurchasesLoading(
        purchases: _purchases, suppliers: _suppliers, items: _items));

    final result = await _markPurchaseReceived(purchaseId);

    switch (result) {
      case Success(:final data):
        _replaceInList(data);
        emit(PurchasesSuccess(
          purchases: _purchases,
          suppliers: _suppliers,
          items: _items,
          message: 'Compra marcada como recibida.',
        ));
      case Err(:final failure):
        emit(PurchasesError(
          purchases: _purchases,
          suppliers: _suppliers,
          items: _items,
          message: failure.message,
        ));
    }
  }
}
