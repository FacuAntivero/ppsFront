// lib/dialogs/add_professional_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/services/api_service.dart';

/// Diálogo reutilizable para crear un profesional.
/// Devuelve `true` si se creó correctamente, `false` si se canceló.
class AddProfessionalDialog extends StatefulWidget {
  final ApiService api;
  final String superUser;

  const AddProfessionalDialog({
    super.key,
    required this.api,
    required this.superUser,
  });

  @override
  State<AddProfessionalDialog> createState() => _AddProfessionalDialogState();

  /// Helper estático cómodo para mostrar el diálogo.
  static Future<bool?> show(BuildContext context,
      {required ApiService api, required String superUser}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddProfessionalDialog(api: api, superUser: superUser),
    );
  }
}

class _AddProfessionalDialogState extends State<AddProfessionalDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _submitting = false;
  String? _remoteError;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _nombreCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _remoteError = null;
    });

    try {
      final resp = await widget.api.createUsuario(
        user: _userCtrl.text.trim(),
        superUser: widget.superUser,
        nombreReal: _nombreCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;

      if (resp['success'] == true) {
        Navigator.of(context).pop(true); // éxito
        return;
      } else {
        final err = resp['error'] ?? resp['message'] ?? 'Error creando usuario';
        setState(() => _remoteError = err.toString());
      }
    } catch (e) {
      setState(() => _remoteError = 'Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Agregar profesional',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Residencia: ${widget.superUser}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                    height: 60,
                    child: TextFormField(
                      controller: _userCtrl,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: 'Usuario (login)',
                        hintText: 'ej: licgonzalez',
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'Min 3 caracteres'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: TextFormField(
                      controller: _nombreCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.badge_outlined),
                        labelText: 'Nombre real',
                        hintText: 'ej: Facundo Antivero',
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'Min 3 caracteres'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: TextFormField(
                      controller: _passCtrl,
                      obscureText: !_passwordVisible,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: 'Contraseña',
                        hintText: 'Min 6 caracteres',
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Min 6 caracteres'
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ),
                ]),
              ),
              if (_remoteError != null) ...[
                const SizedBox(height: 12),
                Text(_remoteError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Crear'),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
