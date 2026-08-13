import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/fcm_service.dart';
import '../../core/services/notification_local_service.dart';
import '../../core/services/storage_service.dart';
import '../guru/guru_screen.dart';

class ProfilUserScreen extends StatefulWidget {
  const ProfilUserScreen({super.key});

  @override
  State<ProfilUserScreen> createState() => _ProfilUserScreenState();
}

class _ProfilUserScreenState extends State<ProfilUserScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _showPasswordSection = false;
  bool _isLoading = true;
  bool _hasError = false;

  UserModel? _user;

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _oldPassCtrl;
  late TextEditingController _newPassCtrl;
  late TextEditingController _confirmPassCtrl;

  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _oldPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
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
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
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
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = _user == null;
      });
    }
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (!_isEditing) {
      if (_user != null) {
        _nameCtrl.text = _user!.name;
        _emailCtrl.text = _user!.email;
        _phoneCtrl.text = _user!.noHp;
      }
      _showPasswordSection = false;
      _oldPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
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
      final updated =
          UserModel.fromJson(r.data['user'] as Map<String, dynamic>);

      if (_showPasswordSection && _newPassCtrl.text.isNotEmpty) {
        await ApiService.instance.patch('/profile/password', data: {
          'current_password': _oldPassCtrl.text,
          'password': _newPassCtrl.text,
          'password_confirmation': _confirmPassCtrl.text,
        });
      }

      if (!mounted) return;
      setState(() {
        _user = updated;
        _isSaving = false;
        _isEditing = false;
        _showPasswordSection = false;
        _oldPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
      });
      messenger.showSnackBar(
        _snackBar('Profil berhasil diperbarui', AppColors.success),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] as String?) ??
              'Gagal menyimpan profil'
          : 'Gagal menyimpan profil';
      messenger.showSnackBar(_snackBar(msg, AppColors.danger));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        _snackBar('Gagal menyimpan profil', AppColors.danger),
      );
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
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(title: 'Profil Saya', showEdit: false),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'lib/animations/loading _school.json',
                        width: 180,
                        height: 180,
                        repeat: true,
                      ),
                      const SizedBox(height: 12),
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
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(title: 'Profil Saya', showEdit: false),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 56,
                        color: AppColors.textLight.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat profil',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Periksa koneksi internet lalu coba lagi.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _fetchProfile,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          'Coba Lagi',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          controller: _scrollCtrl,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(child: _buildHeroHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  16,
                  0,
                  _isEditing
                      ? 16 + bottomInset
                      : 28 + safeBottom,
                ),
                child: Column(
                  children: [
                    _buildInfoSection(),
                    const SizedBox(height: 12),
                    _buildGuruMenu(),
                    const SizedBox(height: 12),
                    _buildPasswordSection(),
                    const SizedBox(height: 12),
                    _buildDangerZone(),
                    if (_isEditing) const SizedBox(height: 72),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isEditing ? _buildSaveBar() : null,
    );
  }

  Widget _buildTopBar({required String title, required bool showEdit}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
            bg: AppColors.primary.withValues(alpha: 0.08),
            iconColor: AppColors.primary,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (showEdit)
            _CircleIconButton(
              icon: _isEditing ? Icons.close_rounded : Icons.edit_rounded,
              onTap: _isSaving ? null : _toggleEdit,
              bg: _isEditing
                  ? AppColors.danger.withValues(alpha: 0.1)
                  : AppColors.gold.withValues(alpha: 0.15),
              iconColor: _isEditing ? AppColors.danger : AppColors.gold,
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  // ── Unified hero header (no double app bar) ───────────────
  Widget _buildHeroHeader() {
    final user = _user;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF254A7A)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -10,
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
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                        bg: Colors.white.withValues(alpha: 0.12),
                        iconColor: AppColors.white,
                      ),
                      Expanded(
                        child: Text(
                          'Profil Saya',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      _CircleIconButton(
                        icon: _isEditing
                            ? Icons.close_rounded
                            : Icons.edit_rounded,
                        onTap: _isSaving ? null : _toggleEdit,
                        bg: _isEditing
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.gold.withValues(alpha: 0.22),
                        iconColor:
                            _isEditing ? Colors.white70 : AppColors.gold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 88,
                    height: 88,
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
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      user?.name ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      user?.email ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildGuruMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GuruScreen()),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: AppColors.primary,
                    size: 20,
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
      ),
    );
  }

  Widget _buildPasswordSection() {
    return _SectionCard(
      title: 'Keamanan',
      icon: Icons.security_rounded,
      children: [
        if (!_showPasswordSection)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isEditing
                  ? () {
                      setState(() => _showPasswordSection = true);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (_scrollCtrl.hasClients) {
                          _scrollCtrl.animateTo(
                            _scrollCtrl.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                      color:
                          _isEditing ? AppColors.primary : AppColors.textLight,
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
            ),
          )
        else ...[
          _buildPasswordField(
            label: 'Kata Sandi Lama',
            controller: _oldPassCtrl,
            obscure: _obscureOld,
            onToggle: () => setState(() => _obscureOld = !_obscureOld),
            validator: (v) {
              if (_newPassCtrl.text.isNotEmpty &&
                  (v == null || v.isEmpty)) {
                return 'Masukkan kata sandi lama';
              }
              return null;
            },
          ),
          _buildPasswordField(
            label: 'Kata Sandi Baru',
            controller: _newPassCtrl,
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
            validator: (v) {
              if (v != null && v.isNotEmpty && v.length < 8) {
                return 'Minimal 8 karakter';
              }
              return null;
            },
          ),
          _buildPasswordField(
            label: 'Konfirmasi Kata Sandi Baru',
            controller: _confirmPassCtrl,
            obscure: _obscureConfirm,
            onToggle: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) {
              if (_newPassCtrl.text.isNotEmpty && v != _newPassCtrl.text) {
                return 'Kata sandi tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() {
              _showPasswordSection = false;
              _oldPassCtrl.clear();
              _newPassCtrl.clear();
              _confirmPassCtrl.clear();
            }),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Batal ganti kata sandi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDangerZone() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _showLogoutDialog,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
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
      ),
    );
  }

  Widget _buildSaveBar() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
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
            child: OutlinedButton(
              onPressed: _isSaving ? null : _toggleEdit,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 50),
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 50),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Simpan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.instance.post('/auth/logout');
              } catch (_) {}
              await FcmService.instance.unregisterToken();
              await NotificationLocalService.instance.resetOnLogout();
              await StorageService.clearAll();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
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
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              prefixIcon: const Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
                size: 20,
              ),
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color bg;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.all(18),
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
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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
