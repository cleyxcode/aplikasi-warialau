class UserModel {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String address;
  final String studentName;
  final String studentClass;

  const UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    required this.studentName,
    required this.studentClass,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? address,
    String? studentName,
    String? studentClass,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      studentName: studentName ?? this.studentName,
      studentClass: studentClass ?? this.studentClass,
    );
  }
}

// Dummy user — nanti diganti dengan data dari API/auth
UserModel currentUser = const UserModel(
  name: 'Budi Santoso',
  email: 'budi.santoso@gmail.com',
  phone: '081234567890',
  role: 'Orang Tua Murid',
  address: 'Jl. Melati No. 12, Warialau, Maluku',
  studentName: 'Andi Santoso',
  studentClass: 'Kelas IV A',
);
