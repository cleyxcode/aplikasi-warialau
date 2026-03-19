import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../guru/guru_screen.dart';

class ProfilUserScreen extends StatefulWidget {
  const ProfilUserScreen({super.key});

  @override
  State<ProfilUserScreen> createState() => _ProfilUserScreenState();
}

class _ProfilUserScreenState extends State<ProfilUserScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _showPasswordSection = false;
  bool _isLoading = true;

  UserModel? _user;

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _oldPassCtrl;
  late TextEditingController _newPassCtrl;
  late TextEditingController _confirmPassCtrl;

  // Animation
  late AnimationController _editAnimCtrl;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _oldPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();

    _editAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fetchProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _editAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final r = await ApiService.instance.get('/profile');
      if (!mounted) return;
      final u = UserModel.fromJson(r.data as Map<String, dynamic>);
      setState(() {
        _user = u;
        _nameCtrl.text = u.name;
        _emailCtrl.text = u.email;
        _phoneCtrl.text = u.noHp;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (_isEditing) {
      _editAnimCtrl.forward();
    } else {
      _editAnimCtrl.reverse();
      if (_user != null) {
        _nameCtrl.text = _user!.name;
        _emailCtrl.text = _user!.email;
        _phoneCtrl.text = _user!.noHp;
      }
      _showPasswordSection = false;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final r = await ApiService.instance.patch('/profile/info', data: {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'no_hp': _phoneCtrl.text.trim(),
      });
      if (!mounted) return;
      final updated = UserModel.fromJson(r.data['user'] as Map<String, dynamic>);
      setState(() {
        _user = updated;
        _isSaving = false;
        _isEditing = false;
        _showPasswordSection = false;
      });
      _editAnimCtrl.reverse();
      messenger.showSnackBar(_snackBar('Profil berhasil diperbarui', AppColors.success));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(_snackBar('Gagal menyimpan profil', AppColors.danger));
    }
  }

  SnackBar _snackBar(String msg, Color color) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            color == AppColors.success
                ? Icons.check_circle_rounded
                : Icons.error_rounded,
            color: AppColors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            msg,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            'Profil Saya',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'lib/animations/loading _school.json',
                width: 200,
                height: 200,
                repeat: true,
              ),
              const SizedBox(height: 16),
              Text(
                'Memuat Profil...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildInfoSection(),
                  const SizedBox(height: 16),
                  _buildGuruMenu(),
                  const SizedBox(height: 16),
                  _buildPasswordSection(),
                  const SizedBox(height: 16),
                  _buildDangerZone(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isEditing ? _buildSaveBar() : null,
    );
  }

  // ── App Bar ──────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.white,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Profil Saya',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            key: ValueKey(_isEditing),
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isEditing
                    ? Colors.white.withValues(alpha: 0.15)
                    : AppColors.gold.withValues(alpha: 0.2),
              ),
              child: Icon(
                _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                color: _isEditing ? Colors.white70 : AppColors.gold,
                size: 18,
              ),
            ),
            onPressed: _isSaving ? null : _toggleEdit,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Profile Header ───────────────────────────────────────
  Widget _buildProfileHeader() {
    final user = _user;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, Color(0xFF254A7A)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, Color(0xFFE8C547)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user?.initials ?? '?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    user?.roleLabel ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Section ─────────────────────────────────────────
  Widget _buildInfoSection() {
    return _SectionCard(
      title: 'Informasi Akun',
      icon: Icons.person_rounded,
      children: [
        _buildField(
          label: 'Nama Lengkap',
          icon: Icons.badge_rounded,
          controller: _nameCtrl,
          enabled: _isEditing,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
        ),
        _buildField(
          label: 'Alamat Email',
          icon: Icons.mail_rounded,
          controller: _emailCtrl,
          enabled: _isEditing,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
            if (!v.contains('@')) return 'Email tidak valid';
            return null;
          },
        ),
        _buildField(
          label: 'Nomor Telepon',
          icon: Icons.phone_rounded,
          controller: _phoneCtrl,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // ── Guru Menu ────────────────────────────────────────────
  Widget _buildGuruMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GuruScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Daftar Guru',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Password Section ─────────────────────────────────────
  Widget _buildPasswordSection() {
    return _SectionCard(
      title: 'Keamanan',
      icon: Icons.security_rounded,
      children: [
        if (!_showPasswordSection)
          GestureDetector(
            onTap: _isEditing
                ? () => setState(() => _showPasswordSection = true)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: _isEditing
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : AppColors.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isEditing
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 20,
                    color: _isEditing ? AppColors.primary : AppColors.textLight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ganti Kata Sandi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isEditing
                            ? AppColors.primary
                            : AppColors.textLight,
                      ),
                    ),
                  ),
                  if (_isEditing)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          )
        else ...[
          _buildPasswordField(
            label: 'Kata Sandi Lama',
            controller: _oldPassCtrl,
            obscure: _obscureOld,
            onToggle: () => setState(() => _obscureOld = !_obscureOld),
          ),
          _buildPasswordField(
            label: 'Kata Sandi Baru',
            controller: _newPassCtrl,
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          _buildPasswordField(
            label: 'Konfirmasi Kata Sandi Baru',
            controller: _confirmPassCtrl,
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) {
              if (_newPassCtrl.text.isNotEmpty && v != _newPassCtrl.text) {
                return 'Kata sandi tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() {
              _showPasswordSection = false;
              _oldPassCtrl.clear();
              _newPassCtrl.clear();
              _confirmPassCtrl.clear();
            }),
            child: Text(
              'Batal ganti kata sandi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Danger Zone ──────────────────────────────────────────
  Widget _buildDangerZone() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded,
                  color: AppColors.danger, size: 20),
              const SizedBox(width: 10),
              Text(
                'Keluar dari Akun',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Save Bar ─────────────────────────────────────────────
  Widget _buildSaveBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isSaving ? null : _toggleEdit,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Center(
                  child: Text(
                    'Batal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isSaving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF2D5A9B)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_rounded,
                                color: AppColors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Simpan Perubahan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Keluar dari Akun?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Anda akan keluar dari akun ini. Apakah Anda yakin?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Panggil endpoint logout + hapus token
              try {
                await ApiService.instance.post('/auth/logout');
              } catch (_) {}
              await StorageService.clearAll();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold, color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field helpers ────────────────────────────────────────

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _FieldLabel(label),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: enabled ? AppColors.white : AppColors.inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.divider,
              width: enabled ? 1.5 : 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: InputBorder.none,
              prefixIcon:
                  Icon(icon, color: AppColors.primary, size: 20),
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _FieldLabel(label),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.lock_rounded,
                  color: AppColors.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textLight,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
