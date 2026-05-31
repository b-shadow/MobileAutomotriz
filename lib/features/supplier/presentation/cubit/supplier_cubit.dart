import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/supplier/domain/usecases/create_supplier.dart';
import 'package:mobile1_app/features/supplier/domain/usecases/delete_supplier.dart';
import 'package:mobile1_app/features/supplier/domain/usecases/get_suppliers.dart';
import 'package:mobile1_app/features/supplier/domain/usecases/update_supplier.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';
import 'supplier_state.dart';

class SupplierCubit extends Cubit<SupplierState> {
  final GetSuppliers _getSuppliers;
  final CreateSupplier _createSupplier;
  final UpdateSupplier _updateSupplier;
  final DeleteSupplier _deleteSupplier;

  List<Supplier> _suppliers = const [];

  SupplierCubit({
    required GetSuppliers getSuppliers,
    required CreateSupplier createSupplier,
    required UpdateSupplier updateSupplier,
    required DeleteSupplier deleteSupplier,
  })  : _getSuppliers = getSuppliers,
        _createSupplier = createSupplier,
        _updateSupplier = updateSupplier,
        _deleteSupplier = deleteSupplier,
        super(const SupplierInitial());

  Future<void> fetchSuppliers() async {
    emit(SupplierLoading(suppliers: _suppliers));

    final result = await _getSuppliers(const NoParams());

    switch (result) {
      case Success(:final data):
        _suppliers = data;
        emit(SupplierLoaded(suppliers: _suppliers));
      case Err(:final failure):
        emit(SupplierError(
          suppliers: _suppliers,
          message: failure.message,
        ));
    }
  }

  Future<void> createSupplier({
    required String nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? contacto,
  }) async {
    emit(SupplierLoading(suppliers: _suppliers));

    final result = await _createSupplier(CreateSupplierParams(
      nombre: nombre,
      telefono: telefono,
      email: email,
      direccion: direccion,
      contacto: contacto,
    ));

    switch (result) {
      case Success(:final data):
        _suppliers = [..._suppliers, data];
        emit(SupplierSuccess(
          suppliers: _suppliers,
          message: 'Proveedor creado exitosamente.',
        ));
      case Err(:final failure):
        emit(SupplierError(
          suppliers: _suppliers,
          message: failure.message,
        ));
    }
  }

  Future<void> updateSupplier({
    required String id,
    required String nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? contacto,
    required bool activo,
  }) async {
    emit(SupplierLoading(suppliers: _suppliers));

    final result = await _updateSupplier(UpdateSupplierParams(
      id: id,
      nombre: nombre,
      telefono: telefono,
      email: email,
      direccion: direccion,
      contacto: contacto,
      activo: activo,
    ));

    switch (result) {
      case Success(:final data):
        _suppliers = _suppliers.map((s) => s.id == id ? data : s).toList();
        emit(SupplierSuccess(
          suppliers: _suppliers,
          message: 'Proveedor actualizado exitosamente.',
        ));
      case Err(:final failure):
        emit(SupplierError(
          suppliers: _suppliers,
          message: failure.message,
        ));
    }
  }

  Future<void> deleteSupplier(String id) async {
    emit(SupplierLoading(suppliers: _suppliers));

    final result = await _deleteSupplier(id);

    switch (result) {
      case Success():
        _suppliers = _suppliers.where((s) => s.id != id).toList();
        emit(SupplierSuccess(
          suppliers: _suppliers,
          message: 'Proveedor eliminado.',
        ));
      case Err(:final failure):
        emit(SupplierError(
          suppliers: _suppliers,
          message: failure.message,
        ));
    }
  }
}
