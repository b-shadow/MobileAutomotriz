import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../domain/entities/report_entities.dart';

/// Servicio que genera y comparte reportes de vehículo en PDF o CSV.
class ReportExportService {
  // ── PDF ────────────────────────────────────────────────────────────────────

  static Future<void> exportPdf(VehicleReportDetail detail) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildPdfHeader(detail),
        footer: (ctx) => _buildPdfFooter(ctx),
        build: (ctx) => [
          _buildPdfKpis(detail),
          pw.SizedBox(height: 24),
          _buildPdfHistorial(detail.historial),
        ],
      ),
    );

    await _shareFile(
      bytes: await pdf.save(),
      fileName: 'Reporte_${detail.placa}_${_today()}.pdf',
      mimeType: 'application/pdf',
    );
  }

  // ── CSV ────────────────────────────────────────────────────────────────────

  static Future<void> exportCsv(VehicleReportDetail detail) async {
    final buf = StringBuffer();

    // Cabecera del reporte
    buf.writeln('REPORTE DE VEHÍCULO');
    buf.writeln('Placa,${detail.placa}');
    buf.writeln('Modelo,${detail.marca} ${detail.modelo}');
    buf.writeln('Total Visitas,${detail.totalVisitas}');
    buf.writeln('Última Visita,${detail.ultimaVisita}');
    buf.writeln('Generado,${_today()}');
    buf.writeln();

    // Historial
    buf.writeln('ID,Fecha,Estado,Canal');
    for (final h in detail.historial) {
      // Escapar comas con comillas dobles
      buf.writeln('"${h.id}","${h.fecha}","${h.estado}","${h.canal}"');
    }

    await _shareFile(
      bytes: Uint8List.fromList(buf.toString().codeUnits),
      fileName: 'Reporte_${detail.placa}_${_today()}.csv',
      mimeType: 'text/csv',
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static String _today() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  static Future<void> _shareFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (kIsWeb) {
      // En web no hay sistema de archivos — informar al usuario
      throw UnsupportedError('Exportar no está disponible en web.');
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      subject: fileName,
    );
  }

  // ── PDF building blocks ────────────────────────────────────────────────────

  static pw.Widget _buildPdfHeader(VehicleReportDetail detail) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue800, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Reporte de Vehículo',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '${detail.placa} — ${detail.marca} ${detail.modelo}',
                style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Text(
            _today(),
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Automotriz SaaS — Reporte generado automáticamente',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
          pw.Text(
            'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfKpis(VehicleReportDetail detail) {
    return pw.Row(
      children: [
        _kpiBox('Total Visitas', '${detail.totalVisitas}', PdfColors.teal700),
        pw.SizedBox(width: 12),
        _kpiBox('Última Visita', detail.ultimaVisita, PdfColors.orange700),
        pw.SizedBox(width: 12),
        _kpiBox(
          'Registros Historial',
          '${detail.historial.length}',
          PdfColors.indigo700,
        ),
      ],
    );
  }

  static pw.Widget _kpiBox(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex(
            color == PdfColors.teal700
                ? '#F0FDFA'
                : color == PdfColors.orange700
                    ? '#FFF7ED'
                    : '#EEF2FF',
          ),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: color, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title,
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildPdfHistorial(List<VehicleHistory> historial) {
    if (historial.isEmpty) {
      return pw.Text('No hay registros en el historial.',
          style: const pw.TextStyle(color: PdfColors.grey600));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Historial de Atenciones',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue800),
              children: [
                _tableCell('ID', isHeader: true),
                _tableCell('Fecha', isHeader: true),
                _tableCell('Estado', isHeader: true),
                _tableCell('Canal', isHeader: true),
              ],
            ),
            // Rows
            ...historial.asMap().entries.map((e) {
              final h = e.value;
              final isEven = e.key.isEven;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: isEven ? PdfColors.grey50 : PdfColors.white,
                ),
                children: [
                  _tableCell('#${h.id}'),
                  _tableCell(h.fecha),
                  _tableCell(h.estado),
                  _tableCell(h.canal),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.grey800,
        ),
      ),
    );
  }
}
