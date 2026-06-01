import 'package:mobile1_app/features/invoices/domain/entities/invoice_entity.dart';

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.pagoTaller,
    required super.numero,
    required super.fechaEmision,
    required super.nitRazonSocial,
    required super.total,
    super.archivoPdfUrl,
    required super.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: (json['id'] ?? '').toString(),
      pagoTaller: (json['pago_taller'] ?? '').toString(),
      numero: (json['numero'] ?? '').toString(),
      fechaEmision: json['fecha_emision'] != null
          ? DateTime.parse(json['fecha_emision'].toString())
          : DateTime.now(),
      nitRazonSocial: (json['nit_razon_social'] ?? '').toString(),
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      archivoPdfUrl: json['archivo_pdf_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}
