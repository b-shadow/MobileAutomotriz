import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';
import 'package:mobile1_app/features/store_sales/presentation/cubit/store_sales_cubit.dart';
import 'package:mobile1_app/features/store_sales/presentation/cubit/store_sales_state.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';

class CreateStoreSalePage extends StatefulWidget {
  const CreateStoreSalePage({super.key});

  @override
  State<CreateStoreSalePage> createState() => _CreateStoreSalePageState();
}

class _CreateStoreSalePageState extends State<CreateStoreSalePage> {
  final _formKey = GlobalKey<FormState>();

  final _clienteNombreCtrl = TextEditingController();
  final _clienteDocumentoCtrl = TextEditingController();

  final List<StoreSaleDetailInput> _detalles = [];
  String _metodoPago = 'EFECTIVO';

  @override
  void dispose() {
    _clienteNombreCtrl.dispose();
    _clienteDocumentoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un ítem a la venta')),
      );
      return;
    }

    final input = StoreSaleInput(
      clienteNombreLibre: _clienteNombreCtrl.text.isEmpty ? null : _clienteNombreCtrl.text,
      clienteDocumento: _clienteDocumentoCtrl.text.isEmpty ? null : _clienteDocumentoCtrl.text,
      detalles: _detalles,
    );

    context.read<StoreSalesCubit>().create(input, _metodoPago);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoreSalesCubit, StoreSalesState>(
      listener: (context, state) {
        if (state is StoreSalesSuccess) {
          context.pop();
        } else if (state is StoreSalesError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ));
        } else if (state is StoreSalesQRPending) {
          _showQRModal(context, state);
        } else if (state is StoreSalesStripeCheckout) {
          _openStripeCheckout(state.checkoutUrl);
        }
      },
      builder: (context, state) {
        final isLoading = state is StoreSalesLoading;
        final items = state.items;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Nueva Venta Presencial', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: isLoading && items.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.info))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 20),
                      _buildItemsSection(items),
                      const SizedBox(height: 12),
                      _buildTotalSection(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_metodoPagoIcon, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    _metodoPago == 'EFECTIVO'
                                        ? 'Registrar y Cobrar'
                                        : _metodoPago == 'QR'
                                            ? 'Generar QR de Pago'
                                            : 'Pagar con Tarjeta',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  IconData get _metodoPagoIcon => switch (_metodoPago) {
        'EFECTIVO' => Icons.attach_money_rounded,
        'QR' => Icons.qr_code_2_rounded,
        'TARJETA' => Icons.credit_card_rounded,
        _ => Icons.payment,
      };

  double get _total => _detalles.fold(0.0, (s, d) => s + d.cantidad * d.precioUnitario);

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            const Color(0xFF6366F1).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('TOTAL', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 1)),
          Text(
            'Bs ${_total.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos de la Venta', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          const Text('Nombre del Cliente (Opcional)', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _clienteNombreCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(),
          ),
          const SizedBox(height: 12),

          const Text('Documento / Cédula (Opcional)', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _clienteDocumentoCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(),
          ),
          const SizedBox(height: 12),

          const Text('Método de Pago *', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _metodoPago,
            dropdownColor: AppColors.darkCard,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(),
            items: const [
              DropdownMenuItem(value: 'EFECTIVO', child: Row(children: [Icon(Icons.attach_money, size: 16, color: Color(0xFF10B981)), SizedBox(width: 8), Text('Efectivo')])),
              DropdownMenuItem(value: 'QR', child: Row(children: [Icon(Icons.qr_code_2, size: 16, color: Color(0xFF8B5CF6)), SizedBox(width: 8), Text('Pago QR')])),
              DropdownMenuItem(value: 'TARJETA', child: Row(children: [Icon(Icons.credit_card, size: 16, color: Color(0xFF3B82F6)), SizedBox(width: 8), Text('Tarjeta (Stripe)')])),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _metodoPago = v);
              }
            },
          ),

          // Payment method info
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _metodoPago == 'EFECTIVO'
                        ? 'La venta se confirmará y el pago se registrará inmediatamente.'
                        : _metodoPago == 'QR'
                            ? 'Se generará un código QR. Escanea para pagar y luego confirma.'
                            : 'Se abrirá la pasarela de Stripe para completar el pago.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(List<InventoryItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ítems de Venta', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showAddItemModal(items),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
              ),
            ],
          ),
          if (_detalles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No hay ítems agregados', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _detalles.length,
              itemBuilder: (ctx, i) {
                final d = _detalles[i];
                final idxMatch = items.indexWhere((x) => x.id == d.itemInventarioId);
                final itemName = idxMatch >= 0 ? items[idxMatch].nombre : 'Item';
                final subtotal = d.cantidad * d.precioUnitario;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(itemName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('${d.cantidad}x Bs ${d.precioUnitario.toStringAsFixed(2)} = Bs ${subtotal.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => setState(() => _detalles.removeAt(i)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── QR Modal ──────────────────────────────────────────────────
  void _showQRModal(BuildContext ctx, StoreSalesQRPending state) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 36, color: Color(0xFF8B5CF6)),
            ),
            const SizedBox(height: 16),
            const Text('Pago QR', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Escanea el código QR o abre el enlace para completar el pago.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 20),

            // QR Image
            if (state.qrImageUrl != null && state.qrImageUrl!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.network(
                  state.qrImageUrl!,
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(child: Text('Error al cargar QR', style: TextStyle(color: Colors.red))),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Payment URL
            if (state.urlPago != null && state.urlPago!.isNotEmpty)
              TextButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(state.urlPago!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('Abrir enlace de pago'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
              ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetCtx).pop();
                      ctx.read<StoreSalesCubit>().confirmQRAndRegister(
                        state.pagoId,
                        state.saleInput,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Ya pagué, confirmar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Stripe Checkout ───────────────────────────────────────────
  Future<void> _openStripeCheckout(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la pasarela de pago')),
        );
      }
    }
  }

  // ── Add Item Modal ────────────────────────────────────────────
  void _showAddItemModal(List<InventoryItem> items) {
    String? selectedItemId;
    final qtyCtrl = TextEditingController(text: '1');
    final costCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Agregar Ítem', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.darkCard,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDecoration().copyWith(hintText: 'Selecciona un producto'),
              items: items.map((x) => DropdownMenuItem<String>(
                value: x.id,
                child: Text('${x.nombre} (Stock: ${x.stockActual})'),
              )).toList(),
              onChanged: (v) => selectedItemId = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration().copyWith(labelText: 'Cantidad'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration().copyWith(labelText: 'Precio Venta (Bs)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (selectedItemId != null && qtyCtrl.text.isNotEmpty && costCtrl.text.isNotEmpty) {
                    setState(() {
                      _detalles.add(StoreSaleDetailInput(
                        itemInventarioId: selectedItemId!,
                        cantidad: int.tryParse(qtyCtrl.text) ?? 1,
                        precioUnitario: double.tryParse(costCtrl.text) ?? 0.0,
                      ));
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Agregar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
