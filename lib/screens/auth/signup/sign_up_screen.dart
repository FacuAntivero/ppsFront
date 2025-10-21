import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/form_texts.dart';
import 'package:flutter_application/constants/size_config.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpScreen extends StatefulWidget {
  // Constante para el nombre de la ruta
  static const String routeName = '/signup';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isValidating = false;
  bool _isCreating = false;
  bool _licenseValid = false;
  String? _licenseInfo; // texto a mostrar (tipo, max_usuarios)
  ApiService? _api;

  @override
  void initState() {
    super.initState();
    _api = ApiService();
    licenseController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    licenseController.removeListener(_updateButtonState);
    licenseController.dispose();

    super.dispose();
  }

  Future<void> _validateLicense() async {
    final key = licenseController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _licenseInfo = 'Ingrese la licencia';
        _licenseValid = false;
      });
      return;
    }

    // cerrar teclado y mostrar loader
    FocusScope.of(context).unfocus();
    setState(() {
      _isValidating = true;
      _licenseInfo = null;
      _licenseValid = false;
    });

    try {
      final res = await _api!.validateLicense(key);

      final bool valid = res['valid'] == true;
      final backendMessage = res.containsKey('message')
          ? res['message']?.toString()
          : 'Respuesta inesperada del servidor';
      final tipoLicencia = res['tipo_licencia'] ?? '-';
      final maxUsuarios = res['max_usuarios'] ?? 'ilimitado';

      if (!mounted) return;

      setState(() {
        _licenseValid = valid;

        if (_licenseValid) {
          _licenseInfo = 'Licencia válida: $tipoLicencia (Máx: $maxUsuarios)';
        } else {
          _licenseInfo = '$backendMessage';
        }
      });
    } on DioException catch (e) {
      // intentar extraer message/error del body
      String serverMsg = 'Error de conexión';
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          serverMsg = data['message'].toString();
        } else if (data is Map && data.containsKey('error')) {
          serverMsg = data['error'].toString();
        } else {
          serverMsg = data?.toString() ?? e.message ?? serverMsg;
        }
      } else {
        serverMsg = e.message ?? serverMsg;
      }

      setState(() {
        _licenseInfo = 'Error validando licencia: $serverMsg';
        _licenseValid = false;
      });
    } catch (e) {
      setState(() {
        _licenseInfo = 'Error validando licencia: $e';
        _licenseValid = false;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isValidating = false;
      });

      if (_licenseValid && _formKey.currentState != null) {
        _formKey.currentState!.validate();
      }
    }
  }

  // Crear superuser: primero validar formulario, luego llamar createSuperUser
  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final license = licenseController.text.trim();
    final pass = passwordController.text;

    setState(() => _isCreating = true);
    try {
      final res = await _api!.createSuperUser(
          superUser: name, password: pass, licenseKey: license);

      if (!mounted) return;

      if (res['success'] == true) {
        await _storage.write(key: 'superUser', value: name);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Residencia creada correctamente')));
        if (!mounted) return;
        Navigator.pop(context); // volver a login, por ejemplo
      } else {
        final err = res['error'] ?? 'Error al crear';
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
    } catch (e) {
      // Chequeo de mounted antes de usar context
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error de red o servidor')));
    } finally {
      // Chequeo de mounted en el finally
      if (!mounted) return;
      setState(() => _isCreating = false);
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

          // Nombre de la residencia
          CustomTextFormField(
            controller: nameController,
            labelText: 'Nombre de la Residencia',
            prefixIcon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.trim().length < 3) return 'Min 3 caracteres';
              return null;
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.03),

          // Licencia + botón validar
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: licenseController,
                      labelText: 'Licencia',
                      prefixIcon: Icons.fingerprint,
                      // mostramos check si _licenseInfo indica éxito
                      suffixIcon: _isValidating
                          ? null
                          : (_licenseInfo?.startsWith('Licencia:') == true
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : null),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'Min 6 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      onPressed: _isValidating ? null : _validateLicense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isValidating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Validar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              if (_licenseInfo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    _licenseInfo!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _licenseValid
                          ? Colors.green.shade700 // 🟢 Válida
                          : Colors.red.shade700, // 🔴 Inválida/Error
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.03),

          // Contraseña
          CustomTextFormField(
            controller: passwordController,
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
              if (v == null || v.length < 6) return 'Min 6 caracteres';
              return null;
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.03),

          // Confirmar contraseña
          CustomTextFormField(
            controller: confirmPasswordController,
            labelText: 'Confirmar Contraseña',
            prefixIcon: Icons.lock,
            isPassword: !_isConfirmPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey),
              onPressed: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
            validator: (v) {
              if (v == null || v != passwordController.text) {
                return 'No coincide';
              }

              return null;
            },
          ),

          const SizedBox(height: 24),

          // Botón registrar: requiere que el form sea válido y que la licencia haya sido validada
          ElevatedButton(
            onPressed: (_isCreating ||
                    !_licenseValid || // Usamos la variable _licenseValid
                    nameController.text.trim().length < 3 ||
                    passwordController.text.length < 6 ||
                    passwordController.text != confirmPasswordController.text)
                ? null
                : _onRegisterPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Registrarse',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
          ),

          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('¿Ya tenes una cuenta? Inicia sesión',
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
