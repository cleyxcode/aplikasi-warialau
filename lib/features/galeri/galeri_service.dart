import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import 'galeri_model.dart';

class GaleriPagedResponse {
  final List<GaleriItem> items;
  final int currentPage;
  final int lastPage;

  const GaleriPagedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });
}

class GaleriService {
  GaleriService._();

  /// GET /api/v1/galeri — Daftar foto galeri paginated
  static Future<GaleriPagedResponse> getGaleri({
    int page = 1,
    int perPage = 12,
  }) async {
    final resp = await ApiService.instance.get(
      '/galeri',
      queryParameters: {'per_page': perPage, 'page': page},
    );
    final data = resp.data as Map<String, dynamic>;
    return GaleriPagedResponse(
      items: (data['data'] as List)
          .map((e) => GaleriItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: data['current_page'] as int,
      lastPage: data['last_page'] as int,
    );
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
