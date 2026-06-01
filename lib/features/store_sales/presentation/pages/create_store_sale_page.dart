import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
                      const SizedBox(height: 30),
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
                            : const Text('Registrar Venta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
        );
      },
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
              DropdownMenuItem(value: 'EFECTIVO', child: Text('Efectivo')),
              DropdownMenuItem(value: 'QR', child: Text('QR')),
              DropdownMenuItem(value: 'TARJETA', child: Text('Tarjeta (Stripe)')),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _metodoPago = v);
              }
            },
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
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(itemName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('${d.cantidad}x \$${d.precioUnitario}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
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
                    decoration: _inputDecoration().copyWith(labelText: 'Precio Venta (\$)'),
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
