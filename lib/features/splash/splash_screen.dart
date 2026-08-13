import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_deep_link.dart';
import '../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showWelcome = false;

  late AnimationController _introController;
  late AnimationController _ambientController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _exitController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _logoGlow;
  late Animation<double> _ringReveal;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _chipFade;
  late Animation<double> _chipScale;
  late Animation<double> _bottomFade;
  late Animation<Offset> _bottomSlide;
  late Animation<double> _progress;
  late Animation<double> _exitFade;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.35, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.55),
      ),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
      ),
    );

    _logoGlow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );

    _ringReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.2, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.42, 0.72, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.42, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    _chipFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.55, 0.82, curve: Curves.easeOut),
      ),
    );

    _chipScale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.55, 0.82, curve: Curves.easeOutBack),
      ),
    );

    _bottomFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _progress = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _exitScale = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _introController.forward().then((_) {
      if (!mounted) return;
      _pulseController.repeat();
      _progressController.forward();
    });

    _progressController.addStatusListener((s) {
      if (s == AnimationStatus.completed) _finishSplash();
    });
  }

  Future<void> _finishSplash() async {
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    try {
      final loggedIn = await StorageService.isLoggedIn();
      if (!mounted) return;

      if (loggedIn) {
        setState(() => _showWelcome = true);
        await Future.delayed(const Duration(milliseconds: 1600));
        if (!mounted) return;
        await _exitController.forward();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        await _exitController.forward();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
      NotificationDeepLink.instance.markReady();
    } catch (e) {
      debugPrint('[Splash] Navigation error: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
      NotificationDeepLink.instance.markReady();
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _ambientController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcome) {
      return FadeTransition(
        opacity: _exitFade,
        child: ScaleTransition(
          scale: _exitScale,
          child: Scaffold(
            backgroundColor: const Color(0xFF0C1E36),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'lib/animations/rocket.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selamat Datang Kembali',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menyiapkan beranda Anda…',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _exitFade,
      child: ScaleTransition(
        scale: _exitScale,
        child: Scaffold(
          backgroundColor: const Color(0xFF0C1E36),
          body: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1F3B61),
                      Color(0xFF132744),
                      Color(0xFF0A1628),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _ambientController,
                builder: (_, __) => CustomPaint(
                  painter: _AmbientPainter(t: _ambientController.value),
                ),
              ),
              Positioned(
                top: -80,
                right: -60,
                child: AnimatedBuilder(
                  animation: _ambientController,
                  builder: (_, __) {
                    final bob = math.sin(_ambientController.value * math.pi * 2) * 10;
                    return Transform.translate(
                      offset: Offset(0, bob),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0.14),
                              AppColors.gold.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: -100,
                left: -70,
                child: AnimatedBuilder(
                  animation: _ambientController,
                  builder: (_, __) {
                    final bob =
                        math.cos(_ambientController.value * math.pi * 2) * 12;
                    return Transform.translate(
                      offset: Offset(0, bob),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF2D5A9B).withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    _buildLogoBlock(),
                    const SizedBox(height: 32),
                    _buildTitleBlock(),
                    const Spacer(flex: 4),
                    _buildProgressBlock(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoBlock() {
    return AnimatedBuilder(
      animation: Listenable.merge([_introController, _pulseController]),
      builder: (_, __) {
        final pulse = _pulseController.isAnimating ? _pulseController.value : 0.0;
        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: _ringReveal.value,
                child: CustomPaint(
                  size: const Size(240, 240),
                  painter: _OrbitPainter(
                    progress: pulse,
                    reveal: _ringReveal.value,
                  ),
                ),
              ),
              _softRing(0.0, 0.75, 210, pulse),
              _softRing(0.28, 0.95, 175, pulse),
              Transform.scale(
                scale: _logoScale.value,
                child: Opacity(
                  opacity: _logoFade.value,
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: AppColors.gold
                              .withValues(alpha: 0.35 * _logoGlow.value),
                          blurRadius: 36 + (12 * _logoGlow.value),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Lottie.asset(
                          'lib/animations/iconSplash.json',
                          fit: BoxFit.contain,
                          animate: true,
                          repeat: true,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.school_rounded,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _softRing(double start, double end, double size, double pulse) {
    final local = ((pulse - start) / (end - start)).clamp(0.0, 1.0);
    final scale = 0.72 + 0.45 * local;
    final opacity = (0.38 * (1 - local) * _ringReveal.value).clamp(0.0, 1.0);
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      children: [
        SlideTransition(
          position: _textSlide,
          child: FadeTransition(
            opacity: _textFade,
            child: Text(
              'SD Negeri Warialau',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.4,
                height: 1.15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeTransition(
          opacity: _chipFade,
          child: ScaleTransition(
            scale: _chipScale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.32),
                ),
              ),
              child: Text(
                'Kab. Kepulauan Aru · Maluku',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBlock() {
    return SlideTransition(
      position: _bottomSlide,
      child: FadeTransition(
        opacity: _bottomFade,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AnimatedBuilder(
            animation: _progress,
            builder: (_, __) {
              final pct = (_progress.value * 100).round();
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menyiapkan aplikasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.45),
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final barWidth =
                          constraints.maxWidth * _progress.value;
                      return SizedBox(
                        height: 5,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            if (barWidth > 0)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 60),
                                height: 5,
                                width: barWidth,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFC9933A),
                                      AppColors.gold,
                                      Color(0xFFF5D060),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold
                                          .withValues(alpha: 0.55),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            if (barWidth > 8)
                              Positioned(
                                left: barWidth - 8,
                                top: -3,
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF5D060),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.8),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  final double reveal;

  _OrbitPainter({required this.progress, required this.reveal});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.06 * reveal)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, track);

    final angle = progress * math.pi * 2;
    final dot = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    final glow = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.55 * reveal)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(dot, 4.5, glow);

    final core = Paint()..color = AppColors.gold.withValues(alpha: 0.95 * reveal);
    canvas.drawCircle(dot, 3.2, core);

    final trailAngle = angle - 0.55;
    final trail = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        trailAngle,
        0.55,
      );
    final trailPaint = Paint()
      ..shader = SweepGradient(
        startAngle: trailAngle,
        endAngle: angle,
        colors: [
          AppColors.gold.withValues(alpha: 0),
          AppColors.gold.withValues(alpha: 0.35 * reveal),
        ],
        transform: GradientRotation(trailAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(trail, trailPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.reveal != reveal;
}

class _AmbientPainter extends CustomPainter {
  final double t;

  _AmbientPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final dots = <(double, double, double)>[
      (0.12, 0.18, 2.2),
      (0.82, 0.22, 1.8),
      (0.74, 0.62, 2.5),
      (0.18, 0.72, 1.6),
      (0.48, 0.12, 1.4),
      (0.90, 0.78, 2.0),
      (0.08, 0.48, 1.5),
    ];

    for (var i = 0; i < dots.length; i++) {
      final (nx, ny, r) = dots[i];
      final wobble = math.sin((t + i * 0.13) * math.pi * 2) * 6;
      final opacity = 0.08 + 0.06 * (0.5 + 0.5 * math.sin((t + i) * math.pi * 2));
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(nx * size.width, ny * size.height + wobble),
        r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) =>
      oldDelegate.t != t;
}
