import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/invoices/domain/entities/invoice_entity.dart';

sealed class InvoicesState extends Equatable {
  final List<InvoiceEntity> invoices;

  const InvoicesState({this.invoices = const []});

  @override
  List<Object?> get props => [invoices];
}

final class InvoicesInitial extends InvoicesState {
  const InvoicesInitial();
}

final class InvoicesLoading extends InvoicesState {
  const InvoicesLoading({super.invoices});
}

final class InvoicesLoaded extends InvoicesState {
  const InvoicesLoaded({required super.invoices});
}

final class InvoicesError extends InvoicesState {
  final String message;

  const InvoicesError({
    required super.invoices,
    required this.message,
  });

  @override
  List<Object?> get props => [invoices, message];
}
