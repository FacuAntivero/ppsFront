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
    this.requireCurrentPassword = false,
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

    if (widget.requireCurrentPassword && currentPass.isEmpty) {
      setState(() => _errorText = 'Debes ingresar tu contraseña actual.');
      return;
    }

    if (newPass.length < 6) {
      setState(() =>
          _errorText = 'La nueva contraseña debe tener + de 6 caracteres.');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _errorText = 'Las nuevas contraseñas no coinciden.');
      return;
    }

    final Map<String, String> result = {
      'new': newPass,
    };

    if (widget.requireCurrentPassword) {
      result['current'] = currentPass;
    }

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Calculamos el ancho responsivo
    final size = MediaQuery.of(context).size;
    final double dialogWidth = size.width > 600 ? 400 : size.width * 0.9;

    // 2. Definimos la decoración segura con padding fijo
    InputDecoration safeDecoration({
      required String label,
      String? hintText,
      required IconData icon,
      required Widget suffixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hintText,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Fijo
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),

      // 3. Control de ancho y scroll interno
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
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
              if (widget.requireCurrentPassword) ...[
                _buildPasswordField(
                  controller: _currentPasswordController,
                  labelText: 'Tu Contraseña Actual',
                  isVisible: _isCurrentVisible,
                  onToggleVisibility: () =>
                      setState(() => _isCurrentVisible = !_isCurrentVisible),
                  decorationBuilder: safeDecoration, // Pasamos el builder
                ),
                const SizedBox(height: 16),
              ],
              _buildPasswordField(
                controller: _passwordController,
                labelText: 'Nueva Contraseña',
                hintText: 'Mínimo 6 caracteres',
                isVisible: _isPasswordVisible,
                onToggleVisibility: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                decorationBuilder: safeDecoration,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmController,
                labelText: 'Confirmar Contraseña',
                hintText: 'Repite la contraseña',
                isVisible: _isConfirmVisible,
                onToggleVisibility: () =>
                    setState(() => _isConfirmVisible = !_isConfirmVisible),
                decorationBuilder: safeDecoration,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(24),
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
            minimumSize: const Size(100, 45), // Botón consistente
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required InputDecoration Function({
      required String label,
      String? hintText,
      required IconData icon,
      required Widget suffixIcon,
    }) decorationBuilder,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: (value) => setState(() => _errorText = null),
      decoration: decorationBuilder(
        label: labelText,
        hintText: hintText,
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
