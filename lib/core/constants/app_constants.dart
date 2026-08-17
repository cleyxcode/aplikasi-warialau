/// Konfigurasi URL API.
///
/// Default: web lokal via Laravel Sail (10.0.2.2 = host dari emulator Android).
/// Override saat build production:
/// ```bash
/// flutter build apk --dart-define=API_BASE_HOST=https://sdnegeriwailau.site
/// ```
class AppConstants {
  static const String _baseHost = String.fromEnvironment(
    'API_BASE_HOST',
    defaultValue: 'http://10.0.2.2:8000',
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
