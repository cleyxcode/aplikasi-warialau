import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showRocket = false;

  late AnimationController _introController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _floatController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _progress;
  late Animation<double> _bottomFade;
  late Animation<Offset> _bottomSlide;
  late Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();

    // ── Intro: logo bounce → text slide → bottom fade ──
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.12), weight: 65),
          TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 35),
        ]).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.3),
      ),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 0.65),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
          ),
        );

    _bottomFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.65, 1.0),
      ),
    );

    _bottomSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
          ),
        );

    // ── Pulse rings (repeat) ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // ── Floating bob effect ──
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _floatOffset = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // ── Progress ──
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _progress = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    // ── Sequence ──
    _introController.forward().then((_) {
      _pulseController.repeat();
      _floatController.repeat(reverse: true);
      _progressController.forward();
    });

    _progressController.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 350), () async {
          if (!mounted) return;
          try {
            final loggedIn = await StorageService.isLoggedIn();
            if (!mounted) return;
            if (loggedIn) {
              setState(() => _showRocket = true);
              await Future.delayed(const Duration(milliseconds: 2800));
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              Navigator.pushReplacementNamed(context, '/onboarding');
            }
          } catch (e) {
            debugPrint('[Splash] Navigation error: $e');
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/onboarding');
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Widget _pulseRing(double startInterval, double endInterval, double size) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final t = _pulseController.value;
        double local = ((t - startInterval) / (endInterval - startInterval))
            .clamp(0.0, 1.0);
        final scale = 0.55 + 0.65 * local;
        final opacity = (0.45 * (1 - local)).clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
            ),
          ),
        );
      },
    );
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
                'Selamat Datang Kembali!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Memuat halaman utama...',
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
      backgroundColor: const Color(0xFF111F35),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F3B61), Color(0xFF0C1E36)],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // ── Diagonal stripe pattern ──
          CustomPaint(painter: _DiagonalPainter()),

          // ── Gold blob top-right ──
          Positioned(
            top: -70,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.07),
              ),
            ),
          ),

          // ── Blue blob bottom-left ──
          Positioned(
            bottom: -90,
            left: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),

          // ── Center content ──
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating logo with pulse rings
                AnimatedBuilder(
                  animation: _floatOffset,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _floatOffset.value),
                    child: child,
                  ),
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _pulseRing(0.0, 0.7, 250),
                        _pulseRing(0.25, 0.9, 210),
                        _pulseRing(0.5, 1.0, 170),

                        // Logo circle with Lottie animation
                        ScaleTransition(
                          scale: _logoScale,
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 32,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color:
                                        AppColors.gold.withValues(alpha: 0.25),
                                    blurRadius: 48,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Lottie.asset(
                                    'lib/animations/iconSplash.json',
                                    fit: BoxFit.contain,
                                    animate: true,
                                    repeat: true,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.school_rounded,
                                      size: 80,
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
                  ),
                ),

                const SizedBox(height: 28),

                // Text block
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          'SD Negeri Warialau',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            'Kab. Kepulauan Aru, Maluku',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                              letterSpacing: 0.3,
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

          // ── Bottom loading (single progress bar only) ──
          Positioned(
            bottom: 52,
            left: 36,
            right: 36,
            child: SlideTransition(
              position: _bottomSlide,
              child: FadeTransition(
                opacity: _bottomFade,
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) {
                    final pct = (_progress.value * 100).toInt();
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'MEMUAT...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.45),
                                letterSpacing: 2.5,
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Glowing progress bar
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final barWidth =
                                constraints.maxWidth * _progress.value;
                            return SizedBox(
                              height: 4,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                  ),
                                  if (barWidth > 0)
                                    Container(
                                      height: 4,
                                      width: barWidth,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.gold,
                                            Color(0xFFF5D060),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.gold
                                                .withValues(alpha: 0.7),
                                            blurRadius: 8,
                                          ),
                                        ],
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
          ),
        ],
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.2;
    const gap = 22.0;
    for (double x = -size.height; x < size.width + size.height; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DiagonalPainter o) => false;
}
