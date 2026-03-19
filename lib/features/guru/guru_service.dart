import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import 'guru_model.dart';

class GuruService {
  static final _dio = ApiService.instance;

  /// GET /api/v1/guru — Daftar semua guru aktif
  static Future<List<GuruModel>> getGuru() async {
    final response = await _dio.get('/guru');
    final list = response.data as List;
    return list
        .map((e) => GuruModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String errorMessage(dynamic error) {
    if (error is DioException) {
      final msg = error.response?.data?['message'];
      if (msg != null) return msg.toString();
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi timeout. Periksa internet Anda.';
        case DioExceptionType.connectionError:
          return 'Tidak dapat terhubung ke server.';
        default:
          return 'Terjadi kesalahan jaringan.';
      }
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
