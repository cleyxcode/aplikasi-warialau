import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import 'berita_model.dart';

class BeritaPagedResponse {
  final List<BeritaModel> items;
  final int currentPage;
  final int lastPage;

  const BeritaPagedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });
}

class BeritaService {
  BeritaService._();

  /// GET /api/v1/berita — Daftar berita paginated
  static Future<BeritaPagedResponse> getBerita({
    int page = 1,
    int perPage = 10,
  }) async {
    final resp = await ApiService.instance.get(
      '/berita',
      queryParameters: {'per_page': perPage, 'page': page},
    );
    final data = resp.data as Map<String, dynamic>;
    return BeritaPagedResponse(
      items: (data['data'] as List)
          .map((e) => BeritaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: data['current_page'] as int,
      lastPage: data['last_page'] as int,
    );
  }

  /// GET /api/v1/berita/{id} — Detail satu berita
  static Future<BeritaModel> getDetailBerita(int id) async {
    final resp = await ApiService.instance.get('/berita/$id');
    return BeritaModel.fromJson(resp.data as Map<String, dynamic>);
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
