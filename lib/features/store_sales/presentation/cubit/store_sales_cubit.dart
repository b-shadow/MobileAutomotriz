import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';
import 'package:mobile1_app/features/store_sales/domain/repositories/store_sales_repository.dart';
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
  final StoreSalesRepository _repository;

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
    required StoreSalesRepository repository,
  })  : _getStoreSales = getStoreSales,
        _createStoreSale = createStoreSale,
        _confirmStoreSale = confirmStoreSale,
        _markPaymentReceived = markPaymentReceived,
        _createInvoice = createInvoice,
        _createPaymentTaller = createPaymentTaller,
        _getInventoryItems = getInventoryItems,
        _repository = repository,
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

  /// Dispatch to the correct payment flow based on method.
  Future<void> create(StoreSaleInput input, String metodoPago) async {
    switch (metodoPago) {
      case 'EFECTIVO':
        await _createWithEfectivo(input);
      case 'QR':
        await _createWithQR(input);
      case 'TARJETA':
        await _createWithStripe(input);
      default:
        await _createWithEfectivo(input);
    }
  }

  // ── EFECTIVO: create → confirm → payment → mark received → invoice ──
  Future<void> _createWithEfectivo(StoreSaleInput input) async {
    emit(StoreSalesLoading(sales: _sales, items: _items));

    // 1. Create sale
    final resultSale = await _createStoreSale(input);
    if (resultSale is Err<StoreSale>) {
      emit(StoreSalesError(sales: _sales, items: _items, message: resultSale.failure.message));
      return;
    }
    final sale = (resultSale as Success<StoreSale>).data;

    // 2. Confirm sale (deducts stock)
    final resultConfirm = await _confirmStoreSale(sale.id);
    if (resultConfirm is Err<StoreSale>) {
      emit(StoreSalesError(sales: _sales, items: _items, message: resultConfirm.failure.message));
      return;
    }
    final confirmedSale = (resultConfirm as Success<StoreSale>).data;

    // 3. Create payment
    final resultPayment = await _createPaymentTaller(
      saleId: confirmedSale.id,
      total: confirmedSale.total,
      metodoPago: 'EFECTIVO',
    );
    if (resultPayment is Err<String>) {
      emit(StoreSalesError(sales: _sales, items: _items, message: resultPayment.failure.message));
      return;
    }
    final pagoId = (resultPayment as Success<String>).data;

    // 4. Mark received
    final resultRec = await _markPaymentReceived(pagoId);
    if (resultRec is Err<void>) {
      emit(StoreSalesError(sales: _sales, items: _items, message: resultRec.failure.message));
      return;
    }

    // 5. Create invoice
    await _createInvoice(pagoId);

    _sales = [confirmedSale, ..._sales];
    emit(StoreSalesSuccess(
      sales: _sales,
      items: _items,
      message: 'Venta registrada y pagada con efectivo.',
    ));
  }

  // ── QR: crear-qr → show modal → user confirms → simular → confirm sale ──
  Future<void> _createWithQR(StoreSaleInput input) async {
    emit(StoreSalesLoading(sales: _sales, items: _items));

    // Generate QR payment first (before creating the sale)
    final total = input.detalles.fold<double>(
      0.0,
      (sum, d) => sum + (d.cantidad * d.precioUnitario),
    );

    final fechaExp = DateTime.now()
        .add(const Duration(minutes: 30))
        .toUtc()
        .toIso8601String();

    final qrResult = await _repository.createQRPayment({
      'tipo_destino': 'VENTA',
      'id_destino': 'MOSTRADOR-${DateTime.now().millisecondsSinceEpoch}',
      'monto_real': double.parse(total.toStringAsFixed(2)),
      'moneda': 'BOB',
      'descripcion': 'Pago QR venta presencial',
      'fecha_expiracion': fechaExp,
    });

    if (qrResult is Err<Map<String, dynamic>>) {
      emit(StoreSalesError(sales: _sales, items: _items, message: qrResult.failure.message));
      return;
    }

    final qrData = (qrResult as Success<Map<String, dynamic>>).data;
    final pagoId = (qrData['id'] ?? '').toString();
    final qrImageUrl = qrData['qr_imagen_url']?.toString();
    final urlPago = qrData['url_pago']?.toString();

    // Emit QR pending state so UI shows the QR modal
    emit(StoreSalesQRPending(
      sales: _sales,
      items: _items,
      pagoId: pagoId,
      qrImageUrl: qrImageUrl,
      urlPago: urlPago,
      saleInput: input,
    ));
  }

  /// Called after user scans QR and clicks "Ya pagué, confirmar"
  Future<void> confirmQRAndRegister(String pagoId, StoreSaleInput input) async {
    emit(StoreSalesLoading(sales: _sales, items: _items));

    // 1. Simulate QR confirmation
    final simResult = await _repository.simularConfirmacionQR(pagoId);
    if (simResult is Err<Map<String, dynamic>>) {
      emit(StoreSalesError(sales: _sales, items: _items, message: simResult.failure.message));
      return;
    }

    // 2. Check QR state
    final estadoResult = await _repository.consultarEstadoQR(pagoId);
    if (estadoResult is Err<Map<String, dynamic>>) {
      emit(StoreSalesError(sales: _sales, items: _items, message: estadoResult.failure.message));
      return;
    }

    final estadoData = (estadoResult as Success<Map<String, dynamic>>).data;
    final estado = (estadoData['estado'] ?? '').toString();
    if (estado != 'CONFIRMADO') {
      emit(StoreSalesError(
        sales: _sales,
        items: _items,
        message: 'El pago QR aún no está confirmado. Estado: $estado',
      ));
      return;
    }

    // 3. Create sale → confirm → invoice (payment already confirmed via QR)
    final resultSale = await _createStoreSale(input);
    if (resultSale is Err<StoreSale>) {
      emit(StoreSalesError(sales: _sales, items: _items, message: resultSale.failure.message));
      return;
    }
    final sale = (resultSale as Success<StoreSale>).data;

    final resultConfirm = await _confirmStoreSale(sale.id);
    if (resultConfirm is Err<StoreSale>) {
      emit(StoreSalesError(sales: _sales, items: _items, message: resultConfirm.failure.message));
      return;
    }
    final confirmedSale = (resultConfirm as Success<StoreSale>).data;

    // 4. Create invoice
    await _createInvoice(pagoId);

    _sales = [confirmedSale, ..._sales];
    emit(StoreSalesSuccess(
      sales: _sales,
      items: _items,
      message: 'Pago QR confirmado. Venta registrada correctamente.',
    ));
  }

  // ── STRIPE: iniciar-pago-tarjeta → open checkout URL ──
  Future<void> _createWithStripe(StoreSaleInput input) async {
    emit(StoreSalesLoading(sales: _sales, items: _items));

    final stripeResult = await _repository.iniciarPagoTarjeta({
      'cliente_nombre_libre': input.clienteNombreLibre ?? 'Cliente Mostrador',
      'cliente_documento': input.clienteDocumento,
      'detalles': input.detalles.map((d) => d.toJson()).toList(),
      'descripcion': 'Pago tarjeta venta presencial',
    });

    if (stripeResult is Err<Map<String, dynamic>>) {
      emit(StoreSalesError(
        sales: _sales,
        items: _items,
        message: stripeResult.failure.message,
      ));
      return;
    }

    final data = (stripeResult as Success<Map<String, dynamic>>).data;
    final checkoutUrl = data['checkoutUrl']?.toString() ?? data['checkout_url']?.toString() ?? '';

    if (checkoutUrl.isEmpty) {
      emit(StoreSalesError(
        sales: _sales,
        items: _items,
        message: 'No se pudo obtener la URL de pago de Stripe.',
      ));
      return;
    }

    emit(StoreSalesStripeCheckout(
      sales: _sales,
      items: _items,
      checkoutUrl: checkoutUrl,
    ));
  }

  void _replaceInList(StoreSale updated) {
    _sales = _sales.map((s) => s.id == updated.id ? updated : s).toList();
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
