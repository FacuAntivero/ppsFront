import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants/size_config.dart';
import 'package:flutter_application/screens/auth/forgot_password/forgot_password_screen.dart';
import 'package:flutter_application/screens/auth/signup/sign_up_screen.dart';

class CommonFormWidgets extends StatelessWidget {
  final bool isMobile;
  final bool rememberMeValue;
  final ValueChanged<bool?> onRememberMeChanged;

  const CommonFormWidgets({
    super.key,
    required this.isMobile,
    required this.rememberMeValue,
    required this.onRememberMeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: SizeConfig.screenHeight * 0.01),
        Row(
          mainAxisAlignment:
              isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Checkbox(
              value: rememberMeValue,
              onChanged: onRememberMeChanged,
              activeColor: Colors.teal,
            ),
            const Text('Recordar nombre'),
          ],
        ),
        Align(
          alignment: isMobile ? Alignment.center : Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
            },
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.01),
        ElevatedButton(
          onPressed: () {
            // Aquí iría la lógica de login
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Ingresar',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.03),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey.shade600),
            children: [
              const TextSpan(text: '¿No tenes una cuenta? '),
              TextSpan(
                text: 'Registrate',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, SignUpScreen.routeName);
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
