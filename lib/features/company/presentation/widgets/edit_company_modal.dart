import 'package:flutter/material.dart';
import 'package:mobile1_app/features/company/domain/entities/empresa.dart';

class EditCompanyModal extends StatefulWidget {
  final Empresa empresa;
  final Function(String nombre, String estado) onSave;

  const EditCompanyModal({
    super.key,
    required this.empresa,
    required this.onSave,
  });

  @override
  State<EditCompanyModal> createState() => _EditCompanyModalState();
}

class _EditCompanyModalState extends State<EditCompanyModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late String _selectedEstado;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.empresa.nombre);
    _selectedEstado = widget.empresa.estado;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nombreController.text.trim(),
        _selectedEstado,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar Información General',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de Empresa',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedEstado.toUpperCase() == 'ACTIVA' || _selectedEstado.toUpperCase() == 'INACTIVA'
                  ? _selectedEstado.toUpperCase()
                  : 'ACTIVA', // Default fallback
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              dropdownColor: const Color(0xFF1E293B),
              items: const [
                DropdownMenuItem(
                  value: 'ACTIVA',
                  child: Text('ACTIVA', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'INACTIVA',
                  child: Text('INACTIVA', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedEstado = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar Cambios'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
