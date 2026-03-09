import '../../core/constants/app_constants.dart';

class GaleriItem {
  final int id;
  final String imageUrl;
  final String title;
  final String category;
  final String date;
  final String keterangan;

  GaleriItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.category = 'Lainnya',
    this.date = '',
    this.keterangan = '',
  });

  factory GaleriItem.fromJson(Map<String, dynamic> json) {
    return GaleriItem(
      id: json['id'] as int,
      imageUrl: AppConstants.imageUrl(json['foto'] as String?),
      title: json['judul'] as String? ?? '',
      keterangan: json['keterangan'] as String? ?? '',
      date: _formatDate(json['created_at'] as String?),
    );
  }

  static String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

const galeriCategories = ['Semua'];
