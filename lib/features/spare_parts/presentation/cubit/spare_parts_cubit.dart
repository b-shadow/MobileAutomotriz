import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/spare_parts/domain/entities/spare_part_request_entity.dart';
import 'package:mobile1_app/features/spare_parts/domain/usecases/aprobar_solicitud.dart';
import 'package:mobile1_app/features/spare_parts/domain/usecases/asignar_proveedor_eta.dart';
import 'package:mobile1_app/features/spare_parts/domain/usecases/en_proceso_almacen.dart';
import 'package:mobile1_app/features/spare_parts/domain/usecases/get_solicitudes.dart';
import 'package:mobile1_app/features/spare_parts/domain/usecases/marcar_entregada.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';
import 'package:mobile1_app/features/supplier/domain/usecases/get_suppliers.dart';
import 'spare_parts_state.dart';

class SparePartsCubit extends Cubit<SparePartsState> {
  final GetSolicitudes _getSolicitudes;
  final AprobarSolicitud _aprobarSolicitud;
  final EnProcesoAlmacen _enProcesoAlmacen;
  final MarcarEntregada _marcarEntregada;
  final AsignarProveedorEta _asignarProveedorEta;
  final GetSuppliers _getSuppliers;

  List<SparePartRequestEntity> _solicitudes = const [];
  List<Supplier> _proveedores = const [];

  SparePartsCubit({
    required GetSolicitudes getSolicitudes,
    required AprobarSolicitud aprobarSolicitud,
    required EnProcesoAlmacen enProcesoAlmacen,
    required MarcarEntregada marcarEntregada,
    required AsignarProveedorEta asignarProveedorEta,
    required GetSuppliers getSuppliers,
  })  : _getSolicitudes = getSolicitudes,
        _aprobarSolicitud = aprobarSolicitud,
        _enProcesoAlmacen = enProcesoAlmacen,
        _marcarEntregada = marcarEntregada,
        _asignarProveedorEta = asignarProveedorEta,
        _getSuppliers = getSuppliers,
        super(const SparePartsInitial());

  Future<void> fetchAll() async {
    emit(SparePartsLoading(
        solicitudes: _solicitudes, proveedores: _proveedores));

    final results = await Future.wait([
      _getSolicitudes(const NoParams()),
      _getSuppliers(const NoParams()),
    ]);

    final solResult = results[0] as Result<List<SparePartRequestEntity>>;
    final provResult = results[1] as Result<List<Supplier>>;

    switch (solResult) {
      case Success(:final data):
        _solicitudes = data;
      case Err(:final failure):
        emit(SparePartsError(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: failure.message,
        ));
        return;
    }

    switch (provResult) {
      case Success(:final data):
        _proveedores = data;
      case Err(:final failure):
        emit(SparePartsError(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: failure.message,
        ));
        return;
    }

    emit(SparePartsLoaded(
        solicitudes: _solicitudes, proveedores: _proveedores));
  }

  void _replaceInList(SparePartRequestEntity updated) {
    _solicitudes = _solicitudes
        .map((s) => s.id == updated.id ? updated : s)
        .toList();
  }

  Future<void> aprobar(String solicitudId,
      {String? observaciones}) async {
    emit(SparePartsLoading(
        solicitudes: _solicitudes, proveedores: _proveedores));

    final result = await _aprobarSolicitud(
      solicitudId: solicitudId,
      observacionesAsesor: observaciones,
    );

    switch (result) {
      case Success(:final data):
        _replaceInList(data);
        emit(SparePartsSuccess(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: 'Solicitud aprobada exitosamente.',
        ));
      case Err(:final failure):
        emit(SparePartsError(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: failure.message,
        ));
    }
  }

  Future<void> enProceso(String solicitudId,
      {String? observaciones}) async {
    emit(SparePartsLoading(
        solicitudes: _solicitudes, proveedores: _proveedores));

    final result = await _enProcesoAlmacen(
      solicitudId: solicitudId,
      observacionesAlmacen: observaciones,
    );

    switch (result) {
      case Success(:final data):
        _replaceInList(data);
        emit(SparePartsSuccess(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: 'Solicitud en proceso de almacén.',
        ));
      case Err(:final failure):
        emit(SparePartsError(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: failure.message,
        ));
    }
  }

  Future<void> entregar(
    String solicitudId,
    List<Map<String, dynamic>> detalles,
  ) async {
    emit(SparePartsLoading(
        solicitudes: _solicitudes, proveedores: _proveedores));

    final result = await _marcarEntregada(
      solicitudId: solicitudId,
      detalles: detalles,
    );

    switch (result) {
      case Success(:final data):
        _replaceInList(data);
        emit(SparePartsSuccess(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: 'Solicitud marcada como entregada.',
        ));
      case Err(:final failure):
        emit(SparePartsError(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: failure.message,
        ));
    }
  }

  Future<void> asignarProveedor(
    String solicitudId,
    String proveedorId, {
    String? eta,
    String? observaciones,
  }) async {
    emit(SparePartsLoading(
        solicitudes: _solicitudes, proveedores: _proveedores));

    final result = await _asignarProveedorEta(
      solicitudId: solicitudId,
      proveedorId: proveedorId,
      eta: eta,
      observaciones: observaciones,
    );

    switch (result) {
      case Success(:final data):
        _replaceInList(data);
        emit(SparePartsSuccess(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: 'Proveedor y ETA asignados.',
        ));
      case Err(:final failure):
        emit(SparePartsError(
          solicitudes: _solicitudes,
          proveedores: _proveedores,
          message: failure.message,
        ));
    }
  }
}
