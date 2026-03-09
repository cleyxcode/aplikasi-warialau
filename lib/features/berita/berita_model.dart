import '../../core/constants/app_constants.dart';

class BeritaModel {
  final int id;
  final String imageUrl;
  final String category;
  final String title;
  final String date;
  final String readTime;
  final String excerpt;
  final String content;
  final List<String> tags;

  BeritaModel({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.date,
    this.readTime = '',
    this.excerpt = '',
    this.content = '',
    this.tags = const [],
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    final raw = json['isi'] as String? ?? '';
    final plain = _stripHtml(raw);
    return BeritaModel(
      id: json['id'] as int,
      imageUrl: AppConstants.imageUrl(json['gambar'] as String?),
      category: json['kategori'] as String? ?? 'Info',
      title: json['judul'] as String? ?? '',
      date: _formatDate(json['tanggal_publish'] as String?),
      readTime: _calcReadTime(plain),
      excerpt: plain.length > 120 ? '${plain.substring(0, 120)}...' : plain,
      content: plain,
    );
  }

  static String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  static String _calcReadTime(String text) {
    if (text.trim().isEmpty) return '1 menit baca';
    final words = text.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil().clamp(1, 99);
    return '$minutes menit baca';
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
