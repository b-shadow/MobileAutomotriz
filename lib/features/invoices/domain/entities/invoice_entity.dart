import 'package:equatable/equatable.dart';

class InvoiceEntity extends Equatable {
  final String id;
  final String pagoTaller;
  final String numero;
  final DateTime fechaEmision;
  final String nitRazonSocial;
  final double total;
  final String? archivoPdfUrl;
  final DateTime createdAt;

  const InvoiceEntity({
    required this.id,
    required this.pagoTaller,
    required this.numero,
    required this.fechaEmision,
    required this.nitRazonSocial,
    required this.total,
    this.archivoPdfUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        pagoTaller,
        numero,
        fechaEmision,
        nitRazonSocial,
        total,
        archivoPdfUrl,
        createdAt,
      ];
}
