import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile1_app/core/theme/app_colors.dart';
import 'package:mobile1_app/features/purchases/domain/entities/purchase_entity.dart';
import 'package:mobile1_app/features/purchases/presentation/cubit/purchases_cubit.dart';
import 'package:mobile1_app/features/purchases/presentation/cubit/purchases_state.dart';

class CreatePurchasePage extends StatefulWidget {
  const CreatePurchasePage({super.key});

  @override
  State<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends State<CreatePurchasePage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedProveedorId;
  final _documentoCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  
  final DateTime _fechaCompra = DateTime.now();

  final List<PurchaseDetailInput> _detalles = [];

  @override
  void dispose() {
    _documentoCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProveedorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un proveedor')),
      );
      return;
    }
    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un ítem a la compra')),
      );
      return;
    }

    final input = PurchaseInput(
      proveedorId: _selectedProveedorId!,
      numeroDocumento: _documentoCtrl.text,
      fechaCompra: _fechaCompra,
      observaciones: _observacionesCtrl.text,
      detalles: _detalles,
    );

    context.read<PurchasesCubit>().create(input);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchasesCubit, PurchasesState>(
      listener: (context, state) {
        if (state is PurchasesSuccess) {
          context.pop();
        } else if (state is PurchasesError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.message),
          ));
        }
      },
      builder: (context, state) {
        final isLoading = state is PurchasesLoading;
        final proveedores = state.suppliers;
        final items = state.items;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Nueva Compra', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: isLoading && proveedores.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.info))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeaderSection(proveedores),
                      const SizedBox(height: 20),
                      _buildItemsSection(items),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Crear Compra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeaderSection(List proveedores) {
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
          const Text('Datos Generales', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Proveedor Dropdown
          const Text('Proveedor', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _selectedProveedorId,
            dropdownColor: AppColors.darkCard,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(),
            items: proveedores.map((p) => DropdownMenuItem<String>(
              value: p.id,
              child: Text(p.nombre),
            )).toList(),
            onChanged: (v) => setState(() => _selectedProveedorId = v),
            validator: (v) => v == null ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          // Numero Documento
          const Text('Número de Documento / Factura', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _documentoCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          // Observaciones
          const Text('Observaciones', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _observacionesCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(List items) {
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
              const Text('Ítems de Compra', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showAddItemModal(items),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(foregroundColor: AppColors.info),
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
                final itemName = items.firstWhere((x) => x.id == d.itemInventarioId, orElse: () => null)?.nombre ?? 'Item';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(itemName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('${d.cantidad}x \$${d.costoUnitario}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
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

  void _showAddItemModal(List items) {
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
              items: items.map((x) => DropdownMenuItem<String>(value: x.id, child: Text(x.nombre))).toList(),
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
                    decoration: _inputDecoration().copyWith(labelText: 'Costo Unitario (\$)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (selectedItemId != null && qtyCtrl.text.isNotEmpty && costCtrl.text.isNotEmpty) {
                    setState(() {
                      _detalles.add(PurchaseDetailInput(
                        itemInventarioId: selectedItemId!,
                        cantidad: int.tryParse(qtyCtrl.text) ?? 1,
                        costoUnitario: double.tryParse(costCtrl.text) ?? 0.0,
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
