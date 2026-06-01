import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';
import 'package:mobile1_app/features/store_sales/domain/usecases/store_sales_usecases.dart';
import 'package:mobile1_app/features/inventory/domain/usecases/get_inventory_items.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';
import 'store_sales_state.dart';

class StoreSalesCubit extends Cubit<StoreSalesState> {
  final GetStoreSales _getStoreSales;
  final CreateStoreSale _createStoreSale;
  final ConfirmStoreSale _confirmStoreSale;
  final MarkPaymentReceived _markPaymentReceived;
  final CreateInvoice _createInvoice;
  final CreatePaymentTaller _createPaymentTaller;
  final GetInventoryItems _getInventoryItems;

  List<StoreSale> _sales = const [];
  List<InventoryItem> _items = const [];

  StoreSalesCubit({
    required GetStoreSales getStoreSales,
    required CreateStoreSale createStoreSale,
    required ConfirmStoreSale confirmStoreSale,
    required MarkPaymentReceived markPaymentReceived,
    required CreateInvoice createInvoice,
    required CreatePaymentTaller createPaymentTaller,
    required GetInventoryItems getInventoryItems,
  })  : _getStoreSales = getStoreSales,
        _createStoreSale = createStoreSale,
        _confirmStoreSale = confirmStoreSale,
        _markPaymentReceived = markPaymentReceived,
        _createInvoice = createInvoice,
        _createPaymentTaller = createPaymentTaller,
        _getInventoryItems = getInventoryItems,
        super(const StoreSalesInitial());

  Future<void> fetchAll() async {
    emit(StoreSalesLoading(sales: _sales, items: _items));

    final results = await Future.wait<dynamic>([
      _getStoreSales(const NoParams()),
      _getInventoryItems(const NoParams()),
    ]);

    final salesResult = results[0] as Result<List<StoreSale>>;
    final invResult = results[1] as Result<List<dynamic>>;

    if (salesResult is Success<List<StoreSale>>) {
      _sales = salesResult.data;
    } else if (salesResult is Err<List<StoreSale>>) {
      emit(StoreSalesError(
        sales: _sales,
        items: _items,
        message: salesResult.failure.message,
      ));
      return;
    }

    if (invResult is Success<List<dynamic>>) {
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

    emit(StoreSalesLoaded(sales: _sales, items: _items));
  }

  void _replaceInList(StoreSale updated) {
    _sales = _sales.map((s) => s.id == updated.id ? updated : s).toList();
  }

  Future<void> create(StoreSaleInput input, String metodoPago) async {
    emit(StoreSalesLoading(sales: _sales, items: _items));

    // 1. Registrar venta
    final resultSale = await _createStoreSale(input);
    if (resultSale is Err<StoreSale>) {
      emit(StoreSalesError(
        sales: _sales,
        items: _items,
        message: resultSale.failure.message,
      ));
      return;
    }
    final sale = (resultSale as Success<StoreSale>).data;

    // 2. Confirmar venta (descuenta stock)
    final resultConfirm = await _confirmStoreSale(sale.id);
    if (resultConfirm is Err<StoreSale>) {
      emit(StoreSalesError(
        sales: _sales,
        items: _items,
        message: resultConfirm.failure.message,
      ));
      return;
    }
    final confirmedSale = (resultConfirm as Success<StoreSale>).data;

    // 3. Crear pago taller
    final resultPayment = await _createPaymentTaller(
      saleId: confirmedSale.id,
      total: confirmedSale.total,
      metodoPago: metodoPago,
    );
    if (resultPayment is Err<String>) {
      emit(StoreSalesError(
        sales: _sales,
        items: _items,
        message: resultPayment.failure.message,
      ));
      return;
    }
    final pagoId = (resultPayment as Success<String>).data;

    // 4. Marcar pago recibido
    final resultRec = await _markPaymentReceived(pagoId);
    if (resultRec is Err<void>) {
      emit(StoreSalesError(
        sales: _sales,
        items: _items,
        message: resultRec.failure.message,
      ));
      return;
    }

    // 5. Emitir factura/recibo
    final resultInv = await _createInvoice(pagoId);
    if (resultInv is Err<void>) {
      emit(StoreSalesError(
        sales: _sales,
        items: _items,
        message: resultInv.failure.message,
      ));
      return;
    }

    _sales = [confirmedSale, ..._sales];
    emit(StoreSalesSuccess(
      sales: _sales,
      items: _items,
      message: 'Venta registrada y pagada correctamente.',
    ));
  }

  Future<void> confirm(String saleId) async {
    emit(StoreSalesLoading(sales: _sales, items: _items));

    final result = await _confirmStoreSale(saleId);

    switch (result) {
      case Success(:final data):
        _replaceInList(data);
        emit(StoreSalesSuccess(
          sales: _sales,
          items: _items,
          message: 'Venta confirmada exitosamente.',
        ));
      case Err(:final failure):
        emit(StoreSalesError(
          sales: _sales,
          items: _items,
          message: failure.message,
        ));
    }
  }

  Future<void> markPaymentReceived(String pagoId) async {
    emit(StoreSalesLoading(sales: _sales, items: _items));

    final result = await _markPaymentReceived(pagoId);

    switch (result) {
      case Success():
        emit(StoreSalesSuccess(
          sales: _sales,
          items: _items,
          message: 'Pago marcado como recibido.',
        ));
      case Err(:final failure):
        emit(StoreSalesError(
          sales: _sales,
          items: _items,
          message: failure.message,
        ));
    }
  }

  Future<void> createInvoice(String pagoId) async {
    emit(StoreSalesLoading(sales: _sales, items: _items));

    final result = await _createInvoice(pagoId);

    switch (result) {
      case Success():
        emit(StoreSalesSuccess(
          sales: _sales,
          items: _items,
          message: 'Factura/Recibo emitido exitosamente.',
        ));
      case Err(:final failure):
        emit(StoreSalesError(
          sales: _sales,
          items: _items,
          message: failure.message,
        ));
    }
  }
}
