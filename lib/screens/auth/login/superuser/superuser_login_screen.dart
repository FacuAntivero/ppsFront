import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/common_form_widgets.dart';
import 'package:flutter_application/components/form_texts.dart';
import 'package:flutter_application/components/responsive_login_layout.dart';
import 'package:flutter_application/constants/size_config.dart';
import 'package:flutter_application/screens/auth/login/user/user_login_screen.dart';
import 'package:flutter_application/screens/dashboard/admin_dashboard.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application/screens/dashboard/dashboard_superUser.dart';
import 'package:flutter_application/components/primary_action_button.dart';

class SuperUserLoginScreen extends StatefulWidget {
  const SuperUserLoginScreen({super.key});

  @override
  State<SuperUserLoginScreen> createState() => _SuperUserLoginScreenState();
}

class _SuperUserLoginScreenState extends State<SuperUserLoginScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  bool rememberUserName = false;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoggingIn = false;
  String? _loginError;
  ApiService? _api;
  final _storage =
      const FlutterSecureStorage(); // para guardar superUser si quisieras
  final List<bool> _toggleSelected = [true, false]; // estado real del toggle

  @override
  void initState() {
    super.initState();
    _api = ApiService();
  }

  Future<void> _onLoginPressed() async {
    // validar form
    if (!_formKey.currentState!.validate()) return;

    final usuario = userNameController.text.trim();
    final password = userPasswordController.text;

    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    try {
      final res =
          await _api!.loginSuperUser(usuario: usuario, password: password);

      if (res['success'] == true) {
        final tipo = res['tipo_licencia']; // puede ser null
        final isAdmin = res['is_admin'] == true;

        // opcional: guardar superUser y tipo
        await _storage.write(key: 'superUser', value: usuario);
        await _storage.write(
            key: 'tipo_licencia', value: tipo?.toString() ?? '');

        if (!mounted) return;

        if (isAdmin) {
          // Navegar al dashboard administrador
          Navigator.pushReplacementNamed(context, AdminDashboard.routeName);
        } else {
          // Dashboard normal de residencia
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SuperUserDashboard(
                superUser: usuario,
                tipoLicencia: tipo?.toString(),
              ),
            ),
          );
        }
      } else {
        final err = res['error'] ?? res['message'] ?? 'Credenciales inválidas';
        setState(() => _loginError = err.toString());
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['error'] ??
              e.response!.data['message'] ??
              e.message)
          : e.message;
      setState(() => _loginError = 'Error: ${msg.toString()}');
    } catch (e) {
      setState(() => _loginError = 'Error inesperado: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoggingIn = false);
    }
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
                  isSelected:
                      _toggleSelected, // debe ser [true, false] en initState
                  onPressed: (index) {
                    setState(() {
                      for (int i = 0; i < _toggleSelected.length; i++) {
                        _toggleSelected[i] = i == index;
                      }
                    });

                    // Si selecciona "Profesional" (índice 1) -> navegar a UserLoginScreen
                    if (index == 1) {
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
                ResponsiveLoginLayout(
                  form: buildUserLoginForm(isMobile: false),
                  imageAsset: 'assets/images/LogoCircular.png',
                  formWidth: 450,
                  imageMaxWidthFraction: 0.35,
                  imageMaxWidthPx: 360,
                  spacing: 60,
                  desktopBreakpoint: 800,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUserLoginForm({bool isMobile = false}) {
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

          // Usuario (residencia)
          CustomTextFormField(
            controller: userNameController,
            labelText: 'Usuario (Residencia)',
            prefixIcon: Icons.person,
            validator: (v) {
              if (v == null || v.trim().length < 3) return 'Min 3 caracteres';
              return null;
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.03),

          // Contraseña
          CustomTextFormField(
            controller: userPasswordController,
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
              if (v == null || v.trim().length < 3) return 'Min 3 caracteres';
              return null;
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),

          // Remember + other controls (your custom widget)
          CommonFormWidgets(
            isMobile: isMobile,
            rememberMeValue: rememberUserName,
            onRememberMeChanged: (value) =>
                setState(() => rememberUserName = value ?? false),
          ),

          const SizedBox(height: 16),

          // Error message from backend
          if (_loginError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_loginError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ),

          // Login button
          PrimaryActionButton(
            onPressed: _isLoggingIn ? null : _onLoginPressed,
            loading: _isLoggingIn,
            label: 'Iniciar sesión',
            height: 52,
          ),
          const SizedBox(height: 12),

          // Link to sign up or other navigation
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            child: const Text('¿No tenés cuenta? Crear residencia',
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
