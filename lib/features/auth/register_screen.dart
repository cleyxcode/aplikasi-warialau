import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  int _passStrength = 0;

  late AnimationController _formCtrl;

  @override
  void initState() {
    super.initState();

    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _passCtrl.addListener(() {
      final p = _passCtrl.text;
      int s = 0;
      if (p.length >= 8) s++;
      if (p.contains(RegExp(r'[A-Z]'))) s++;
      if (p.contains(RegExp(r'[0-9!@#\$%^&*]'))) s++;
      setState(() => _passStrength = s);
    });
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await ApiService.instance.post(
        '/auth/register',
        data: {
          'name': _namaCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passCtrl.text,
          'password_confirmation': _confirmCtrl.text,
          'no_hp': _phoneCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      await StorageService.saveToken(response.data['token'] as String);
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/home');
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final data = e.response?.data;
      String msg = 'Registrasi gagal. Periksa koneksi Anda.';
      if (data != null) {
        if (data['errors'] != null) {
          final errors = Map<String, dynamic>.from(data['errors']);
          msg = (errors.values.first as List).first as String;
        } else if (data['message'] != null) {
          msg = data['message'] as String;
        }
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.white,
            ),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Color get _strengthColor => [
    AppColors.divider,
    AppColors.danger,
    AppColors.warning,
    AppColors.success,
  ][_passStrength];

  String get _strengthLabel => ['', 'Lemah', 'Sedang', 'Kuat'][_passStrength];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Header dengan Lottie ──
          Expanded(
            flex: 46,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              'Masuk',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lottie animation
                  Expanded(
                    child: Lottie.asset(
                      'lib/animations/register.json',
                      fit: BoxFit.contain,
                      animate: true,
                      repeat: true,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_add_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Title chip
                  Text(
                    'Buat Akun Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'SD NEGERI WARIALAU',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Form card ──
          Expanded(
            flex: 54,
            child: AnimatedBuilder(
              animation: _formCtrl,
              builder: (_, child) => FadeTransition(
                opacity: _formCtrl,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _formCtrl,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: child,
                ),
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Isi data diri Anda untuk membuat akun',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nama
                        _label('Nama Lengkap'),
                        const SizedBox(height: 8),
                        _field(
                          ctrl: _namaCtrl,
                          hint: 'Masukkan nama lengkap',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Nama tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _label('Alamat Email'),
                        const SizedBox(height: 8),
                        _field(
                          ctrl: _emailCtrl,
                          hint: 'contoh@email.com',
                          icon: Icons.mail_outline_rounded,
                          type: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!v.contains('@')) return 'Email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Telepon
                        _label('Nomor HP'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: _ts(),
                          decoration: InputDecoration(
                            hintText: '812xxxx',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 14),
                                Text(
                                  '+62',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: AppColors.divider,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            filled: true,
                            fillColor: AppColors.inputBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.danger,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.danger,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Nomor HP tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Kata Sandi
                        _label('Kata Sandi'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          style: _ts(),
                          decoration: _dec(
                            hint: 'Min. 8 karakter',
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textLight,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 8) {
                              return 'Kata sandi min. 8 karakter';
                            }
                            return null;
                          },
                        ),

                        // Password strength
                        if (_passCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(3, (i) {
                              return Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                                  height: 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: i < _passStrength
                                        ? _strengthColor
                                        : AppColors.divider,
                                  ),
                                ),
                              );
                            }),
                          ),
                          if (_strengthLabel.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _strengthLabel,
                                key: ValueKey(_strengthLabel),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _strengthColor,
                                ),
                              ),
                            ),
                          ],
                        ],

                        const SizedBox(height: 16),

                        // Konfirmasi
                        _label('Konfirmasi Kata Sandi'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _obscureConfirm,
                          style: _ts(),
                          decoration: _dec(
                            hint: 'Ulangi kata sandi',
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textLight,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                          validator: (v) => v != _passCtrl.text
                              ? 'Kata sandi tidak cocok'
                              : null,
                        ),

                        const SizedBox(height: 28),

                        // Daftar button
                        _PressableBtn(
                          onTap: _isLoading ? null : _submit,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gold, Color(0xFFE8C53A)],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Daftar Sekarang',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                children: const [
                                  TextSpan(text: 'Sudah punya akun? '),
                                  TextSpan(
                                    text: 'Masuk',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Text(
                            '© 2024 SD Negeri Warialau • Portal PPDB',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: AppColors.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _ts() =>
      GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary);

  Widget _label(String t) => Text(
    t,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: _ts(),
      decoration: _dec(hint: hint, icon: icon),
      validator: validator,
    );
  }

  InputDecoration _dec({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.textLight,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffix,
    );
  }
}

class _PressableBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressableBtn({required this.child, this.onTap});

  @override
  State<_PressableBtn> createState() => _PressableBtnState();
}

class _PressableBtnState extends State<_PressableBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _s = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) _c.forward();
      },
      onTapUp: (_) {
        _c.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(scale: _s, child: widget.child),
    );
  }
}
