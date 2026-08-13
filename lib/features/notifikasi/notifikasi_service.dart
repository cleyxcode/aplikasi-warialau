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
    final data = response.data;
    if (data is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Format respons notifikasi tidak valid.',
        type: DioExceptionType.badResponse,
      );
    }
    return NotifikasiPaginatedResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  /// GET /api/v1/notifikasi/unread-count — Jumlah belum dibaca
  static Future<int> getUnreadCount() async {
    final response = await _dio.get('/notifikasi/unread-count');
    final data = response.data;
    if (data is! Map) return 0;
    return _asInt(
          Map<String, dynamic>.from(data)['unread'],
        ) ??
        0;
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// PATCH /api/v1/notifikasi/{id}/baca — Tandai satu notifikasi dibaca
  static Future<void> markRead(int id) async {
    await _dio.patch('/notifikasi/$id/baca');
  }

  /// PATCH /api/v1/notifikasi/baca-semua — Tandai semua dibaca
  static Future<void> markAllRead() async {
    await _dio.patch('/notifikasi/baca-semua');
  }

  /// DELETE /api/v1/notifikasi/{id} — Hapus notifikasi
  static Future<void> delete(int id) async {
    await _dio.delete('/notifikasi/$id');
  }

  /// Helper: pesan error yang lebih jelas (termasuk HTTP status).
  static String errorMessage(dynamic error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final msg = error.response?.data is Map
          ? (error.response!.data as Map)['message']
          : null;
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
      if (status == 401) {
        return 'Sesi berakhir. Silakan masuk kembali.';
      }
      if (status == 404) {
        return 'Endpoint notifikasi tidak ditemukan (404).';
      }
      if (status == 429) {
        return 'Terlalu banyak permintaan. Coba lagi sebentar.';
      }
      if (status != null && status >= 500) {
        return 'Server sedang bermasalah. Coba lagi nanti.';
      }
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
