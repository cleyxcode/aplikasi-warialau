import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Label & warna status PPDB — dipakai UI dan unit test.
class PendaftaranStatus {
  PendaftaranStatus._();

  static String label(String? status) {
    return switch (status) {
      'diterima' => 'Diterima',
      'ditolak' => 'Ditolak',
      'perlu_perbaikan' => 'Perlu perbaikan dokumen',
      _ => 'Menunggu verifikasi',
    };
  }

  static Color color(String? status) {
    return switch (status) {
      'diterima' => const Color(0xFF16A34A),
      'ditolak' => AppColors.danger,
      'perlu_perbaikan' => const Color(0xFF0284C7),
      _ => const Color(0xFFD97706),
    };
  }

  static bool canResubmitDokumen(String? status) => status == 'perlu_perbaikan';

  static bool isFinal(String? status) =>
      status == 'diterima' || status == 'ditolak';
}
