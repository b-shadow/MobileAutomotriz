import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as ex;

import '../domain/entities/report_data.dart';
import 'report_catalog.dart';

/// Servicio de exportación para el Explorador de Datos
/// Soporta PDF, CSV, Excel, HTML y Word (como .doc conteniendo HTML)
class ReportExportServiceExplorer {
  // ── Helpers ────────────────────────────────────────────────────────────────

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

  static String _formatHeader(String key) {
    return key.replaceAll('__', ' ').replaceAll('_', ' ').toUpperCase();
  }

  static String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is bool) return value ? 'Sí' : 'No';
    return value.toString();
  }

  static List<String> _extractKeys(ReportData report) {
    final rows = report.data['resultados'] as List<dynamic>? ?? [];
    if (rows.isEmpty) return [];
    return (rows.first as Map<String, dynamic>).keys.toList();
  }

  // ── PDF ────────────────────────────────────────────────────────────────────

  static Future<void> exportPdf(ReportTemplate template, ReportData report) async {
    final rows = report.data['resultados'] as List<dynamic>? ?? [];
    if (rows.isEmpty) return;

    final keys = _extractKeys(report);
    final baseName = 'Reporte_${template.id}_${_today()}';

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              template.title,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Fecha: ${_today()} | Total Registros: ${rows.length}',
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
              pw.Text('AutoGestión — Reporte Personalizado',
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
                            _formatHeader(k),
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
                final row = entry.value as Map<String, dynamic>;
                final isEven = entry.key.isEven;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.grey50 : PdfColors.white,
                  ),
                  children: keys
                      .map((k) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: pw.Text(
                              _formatValue(row[k]),
                              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey800),
                            ),
                          ))
                      .toList(),
                );
              }),
            ],
          ),
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

  static Future<void> exportCsv(ReportTemplate template, ReportData report) async {
    final rows = report.data['resultados'] as List<dynamic>? ?? [];
    if (rows.isEmpty) return;

    final keys = _extractKeys(report);
    final baseName = 'Reporte_${template.id}_${_today()}';
    final buf = StringBuffer();

    // Header
    buf.writeln(keys.map((k) => '"${_formatHeader(k)}"').join(','));

    // Rows
    for (final r in rows) {
      final row = r as Map<String, dynamic>;
      buf.writeln(keys.map((k) {
        final val = _formatValue(row[k]).replaceAll('"', '""');
        return '"$val"';
      }).join(','));
    }

    await _shareFile(
      bytes: Uint8List.fromList(buf.toString().codeUnits),
      fileName: '$baseName.csv',
      mimeType: 'text/csv',
    );
  }

  // ── Excel (.xlsx) ──────────────────────────────────────────────────────────

  static Future<void> exportExcel(ReportTemplate template, ReportData report) async {
    final rows = report.data['resultados'] as List<dynamic>? ?? [];
    if (rows.isEmpty) return;

    final keys = _extractKeys(report);
    final baseName = 'Reporte_${template.id}_${_today()}';

    final excel = ex.Excel.createExcel();
    final sheet = excel['Reporte'];
    excel.setDefaultSheet('Reporte');

    // Headers
    final headerRow = keys.map((k) => ex.TextCellValue(_formatHeader(k))).toList();
    sheet.appendRow(headerRow);

    // Rows
    for (final r in rows) {
      final row = r as Map<String, dynamic>;
      final dataRow = keys.map((k) => ex.TextCellValue(_formatValue(row[k]))).toList();
      sheet.appendRow(dataRow);
    }

    final bytes = excel.save();
    if (bytes != null) {
      await _shareFile(
        bytes: Uint8List.fromList(bytes),
        fileName: '$baseName.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
  }

  // ── HTML ───────────────────────────────────────────────────────────────────

  static String _generateHtmlContent(ReportTemplate template, ReportData report) {
    final rows = report.data['resultados'] as List<dynamic>? ?? [];
    final keys = _extractKeys(report);

    final buf = StringBuffer();
    buf.writeln('<!DOCTYPE html>');
    buf.writeln('<html><head><meta charset="UTF-8"><title>${template.title}</title>');
    buf.writeln('''
      <style>
        body { font-family: Arial, sans-serif; padding: 20px; color: #333; }
        h1 { color: #1e3a8a; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; font-size: 12px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #1e3a8a; color: white; }
        tr:nth-child(even) { background-color: #f9fafb; }
      </style>
    ''');
    buf.writeln('</head><body>');
    buf.writeln('<h1>${template.title}</h1>');
    buf.writeln('<p><strong>Fecha:</strong> ${_today()} | <strong>Total Registros:</strong> ${rows.length}</p>');

    if (rows.isNotEmpty) {
      buf.writeln('<table><thead><tr>');
      for (final k in keys) {
        buf.writeln('<th>${_formatHeader(k)}</th>');
      }
      buf.writeln('</tr></thead><tbody>');

      for (final r in rows) {
        final row = r as Map<String, dynamic>;
        buf.writeln('<tr>');
        for (final k in keys) {
          buf.writeln('<td>${_formatValue(row[k])}</td>');
        }
        buf.writeln('</tr>');
      }
      buf.writeln('</tbody></table>');
    } else {
      buf.writeln('<p>No hay datos disponibles.</p>');
    }

    buf.writeln('</body></html>');
    return buf.toString();
  }

  static Future<void> exportHtml(ReportTemplate template, ReportData report) async {
    final htmlContent = _generateHtmlContent(template, report);
    final baseName = 'Reporte_${template.id}_${_today()}';

    await _shareFile(
      bytes: Uint8List.fromList(htmlContent.codeUnits),
      fileName: '$baseName.html',
      mimeType: 'text/html',
    );
  }

  // ── Word (.doc) ────────────────────────────────────────────────────────────
  // Word can naturally read HTML files if they are saved with a .doc extension.
  // This is a common and robust trick for generating basic Word documents without
  // needing complex docx XML manipulation.
  static Future<void> exportWord(ReportTemplate template, ReportData report) async {
    final htmlContent = _generateHtmlContent(template, report);
    final baseName = 'Reporte_${template.id}_${_today()}';

    await _shareFile(
      bytes: Uint8List.fromList(htmlContent.codeUnits),
      fileName: '$baseName.doc',
      mimeType: 'application/msword',
    );
  }
}
