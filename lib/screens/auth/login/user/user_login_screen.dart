import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/common_form_widgets.dart';
import 'package:flutter_application/components/form_texts.dart';
import 'package:flutter_application/constants/size_config.dart';
import 'package:flutter_application/screens/auth/login/superuser/superuser_login_screen.dart';
import 'package:flutter_application/screens/dashboard/dashboard_user.dart';
import 'package:flutter_application/services/api_service.dart';

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
  final _formKey = GlobalKey<FormState>();

  bool rememberProfessionalName = false;
  bool _isPasswordVisible = false;
  bool _isLoggingIn = false;
  String? _loginError;
  final List<bool> _toggleSelected = [false, true];

  late final ApiService _api;

  @override
  void initState() {
    super.initState();
    _api = ApiService();
  }

  @override
  void dispose() {
    professionalEmailController.dispose();
    professionalPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = professionalEmailController.text.trim();
    final password = professionalPasswordController.text;

    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    try {
      final res = await _api.loginUser(usuario: usuario, password: password);

      // comprobación estricta
      if (res['success'] == true) {
        final superUser = (res['superUser'] as String?) ?? '';

        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          UserDashboard.routeName,
          arguments: {'superUser': superUser},
        );
        return;
      }

      // Si llegamos acá, login inválido --- mostrar error del backend o genérico
      final err = (res['error'] ?? res['message']) != null
          ? (res['error'] ?? res['message']).toString()
          : 'Credenciales inválidas';
      setState(() => _loginError = err);
    } on DioException catch (e) {
      // Si el backend devolvió 401/400, e.response puede contener body con { success:false, error:... }
      final serverMsg = e.response?.data;
      final err = (serverMsg is Map &&
              (serverMsg['error'] ?? serverMsg['message']) != null)
          ? (serverMsg['error'] ?? serverMsg['message']).toString()
          : 'Error de conexión o servidor';
      setState(() => _loginError = err);
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG unknown error loginUser: $e');
      setState(() => _loginError = 'Error inesperado: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoggingIn = false);
    }
  }

  Widget buildProfessionalLoginForm({bool isMobile = false}) {
    return Form(
      key: _formKey,
      child: Column(
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
            labelText: 'Usuario (Profesional)',
            prefixIcon: Icons.person,
            validator: (v) {
              if (v == null || v.trim().length < 3) return 'Min 3 caracteres';
              return null;
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.03),
          CustomTextFormField(
            controller: professionalPasswordController,
            labelText: 'Contraseña',
            prefixIcon: Icons.lock,
            isPassword: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            validator: (v) {
              if (v == null || v.trim().length < 6) return 'Min 6 caracteres';
              return null;
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          CommonFormWidgets(
            isMobile: isMobile,
            rememberMeValue: rememberProfessionalName,
            onRememberMeChanged: (value) {
              setState(() => rememberProfessionalName = value ?? false);
            },
          ),
          const SizedBox(height: 16),
          if (_loginError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_loginError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ),
          ElevatedButton(
            onPressed: _isLoggingIn ? null : _onLoginPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoggingIn
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Iniciar sesión',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          const SizedBox(
              height: 36), // <- placeholder que iguala la altura del TextButton
        ],
      ),
    );
  }

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
                  isSelected: _toggleSelected,
                  onPressed: (index) {
                    setState(() {
                      for (int i = 0; i < _toggleSelected.length; i++) {
                        _toggleSelected[i] = i == index;
                      }
                    });

                    if (index == 0) {
                      // Volver a la pantalla de login de Residencia (UserLoginScreen)
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const UserLoginScreen(),
                          transitionsBuilder: (_, a, __, c) =>
                              FadeTransition(opacity: a, child: c),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    }
                    // si index == 1, ya estás en Profesional; no navegamos
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
                        child: Text('Residencia')),
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text('Profesional')),
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
                              child: Image.asset(
                                  'assets/images/LogoCircular.png',
                                  fit: BoxFit.contain)),
                          const SizedBox(width: 60),
                          SizedBox(
                              width: 450,
                              child:
                                  buildProfessionalLoginForm(isMobile: false)),
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
}
