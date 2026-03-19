import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import 'notifikasi_model.dart';

class NotifikasiService {
  static final _dio = ApiService.instance;

  /// GET /api/v1/notifikasi — Daftar notifikasi (paginated)
  static Future<NotifikasiPaginatedResponse> getNotifikasi({
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/notifikasi',
      queryParameters: {'page': page},
    );
    return NotifikasiPaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// GET /api/v1/notifikasi/unread-count — Jumlah belum dibaca
  static Future<int> getUnreadCount() async {
    final response = await _dio.get('/notifikasi/unread-count');
    return (response.data as Map<String, dynamic>)['unread'] as int;
  }

  /// PATCH /api/v1/notifikasi/{id}/baca — Tandai satu notifikasi dibaca
  static Future<void> markRead(int id) async {
    await _dio.patch('/notifikasi/$id/baca');
  }

  /// PATCH /api/v1/notifikasi/baca-semua — Tandai semua dibaca
  static Future<void> markAllRead() async {
    await _dio.patch('/notifikasi/baca-semua');
  }

  /// Helper: cek apakah error adalah DioException
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
