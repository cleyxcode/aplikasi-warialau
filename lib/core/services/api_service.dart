import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'auth_session.dart';
import 'storage_service.dart';

class ApiService {
  static Dio? _instance;
  static bool _handlingUnauthorized = false;

  static Dio get instance {
    _instance ??= _create();
    return _instance!;
  }

  static Dio _create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.data is FormData) {
            options.headers.remove('Content-Type');
          }
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          final isAuthEndpoint = path.contains('/auth/login') ||
              path.contains('/auth/register') ||
              path.contains('/auth/forgot-password') ||
              path.contains('/auth/verify-otp') ||
              path.contains('/auth/reset-password');

          if (status == 401 && !isAuthEndpoint && !_handlingUnauthorized) {
            _handlingUnauthorized = true;
            try {
              await AuthSession.handleUnauthorized();
            } finally {
              _handlingUnauthorized = false;
            }
          }

          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
