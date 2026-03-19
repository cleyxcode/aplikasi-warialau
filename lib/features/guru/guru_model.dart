class GuruModel {
  final int id;
  final String nama;
  final String? nip;
  final String jabatan;
  final String? mataPelajaran;
  final String? noHp;
  final String? foto;
  final String status;

  GuruModel({
    required this.id,
    required this.nama,
    this.nip,
    required this.jabatan,
    this.mataPelajaran,
    this.noHp,
    this.foto,
    required this.status,
  });

  factory GuruModel.fromJson(Map<String, dynamic> json) {
    return GuruModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      nip: json['nip'] as String?,
      jabatan: json['jabatan'] as String,
      mataPelajaran: json['mata_pelajaran'] as String?,
      noHp: json['no_hp'] as String?,
      foto: json['foto'] as String?,
      status: json['status'] as String,
    );
  }

  bool get isAktif => status == 'aktif';

  String get fotoUrl {
    if (foto == null) return '';
    const base = 'http://127.0.0.1:8000/storage/';
    return '$base$foto';
  }

  String get initials {
    final parts = nama.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }
}
