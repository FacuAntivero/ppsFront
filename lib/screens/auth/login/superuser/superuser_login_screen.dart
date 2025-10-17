import 'package:flutter/material.dart';
import 'package:flutter_application/components/common_form_widgets.dart';
import 'package:flutter_application/components/form_texts.dart';
import 'package:flutter_application/constants/size_config.dart';
import 'package:flutter_application/screens/auth/login/user/user_login_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  bool rememberUserName = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              children: [
                ToggleButtons(
                  isSelected: const [true, false],
                  onPressed: (index) {
                    if (index == 1) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const SuperUserLoginScreen(),
                          transitionsBuilder: (_, a, __, c) =>
                              FadeTransition(opacity: a, child: c),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedBorderColor: Colors.teal,
                  selectedColor: Colors.teal,
                  fillColor: Colors.teal.shade100,
                  color: Colors.teal.shade600,
                  children: const [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text('Residencia'),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text('Profesional'),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.05),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;
                    if (isDesktop) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Image.asset('assets/images/LogoCircular.png',
                                fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 60),
                          SizedBox(
                            width: 450,
                            child: buildUserLoginForm(isMobile: false),
                          ),
                        ],
                      );
                    } else {
                      return buildUserLoginForm(isMobile: true);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUserLoginForm({bool isMobile = false}) {
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
        CustomTextFormField(
          controller: userEmailController,
          labelText: 'Usuario (Residencia)',
          prefixIcon: Icons.person,
          validator: (v) {
            if (v == null || v.trim().length < 3) return 'Min 3 caracteres';
            return null;
          },
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.03),
        CustomTextFormField(
          controller: userPasswordController,
          labelText: 'Contraseña',
          prefixIcon: Icons.lock,
          isPassword: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: (v) {
            if (v == null || v.trim().length < 3) return 'Min 3 caracteres';
            return null;
          },
        ),
        CommonFormWidgets(
          isMobile: isMobile,
          rememberMeValue: rememberUserName,
          onRememberMeChanged: (value) {
            setState(() => rememberUserName = value ?? false);
          },
        ),
      ],
    );
  }
}
