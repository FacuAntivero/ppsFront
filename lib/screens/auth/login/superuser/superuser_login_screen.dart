import 'package:flutter/material.dart';
import 'package:flutter_application/components/common_form_widgets.dart';
import 'package:flutter_application/components/form_texts.dart';
import 'package:flutter_application/constants/size_config.dart';
import 'package:flutter_application/screens/auth/login/user/user_login_screen.dart';

class SuperUserLoginScreen extends StatefulWidget {
  const SuperUserLoginScreen({super.key});

  @override
  State<SuperUserLoginScreen> createState() => _SuperUserLoginScreenState();
}

class _SuperUserLoginScreenState extends State<SuperUserLoginScreen> {
  final TextEditingController professionalEmailController =
      TextEditingController();
  final TextEditingController professionalPasswordController =
      TextEditingController();
  bool rememberProfessionalName = false;

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
                  isSelected: const [false, true],
                  onPressed: (index) {
                    if (index == 0) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const UserLoginScreen(),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(
                            opacity: a,
                            child: c,
                          ),
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
                      child: Text('Usuario'),
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
                            child: buildProfessionalLoginForm(isMobile: false),
                          ),
                        ],
                      );
                    } else {
                      return buildProfessionalLoginForm(isMobile: true);
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

  Widget buildProfessionalLoginForm({bool isMobile = false}) {
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
          controller: professionalEmailController,
          labelText: 'Profesional (Matrícula)',
          prefixIcon: Icons.school,
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.03),
        CustomTextFormField(
          controller: professionalPasswordController,
          labelText: 'Contraseña',
          prefixIcon: Icons.lock,
          isPassword: true,
        ),
        CommonFormWidgets(
          isMobile: isMobile,
          rememberMeValue: rememberProfessionalName,
          onRememberMeChanged: (value) {
            setState(() => rememberProfessionalName = value ?? false);
          },
        ),
      ],
    );
  }
}
