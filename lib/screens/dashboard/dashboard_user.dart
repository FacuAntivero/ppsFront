import 'package:flutter/material.dart';
import 'package:flutter_application/screens/auth/login/superUser/superuser_login_screen.dart';
import 'package:flutter_application/utils/auth_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDashboard extends StatelessWidget {
  static const String routeName = '/user-dashboard';

  final String usuario; // login del profesional
  final String superUser; // nombre de la residencia que lo contiene
  final _storage = const FlutterSecureStorage();

  const UserDashboard({
    required this.usuario,
    required this.superUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido $usuario',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Residencia: $superUser',
              style: TextStyle(
                fontSize: 15,
                color: const Color.fromARGB(255, 59, 59, 59),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // Lógica para refrescar la pantalla
              // Por ejemplo, podrías llamar a un método que recargue los datos
            },
            tooltip: 'Refrescar',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => logoutAndNavigate(
              context: context,
              storage: _storage,
              loginPage: const SuperUserLoginScreen(),
            ),
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Dashboard del Profesional',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
