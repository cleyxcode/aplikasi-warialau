import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/app_transitions.dart';
import '../profil/profil_user_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../berita/berita_model.dart';
import '../berita/detail_berita_screen.dart';
import '../guru/guru_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int)? onTabSwitch;
  const HomeScreen({super.key, this.onTabSwitch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final PageController _bannerCtrl = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  String _userName = '';
  String _userRole = 'Pengguna';

  List<String> _bannerUrls = [];
  List<BeritaModel> _beritaItems = [];
  List<String> _galeriUrls = [];

  String _tahunAjaran = '';
  bool _pendaftaranAktif = false;
  bool _isLoadingData = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Data fetching ───────────────────────────────────────────

  Future<void> _loadData() async {
    await Future.wait([
      _fetchProfile(),
      _fetchBanners(),
      _fetchBerita(),
      _fetchGaleri(),
      _fetchInfoPendaftaran(),
    ]);
    if (!mounted) return;
    setState(() => _isLoadingData = false);
    _fadeController.forward();
    if (_bannerUrls.isNotEmpty) _startBannerTimer();
  }

  Future<void> _fetchProfile() async {
    try {
      final r = await ApiService.instance.get('/profile');
      _userName = r.data['name'] as String? ?? '';
      _userRole = _mapRole(r.data['role'] as String? ?? '');
    } catch (_) {}
  }

  Future<void> _fetchBanners() async {
    try {
      final r = await ApiService.instance.get('/banner');
      final list = (r.data as List<dynamic>?) ?? [];
      _bannerUrls = list
          .where((b) => b['status'] == 'aktif')
          .map((b) => AppConstants.imageUrl(b['gambar'] as String?))
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (_) {}
  }

  Future<void> _fetchBerita() async {
    try {
      final r = await ApiService.instance.get(
        '/berita',
        queryParameters: {'per_page': 5, 'page': 1},
      );
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      _beritaItems = list
          .map((b) => BeritaModel.fromJson(b as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<void> _fetchGaleri() async {
    try {
      final r = await ApiService.instance.get(
        '/galeri',
        queryParameters: {'per_page': 4, 'page': 1},
      );
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      _galeriUrls = list
          .map((g) => AppConstants.imageUrl(g['foto'] as String?))
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (_) {}
  }

  Future<void> _fetchInfoPendaftaran() async {
    try {
      final r = await ApiService.instance.get('/info-pendaftaran');
      _tahunAjaran = r.data['tahun_ajaran'] as String? ?? '';
      _pendaftaranAktif = (r.data['status'] as String?) == 'aktif';
    } catch (_) {
      _pendaftaranAktif = false;
    }
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerCtrl.hasClients || _bannerUrls.isEmpty) return;
      final next = (_bannerIndex + 1) % _bannerUrls.length;
      _bannerCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // ── Helpers ────────────────────────────────────────────────

  String _mapRole(String role) {
    switch (role) {
      case 'orangtua':
        return '';
      case 'admin':
        return 'Admin';
      default:
        return 'Pengguna';
    }
  }

  String get _initials {
    final parts = _userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _userName.isNotEmpty ? _userName[0].toUpperCase() : '?';
  }

  String get _firstName =>
      _userName.isNotEmpty ? _userName.split(' ').first : 'Pengguna';

  void _goDetailBerita(BeritaModel berita) => Navigator.push(
        context,
        AppRoute(page: DetailBeritaScreen(berita: berita)),
      );

  void _goToBerita() => widget.onTabSwitch?.call(1);
  void _goToGaleri() => widget.onTabSwitch?.call(2);
  void _goToPendaftaran() => widget.onTabSwitch?.call(3);

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return _ShimmerWrap(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _isLoadingData
                  ? const AlwaysStoppedAnimation(1.0)
                  : _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBox(),
                  const SizedBox(height: 4),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildBannerSlider(),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Berita Terbaru', _goToBerita),
                  const SizedBox(height: 14),
                  _buildBeritaList(),
                  const SizedBox(height: 24),
                  if (!_isLoadingData && _pendaftaranAktif) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildPendaftaranCard(),
                    ),
                    const SizedBox(height: 28),
                  ],
                  _buildSectionHeader('Galeri Kegiatan', _goToGaleri),
                  const SizedBox(height: 14),
                  _buildGaleriList(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF2D5A9B),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -20,
                right: 60,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: 80,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () =>
            Navigator.push(
              context,
              AppRoute(page: const ProfilUserScreen()),
            ).then(
              (_) => _fetchProfile().then((_) {
                if (mounted) setState(() {});
              }),
            ),
        child: Row(
          children: [
            // Avatar
            RepaintBoundary(
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3A6AB0), Color(0xFF1A2F50)],
                  ),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoadingData
                      ? _shimmerBox(width: 16, height: 16, radius: 8)
                      : Text(
                          _initials,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _isLoadingData
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _shimmerBox(width: 130, height: 13, radius: 6),
                        const SizedBox(height: 5),
                        _shimmerBox(width: 80, height: 10, radius: 5),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Halo, $_firstName!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('👋', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        if (_userRole.isNotEmpty)
                          Text(
                            _userRole,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white.withValues(alpha: 0.75),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              AppRoute(page: const NotifikasiScreen()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold,
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Search Box ─────────────────────────────────────────

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to search screen or open search delegate
        },
        child: Container(
          width: double.infinity,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.textLight,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cari informasi sekolah...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick Actions ────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      _QuickActionData(
        icon: Icons.newspaper_rounded,
        label: 'Berita',
        gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        onTap: _goToBerita,
      ),
      _QuickActionData(
        icon: Icons.photo_library_rounded,
        label: 'Galeri',
        gradientColors: const [Color(0xFF22C55E), Color(0xFF15803D)],
        onTap: _goToGaleri,
      ),
      _QuickActionData(
        icon: Icons.people_rounded,
        label: 'Guru',
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        onTap: () => Navigator.push(
          context,
          AppRoute(page: const GuruScreen()),
        ),
      ),
      _QuickActionData(
        icon: Icons.assignment_rounded,
        label: 'Daftar',
        gradientColors: const [AppColors.gold, Color(0xFFB8860B)],
        onTap: _goToPendaftaran,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions
            .map((a) => Expanded(child: _QuickActionButton(data: a)))
            .toList(),
      ),
    );
  }

  // ── Banner Slider ─────────────────────────────────────────

  Widget _buildBannerSlider() {
    if (_isLoadingData) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _ShimmerWrap(
          child: Container(
            height: 196,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    if (_bannerUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 196,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.gold.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: AppColors.textLight,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SD Negeri Warialau',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 196,
          child: PageView.builder(
            controller: _bannerCtrl,
            itemCount: _bannerUrls.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _BannerItem(imageUrl: _bannerUrls[index]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Modern pill indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerUrls.length, (i) {
            final active = i == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 28 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: active ? AppColors.gold : const Color(0xFFCDD5DF),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Section Header ────────────────────────────────────────

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Gold accent bar
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Text(
                    'Lihat Semua',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.gold,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Berita List ───────────────────────────────────────────

  Widget _buildBeritaList() {
    if (_isLoadingData) {
      return SizedBox(
        height: 252,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => _ShimmerWrap(
            child: Container(
              width: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 150,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 80,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
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
      );
    }

    if (_beritaItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 80,
          alignment: Alignment.center,
          child: Text(
            'Belum ada berita',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 252,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _beritaItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _BeritaCard(
          item: _beritaItems[i],
          onTap: () => _goDetailBerita(_beritaItems[i]),
        ),
      ),
    );
  }

  // ── Pendaftaran Card ──────────────────────────────────────

  Widget _buildPendaftaranCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold,
            Color(0xFFE8C04A),
            Color(0xFFC8A020),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background pattern circles
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -24,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              Icons.school_rounded,
              size: 96,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PENDAFTARAN DIBUKA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tahun Ajaran\n$_tahunAjaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Daftarkan putra-putri Anda sekarang.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _goToPendaftaran,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 14,
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
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Galeri List ───────────────────────────────────────────

  Widget _buildGaleriList() {
    if (_isLoadingData) {
      return SizedBox(
        height: 136,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => _ShimmerWrap(
            child: Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      );
    }

    if (_galeriUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 80,
          alignment: Alignment.center,
          child: Text(
            'Belum ada galeri',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _galeriUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _GaleriItem(imageUrl: _galeriUrls[i]),
      ),
    );
  }
}

// ── Shimmer Wrapper ───────────────────────────────────────────────────────────

class _ShimmerWrap extends StatelessWidget {
  final Widget child;
  const _ShimmerWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EDF2),
      highlightColor: const Color(0xFFF5F7FA),
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

// ── Quick Action Data ─────────────────────────────────────────────────────────

class _QuickActionData {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });
}

// ── Quick Action Button ───────────────────────────────────────────────────────

class _QuickActionButton extends StatefulWidget {
  final _QuickActionData data;
  const _QuickActionButton({required this.data});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
        widget.data.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: RepaintBoundary(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.data.gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.data.gradientColors.first
                          .withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.data.icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.data.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Banner Item ───────────────────────────────────────────────────────────────

class _BannerItem extends StatelessWidget {
  final String imageUrl;
  const _BannerItem({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  _ShimmerWrap(child: Container(color: Colors.white)),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.inputBg,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.textLight,
                  size: 40,
                ),
              ),
            ),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Galeri Item ───────────────────────────────────────────────────────────────

class _GaleriItem extends StatelessWidget {
  final String imageUrl;
  const _GaleriItem({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 136,
          height: 136,
          fit: BoxFit.cover,
          placeholder: (_, __) => _ShimmerWrap(
            child: Container(width: 136, height: 136, color: Colors.white),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 136,
            height: 136,
            color: AppColors.inputBg,
            child: const Icon(
              Icons.image_outlined,
              color: AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Berita Card Widget ────────────────────────────────────────────────────────

class _BeritaCard extends StatefulWidget {
  final BeritaModel item;
  final VoidCallback? onTap;

  const _BeritaCard({required this.item, this.onTap});

  @override
  State<_BeritaCard> createState() => _BeritaCardState();
}

class _BeritaCardState extends State<_BeritaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  static const _badgeColor = {
    'PRESTASI': Color(0xFFF59E0B),
    'KEGIATAN': Color(0xFF22C55E),
    'INFO': Color(0xFF3B82F6),
    'PENGUMUMAN': Color(0xFF8B5CF6),
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryLabel = widget.item.category.toUpperCase();
    final badgeColor = _badgeColor[categoryLabel] ?? AppColors.gold;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: RepaintBoundary(
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 240,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with gradient overlay
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.item.imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: const Color(0xFFE8EDF2),
                          highlightColor: const Color(0xFFF5F7FA),
                          child: Container(height: 140, color: Colors.white),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 140,
                          color: AppColors.inputBg,
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.textLight,
                            size: 32,
                          ),
                        ),
                      ),
                      // Gradient overlay at bottom of image
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: badgeColor.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            categoryLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.item.date,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
