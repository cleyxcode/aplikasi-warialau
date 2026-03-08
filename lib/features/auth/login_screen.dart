import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  bool _showRocket = false;

  late AnimationController _decoreCtrl;
  late Animation<double> _decoreY;

  late AnimationController _formCtrl;
  late Animation<double> _field1Fade;
  late Animation<Offset> _field1Slide;
  late Animation<double> _field2Fade;
  late Animation<Offset> _field2Slide;
  late Animation<double> _btnFade;
  late Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();

    _decoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _decoreY = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _decoreCtrl, curve: Curves.easeInOut));

    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _field1Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _field1Slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _formCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    _field2Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formCtrl,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    _field2Slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _formCtrl,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
          ),
        );

    _btnFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formCtrl,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );
    _btnSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _formCtrl,
            curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
          ),
        );

    _formCtrl.forward();
  }

  @override
  void dispose() {
    _decoreCtrl.dispose();
    _formCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.instance.post(
        '/auth/login',
        data: {'email': _emailCtrl.text.trim(), 'password': _passCtrl.text},
      );
      if (!mounted) return;
      await StorageService.saveToken(response.data['token'] as String);
      setState(() {
        _isLoading = false;
        _showRocket = true;
      });
      await Future.delayed(const Duration(milliseconds: 2800));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg =
          e.response?.data['message'] as String? ??
          'Login gagal. Periksa koneksi Anda.';
      ScaffoldMessenger.of(context).showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    if (_showRocket) {
      return Scaffold(
        backgroundColor: const Color(0xFF0C1E36),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'lib/animations/rocket.json',
                width: 260,
                height: 260,
                repeat: false,
              ),
              const SizedBox(height: 20),
              Text(
                'Login Berhasil!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selamat datang di SD Negeri Warialau',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Header (48%) ──
          Expanded(
            flex: 52,
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center: Lottie icon + title
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'lib/animations/login.json',
                        width: 270,
                        height: 270,
                        fit: BoxFit.contain,
                        animate: true,
                        repeat: true,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school_rounded,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'SD Negeri Warialau',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
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
                          'MASUK KE AKUN ANDA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Form card (48%) ──
          Expanded(
            flex: 48,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 40,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masuk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Silakan masuk untuk melanjutkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email field
                      SlideTransition(
                        position: _field1Slide,
                        child: FadeTransition(
                          opacity: _field1Fade,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Alamat Email'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: _fieldTextStyle(),
                                decoration: _inputDec(
                                  hint: 'contoh@email.com',
                                  icon: Icons.mail_outline_rounded,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  if (!v.contains('@'))
                                    return 'Email tidak valid';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Password field
                      SlideTransition(
                        position: _field2Slide,
                        child: FadeTransition(
                          opacity: _field2Fade,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Kata Sandi'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                style: _fieldTextStyle(),
                                decoration: _inputDec(
                                  hint: 'Masukkan kata sandi',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textLight,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Kata sandi tidak boleh kosong'
                                    : null,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/forgot-password',
                                  ),
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                  ),
                                  child: Text(
                                    'Lupa kata sandi?',
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
                      ),

                      const SizedBox(height: 20),

                      // Button + footer
                      SlideTransition(
                        position: _btnSlide,
                        child: FadeTransition(
                          opacity: _btnFade,
                          child: Column(
                            children: [
                              _PressableButton(
                                onTap: _isLoading ? null : _handleLogin,
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1F3B61),
                                        Color(0xFF2D5A9B),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.35,
                                        ),
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
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'Masuk',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(color: AppColors.divider),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      'atau',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(color: AppColors.divider),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/register'),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Belum punya akun? '),
                                      TextSpan(
                                        text: 'Daftar Sekarang',
                                        style: TextStyle(
                                          color: AppColors.gold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Khusus Orang Tua / Wali Murid',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
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

  TextStyle _fieldTextStyle() =>
      GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary);

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );

  InputDecoration _inputDec({
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

// ── Pressable button (scale on tap) ──
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressableButton({required this.child, this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) _ctrl.forward();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
