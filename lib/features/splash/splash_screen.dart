import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    // ── Intro: logo bounce → text slide ──
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.12), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 35),
    ]).animate(
      CurvedAnimation(
          parent: _introController,
          curve: const Interval(0.0, 0.75, curve: Curves.easeOut)),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _introController, curve: const Interval(0.0, 0.4)),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _introController, curve: const Interval(0.55, 1.0)),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    ));

    // ── Pulse rings (repeat) ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // ── Progress ──
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _progress = CurvedAnimation(
        parent: _progressController, curve: Curves.easeInOut);

    // ── Sequence ──
    _introController.forward().then((_) {
      _pulseController.repeat();
      _progressController.forward();
    });

    _progressController.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
        });
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
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
                border: Border.all(
                  color: AppColors.gold,
                  width: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // Pulse rings + logo
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _pulseRing(0.0, 0.7, 190),
                      _pulseRing(0.25, 0.9, 160),
                      _pulseRing(0.5, 1.0, 130),

                      // Logo circle
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoFade,
                          child: Container(
                            width: 116,
                            height: 116,
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
                                  color: AppColors.gold.withValues(alpha: 0.25),
                                  blurRadius: 48,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAszatERUl6AuXqbahV1RqucUb0ZE49etzQvQlrjSWuW17luulHa2a6IRSE3JgZ6qWHa-JebTyBxxZgQkUKMrx4pk7tTGuw2iNk79m2xshQB89BcXN_hmLLp_L0Wif17jltORwtyVkHFZw_EXl7WpTNR3pHbBGW-kPMyNewVWc6rN2mrliG1riFIhYBT5rN-_zjLP8_CxMAvWozrjMDWAMN1XelgTZ5N52svBDps8YbThuDteUEjnZ_9hBj-nkE_GN7r9OTUVouwc6p',
                                  fit: BoxFit.contain,
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
                              horizontal: 14, vertical: 5),
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

          // ── Bottom loading ──
          Positioned(
            bottom: 52,
            left: 36,
            right: 36,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (_, __) {
                final pct = (_progress.value * 100).toInt();
                return Column(
                  children: [
                    // Circular progress + percentage
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 3,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          CircularProgressIndicator(
                            value: _progress.value,
                            strokeWidth: 3,
                            strokeCap: StrokeCap.round,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.gold),
                          ),
                          Text(
                            '$pct%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
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
                          '$pct / 100',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Glowing progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 4,
                        color: Colors.white.withValues(alpha: 0.08),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progress.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                AppColors.gold,
                                Color(0xFFF5D060),
                              ]),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.7),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_DiagonalPainter o) => false;
}
