class UserModel {
  final int id;
  final String name;
  final String email;
  final String noHp;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.noHp,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      noHp: json['no_hp'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get roleLabel {
    switch (role) {
      case 'orangtua':
        return 'Orang Tua Murid';
      case 'admin':
        return 'Admin';
      default:
        return 'Pengguna';
    }
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? noHp,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      role: role ?? this.role,
    );
  }
}
