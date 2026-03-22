import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_local_service.dart';
import '../home/home_screen.dart';
import '../berita/berita_screen.dart';
import '../galeri/galeri_screen.dart';
import '../pendaftaran/pendaftaran_screen.dart';
import '../profil/profil_sekolah_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageCtrl;
  bool _isRefreshing = false;
  // Key unik per tab → ganti key = rebuild widget dari awal
  final List<UniqueKey> _pageKeys = List.generate(5, (_) => UniqueKey());

  static const _tabs = [
    _TabItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Beranda',
    ),
    _TabItem(
      icon: Icons.newspaper_outlined,
      activeIcon: Icons.newspaper_rounded,
      label: 'Berita',
    ),
    _TabItem(
      icon: Icons.photo_library_outlined,
      activeIcon: Icons.photo_library_rounded,
      label: 'Galeri',
    ),
    _TabItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'Daftar',
    ),
    _TabItem(
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance_rounded,
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // Minta izin notifikasi (Android 13+)
    await NotificationLocalService.instance.requestPermission();
    // Mulai polling notifikasi dari API setiap 30 detik
    NotificationLocalService.instance.startPolling(intervalSeconds: 30);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    NotificationLocalService.instance.stopPolling();
    super.dispose();
  }

  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    if (index == _currentIndex) {
      // Double-tap pada tab aktif → refresh halaman
      _refreshCurrentPage();
      return;
    }
    // Jangan panggil setState di sini — biarkan onPageChanged yang update state
    // agar tidak terjadi double setState dalam satu frame (menyebabkan layout error)
    _pageCtrl.jumpToPage(index);
  }

  Future<void> _refreshCurrentPage() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      // Ganti key untuk tab saat ini → widget direbuild dari awal
      _pageKeys[_currentIndex] = UniqueKey();
      _isRefreshing = false;
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen(key: _pageKeys[0], onTabSwitch: _onTabTap);
      case 1:
        return BeritaScreen(key: _pageKeys[1]);
      case 2:
        return GaleriScreen(key: _pageKeys[2]);
      case 3:
        return PendaftaranScreen(key: _pageKeys[3]);
      case 4:
        return ProfilSekolahScreen(key: _pageKeys[4]);
      default:
        return HomeScreen(key: _pageKeys[0], onTabSwitch: _onTabTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentIndex = i),
            children: List.generate(5, (i) => _KeepAlivePage(child: _buildPage(i))),
          ),
          // ── Loading overlay saat refresh ──
          if (_isRefreshing)
            Container(
              color: const Color(0xFF0C1E36).withValues(alpha: 0.85),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'lib/animations/loading _school.json',
                      width: 200,
                      height: 200,
                      repeat: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat ulang...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
  final String label;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ── Floating Nav Bar ──────────────────────────────────────────────────────────
// TIDAK menggunakan LayoutBuilder karena LayoutBuilder melakukan
// _rebuildWithConstraints SELAMA fase layout Scaffold (_ScaffoldLayout.performLayout).
// Jika ada widget animasi yang dirty di dalamnya, akan terjadi crash
// "Each child must be laid out exactly once".
//
// Solusi: AnimatedAlign + FractionallySizedBox — tidak butuh constraint runtime,
// tidak ada LayoutBuilder, posisi dihitung dari currentIndex saja.

class _FloatingNavBar extends StatelessWidget {
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

  // Alignment pill dari -1.0 (tab 0) hingga 1.0 (tab terakhir)
  // Formula: (2i - n + 1) / (n - 1)  di mana n = jumlah tab, i = currentIndex
  double get _pillAlignment =>
      (2.0 * currentIndex - tabs.length + 1) / (tabs.length - 1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad + 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Gold pill: AnimatedAlign + FractionallySizedBox
            // Tidak perlu LayoutBuilder, tidak ada Positioned,
            // animasi aman karena tidak terikat ke layout callback.
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: Alignment(_pillAlignment, 0),
              child: FractionallySizedBox(
                widthFactor: 1.0 / tabs.length,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.gold, Color(0xFFE8C842)],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Tab items
            Row(
              children: List.generate(tabs.length, (i) {
                final active = i == currentIndex;
                final tab = tabs[i];
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              active ? tab.activeIcon : tab.icon,
                              key: ValueKey('icon_${i}_$active'),
                              size: active ? 22 : 20,
                              color: active
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: active ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 180),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: active ? 14.0 : 0.0,
                              curve: Curves.easeOut,
                              child: Text(
                                tab.label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
