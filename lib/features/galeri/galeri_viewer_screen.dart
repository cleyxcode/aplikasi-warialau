import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import 'galeri_model.dart';

class GaleriViewerScreen extends StatefulWidget {
  final List<GaleriItem> items;
  final int initialIndex;

  const GaleriViewerScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<GaleriViewerScreen> createState() => _GaleriViewerScreenState();
}

class _GaleriViewerScreenState extends State<GaleriViewerScreen>
    with TickerProviderStateMixin {
  late PageController _pageCtrl;
  late int _currentIndex;

  // Info panel animation
  late AnimationController _panelCtrl;
  late Animation<Offset> _panelSlide;
  late Animation<double> _panelFade;

  // Top bar animation
  late AnimationController _topBarCtrl;
  late Animation<Offset> _topBarSlide;
  late Animation<double> _topBarFade;

  bool _showInfo = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Panel slide from bottom
    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutCubic));
    _panelFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOut));

    // Top bar from top
    _topBarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _topBarSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _topBarCtrl, curve: Curves.easeOutCubic));
    _topBarFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _topBarCtrl, curve: Curves.easeOut));

    _panelCtrl.forward();
    _topBarCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _panelCtrl.dispose();
    _topBarCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleInfo() {
    setState(() => _showInfo = !_showInfo);
    if (_showInfo) {
      _panelCtrl.forward();
      _topBarCtrl.forward();
    } else {
      _panelCtrl.reverse();
      _topBarCtrl.reverse();
    }
  }

  void _close() {
    _panelCtrl.reverse();
    _topBarCtrl.reverse().then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  GaleriItem get _current => widget.items[_currentIndex];

  static const _categoryColors = {
    'Seni Budaya': Color(0xFFEC4899),
    'Akademik': Color(0xFF3B82F6),
    'Olahraga': Color(0xFF22C55E),
    'Pramuka': Color(0xFFF59E0B),
    'Lainnya': Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColors[_current.category] ?? AppColors.gold;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Image PageView ───────────────────────────────
          GestureDetector(
            onTap: _toggleInfo,
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: widget.items.length,
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
                // Re-animate info panel for new item
                _panelCtrl
                  ..reset()
                  ..forward();
              },
              itemBuilder: (_, i) {
                final item = widget.items[i];
                return Hero(
                  tag: 'galeri-${item.id}',
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                        size: 64,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Top Bar ──────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _topBarSlide,
              child: FadeTransition(
                opacity: _topBarFade,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                      child: Row(
                        children: [
                          // Close button
                          _ViewerIconBtn(
                            icon: Icons.close_rounded,
                            onTap: _close,
                          ),
                          const Spacer(),
                          // Counter
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_currentIndex + 1} / ${widget.items.length}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Share button
                          _ViewerIconBtn(
                            icon: Icons.share_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Dot Indicators (middle bottom-ish) ───────────
          if (widget.items.length > 1)
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _panelFade,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.items.length > 8 ? 0 : widget.items.length,
                    (i) {
                      final active = i == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.gold
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // ── Bottom Info Panel ────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _panelSlide,
              child: FadeTransition(
                opacity: _panelFade,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.95),
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Category pill
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              key: ValueKey(_current.category),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _current.category.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Title
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _current.title,
                              key: ValueKey(_current.title),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Date
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: Colors.white60,
                              ),
                              const SizedBox(width: 5),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _current.date,
                                  key: ValueKey(_current.date),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Swipe hint
                          if (widget.items.length > 1)
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.swipe_rounded,
                                    size: 14,
                                    color: Colors.white38,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Geser untuk foto lainnya',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: Colors.white38,
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
            ),
          ),

          // ── Swipe Left/Right arrows ──────────────────────
          if (_currentIndex > 0)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: FadeTransition(
                  opacity: _panelFade,
                  child: _NavArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _pageCtrl.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),
            ),
          if (_currentIndex < widget.items.length - 1)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: FadeTransition(
                  opacity: _panelFade,
                  child: _NavArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _pageCtrl.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Viewer Icon Button ────────────────────────────────────────────────────────

class _ViewerIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ViewerIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.45),
        ),
        child: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }
}

// ── Nav Arrow ─────────────────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white70, size: 24),
      ),
    );
  }
}
