import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../berita/berita_screen.dart';
import '../galeri/galeri_screen.dart';
import '../pendaftaran/pendaftaran_screen.dart';
import '../profil_sekolah/profil_sekolah_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageCtrl;

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    _TabItem(
      icon: Icons.newspaper_outlined,
      activeIcon: Icons.newspaper_rounded,
    ),
    _TabItem(
      icon: Icons.photo_library_outlined,
      activeIcon: Icons.photo_library_rounded,
    ),
    _TabItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
    ),
    _TabItem(
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    // Gunakan jumpToPage agar tidak ada bug animasi PageView
    _pageCtrl.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      extendBody: true,
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: [
          _KeepAlivePage(child: HomeScreen(onTabSwitch: _onTabTap)),
          const _KeepAlivePage(child: BeritaScreen()),
          const _KeepAlivePage(child: GaleriScreen()),
          const _KeepAlivePage(child: PendaftaranScreen()),
          const _KeepAlivePage(child: ProfilSekolahScreen()),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        tabs: _tabs,
        bottomPad: bottomPad,
        onTap: _onTabTap,
      ),
    );
  }
}

// ── Keep Alive Wrapper ────────────────────────────────────────────────────────

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// ── Tab Item Data ─────────────────────────────────────────────────────────────

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  const _TabItem({required this.icon, required this.activeIcon});
}

// ── Floating Nav Bar ──────────────────────────────────────────────────────────

class _FloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final double bottomPad;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.tabs,
    required this.bottomPad,
    required this.onTap,
  });

  @override
  State<_FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<_FloatingNavBar> {
  // Simpan index sebelumnya untuk animasi dari posisi lama ke baru
  int _prevIndex = 0;

  @override
  void didUpdateWidget(_FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _prevIndex = oldWidget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 0, 28, widget.bottomPad + 14),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final itemW = constraints.maxWidth / widget.tabs.length;

          return Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // ── Gold pill – TweenAnimationBuilder agar smooth tanpa bug
                TweenAnimationBuilder<double>(
                  key: const ValueKey('pill'),
                  tween: Tween<double>(
                    begin: itemW * _prevIndex,
                    end: itemW * widget.currentIndex,
                  ),
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  builder: (_, left, __) {
                    return Positioned(
                      left: left + 5,
                      top: 5,
                      bottom: 5,
                      width: itemW - 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.42),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // ── Icon buttons
                Row(
                  children: List.generate(widget.tabs.length, (i) {
                    final active = i == widget.currentIndex;
                    final tab = widget.tabs[i];
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onTap(i),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, anim) => ScaleTransition(
                              scale: Tween<double>(begin: 0.7, end: 1.0)
                                  .animate(
                                    CurvedAnimation(
                                      parent: anim,
                                      curve: Curves.easeOutBack,
                                    ),
                                  ),
                              child: FadeTransition(
                                opacity: anim,
                                child: child,
                              ),
                            ),
                            child: Icon(
                              active ? tab.activeIcon : tab.icon,
                              key: ValueKey('icon_${i}_$active'),
                              size: active ? 21 : 19,
                              color: active
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
