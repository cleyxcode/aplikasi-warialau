import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotifikasiModel {
  final int id;
  final int userId;
  final String judul;
  final String pesan;
  final String tipe;
  final int? referensiId;
  final bool dibaca;
  final DateTime createdAt;

  NotifikasiModel({
    required this.id,
    required this.userId,
    required this.judul,
    required this.pesan,
    required this.tipe,
    this.referensiId,
    required this.dibaca,
    required this.createdAt,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: _asInt(json['id']) ?? 0,
      userId: _asInt(json['user_id']) ?? 0,
      judul: (json['judul'] ?? '').toString(),
      pesan: (json['pesan'] ?? '').toString(),
      tipe: (json['tipe'] ?? 'umum').toString(),
      referensiId: _asInt(json['referensi_id']),
      dibaca: _asBool(json['dibaca']),
      createdAt: _asDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value?.toString().toLowerCase().trim();
    return raw == '1' || raw == 'true' || raw == 'yes';
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  NotifikasiModel copyWith({bool? dibaca}) {
    return NotifikasiModel(
      id: id,
      userId: userId,
      judul: judul,
      pesan: pesan,
      tipe: tipe,
      referensiId: referensiId,
      dibaca: dibaca ?? this.dibaca,
      createdAt: createdAt,
    );
  }

  // Warna ikon berdasarkan tipe
  Color get iconColor {
    switch (tipe) {
      case 'pendaftaran':
        return AppColors.gold;
      case 'berita':
        return AppColors.primary;
      case 'pengumuman':
        return const Color(0xFF3B82F6);
      case 'galeri':
        return const Color(0xFFEC4899);
      case 'kegiatan':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.textSecondary;
    }
  }

  // Ikon berdasarkan tipe
  IconData get icon {
    switch (tipe) {
      case 'pendaftaran':
        return Icons.how_to_reg_rounded;
      case 'berita':
        return Icons.newspaper_rounded;
      case 'pengumuman':
        return Icons.campaign_rounded;
      case 'galeri':
        return Icons.photo_library_rounded;
      case 'kegiatan':
        return Icons.event_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  // Label kategori
  String get kategoriLabel {
    switch (tipe) {
      case 'pendaftaran':
        return 'Pendaftaran';
      case 'berita':
        return 'Berita';
      case 'pengumuman':
        return 'Pengumuman';
      case 'galeri':
        return 'Galeri';
      case 'kegiatan':
        return 'Kegiatan';
      default:
        return 'Info';
    }
  }

  // Pengelompokan berdasarkan tanggal
  String get group {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notifDay = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (notifDay == today) return 'Hari Ini';
    if (notifDay == yesterday) return 'Kemarin';
    return 'Lebih Lama';
  }
}

class NotifikasiPaginatedResponse {
  final List<NotifikasiModel> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? nextPageUrl;

  NotifikasiPaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.nextPageUrl,
  });

  factory NotifikasiPaginatedResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = rawData is List
        ? rawData
            .whereType<Map>()
            .map((e) => NotifikasiModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <NotifikasiModel>[];

    // Support both classic paginator and JsonResource meta wrapper.
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : <String, dynamic>{};

    return NotifikasiPaginatedResponse(
      data: items,
      currentPage: NotifikasiModel._asInt(json['current_page'] ?? meta['current_page']) ?? 1,
      lastPage: NotifikasiModel._asInt(json['last_page'] ?? meta['last_page']) ?? 1,
      total: NotifikasiModel._asInt(json['total'] ?? meta['total']) ?? items.length,
      nextPageUrl: (json['next_page_url'] ?? meta['next_page_url'])?.toString(),
    );
  }

  bool get hasNextPage => nextPageUrl != null && nextPageUrl!.isNotEmpty;
}
