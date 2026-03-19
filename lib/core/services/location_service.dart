import 'package:geolocator/geolocator.dart';

/// Service untuk mengambil lokasi pengguna.
/// Panggil [requestAndGetLocation] untuk minta izin + ambil koordinat.
class LocationService {
  LocationService._();

  /// Minta izin lokasi dan kembalikan [Position] jika diizinkan.
  /// Lempar [LocationException] jika ditolak atau layanan mati.
  static Future<Position> requestAndGetLocation() async {
    // Cek apakah layanan lokasi aktif
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'Layanan lokasi tidak aktif. Aktifkan GPS di pengaturan.',
      );
    }

    // Cek / minta izin
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkan.',
      );
    }

    // Ambil posisi
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// Kembalikan [LocationPermission] saat ini tanpa meminta izin.
  static Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  /// Buka pengaturan aplikasi agar user bisa ubah izin secara manual.
  static Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Buka pengaturan lokasi perangkat.
  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}
