import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_sd/core/constants/app_colors.dart';
import 'package:mobile_apps_sd/core/constants/app_constants.dart';
import 'package:mobile_apps_sd/core/models/user_model.dart';
import 'package:mobile_apps_sd/core/widgets/empty_view.dart';
import 'package:mobile_apps_sd/core/widgets/error_view.dart';
import 'package:mobile_apps_sd/features/berita/berita_model.dart';
import 'package:mobile_apps_sd/features/galeri/galeri_model.dart';
import 'package:mobile_apps_sd/features/guru/guru_model.dart';
import 'package:mobile_apps_sd/features/notifikasi/notifikasi_model.dart';
import 'package:mobile_apps_sd/features/splash/splash_screen.dart';

void main() {
  group('AppConstants', () {
    test('imageUrl builds storage path', () {
      expect(
        AppConstants.imageUrl('berita/foto.jpg'),
        '${AppConstants.storageUrl}/berita/foto.jpg',
      );
    });

    test('imageUrl returns empty for null/blank', () {
      expect(AppConstants.imageUrl(null), '');
      expect(AppConstants.imageUrl(''), '');
    });

    test('baseUrl points to api v1', () {
      expect(AppConstants.baseUrl.endsWith('/api/v1'), isTrue);
    });
  });

  group('UserModel', () {
    test('fromJson maps fields and helpers', () {
      final user = UserModel.fromJson({
        'id': 7,
        'name': 'Maria Wattimena',
        'email': 'maria@test.com',
        'no_hp': '0812',
        'role': 'orangtua',
      });

      expect(user.id, 7);
      expect(user.initials, 'MW');
      expect(user.roleLabel, 'Orang Tua Murid');
      expect(user.copyWith(name: 'Budi').name, 'Budi');
    });

    test('roleLabel fallback', () {
      final user = UserModel.fromJson({'name': 'X', 'role': 'lain'});
      expect(user.roleLabel, 'Pengguna');
      expect(user.initials, 'X');
    });
  });

  group('BeritaModel', () {
    test('fromJson strips html and formats metadata', () {
      final berita = BeritaModel.fromJson({
        'id': 1,
        'judul': 'Judul Berita',
        'kategori': 'Prestasi',
        'gambar': 'berita/a.jpg',
        'tanggal_publish': '2026-03-01',
        'isi': '<p>Halo dunia sekolah dasar Warialau untuk uji baca.</p>',
      });

      expect(berita.id, 1);
      expect(berita.title, 'Judul Berita');
      expect(berita.category, 'Prestasi');
      expect(berita.imageUrl, contains('berita/a.jpg'));
      expect(berita.content, contains('Halo dunia'));
      expect(berita.content.contains('<p>'), isFalse);
      expect(berita.date, '1 Mar 2026');
      expect(berita.readTime, contains('menit baca'));
    });
  });

  group('GuruModel', () {
    test('fromJson and helpers', () {
      final guru = GuruModel.fromJson({
        'id': 3,
        'nama': 'Andi Wijaya',
        'nip': '123',
        'jabatan': 'Guru Kelas',
        'mata_pelajaran': 'IPA',
        'no_hp': '0811',
        'foto': 'guru/a.jpg',
        'status': 'aktif',
      });

      expect(guru.isAktif, isTrue);
      expect(guru.initials, 'AW');
      expect(guru.fotoUrl, contains('guru/a.jpg'));
    });
  });

  group('GaleriItem', () {
    test('fromJson maps title and date', () {
      final item = GaleriItem.fromJson({
        'id': 9,
        'judul': 'Kegiatan Literasi',
        'foto': 'galeri/x.jpg',
        'keterangan': 'Keterangan',
        'created_at': '2026-02-10T10:00:00.000000Z',
      });

      expect(item.title, 'Kegiatan Literasi');
      expect(item.imageUrl, contains('galeri/x.jpg'));
      expect(item.date, '10 Feb 2026');
    });
  });

  group('NotifikasiModel', () {
    test('fromJson and typed helpers', () {
      final notif = NotifikasiModel.fromJson({
        'id': 1,
        'user_id': 2,
        'judul': 'Status berubah',
        'pesan': 'Pendaftaran diterima',
        'tipe': 'pendaftaran',
        'referensi_id': 99,
        'dibaca': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      expect(notif.kategoriLabel, 'Pendaftaran');
      expect(notif.group, 'Hari Ini');
      expect(notif.iconColor, AppColors.gold);
      expect(notif.copyWith(dibaca: true).dibaca, isTrue);
    });

    test('fromJson coerces mysql-style ints and strings', () {
      final notif = NotifikasiModel.fromJson({
        'id': '12',
        'user_id': 3.0,
        'judul': 'Berita',
        'pesan': 'Pesan',
        'tipe': 'berita',
        'referensi_id': '8',
        'dibaca': 0,
        'created_at': '2026-01-01T00:00:00.000000Z',
      });

      expect(notif.id, 12);
      expect(notif.userId, 3);
      expect(notif.referensiId, 8);
      expect(notif.dibaca, isFalse);

      final read = NotifikasiModel.fromJson({
        'id': 1,
        'user_id': 1,
        'judul': 'X',
        'pesan': 'Y',
        'tipe': 'umum',
        'dibaca': 1,
        'created_at': '2026-01-01T00:00:00.000000Z',
      });
      expect(read.dibaca, isTrue);
    });

    test('paginated response parser', () {
      final page = NotifikasiPaginatedResponse.fromJson({
        'data': [
          {
            'id': 1,
            'user_id': 2,
            'judul': 'A',
            'pesan': 'B',
            'tipe': 'umum',
            'dibaca': true,
            'created_at': '2026-01-01T00:00:00.000000Z',
          },
        ],
        'current_page': 1,
        'last_page': 2,
        'total': 3,
        'next_page_url': 'https://example.com?page=2',
      });

      expect(page.data, hasLength(1));
      expect(page.hasNextPage, isTrue);
      expect(page.total, 3);
    });

    test('paginated response supports meta wrapper', () {
      final page = NotifikasiPaginatedResponse.fromJson({
        'data': [
          {
            'id': 1,
            'user_id': 1,
            'judul': 'A',
            'pesan': 'B',
            'tipe': 'umum',
            'dibaca': false,
            'created_at': '2026-01-01T00:00:00.000000Z',
          },
        ],
        'meta': {
          'current_page': 2,
          'last_page': 4,
          'total': 10,
        },
      });

      expect(page.currentPage, 2);
      expect(page.lastPage, 4);
      expect(page.total, 10);
      expect(page.hasNextPage, isFalse);
    });
  });

  group('Shared widgets', () {
    testWidgets('EmptyView renders message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(message: 'Belum ada data'),
          ),
        ),
      );
      expect(find.text('Belum ada data'), findsOneWidget);
    });

    testWidgets('ErrorView renders and triggers retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Gagal memuat',
              onRetry: () => retried = true,
              lottieSize: 80,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Gagal memuat'), findsOneWidget);
      await tester.ensureVisible(find.text('Coba Lagi'));
      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });
  });

  group('SplashScreen', () {
    testWidgets('renders school brand on first frame', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      await tester.pump();
      expect(find.text('SD Negeri Warialau'), findsOneWidget);
      expect(find.textContaining('Kepulauan Aru'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
