import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/app_transitions.dart';
import '../profil/profil_user_screen.dart';
import '../notifikasi/notifikasi_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerCtrl = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  // ── State dari API ──────────────────────────────────────────
  String _userName = '';
  String _userRole = 'Pengguna';

  List<String> _bannerUrls = [];
  List<_BeritaItem> _beritaItems = [];
  List<String> _galeriUrls = [];

  String _tahunAjaran = '';
  bool _pendaftaranAktif = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
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
      final r = await ApiService.instance
          .get('/berita', queryParameters: {'per_page': 5, 'page': 1});
      final list = (r.data['data'] as List<dynamic>?) ?? [];
      _beritaItems = list.map((b) {
        final kategori = (b['kategori'] as String? ?? 'Info').toUpperCase();
        return _BeritaItem(
          id: b['id'] as int? ?? 0,
          imageUrl: AppConstants.imageUrl(b['gambar'] as String?),
          badge: kategori,
          title: b['judul'] as String? ?? '',
          date: _formatDate(b['tanggal_publish'] as String?),
        );
      }).toList();
    } catch (_) {}
  }

  Future<void> _fetchGaleri() async {
    try {
      final r = await ApiService.instance
          .get('/galeri', queryParameters: {'per_page': 4, 'page': 1});
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
        return 'Orang Tua Murid';
      case 'admin':
        return 'Admin';
      default:
        return 'Pengguna';
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String get _initials {
    final parts = _userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _userName.isNotEmpty ? _userName[0].toUpperCase() : '?';
  }

  String get _firstName =>
      _userName.isNotEmpty ? _userName.split(' ').first : 'Pengguna';

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 16),
                _buildBannerSlider(),
                const SizedBox(height: 24),
                _buildSectionHeader('Berita Terbaru', () {}),
                const SizedBox(height: 12),
                _buildBeritaList(),
                const SizedBox(height: 20),
                if (_pendaftaranAktif)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPendaftaranCard(),
                  ),
                if (_pendaftaranAktif) const SizedBox(height: 24),
                _buildSectionHeader('Galeri Kegiatan', () {}),
                const SizedBox(height: 12),
                _buildGaleriList(),
                const SizedBox(height: 28),
              ],
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
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      title: GestureDetector(
        onTap: () => Navigator.push(
          context,
          AppRoute(page: const ProfilUserScreen()),
        ).then((_) => _fetchProfile().then((_) {
              if (mounted) setState(() {});
            })),
        child: Row(
          children: [
            // Avatar circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.gold, Color(0xFFE8C547)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: _isLoadingData
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _initials,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoadingData ? 'Memuat...' : 'Halo, $_firstName! 👋',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _userRole,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Notification bell
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              AppRoute(page: const NotifikasiScreen()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.inputBg,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 7,
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

  // ── Welcome Card ─────────────────────────────────────────
  Widget _buildWelcomeCard() {
    final displayName = _isLoadingData
        ? '...'
        : _userName.split(' ').take(2).join(' ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF254A7A)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative blobs
            Positioned(
              right: -16,
              bottom: -16,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              left: -12,
              top: -12,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    height: 1.3,
                  ),
                ),
                Text(
                  displayName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Temukan informasi terbaru sekolah kami',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Banner Slider ─────────────────────────────────────────
  Widget _buildBannerSlider() {
    if (_isLoadingData) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 180,
            color: AppColors.inputBg,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      );
    }

    if (_bannerUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 180,
            color: AppColors.inputBg,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_outlined,
                      color: AppColors.textLight, size: 40),
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
          height: 180,
          child: PageView.builder(
            controller: _bannerCtrl,
            itemCount: _bannerUrls.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: _bannerUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.inputBg,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.inputBg,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textLight,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerUrls.length, (i) {
            final active = i == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 24 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: active ? AppColors.gold : const Color(0xFFCDD5DF),
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
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  'Lihat Semua',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gold,
                  size: 18,
                ),
              ],
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
        height: 240,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => Container(
            width: 230,
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(16),
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
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _beritaItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _BeritaCard(item: _beritaItems[i]),
      ),
    );
  }

  // ── Pendaftaran Card ──────────────────────────────────────
  Widget _buildPendaftaranCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative icon
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              Icons.school_rounded,
              size: 90,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pendaftaran Dibuka!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tahun Ajaran $_tahunAjaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ],
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
        height: 128,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(14),
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
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _galeriUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: _galeriUrls[i],
              width: 128,
              height: 128,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 128,
                height: 128,
                color: AppColors.inputBg,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 128,
                height: 128,
                color: AppColors.inputBg,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.textLight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _BeritaItem {
  final int id;
  final String imageUrl;
  final String badge;
  final String title;
  final String date;

  const _BeritaItem({
    required this.id,
    required this.imageUrl,
    required this.badge,
    required this.title,
    required this.date,
  });
}

// ── Berita Card Widget ────────────────────────────────────────────────────────

class _BeritaCard extends StatelessWidget {
  final _BeritaItem item;

  const _BeritaCard({required this.item});

  static const _badgeColor = {
    'PRESTASI': Color(0xFFF59E0B),
    'KEGIATAN': Color(0xFF22C55E),
    'INFO': Color(0xFF3B82F6),
    'PENGUMUMAN': Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final badgeColor = _badgeColor[item.badge] ?? AppColors.gold;

    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 130,
                    color: AppColors.inputBg,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 130,
                    color: AppColors.inputBg,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.textLight,
                      size: 32,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.badge,
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
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.date,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
