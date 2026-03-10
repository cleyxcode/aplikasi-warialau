import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../features/auth/reset_password_screen.dart'; // Just in case, though names are used

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  static const int _len = 6;
  static const int _maxSeconds = 150;

  final List<TextEditingController> _ctrls = List.generate(
    _len,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(_len, (_) => FocusNode());

  // Staggered box entrance
  late AnimationController _boxCtrl;
  late List<Animation<double>> _boxFades;
  late List<Animation<Offset>> _boxSlides;

  // Header slide in
  late AnimationController _headerCtrl;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerFade;

  // Shake on wrong OTP
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeX;

  // Floating decor
  late AnimationController _floatCtrl;
  late Animation<double> _floatY;

  Timer? _timer;
  int _secsLeft = _maxSeconds;
  bool _canResend = false;
  bool _isLoading = false;
  String _email = '';

  @override
  void initState() {
    super.initState();

    // Header
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerFade = Tween<double>(begin: 0, end: 1).animate(_headerCtrl);
    _headerCtrl.forward();

    // Staggered OTP boxes (each box delayed by 60ms)
    _boxCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _boxFades = List.generate(_len, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _boxCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _boxSlides = List.generate(_len, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _boxCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 200), () => _boxCtrl.forward());

    // Shake
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOut));

    // Floating decor
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _floatY = Tween<double>(
      begin: -7,
      end: 7,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) setState(() => _email = args);
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secsLeft = _maxSeconds;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secsLeft <= 0) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secsLeft--);
      }
    });
  }

  String get _timerText {
    final m = _secsLeft ~/ 60;
    final s = _secsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _maskedEmail {
    if (_email.isEmpty) return 'cont***@email.com';
    final parts = _email.split('@');
    if (parts.length < 2) return _email;
    final n = parts[0];
    final masked = n.length > 3 ? '${n.substring(0, 3)}***' : '${n[0]}***';
    return '$masked@${parts[1]}';
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  void _onChanged(int i, String v) {
    if (v.length == 1 && i < _len - 1) _nodes[i + 1].requestFocus();
    if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
    setState(() {});
  }

  Future<void> _verify() async {
    if (_otp.length < _len) {
      _shakeCtrl.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masukkan 6 digit kode OTP',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final response = await ApiService.instance.post(
        '/auth/verify-otp',
        data: {'email': _email, 'otp': _otp},
      );
      final resetEmail = response.data['reset_email'] as String? ?? _email;
      if (!mounted) return;
      setState(() => _isLoading = false);

      _showResultDialog(true);
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      Navigator.pushReplacementNamed(
        context,
        '/reset-password',
        arguments: resetEmail,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _shakeCtrl.forward(from: 0);
      final msg = e.response?.data['message'] ?? 'Kode OTP tidak valid.';
      _showResultDialog(false, msg);
    }
  }

  void _showResultDialog(bool success, [String? message]) {
    showDialog(
      context: context,
      barrierDismissible: !success,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                success
                    ? 'lib/animations/success.json'
                    : 'lib/animations/Fail.json',
                width: 150,
                height: 150,
                repeat: false,
              ),
              const SizedBox(height: 16),
              Text(
                success ? 'Verifikasi Berhasil' : 'Verifikasi Gagal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: success ? AppColors.success : AppColors.danger,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (!success) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resend() async {
    if (_email.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ApiService.instance.post(
        '/auth/forgot-password',
        data: {'email': _email},
      );
      _startTimer();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Kode OTP baru telah dikirim.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Gagal mengirim ulang OTP.';
      messenger.showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.plusJakartaSans()),
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
  void dispose() {
    _timer?.cancel();
    _headerCtrl.dispose();
    _boxCtrl.dispose();
    _shakeCtrl.dispose();
    _floatCtrl.dispose();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Header (36%) ──
          Expanded(
            flex: 36,
            child: SafeArea(
              bottom: false,
              child: SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: Stack(
                    children: [
                      // Floating decor
                      AnimatedBuilder(
                        animation: _floatY,
                        builder: (_, __) => Positioned(
                          top: _floatY.value,
                          right: -20,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _floatY,
                        builder: (_, __) => Positioned(
                          bottom: 0,
                          left: -15,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            // Top bar
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'SD Negeri Warialau',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),

                            // Center icon + title
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                        BoxShadow(
                                          color: AppColors.gold.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 30,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.verified_user_rounded,
                                      color: AppColors.primary,
                                      size: 34,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Verifikasi OTP',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.gold.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      _maskedEmail,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body (64%) ──
          Expanded(
            flex: 64,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    Text(
                      'Masukkan Kode OTP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kode 6 digit telah dikirim ke email Anda untuk memvalidasi identitas akses Anda.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // ── OTP Boxes (staggered) ──
                    AnimatedBuilder(
                      animation: _shakeX,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(_shakeX.value, 0),
                        child: child,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_len, (i) {
                          final filled = _ctrls[i].text.isNotEmpty;
                          return FadeTransition(
                            opacity: _boxFades[i],
                            child: SlideTransition(
                              position: _boxSlides[i],
                              child: Container(
                                width: 46,
                                height: 54,
                                margin: EdgeInsets.only(
                                  right: i < _len - 1 ? 8 : 0,
                                ),
                                child: TextFormField(
                                  controller: _ctrls[i],
                                  focusNode: _nodes[i],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                  onChanged: (v) => _onChanged(i, v),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: filled
                                        ? AppColors.gold.withValues(alpha: 0.1)
                                        : AppColors.inputBg,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: filled
                                            ? AppColors.gold
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: filled
                                            ? AppColors.gold
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.gold,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Timer
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: !_canResend
                          ? Row(
                              key: const ValueKey('timer'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: AppColors.gold,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Kode berlaku selama $_timerText',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(key: ValueKey('no-timer')),
                    ),

                    const SizedBox(height: 12),

                    // Resend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum menerima kode? ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: _canResend ? _resend : null,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _canResend
                                  ? AppColors.gold
                                  : AppColors.textLight,
                            ),
                            child: const Text('Kirim Ulang'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Verify button
                    _PressBtn(
                      onTap: _isLoading ? null : _verify,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1F3B61), Color(0xFF2D5A9B)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
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
                                  'Verifikasi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Periksa folder spam atau promosi jika Anda tidak menemukan email di kotak masuk utama.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textLight,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PressBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressBtn({required this.child, this.onTap});

  @override
  State<_PressBtn> createState() => _PressBtnState();
}

class _PressBtnState extends State<_PressBtn>
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
