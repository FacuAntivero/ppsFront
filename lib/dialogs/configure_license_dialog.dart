import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Un diálogo reutilizable para "Crear" o "Modificar" una licencia.
///
/// Devuelve un Map<String, String> con {'tipo': ..., 'max': ...} si se confirma,
/// o null si se cancela.
class ConfigureLicenseDialog extends StatefulWidget {
  final String title;
  final String submitButtonText;
  final String? initialType;
  final int? initialMaxUsers;

  const ConfigureLicenseDialog({
    super.key,
    required this.title,
    required this.submitButtonText,
    this.initialType,
    this.initialMaxUsers,
  });

  @override
  State<ConfigureLicenseDialog> createState() => _ConfigureLicenseDialogState();
}

class _ConfigureLicenseDialogState extends State<ConfigureLicenseDialog> {
  late String _selectedType;
  final TextEditingController _maxUsersController = TextEditingController();
  bool _showCustomField = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Establece los valores iniciales (para 'Modificar' o 'Crear')
    _selectedType = widget.initialType ?? 'basica';
    _showCustomField = (_selectedType == 'personalizada');
    _maxUsersController.text = widget.initialMaxUsers?.toString() ?? '';

    // Si es 'custom' pero no hay usuarios, pone 10 como placeholder (opcional)
    if (_showCustomField && _maxUsersController.text.isEmpty) {
      _maxUsersController.text = '10';
    }
  }

  @override
  void dispose() {
    _maxUsersController.dispose();
    super.dispose();
  }

  // Lógica para manejar el cambio del dropdown
  void _onTypeChanged(String? newType) {
    if (newType == null) return;
    setState(() {
      _selectedType = newType;
      _showCustomField = (newType == 'personalizada');

      // Asignar usuarios por defecto si no es custom
      if (newType == 'basica') _maxUsersController.text = '3';
      if (newType == 'mediana')
        _maxUsersController.text = '5'; // (5 segun tu backend)
      if (newType == 'pro')
        _maxUsersController.text = '7'; // (7 segun tu backend)
      if (newType == 'personalizada' && widget.initialType != 'personalizada') {
        _maxUsersController.text = '10'; // Placeholder para personalizada
      }
    });
  }

  // Valida el formulario y lo cierra, devolviendo los datos
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return; // No envía si el formulario no es válido
    }

    // Devuelve los nuevos valores al Dashboard
    Navigator.pop(context, {
      'tipo': _selectedType,
      'max': _maxUsersController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // 1. Título dinámico
      title: Text(widget.title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Dropdown de Tipo ---
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Licencia',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.star, color: Colors.amber),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'basica', child: Text('Básica (3 usuarios)')),
                  DropdownMenuItem(
                      value: 'mediana', child: Text('Mediana (5 usuarios)')),
                  DropdownMenuItem(
                      value: 'pro', child: Text('Pro (7 usuarios)')),
                  DropdownMenuItem(
                      value: 'personalizada', child: Text('Personalizada')),
                ],
                onChanged: _onTypeChanged,
              ),
              const SizedBox(height: 16),

              // --- Campo Condicional para 'Personalizada' ---
              // (Usamos AnimatedSize para una transición suave)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Visibility(
                  visible: _showCustomField,
                  child: TextFormField(
                    controller: _maxUsersController,
                    decoration: InputDecoration(
                      labelText: 'Máx. Usuarios (Personalizada)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (!_showCustomField)
                        return null; // No validar si no es custom

                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido para tipo Personalizada';
                      }
                      final int? num = int.tryParse(value);
                      if (num == null || num <= 0) {
                        return 'Debe ser > 0';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          // 2. Texto del botón dinámico
          child: Text(widget.submitButtonText,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
