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
      id: json['id'] as int,
      userId: json['user_id'] as int,
      judul: json['judul'] as String,
      pesan: json['pesan'] as String,
      tipe: json['tipe'] as String,
      referensiId: json['referensi_id'] as int?,
      dibaca: json['dibaca'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
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
    return NotifikasiPaginatedResponse(
      data: (json['data'] as List)
          .map((e) => NotifikasiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      total: json['total'] as int,
      nextPageUrl: json['next_page_url'] as String?,
    );
  }

  bool get hasNextPage => nextPageUrl != null;
}
