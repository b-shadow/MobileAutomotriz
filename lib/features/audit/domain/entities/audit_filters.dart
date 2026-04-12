import 'package:equatable/equatable.dart';

class AuditFilters extends Equatable {
  final String? usuarioId;
  final String? accion;
  final String? entidadTipo;
  final String? createdAtGte;
  final String? createdAtLte;
  final String? search;
  final String? ordering;
  final String? createdAtDate;

  const AuditFilters({
    this.usuarioId,
    this.accion,
    this.entidadTipo,
    this.createdAtGte,
    this.createdAtLte,
    this.search,
    this.ordering,
    this.createdAtDate,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if ((usuarioId ?? '').isNotEmpty) params['usuario'] = usuarioId;
    if ((accion ?? '').isNotEmpty) params['accion'] = accion;
    if ((entidadTipo ?? '').isNotEmpty) params['entidad_tipo'] = entidadTipo;
    if ((createdAtGte ?? '').isNotEmpty) params['created_at__gte'] = createdAtGte;
    if ((createdAtLte ?? '').isNotEmpty) params['created_at__lte'] = createdAtLte;
    if ((search ?? '').isNotEmpty) params['search'] = search;
    if ((ordering ?? '').isNotEmpty) params['ordering'] = ordering;
    if ((createdAtDate ?? '').isNotEmpty) params['created_at__date'] = createdAtDate;
    return params;
  }

  @override
  List<Object?> get props => [
        usuarioId,
        accion,
        entidadTipo,
        createdAtGte,
        createdAtLte,
        search,
        ordering,
        createdAtDate,
      ];
}

