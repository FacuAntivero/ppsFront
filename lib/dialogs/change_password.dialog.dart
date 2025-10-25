import 'package:flutter/material.dart';

class ChangePasswordDialog extends StatefulWidget {
  final String superUser;

  const ChangePasswordDialog({super.key, required this.superUser});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _errorText;

  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final newPass = _passwordController.text.trim();
    final confirmPass = _confirmController.text.trim();

    if (newPass.length < 6) {
      setState(() {
        _errorText = 'La contraseña debe tener al menos 6 caracteres.';
      });
      return;
    }
    if (newPass != confirmPass) {
      setState(() {
        _errorText = 'Las contraseñas no coinciden.';
      });
      return;
    }

    Navigator.pop(context, newPass);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Cambiar contraseña de: ${widget.superUser}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Introduce la nueva contraseña para esta Residencia y confírmala.',
                style: TextStyle(fontSize: 14, color: Colors.black54)),

            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_errorText!,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),

            const SizedBox(height: 16),

            // 1. Campo de Nueva Contraseña
            SizedBox(
              height: 80,
              child: TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                autofocus: true,
                onChanged: (value) => setState(() => _errorText = null),
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  hintText: 'Mínimo 6 caracteres',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Campo de Confirmación de Contraseña
            SizedBox(
              height: 80,
              child: TextField(
                controller: _confirmController,
                obscureText: !_isConfirmVisible,
                onChanged: (value) => setState(() => _errorText = null),
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  hintText: 'Repite la contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmVisible = !_isConfirmVisible;
                      });
                    },
                  ),
                ),
              ),
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
          label: const Text('Cambiar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 5,
          ),
        ),
      ],
    );
  }
}
