// lib/utils/auth_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Muestra un diálogo de confirmación de logout.
/// Si el usuario confirma, borra las keys provistas en `storageKeys`
/// y navega removiendo toda la pila hacia `loginPage` (widget).
///
/// Devuelve `true` si efectivamente se realizó el logout y la navegación,
/// `false` si se canceló.
Future<bool> logoutAndNavigate({
  required BuildContext context,
  required FlutterSecureStorage storage,
  required Widget loginPage,
  List<String> storageKeys = const ['superUser', 'tipo_licencia'],
  String confirmTitle = 'Cerrar sesión',
  String confirmText = '¿Seguro que querés cerrar sesión?',
  String positiveLabel = 'Cerrar sesión',
  String negativeLabel = 'Cancelar',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(confirmTitle),
      content: Text(confirmText),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(negativeLabel)),
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(positiveLabel)),
      ],
    ),
  );

  if (ok != true) return false;
  // Borra las keys solicitadas (silencioso si no existen)
  for (final k in storageKeys) {
    try {
      await storage.delete(key: k);
    } catch (_) {}
  }

  // Navegar quitando navegación anterior:
  if (!Navigator.of(context).mounted) return true;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => loginPage),
    (route) => false,
  );
  return true;
}

/// Variante que navega por nombre de ruta (pushNamedAndRemoveUntil).
Future<bool> logoutAndNavigateNamed({
  required BuildContext context,
  required FlutterSecureStorage storage,
  required String loginRouteName,
  List<String> storageKeys = const ['superUser', 'tipo_licencia'],
  String confirmTitle = 'Cerrar sesión',
  String confirmText = '¿Seguro que querés cerrar sesión?',
  String positiveLabel = 'Cerrar sesión',
  String negativeLabel = 'Cancelar',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(confirmTitle),
      content: Text(confirmText),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(negativeLabel)),
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(positiveLabel)),
      ],
    ),
  );

  if (ok != true) return false;
  for (final k in storageKeys) {
    try {
      await storage.delete(key: k);
    } catch (_) {}
  }

  if (!Navigator.of(context).mounted) return true;
  Navigator.of(context).pushNamedAndRemoveUntil(loginRouteName, (r) => false);
  return true;
}
