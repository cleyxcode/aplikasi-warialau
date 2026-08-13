import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_sd/app/app_routes.dart';
import 'package:mobile_apps_sd/core/constants/app_colors.dart';
import 'package:mobile_apps_sd/core/constants/app_constants.dart';
import 'package:mobile_apps_sd/core/services/storage_service.dart';
import 'package:mobile_apps_sd/features/pendaftaran/pendaftaran_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRoutes', () {
    test('exposes auth and feature paths used by APK', () {
      expect(AppRoutes.splash, '/');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.register, '/register');
      expect(AppRoutes.forgotPassword, '/forgot-password');
      expect(AppRoutes.otp, '/otp');
      expect(AppRoutes.resetPassword, '/reset-password');
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.notifikasi, '/notifikasi');
      expect(AppRoutes.detailBerita, '/detail-berita');
      expect(AppRoutes.detailPendaftaran, '/detail-pendaftaran');
    });
  });

  group('AppConstants API contract', () {
    test('base and storage urls are consistent', () {
      expect(AppConstants.baseUrl, endsWith('/api/v1'));
      expect(AppConstants.storageUrl, endsWith('/storage'));
      expect(
        AppConstants.imageUrl('pendaftaran/kk/a.jpg'),
        '${AppConstants.storageUrl}/pendaftaran/kk/a.jpg',
      );
    });
  });

  group('StorageService auth token', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('save get clear and isLoggedIn', () async {
      expect(await StorageService.isLoggedIn(), isFalse);

      await StorageService.saveToken('token-abc');
      expect(await StorageService.getToken(), 'token-abc');
      expect(await StorageService.isLoggedIn(), isTrue);

      await StorageService.clearToken();
      expect(await StorageService.getToken(), isNull);
      expect(await StorageService.isLoggedIn(), isFalse);

      await StorageService.saveToken('again');
      await StorageService.clearAll();
      expect(await StorageService.getToken(), isNull);
    });
  });

  group('PendaftaranStatus', () {
    test('labels for workflow statuses', () {
      expect(PendaftaranStatus.label('pending'), 'Menunggu verifikasi');
      expect(PendaftaranStatus.label(null), 'Menunggu verifikasi');
      expect(PendaftaranStatus.label('diterima'), 'Diterima');
      expect(PendaftaranStatus.label('ditolak'), 'Ditolak');
      expect(
        PendaftaranStatus.label('perlu_perbaikan'),
        'Perlu perbaikan dokumen',
      );
    });

    test('colors and flags', () {
      expect(PendaftaranStatus.color('diterima'), const Color(0xFF16A34A));
      expect(PendaftaranStatus.color('ditolak'), AppColors.danger);
      expect(PendaftaranStatus.color('perlu_perbaikan'), const Color(0xFF0284C7));
      expect(PendaftaranStatus.color('pending'), const Color(0xFFD97706));

      expect(PendaftaranStatus.canResubmitDokumen('perlu_perbaikan'), isTrue);
      expect(PendaftaranStatus.canResubmitDokumen('pending'), isFalse);
      expect(PendaftaranStatus.isFinal('diterima'), isTrue);
      expect(PendaftaranStatus.isFinal('ditolak'), isTrue);
      expect(PendaftaranStatus.isFinal('pending'), isFalse);
    });
  });
}
