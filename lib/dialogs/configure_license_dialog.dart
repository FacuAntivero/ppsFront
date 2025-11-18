import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    _selectedType = widget.initialType ?? 'basica';
    _showCustomField = (_selectedType == 'personalizada');
    _maxUsersController.text = widget.initialMaxUsers?.toString() ?? '';

    if (_showCustomField && _maxUsersController.text.isEmpty) {
      _maxUsersController.text = '10';
    }
  }

  @override
  void dispose() {
    _maxUsersController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String? newType) {
    if (newType == null) return;
    setState(() {
      _selectedType = newType;
      _showCustomField = (newType == 'personalizada');

      if (newType == 'basica') _maxUsersController.text = '3';
      if (newType == 'mediana') _maxUsersController.text = '5';
      if (newType == 'pro') _maxUsersController.text = '7';
      if (newType == 'personalizada' && widget.initialType != 'personalizada') {
        _maxUsersController.text = '10';
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop(context, {
      'tipo': _selectedType,
      'max': _maxUsersController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double dialogWidth = size.width > 600 ? 400 : size.width * 0.9;

    InputDecoration safeDecoration({
      required String label,
      String? helperText,
      required IconData icon,
    }) {
      return InputDecoration(
        labelText: label,
        helperText: helperText,
        isDense: true, // Hace el campo más compacto
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16), // Fijo y seguro
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(icon, color: Colors.amber),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  isExpanded: true,
                  decoration: safeDecoration(
                    label: 'Tipo de Licencia',
                    icon: Icons.star,
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
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Visibility(
                    visible: _showCustomField,
                    child: Column(
                      children: [
                        if (_showCustomField) const SizedBox(height: 16),
                        TextFormField(
                          controller: _maxUsersController,
                          decoration: safeDecoration(
                            label: 'Máx. Usuarios',
                            helperText: 'Ingrese el límite personalizado',
                            icon: Icons.people,
                          ).copyWith(
                            prefixIcon: const Icon(Icons.people),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (!_showCustomField) return null;
                            if (value == null || value.trim().isEmpty) {
                              return 'Requerido';
                            }
                            final int? num = int.tryParse(value);
                            if (num == null || num <= 0) {
                              return 'Debe ser > 0';
                            }
                            return null;
                          },
                        ),
                        if (_showCustomField) const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(24),
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
            minimumSize: const Size(100, 45),
          ),
          child: Text(widget.submitButtonText,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
