import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/invoices/domain/entities/invoice_entity.dart';
import 'package:mobile1_app/features/invoices/presentation/cubit/invoices_cubit.dart';
import 'package:mobile1_app/features/invoices/presentation/cubit/invoices_state.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    context.read<InvoicesCubit>().fetchInvoices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Facturas y Recibos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => context.read<InvoicesCubit>().fetchInvoices(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Search bar ─────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar por número o NIT/Razón social...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              // ── List ──────────────────────────
              Expanded(
                child: BlocBuilder<InvoicesCubit, InvoicesState>(
                  builder: (ctx, state) {
                    if (state is InvoicesLoading && state.invoices.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.info),
                      );
                    }

                    if (state is InvoicesError && state.invoices.isEmpty) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }

                    final filtered = _filter(state.invoices, _query);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _query.isEmpty
                                  ? 'No hay facturas o recibos emitidos'
                                  : 'Sin resultados para "$_query"',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.info,
                      onRefresh: () =>
                          context.read<InvoicesCubit>().fetchInvoices(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _InvoiceCard(
                          invoice: filtered[index],
                          onDownloadShare: () => _downloadAndShare(filtered[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isDownloading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  color: AppColors.darkCard,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.info),
                        SizedBox(height: 16),
                        Text(
                          'Descargando PDF...',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<InvoiceEntity> _filter(List<InvoiceEntity> invoices, String q) {
    if (q.trim().isEmpty) return invoices;
    final lower = q.toLowerCase();
    return invoices.where((inv) {
      return inv.numero.toLowerCase().contains(lower) ||
          inv.nitRazonSocial.toLowerCase().contains(lower);
    }).toList();
  }

  Future<void> _downloadAndShare(InvoiceEntity invoice) async {
    final pdfUrl = invoice.archivoPdfUrl;
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          content: Text('Esta factura no tiene un archivo PDF asociado.'),
        ),
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        throw Exception('El contenido del archivo es nulo.');
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${invoice.numero}.pdf');
      await file.writeAsBytes(response.data!);

      setState(() => _isDownloading = false);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Factura ${invoice.numero}',
      );
    } catch (e) {
      setState(() => _isDownloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Error al descargar el PDF: ${e.toString()}'),
          ),
        );
      }
    }
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceEntity invoice;
  final VoidCallback onDownloadShare;

  const _InvoiceCard({
    required this.invoice,
    required this.onDownloadShare,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(invoice.fechaEmision);
    final formattedTotal = NumberFormat.currency(
      symbol: '\$ ',
      decimalDigits: 2,
    ).format(invoice.total);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.numero,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                formattedTotal,
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NIT / Razón social',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.nitRazonSocial.isNotEmpty
                          ? invoice.nitRazonSocial
                          : 'Sin registrar',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onDownloadShare,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.info,
                  side: BorderSide(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text(
                  'Compartir PDF',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
