import 'package:flutter/material.dart';

class ReusablePasswordDialog extends StatefulWidget {
  final String title;
  final String description;
  final String submitButtonText;
  final bool requireCurrentPassword;

  const ReusablePasswordDialog({
    super.key,
    required this.title,
    required this.description,
    this.submitButtonText = "Guardar",
    this.requireCurrentPassword = false, // Por defecto, solo pide la nueva
  });

  @override
  State<ReusablePasswordDialog> createState() => _ReusablePasswordDialogState();
}

class _ReusablePasswordDialogState extends State<ReusablePasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _errorText;

  bool _isCurrentVisible = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final currentPass = _currentPasswordController.text.trim();
    final newPass = _passwordController.text.trim();
    final confirmPass = _confirmController.text.trim();

    // 1. Validar contraseña actual (si se requiere)
    if (widget.requireCurrentPassword && currentPass.isEmpty) {
      setState(() => _errorText = 'Debes ingresar tu contraseña actual.');
      return;
    }

    // 2. Validar nueva contraseña
    if (newPass.length < 6) {
      setState(() =>
          _errorText = 'La nueva contraseña debe tener + de 6 caracteres.');
      return;
    }

    // 3. Validar confirmación
    if (newPass != confirmPass) {
      setState(() => _errorText = 'Las nuevas contraseñas no coinciden.');
      return;
    }

    // Si todo es válido, preparamos el resultado
    final Map<String, String> result = {
      'new': newPass,
    };

    if (widget.requireCurrentPassword) {
      result['current'] = currentPass;
    }

    Navigator.pop(context, result); // Devuelve el Map
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.description,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),

            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(_errorText!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),

            const SizedBox(height: 16),

            // --- CAMPO CONDICIONAL: CONTRASEÑA ACTUAL ---
            if (widget.requireCurrentPassword) ...[
              _buildPasswordField(
                controller: _currentPasswordController,
                labelText: 'Tu Contraseña Actual',
                isVisible: _isCurrentVisible,
                onToggleVisibility: () =>
                    setState(() => _isCurrentVisible = !_isCurrentVisible),
              ),
              const SizedBox(height: 16),
            ],

            // --- CAMPO: NUEVA CONTRASEÑA ---
            _buildPasswordField(
              controller: _passwordController,
              labelText: 'Nueva Contraseña',
              hintText: 'Mínimo 6 caracteres',
              isVisible: _isPasswordVisible,
              onToggleVisibility: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),

            const SizedBox(height: 16),

            // --- CAMPO: CONFIRMAR NUEVA CONTRASEÑA ---
            _buildPasswordField(
              controller: _confirmController,
              labelText: 'Confirmar Contraseña',
              hintText: 'Repite la contraseña',
              isVisible: _isConfirmVisible,
              onToggleVisibility: () =>
                  setState(() => _isConfirmVisible = !_isConfirmVisible),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _validateAndSubmit,
          icon: const Icon(Icons.key),
          label: Text(widget.submitButtonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 5,
          ),
        ),
      ],
    );
  }

  // Widget de ayuda para no repetir el TextField
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: (value) => setState(() => _errorText = null),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
