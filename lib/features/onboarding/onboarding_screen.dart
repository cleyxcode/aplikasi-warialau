import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import '../../core/constants/app_colors.dart';

// ── Palette (matches splash screen) ──
class _OB {
  static const bg1 = Color(0xFF0C1E36); // deep navy
  static const bg2 = Color(0xFF1F3B61); // mid navy
  static const bg3 = Color(0xFF112644); // dark blue
  static const accent = Color(0xFFD4AF37); // gold (from AppColors.gold)
  static const cardBg = Color(0xFF1A3255); // card surface
  static const glowBlue = Color(0xFF2E6FD8);
  static const white = Colors.white;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late LiquidController _liquidController;
  int _currentPage = 0;

  late AnimationController _textController;
  late AnimationController _glowController;

  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _glowPulse;

  final List<_OnboardData> _pages = [
    _OnboardData(
      lottiePath: 'lib/animations/onboarding1.json',
      titleBefore: 'Selamat Datang di\n',
      titleGold: 'SD Negeri Warialau',
      titleAfter: '',
      subtitle:
          'Sistem informasi sekolah yang modern,\ncepat, dan mudah digunakan.',
      bgTop: const Color(0xFF1F3B61),
      bgBottom: const Color(0xFF0C1E36),
      glowColor: const Color(0xFF2E6FD8),
      chipLabel: 'Mulai Perjalanan',
      chipIcon: Icons.rocket_launch_rounded,
    ),
    _OnboardData(
      lottiePath: 'lib/animations/onboarding2.json',
      titleBefore: 'Informasi ',
      titleGold: 'Terkini',
      titleAfter: '\nSekolah',
      subtitle:
          'Akses berita, pengumuman, dan\ngaleri kegiatan sekolah kapan saja.',
      bgTop: const Color(0xFF0D2B4E),
      bgBottom: const Color(0xFF071525),
      glowColor: const Color(0xFF1A5FAD),
      chipLabel: 'Selalu Update',
      chipIcon: Icons.notifications_active_rounded,
    ),
    _OnboardData(
      lottiePath: 'lib/animations/onboarding3.json',
      titleBefore: 'Daftar ',
      titleGold: 'Putra-Putri',
      titleAfter: '\nAnda',
      subtitle:
          'Isi formulir pendaftaran siswa baru\nsecara online dengan mudah dan cepat.',
      bgTop: const Color(0xFF163352),
      bgBottom: const Color(0xFF091D33),
      glowColor: const Color(0xFF0E4A8A),
      chipLabel: 'Mudah & Cepat',
      chipIcon: Icons.how_to_reg_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _liquidController = LiquidController();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _textFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textController.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _textController.forward(from: 0);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _liquidController.animateToPage(page: _currentPage + 1);
    }
  }

  void _skip() => Navigator.pushReplacementNamed(context, '/login');
  void _start() => Navigator.pushReplacementNamed(context, '/login');

  @override
  void dispose() {
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Liquid Swipe ──
          LiquidSwipe(
            pages: List.generate(
              _pages.length,
              (index) => _buildPage(index, size),
            ),
            liquidController: _liquidController,
            onPageChangeCallback: _onPageChanged,
            waveType: WaveType.liquidReveal,
            enableLoop: false,
            ignoreUserGestureWhileAnimating: true,
            slideIconWidget: null,
          ),

          // ── Top bar overlay ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: GestureDetector(
                      onTap: () => _liquidController.animateToPage(
                        page: _currentPage - 1,
                      ),
                      child: _GlassChip(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Kembali',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage == 0) const SizedBox(width: 80),

                  // Skip button
                  GestureDetector(
                    onTap: _skip,
                    child: _GlassChip(
                      child: Text(
                        'Lewati',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index, Size size) {
    final p = _pages[index];
    final isActive = _currentPage == index;
    final isLast = index == _pages.length - 1;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.bgTop, p.bgBottom],
        ),
      ),
      child: Stack(
        children: [
          // ── Background diagonal stripes ──
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _DiagonalPainter(),
          ),

          // ── Top-right glow blob ──
          Positioned(
            top: -60,
            right: -60,
            child: AnimatedBuilder(
              animation: _glowPulse,
              builder: (_, __) => Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.glowColor.withValues(alpha: 0.12 * _glowPulse.value),
                ),
              ),
            ),
          ),

          // ── Bottom-left glow blob ──
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 68),

                // ── Lottie illustration area ──
                Expanded(
                  flex: 52,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        AnimatedBuilder(
                          animation: _glowPulse,
                          builder: (_, __) => Container(
                            width: size.width * 0.75,
                            height: size.width * 0.75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: p.glowColor.withValues(
                                  alpha: 0.25 * _glowPulse.value,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        // Inner glow ring
                        AnimatedBuilder(
                          animation: _glowPulse,
                          builder: (_, __) => Container(
                            width: size.width * 0.62,
                            height: size.width * 0.62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.glowColor.withValues(
                                alpha: 0.08 * _glowPulse.value,
                              ),
                              border: Border.all(
                                color: p.glowColor.withValues(
                                  alpha: 0.18 * _glowPulse.value,
                                ),
                                width: 1,
                              ),
                            ),
                          ),
                        ),

                        // Card backdrop
                        Container(
                          width: size.width * 0.72,
                          height: size.width * 0.72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _OB.cardBg.withValues(alpha: 0.6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: p.glowColor.withValues(alpha: 0.2),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        // Lottie
                        SizedBox(
                          width: size.width * 0.65,
                          height: size.width * 0.65,
                          child: Lottie.asset(
                            p.lottiePath,
                            fit: BoxFit.contain,
                            animate: isActive,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.school_rounded,
                              size: 100,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),

                        // Star dots
                        ..._starDots(size, p.glowColor),
                      ],
                    ),
                  ),
                ),

                // ── Text + Controls ──
                Expanded(
                  flex: 48,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Feature chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: p.glowColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: p.glowColor.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(p.chipIcon, size: 12, color: _OB.accent),
                              const SizedBox(width: 6),
                              Text(
                                p.chipLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _OB.accent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Title + subtitle
                        isActive
                            ? SlideTransition(
                                position: _textSlide,
                                child: FadeTransition(
                                  opacity: _textFade,
                                  child: _buildTextContent(p),
                                ),
                              )
                            : _buildTextContent(p),

                        const Spacer(),

                        // ── Dots + Button row ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Dot indicators
                            Row(
                              children: List.generate(_pages.length, (i) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.only(right: 6),
                                  width: _currentPage == i ? 24 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: _currentPage == i
                                        ? _OB.accent
                                        : Colors.white.withValues(alpha: 0.2),
                                  ),
                                );
                              }),
                            ),

                            // Button
                            if (!isLast)
                              _AnimatedButton(
                                onTap: _nextPage,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _OB.accent,
                                        const Color(0xFFE8C53A),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _OB.accent.withValues(
                                          alpha: 0.45,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF0C1E36),
                                    size: 24,
                                  ),
                                ),
                              )
                            else
                              _AnimatedButton(
                                onTap: _start,
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [_OB.accent, Color(0xFFE8C53A)],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _OB.accent.withValues(
                                          alpha: 0.45,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Daftar Sekarang',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0C1E36),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: Color(0xFF0C1E36),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(_OnboardData p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
            children: [
              TextSpan(text: p.titleBefore),
              TextSpan(
                text: p.titleGold,
                style: TextStyle(
                  color: _OB.accent,
                  shadows: [
                    Shadow(
                      color: _OB.accent.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              TextSpan(text: p.titleAfter),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          p.subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: Colors.white.withValues(alpha: 0.6),
            height: 1.65,
          ),
        ),
      ],
    );
  }

  List<Widget> _starDots(Size size, Color glowColor) {
    final positions = [
      {'top': 20.0, 'left': 20.0, 'size': 5.0},
      {'top': 45.0, 'right': 18.0, 'size': 4.0},
      {'bottom': 30.0, 'left': 30.0, 'size': 6.0},
      {'bottom': 55.0, 'right': 30.0, 'size': 4.0},
      {'top': 80.0, 'left': 55.0, 'size': 3.0},
    ];

    return positions.map((pos) {
      return Positioned(
        top: pos['top'],
        left: pos['left'],
        right: pos['right'],
        bottom: pos['bottom'],
        child: AnimatedBuilder(
          animation: _glowPulse,
          builder: (_, __) => Container(
            width: pos['size'],
            height: pos['size'],
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.4 * _glowPulse.value),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.6 * _glowPulse.value),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ── Glass chip ──
class _GlassChip extends StatelessWidget {
  final Widget child;
  const _GlassChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12),
        ],
      ),
      child: child,
    );
  }
}

// ── Diagonal painter ──
class _DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1.0;
    const gap = 24.0;
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

// ── Bounce-press button ──
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimatedButton({required this.child, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.92,
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class _OnboardData {
  final String lottiePath;
  final String titleBefore;
  final String titleGold;
  final String titleAfter;
  final String subtitle;
  final Color bgTop;
  final Color bgBottom;
  final Color glowColor;
  final String chipLabel;
  final IconData chipIcon;

  const _OnboardData({
    required this.lottiePath,
    required this.titleBefore,
    required this.titleGold,
    required this.titleAfter,
    required this.subtitle,
    required this.bgTop,
    required this.bgBottom,
    required this.glowColor,
    required this.chipLabel,
    required this.chipIcon,
  });
}
