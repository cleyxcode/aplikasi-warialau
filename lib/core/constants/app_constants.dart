/// Konfigurasi URL API.
///
  /// Default: URL production yang sudah di-deploy.
  /// Override saat build lokal:
  /// ```bash
  /// flutter run --dart-define=API_BASE_HOST=http://10.0.2.2:8000
  /// ```
class AppConstants {
  static const String _baseHost = String.fromEnvironment(
    'API_BASE_HOST',
    defaultValue: 'https://mediumorchid-quail-508400.hostingersite.com',
  );

  /// Domain publik resmi (dokumentasi / deep link web).
  static const String publicSiteHost = String.fromEnvironment(
    'PUBLIC_SITE_HOST',
    defaultValue: 'https://sdnegeriwailau.site',
  );

  static const String baseUrl = '$_baseHost/api/v1';
  static const String storageUrl = '$_baseHost/storage';

  /// Mengembalikan URL lengkap untuk gambar dari storage Laravel.
  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$storageUrl/$path';
  }
}
