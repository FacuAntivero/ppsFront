import 'package:flutter/material.dart';
import 'package:flutter_application/components/form_texts.dart';
import 'package:flutter_application/constants/size_config.dart';

class SignUpScreen extends StatefulWidget {
  // Constante para el nombre de la ruta
  static const String routeName = '/signup';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                if (isDesktop) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Image.asset(
                          'assets/images/LogoCircular.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 60),
                      SizedBox(
                        width: 450,
                        child: buildSignUpForm(),
                      ),
                    ],
                  );
                } else {
                  return buildSignUpForm(isMobile: true);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignUpForm({bool isMobile = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
      children: [
        if (isMobile)
          Center(
            child: SizedBox(
              height: SizeConfig.screenWidth * 0.3,
              width: SizeConfig.screenWidth * 0.3,
              child: Image.asset('assets/images/LogoCircular.png',
                  fit: BoxFit.cover),
            ),
          ),
        if (isMobile) SizedBox(height: SizeConfig.screenHeight * 0.04),
        Text(
          'Crear Cuenta',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        CustomTextFormField(
          controller: nameController,
          labelText: 'Nombre y Apellido',
          prefixIcon: Icons.person_outline,
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.03),
        CustomTextFormField(
          controller: emailController,
          labelText: 'Email',
          prefixIcon: Icons.email_outlined,
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.03),
        CustomTextFormField(
          controller: passwordController,
          labelText: 'Contraseña',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.03),
        CustomTextFormField(
          controller: confirmPasswordController,
          labelText: 'Confirmar Contraseña',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // Lógica para registrar al usuario
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
          ),
          child: const Text(
            'Registrarse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '¿Ya tenes una cuenta? Inicia sesión',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
