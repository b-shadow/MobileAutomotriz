import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_category.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_item.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:mobile1_app/features/inventory/domain/usecases/adjust_stock.dart';
import 'package:mobile1_app/features/inventory/domain/usecases/create_category.dart';
import 'package:mobile1_app/features/inventory/domain/usecases/create_inventory_item.dart';
import 'package:mobile1_app/features/inventory/domain/usecases/get_categories.dart';
import 'package:mobile1_app/features/inventory/domain/usecases/get_inventory_items.dart';
import 'package:mobile1_app/features/inventory/domain/usecases/get_movements.dart';
import 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final GetCategories _getCategories;
  final CreateCategory _createCategory;
  final GetInventoryItems _getInventoryItems;
  final CreateInventoryItem _createInventoryItem;
  final AdjustStock _adjustStock;
  final GetMovements _getMovements;

  List<InventoryItem> _items = const [];
  List<InventoryCategory> _categories = const [];
  List<InventoryMovement> _movements = const [];

  InventoryCubit({
    required GetCategories getCategories,
    required CreateCategory createCategory,
    required GetInventoryItems getInventoryItems,
    required CreateInventoryItem createInventoryItem,
    required AdjustStock adjustStock,
    required GetMovements getMovements,
  })  : _getCategories = getCategories,
        _createCategory = createCategory,
        _getInventoryItems = getInventoryItems,
        _createInventoryItem = createInventoryItem,
        _adjustStock = adjustStock,
        _getMovements = getMovements,
        super(const InventoryInitial());

  /// Fetches categories, items and movements in parallel.
  Future<void> fetchAll() async {
    emit(InventoryLoading(
      items: _items,
      categories: _categories,
      movements: _movements,
    ));

    final results = await Future.wait([
      _getCategories(const NoParams()),
      _getInventoryItems(const NoParams()),
      _getMovements(const NoParams()),
    ]);

    final catResult = results[0] as Result<List<InventoryCategory>>;
    final itemResult = results[1] as Result<List<InventoryItem>>;
    final movResult = results[2] as Result<List<InventoryMovement>>;

    // Check for failures
    String? error;
    switch (catResult) {
      case Success(:final data):
        _categories = data;
      case Err(:final failure):
        error = failure.message;
    }
    switch (itemResult) {
      case Success(:final data):
        _items = data;
      case Err(:final failure):
        error ??= failure.message;
    }
    switch (movResult) {
      case Success(:final data):
        _movements = data;
      case Err(:final failure):
        error ??= failure.message;
    }

    if (error != null) {
      emit(InventoryError(
        items: _items,
        categories: _categories,
        movements: _movements,
        message: error,
      ));
    } else {
      emit(InventoryLoaded(
        items: _items,
        categories: _categories,
        movements: _movements,
      ));
    }
  }

  Future<void> createCategory({
    required String nombre,
    String? descripcion,
  }) async {
    emit(InventoryLoading(
      items: _items,
      categories: _categories,
      movements: _movements,
    ));

    final result = await _createCategory(
      CreateCategoryParams(nombre: nombre, descripcion: descripcion),
    );

    switch (result) {
      case Success(:final data):
        _categories = [..._categories, data];
        emit(InventorySuccess(
          items: _items,
          categories: _categories,
          movements: _movements,
          message: 'Categoría creada exitosamente.',
        ));
      case Err(:final failure):
        emit(InventoryError(
          items: _items,
          categories: _categories,
          movements: _movements,
          message: failure.message,
        ));
    }
  }

  Future<void> createItem({
    required String categoria,
    required String codigo,
    required String nombre,
    String? descripcion,
    required String tipoItem,
    required String unidadMedida,
    int stockActual = 0,
    int stockMinimo = 0,
    double costoPromedio = 0,
    double precioVenta = 0,
  }) async {
    emit(InventoryLoading(
      items: _items,
      categories: _categories,
      movements: _movements,
    ));

    final result = await _createInventoryItem(CreateInventoryItemParams(
      categoria: categoria,
      codigo: codigo,
      nombre: nombre,
      descripcion: descripcion,
      tipoItem: tipoItem,
      unidadMedida: unidadMedida,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      costoPromedio: costoPromedio,
      precioVenta: precioVenta,
    ));

    switch (result) {
      case Success(:final data):
        _items = [..._items, data];
        emit(InventorySuccess(
          items: _items,
          categories: _categories,
          movements: _movements,
          message: 'Item creado exitosamente.',
        ));
      case Err(:final failure):
        emit(InventoryError(
          items: _items,
          categories: _categories,
          movements: _movements,
          message: failure.message,
        ));
    }
  }

  Future<void> adjustStock({
    required String itemId,
    required String tipoMovimiento,
    required int cantidad,
    int? cantidadAjuste,
    String? observacion,
  }) async {
    emit(InventoryLoading(
      items: _items,
      categories: _categories,
      movements: _movements,
    ));

    final result = await _adjustStock(AdjustStockParams(
      itemId: itemId,
      tipoMovimiento: tipoMovimiento,
      cantidad: cantidad,
      cantidadAjuste: cantidadAjuste,
      observacion: observacion,
    ));

    switch (result) {
      case Success(:final data):
        _movements = [data, ..._movements];
        // Update the item's stock in our local list
        final idx = _items.indexWhere((i) => i.id == itemId);
        if (idx != -1) {
          // Re-fetch all data to get accurate stock values
          await fetchAll();
          return;
        }
        emit(InventorySuccess(
          items: _items,
          categories: _categories,
          movements: _movements,
          message: 'Stock actualizado correctamente.',
        ));
      case Err(:final failure):
        emit(InventoryError(
          items: _items,
          categories: _categories,
          movements: _movements,
          message: failure.message,
        ));
    }
  }
}
