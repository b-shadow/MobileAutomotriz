import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/invoices/domain/usecases/get_invoices.dart';
import 'package:mobile1_app/features/invoices/domain/entities/invoice_entity.dart';
import 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  final GetInvoices _getInvoices;

  List<InvoiceEntity> _invoices = const [];

  InvoicesCubit({
    required GetInvoices getInvoices,
  })  : _getInvoices = getInvoices,
        super(const InvoicesInitial());

  Future<void> fetchInvoices() async {
    emit(InvoicesLoading(invoices: _invoices));

    final result = await _getInvoices(const NoParams());

    switch (result) {
      case Success(:final data):
        _invoices = data;
        emit(InvoicesLoaded(invoices: _invoices));
      case Err(:final failure):
        emit(InvoicesError(
          invoices: _invoices,
          message: failure.message,
        ));
    }
  }
}
