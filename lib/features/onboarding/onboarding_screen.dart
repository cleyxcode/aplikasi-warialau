import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _blobController;
  late AnimationController _textController;
  late AnimationController _floatController;

  late Animation<double> _blobScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _floatY;

  final List<_OnboardData> _pages = [
    _OnboardData(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDWCNTZdDqWGWDKMnzbRrnz1LYzQ_6JaD-xgtH1qF0HIfhDuTPLskXVQIPQuzfZDmlkgRkt8Q3ODhjIhhvzKyYLnjNzwSRxWmDM8UeEWJRQ3o7vP0zoIo-cvNMzvjDpd0WIuRCqt2b9wmQJebNqmL2O_-25ro_zrQQpFx_Ng68B6-IG6yfHZoyB1La0ecjSCJmjXxQs6VF21efbNYzhIVNmjSF26kvUNhwaUYoXu-l9jyYiyCHemNivYMtj8vpGg5TSC1qrdBq-vDnj',
      titleBefore: 'Selamat Datang di\n',
      titleGold: 'SD Negeri Warialau',
      titleAfter: '',
      subtitle: 'Sistem informasi sekolah yang modern dan mudah digunakan.',
      blobColor: Color(0xFFF5E6B3),
    ),
    _OnboardData(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAKcYlInvXwXbK6qVfb6bueulQlp1PsYoxtMjFKgb812UXq85-i_YLdkG1kCkyoYwYvlTL95W0nY4ZkS_Al1oY5yyn8fkz0sWtjy2ZmpDvJ8LkW7_WqVynOvDgS1StG-fMgJfe8gexw8hbIHJ818UHQAM8TAojr9srtLsv6mL3CvVpGwJydOPMnr-P6S8Pa5EPS6ZZHgCL6GfRkTR1WwWNLwI3CwZ2LnjPCTHgKGb90JOZyZyAZBJGAgvN0z2N5FnaiGRErBU6X_2aJ',
      titleBefore: 'Informasi ',
      titleGold: 'Terkini',
      titleAfter: '\nSekolah',
      subtitle:
          'Akses berita, pengumuman, dan galeri kegiatan sekolah kapan saja.',
      blobColor: Color(0xFFD8EAF5),
    ),
    _OnboardData(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvZGbm19swgATyQG4i-esw5J9pQIumvpT37FHcEKD6O0b_sKK5Pt_dlNS66D3tQP2c-2HZY8_6XUwFoHbkQTjsHbAVIhblINldspyjM5-QIrdPQFrhAZkbTzkc1hhVPHJKHK2bU0mbGfeY8sLWyGPnQkZECbPDZVjNBk2SaxxJDh-70jthL2GPNa9YnO-P0G_WOdKS21FgSTiqzxY6nYHwMQxR1-CyQN3Y7qJ8rrTdx7wXTduUx99-8yU78Y2jdRsEChZ5YtjHMy3g',
      titleBefore: 'Daftar ',
      titleGold: 'Putra-Putri',
      titleAfter: '\nAnda',
      subtitle:
          'Isi formulir pendaftaran siswa baru secara online dengan mudah dan cepat.',
      blobColor: Color(0xFFEBF5E6),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Blob animate on page change
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _blobScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _blobController, curve: Curves.easeOutBack),
    );
    _blobController.value = 1.0;

    // Text stagger per page
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textController.value = 1.0;

    // Floating image animation (up-down)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatY = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _blobController.forward(from: 0);
    _textController.forward(from: 0);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() => Navigator.pushReplacementNamed(context, '/login');
  void _start() => Navigator.pushReplacementNamed(context, '/login');

  @override
  void dispose() {
    _pageController.dispose();
    _blobController.dispose();
    _textController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.chevron_left_rounded,
                            color: AppColors.primary),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  // Page title for slide 2+
                  AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      'SD Negeri Warialau',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _skip,
                    child: Text(
                      'Lewati',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Illustration area ──
            Expanded(
              flex: 55,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (_, index) {
                  final p = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Floating decoration dots
                        ..._floatingDots(size),

                        // Animated blob background
                        ScaleTransition(
                          scale: index == _currentPage
                              ? _blobScale
                              : const AlwaysStoppedAnimation(1.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: size.width * 0.72,
                            height: size.width * 0.72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.blobColor.withValues(alpha: 0.85),
                            ),
                          ),
                        ),

                        // Floating image
                        AnimatedBuilder(
                          animation: _floatY,
                          builder: (_, child) => Transform.translate(
                            offset: index == _currentPage
                                ? Offset(0, _floatY.value)
                                : Offset.zero,
                            child: child,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Image.network(
                              p.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.school_rounded,
                                size: 110,
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Text + controls ──
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated text block
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textFade,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                                children: [
                                  TextSpan(text: page.titleBefore),
                                  TextSpan(
                                    text: page.titleGold,
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  TextSpan(text: page.titleAfter),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.65,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Dot indicators + button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dots
                        Row(
                          children: List.generate(_pages.length, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(right: 6),
                              width: _currentPage == i ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: _currentPage == i
                                    ? AppColors.gold
                                    : AppColors.divider,
                              ),
                            );
                          }),
                        ),

                        // Next / Start button
                        if (_currentPage < _pages.length - 1)
                          _AnimatedButton(
                            onTap: _nextPage,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.gold.withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 26),
                            ),
                          )
                        else
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: _AnimatedButton(
                                onTap: _start,
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      AppColors.gold,
                                      Color(0xFFE8C53A),
                                    ]),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Mulai Sekarang',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _floatingDots(Size size) {
    return [
      Positioned(
        top: 16,
        left: 16,
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _floatY.value * 0.6),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: 60,
        right: 24,
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, -_floatY.value * 0.5),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 20,
        left: 40,
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _floatY.value * 0.4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

// ── Bounce-press button wrapper ──
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
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
  final String imageUrl;
  final String titleBefore;
  final String titleGold;
  final String titleAfter;
  final String subtitle;
  final Color blobColor;

  const _OnboardData({
    required this.imageUrl,
    required this.titleBefore,
    required this.titleGold,
    required this.titleAfter,
    required this.subtitle,
    required this.blobColor,
  });
}
