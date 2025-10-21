import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  final Dio dio;

  ApiService({String? baseUrl})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl ??
              (kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000'),
          connectTimeout: const Duration(milliseconds: 50000),
          receiveTimeout: const Duration(milliseconds: 50000),
        ));

  // Utility: normalizar respuesta de error de Dio a Map
  Map<String, dynamic> _errorFromDio(DioException e) {
    if (e.response != null && e.response!.data is Map) {
      try {
        return Map<String, dynamic>.from(e.response!.data);
      } catch (_) {
        return {'success': false, 'error': e.response!.data.toString()};
      }
    }
    return {'success': false, 'error': e.message};
  }

  // Validate license
  Future<Map<String, dynamic>> validateLicense(String licenseKey) async {
    try {
      final resp =
          await dio.post('/license/validate', data: {'licenseKey': licenseKey});
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      return _errorFromDio(e);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Create superuser (register residence)
  Future<Map<String, dynamic>> createSuperUser({
    required String superUser,
    required String password,
    required String licenseKey,
  }) async {
    try {
      final resp = await dio.post('/superuser', data: {
        'superUser': superUser,
        'password': password,
        'confirmPassword': password,
        'licenseKey': licenseKey,
      });
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      return _errorFromDio(e);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // LOGIN SUPERUSER
  Future<Map<String, dynamic>> loginSuperUser({
    required String usuario,
    required String password,
  }) async {
    try {
      final resp = await dio.post('/login-superuser', data: {
        'usuario': usuario,
        'password': password,
      });
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      return _errorFromDio(e);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // GET /superuser/:superUser/usuarios
  Future<Map<String, dynamic>> getUsuariosSuperUser(String superUser) async {
    try {
      final resp = await dio.get('/superuser/$superUser/usuarios');
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      return _errorFromDio(e);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // POST /usuarios  (crear usuario profesional)
  Future<Map<String, dynamic>> createUsuario({
    required String user,
    required String superUser,
    required String nombreReal,
    required String password,
  }) async {
    try {
      final resp = await dio.post('/usuarios', data: {
        'user': user,
        'superUser': superUser,
        'nombreReal': nombreReal,
        'password': password,
      });
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      return _errorFromDio(e);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // PUT /cambiar-password
  Future<Map<String, dynamic>> changePassword({
    required String superUser,
    required String superUserPassword,
    required String targetUser,
    required String newPassword,
  }) async {
    try {
      final resp = await dio.put('/cambiar-password', data: {
        'superUser': superUser,
        'superUserPassword': superUserPassword,
        'targetUser': targetUser,
        'newPassword': newPassword,
      });
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      return _errorFromDio(e);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // POST /login-user (profesional)
  Future<Map<String, dynamic>> loginUser({
    required String usuario,
    required String password,
  }) async {
    try {
      final resp = await dio.post('/login-user', data: {
        'usuario': usuario,
        'password': password,
      });
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      return _errorFromDio(e);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // helper: crear instancia singleton si querés
  static ApiService instance({String? baseUrl}) => ApiService(baseUrl: baseUrl);
}
