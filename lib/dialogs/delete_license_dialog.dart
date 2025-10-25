import 'package:flutter/material.dart';

class DeleteLicenseDialog extends StatelessWidget {
  final int licenseId;
  final String licenseType;

  const DeleteLicenseDialog({
    super.key,
    required this.licenseId,
    required this.licenseType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const dangerColor = Colors.red;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: dangerColor, size: 28),
          const SizedBox(width: 10),
          const Text('Confirmar eliminación'),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
          children: <TextSpan>[
            const TextSpan(
                text:
                    '¿Estás seguro de que quieres eliminar permanentemente la licencia '),
            TextSpan(
              text: '${licenseType.toUpperCase()} (ID $licenseId)',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: dangerColor),
            ),
            const TextSpan(text: '? Esta acción no se puede deshacer.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.delete_forever),
          label: const Text('Borrar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: dangerColor, // Color rojo para acción destructiva
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 5,
          ),
        ),
      ],
    );
  }
}
