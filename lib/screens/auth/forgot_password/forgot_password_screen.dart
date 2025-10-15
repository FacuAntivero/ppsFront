import 'package:flutter/material.dart';
import 'package:flutter_application/components/form_texts.dart';
import 'package:flutter_application/constants/size_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

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
                        child: buildForgotPasswordForm(),
                      ),
                    ],
                  );
                } else {
                  return buildForgotPasswordForm(isMobile: true);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildForgotPasswordForm({
    bool isMobile = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
      children: [
        if (isMobile)
          Center(
            child: SizedBox(
              height: SizeConfig.screenWidth * 0.4,
              width: SizeConfig.screenWidth * 0.4,
              child: Image.asset('assets/images/LogoCircular.png',
                  fit: BoxFit.cover),
            ),
          ),
        if (isMobile) SizedBox(height: SizeConfig.screenHeight * 0.05),
        Text(
          'Recuperar Contraseña',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        CustomTextFormField(
          controller: emailController,
          labelText: 'Email de recuperación',
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // Lógica para enviar el email de recuperación
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
            'Enviar Enlace',
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
            'Volver al inicio de sesión',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
