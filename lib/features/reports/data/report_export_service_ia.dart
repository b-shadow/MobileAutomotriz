import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'models/ia_report_result.dart';

/// Export service for AI-generated reports — PDF & CSV via share_plus.
class IaReportExportService {
  // ── PDF ────────────────────────────────────────────────────────────────────

  static Future<void> exportPdf(IaReportResult result) async {
    final rows = result.data;
    if (rows.isEmpty) return;

    final keys = rows.first.keys.toList();
    final baseName = 'Reporte_IA_${_today()}';

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Reporte generado por IA',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Fecha: ${_today()}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('AutoGestión — Reportes IA',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
              pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            ],
          ),
        ),
        build: (ctx) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              for (int i = 0; i < keys.length; i++) i: const pw.FlexColumnWidth(),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                children: keys
                    .map((k) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                          child: pw.Text(
                            k.replaceAll('_', ' ').toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              // Data rows
              ...rows.asMap().entries.map((entry) {
                final row = entry.value;
                final isEven = entry.key.isEven;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.grey50 : PdfColors.white,
                  ),
                  children: keys
                      .map((k) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: pw.Text(
                              row[k]?.toString() ?? '-',
                              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey800),
                            ),
                          ))
                      .toList(),
                );
              }),
            ],
          ),
          if (result.sql != null) ...[
            pw.SizedBox(height: 16),
            pw.Text('SQL generado:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(result.sql!, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
            ),
          ],
        ],
      ),
    );

    await _shareFile(
      bytes: await pdf.save(),
      fileName: '$baseName.pdf',
      mimeType: 'application/pdf',
    );
  }

  // ── CSV ────────────────────────────────────────────────────────────────────

  static Future<void> exportCsv(IaReportResult result) async {
    final rows = result.data;
    if (rows.isEmpty) return;

    final keys = rows.first.keys.toList();
    final baseName = 'Reporte_IA_${_today()}';
    final buf = StringBuffer();

    // Header
    buf.writeln(keys.map((k) => '"${k.replaceAll('_', ' ')}"').join(','));

    // Rows
    for (final row in rows) {
      buf.writeln(keys.map((k) => '"${row[k] ?? ''}"').join(','));
    }

    await _shareFile(
      bytes: Uint8List.fromList(buf.toString().codeUnits),
      fileName: '$baseName.csv',
      mimeType: 'text/csv',
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static Future<void> _shareFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (kIsWeb) {
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
}
