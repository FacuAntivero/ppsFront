import 'package:flutter/material.dart';
//import 'package:flutter_application/screens/auth/forgot_password/forgot_password_screen.dart';

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
        // Row(
        //   mainAxisAlignment:
        //       isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        //   children: [
        //     Checkbox(
        //       value: rememberMeValue,
        //       onChanged: onRememberMeChanged,
        //       activeColor: Colors.teal,
        //     ),
        //     const Text('Recordar nombre'),
        //   ],
        // ),
        // Align(
        //   alignment: isMobile ? Alignment.center : Alignment.centerLeft,
        //   child: TextButton(
        //     onPressed: () {
        //       Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
        //     },
        //     child: const Text(
        //       '¿Olvidaste tu contraseña?',
        //       style: TextStyle(color: Colors.blue),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
