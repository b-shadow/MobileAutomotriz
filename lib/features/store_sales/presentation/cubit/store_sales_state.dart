import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';

sealed class StoreSalesState extends Equatable {
  final List<StoreSale> sales;
  final List<InventoryItem> items;

  const StoreSalesState({
    this.sales = const [],
    this.items = const [],
  });

  @override
  List<Object?> get props => [sales, items];
}

final class StoreSalesInitial extends StoreSalesState {
  const StoreSalesInitial();
}

final class StoreSalesLoading extends StoreSalesState {
  const StoreSalesLoading({super.sales, super.items});
}

final class StoreSalesLoaded extends StoreSalesState {
  const StoreSalesLoaded({
    required super.sales,
    required super.items,
  });
}

final class StoreSalesSuccess extends StoreSalesState {
  final String message;

  const StoreSalesSuccess({
    required super.sales,
    required super.items,
    required this.message,
  });

  @override
  List<Object?> get props => [sales, items, message];
}

final class StoreSalesError extends StoreSalesState {
  final String message;

  const StoreSalesError({
    required super.sales,
    required super.items,
    required this.message,
  });

  @override
  List<Object?> get props => [sales, items, message];
}

/// Emitted when a QR payment is created and the QR image needs to be shown.
final class StoreSalesQRPending extends StoreSalesState {
  final String pagoId;
  final String? qrImageUrl;
  final String? urlPago;
  final StoreSaleInput saleInput;

  const StoreSalesQRPending({
    required super.sales,
    required super.items,
    required this.pagoId,
    this.qrImageUrl,
    this.urlPago,
    required this.saleInput,
  });

  @override
  List<Object?> get props => [sales, items, pagoId, qrImageUrl, urlPago, saleInput];
}

/// Emitted when a Stripe checkout URL is ready to be opened.
final class StoreSalesStripeCheckout extends StoreSalesState {
  final String checkoutUrl;

  const StoreSalesStripeCheckout({
    required super.sales,
    required super.items,
    required this.checkoutUrl,
  });

  @override
  List<Object?> get props => [sales, items, checkoutUrl];
}
