import 'package:flutter/material.dart';
import 'package:flutter_application/screens/auth/forgot_password/forgot_password_screen.dart';
import 'package:flutter_application/screens/auth/signup/sign_up_screen.dart';
import 'package:flutter_application/screens/dashboard/dashboard_superUser.dart';
import 'package:flutter_application/screens/dashboard/dashboard_user.dart';
import 'package:flutter_application/screens/dashboard/admin_dashboard.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case ForgotPasswordScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case SignUpScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case SuperUserDashboard.routeName:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final su = args['superUser'] as String? ?? '';
        final tipo = args['tipoLicencia'] as String?;
        return MaterialPageRoute(
          builder: (_) => SuperUserDashboard(superUser: su, tipoLicencia: tipo),
        );

      case UserDashboard.routeName:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final usuario = args['usuario'] as String? ?? '';
        final superUser = args['superUser'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => UserDashboard(
            usuario: usuario,
            superUser: superUser,
          ),
        );

      case AdminDashboard.routeName:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Página no encontrada')),
        );
      },
    );
  }
}
