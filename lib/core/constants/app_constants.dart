/// Konfigurasi URL API — ubah [_baseHost] saja untuk ganti domain.
class AppConstants {
  // ── Ganti domain di sini saja ────────────────────────────────────────────
  static const String _baseHost = 'https://lightyellow-dragonfly-487639.hostingersite.com';
  // ─────────────────────────────────────────────────────────────────────────

  static const String baseUrl = '$_baseHost/api/v1';
  static const String storageUrl = '$_baseHost/storage';

  /// Mengembalikan URL lengkap untuk gambar dari storage Laravel.
  /// [path] adalah nilai field gambar dari API, misal: "berita/foto1.jpg"
  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$storageUrl/$path';
  }
}
