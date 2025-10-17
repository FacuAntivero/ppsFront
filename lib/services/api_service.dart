import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;
  ApiService(String baseUrl)
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(milliseconds: 50000),
          receiveTimeout: const Duration(milliseconds: 50000),
        ));

  // Validate license
  Future<Map<String, dynamic>> validateLicense(String licenseKey) async {
    final resp =
        await dio.post('/license/validate', data: {'licenseKey': licenseKey});
    return resp.data as Map<String, dynamic>;
  }

  // Create superuser (register residence)
  Future<Map<String, dynamic>> createSuperUser({
    required String superUser,
    required String password,
    required String licenseKey,
  }) async {
    final resp = await dio.post('/superuser', data: {
      'superUser': superUser,
      'password': password,
      'confirmPassword': password, // server validates equality too
      'licenseKey': licenseKey,
    });
    return resp.data as Map<String, dynamic>;
  }
}
