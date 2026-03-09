import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';

class _SekolahData {
  final String kepalaSekolah;
  final String akreditasi;
  final String tahunBerdiri;
  final int jumlahRuangKelas;
  final String visi;
  final List<String> misiList;
  final String sejarah;
  final String alamat;
  final String kontak;

  const _SekolahData({
    required this.kepalaSekolah,
    required this.akreditasi,
    required this.tahunBerdiri,
    required this.jumlahRuangKelas,
    required this.visi,
    required this.misiList,
    required this.sejarah,
    required this.alamat,
    required this.kontak,
  });

  factory _SekolahData.fromJson(Map<String, dynamic> j) {
    final misiRaw = j['misi'] as String? ?? '';
    final misiLines = misiRaw
        .split('\n')
        .map((s) => s.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return _SekolahData(
      kepalaSekolah: j['kepala_sekolah'] as String? ?? '-',
      akreditasi: j['akreditasi'] as String? ?? 'B',
      tahunBerdiri: j['tahun_berdiri'] as String? ?? '-',
      jumlahRuangKelas: (j['jumlah_ruang_kelas'] as num?)?.toInt() ?? 0,
      visi: j['visi'] as String? ?? '',
      misiList: misiLines,
      sejarah: j['sejarah'] as String? ?? '',
      alamat: j['alamat'] as String? ?? '-',
      kontak: j['kontak'] as String? ?? '-',
    );
  }
}

class ProfilSekolahScreen extends StatefulWidget {
  const ProfilSekolahScreen({super.key});

  @override
  State<ProfilSekolahScreen> createState() => _ProfilSekolahScreenState();
}

class _ProfilSekolahScreenState extends State<ProfilSekolahScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  _SekolahData? _data;
  bool _isLoading = false;

  static const _tabs = ['Profil', 'Visi Misi', 'Sejarah', 'Kontak'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _fetchProfil();
  }

  Future<void> _fetchProfil() async {
    setState(() => _isLoading = true);
    try {
      final resp = await ApiService.instance.get('/profil-sekolah');
      setState(() {
        _data = _SekolahData.fromJson(resp.data as Map<String, dynamic>);
        _isLoading = false;
      });
    } on DioException {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              tabs: _tabs,
            ),
          ),
        ],
        body: _isLoading
            ? _buildShimmerBody()
            : TabBarView(
                controller: _tabController,
                children: [
                  _ProfilTab(data: _data),
                  _VisiMisiTab(data: _data),
                  _SejarahTab(data: _data),
                  _KontakTab(data: _data),
                ],
              ),
      ),
    );
  }

  // ── Shimmer body (mengganti CircularProgressIndicator) ────

  Widget _buildShimmerBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Section title
        _shimmerBox(width: 140, height: 16, radius: 6),
        const SizedBox(height: 12),

        // Info card shimmer
        _ShimmerWrap(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 140,
                              height: 13,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
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

        const SizedBox(height: 20),
        _shimmerBox(width: 120, height: 16, radius: 6),
        const SizedBox(height: 12),

        // Second info card shimmer
        _ShimmerWrap(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 100,
                              height: 13,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
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

        const SizedBox(height: 20),

        // Akreditasi banner shimmer
        _ShimmerWrap(
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }

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

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, Color(0xFF254A7A)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -40,
              top: 0,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeaderIconBtn(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      Text(
                        'Profil Sekolah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      _HeaderIconBtn(icon: Icons.share_rounded, onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Logo dengan shimmer placeholder
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBIl6kDPv_b3UxLFZeMY2JzBi6CcZCq0qSDPih_0X8jy0BwHOWqc2jSjuFxHcxl15V2bvAvRbzC6z6J5YhJR1cNKt_ofiLp24zoFDjz3lwrR41kPsuBBdVPl_ejeRZn1JT5_aO96j1e7M-IG1pDcDX-mTKdhEZRnN6w_4EAm7mUZaY0FVIewedxBH9-ALzFLP_eB8htcKSnsRdXXMjVwg9IvNipK1aa-BAl5QWis36vgGsu5ZhRcGSE9b5rsuHCnOTydDqXWHswbKv5',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        // ── Shimmer untuk logo saat loading ──
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: const Color(0xFFE0E6EF),
                          highlightColor: const Color(0xFFF2F5F9),
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: AppColors.inputBg,
                          child: const Icon(
                            Icons.school_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'SD Negeri Warialau',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'NPSN: 12345678',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _isLoading
            ? Row(
                children: List.generate(3, (i) {
                  final spacer = i < 2
                      ? const SizedBox(width: 10)
                      : const SizedBox.shrink();
                  return [
                    Expanded(
                      child: _ShimmerWrap(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    spacer,
                  ];
                }).expand((w) => w).toList(),
              )
            : Row(
                children: [
                  _StatCard(
                    icon: Icons.verified_rounded,
                    label: 'Akreditasi',
                    value: _data?.akreditasi ?? 'A',
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Berdiri',
                    value: _data?.tahunBerdiri ?? '1985',
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.meeting_room_rounded,
                    label: 'Kelas',
                    value: _data != null ? '${_data!.jumlahRuangKelas}' : '12',
                  ),
                ],
              ),
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

// ── Tab Bar Delegate ──────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> tabs;

  const _TabBarDelegate({required this.tabController, required this.tabs});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppColors.divider,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabController != tabController;
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header Icon Button ────────────────────────────────────────────────────────

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        child: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — PROFIL
// ─────────────────────────────────────────────────────────────────────────────

class _ProfilTab extends StatelessWidget {
  final _SekolahData? data;
  const _ProfilTab({this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        const SizedBox(height: 4),
        _SectionTitle('Informasi Umum'),
        const SizedBox(height: 12),
        _InfoCard(
          children: [
            _InfoRow(
              icon: Icons.person_rounded,
              label: 'Kepala Sekolah',
              value: data?.kepalaSekolah ?? 'Drs. Haji Ahmad',
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.school_rounded,
              label: 'Status Sekolah',
              value: 'Negeri (SDN)',
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.location_city_rounded,
              label: 'Kabupaten',
              value: 'Kepulauan Aru',
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.flag_rounded,
              label: 'Provinsi',
              value: 'Maluku',
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Data Sekolah'),
        const SizedBox(height: 12),
        _InfoCard(
          children: [
            _InfoRow(icon: Icons.tag_rounded, label: 'NPSN', value: '12345678'),
            const _Divider(),
            _InfoRow(
              icon: Icons.badge_rounded,
              label: 'NSS',
              value: '101217102001',
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.group_rounded,
              label: 'Total Siswa',
              value: '384 Siswa',
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.people_alt_rounded,
              label: 'Total Guru',
              value: '24 Guru',
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Akreditasi badge
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFF254A7A)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    data?.akreditasi ?? 'A',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terakreditasi ${data?.akreditasi ?? 'A'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BAN-S/M — Badan Akreditasi Nasional',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: AppColors.gold,
                size: 28,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — VISI MISI
// ─────────────────────────────────────────────────────────────────────────────

class _VisiMisiTab extends StatelessWidget {
  final _SekolahData? data;
  const _VisiMisiTab({this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _SectionTitle('Visi Sekolah'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: const Border(
              left: BorderSide(color: AppColors.primary, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'VISI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data?.visi.isNotEmpty == true
                    ? '"${data!.visi}"'
                    : '"Mewujudkan generasi yang berakhlak mulia, cerdas, terampil, dan peduli lingkungan berdasarkan iman dan taqwa."',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionTitle('Misi Sekolah'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: const Border(
              left: BorderSide(color: AppColors.gold, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'MISI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...(data?.misiList.isNotEmpty == true
                      ? data!.misiList
                      : _misiList)
                  .asMap()
                  .entries
                  .map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold.withValues(alpha: 0.15),
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                height: 1.6,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionTitle('Tujuan Sekolah'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.05),
                AppColors.gold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            'Menghasilkan peserta didik yang berkarakter, berprestasi, dan mampu bersaing di era global dengan tetap menjunjung nilai-nilai budaya lokal Maluku.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  static const _misiList = [
    'Meningkatkan kualitas pembelajaran berbasis teknologi.',
    'Menanamkan nilai karakter melalui pembiasaan harian.',
    'Menumbuhkan budaya literasi dan numerasi di lingkungan sekolah.',
    'Membangun kemitraan yang kuat antara sekolah, orang tua, dan masyarakat.',
    'Mengembangkan potensi seni dan budaya lokal siswa.',
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — SEJARAH
// ─────────────────────────────────────────────────────────────────────────────

class _SejarahTab extends StatelessWidget {
  final _SekolahData? data;
  const _SejarahTab({this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _SectionTitle('Sejarah Sekolah'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            data?.sejarah.isNotEmpty == true
                ? data!.sejarah
                : 'SD Negeri Warialau didirikan pada tahun 1985 sebagai respons atas kebutuhan pendidikan dasar bagi warga sekitar. Awalnya hanya memiliki 3 ruang kelas sederhana dengan fasilitas yang sangat terbatas.\n\nSeiring berjalannya waktu, sekolah ini terus berkembang pesat dalam aspek infrastruktur dan prestasi akademik maupun non-akademik di tingkat provinsi. Dukungan penuh dari pemerintah daerah dan masyarakat setempat menjadi pendorong utama kemajuan sekolah.\n\nHingga saat ini, SD Negeri Warialau telah memiliki 12 ruang kelas yang representatif, laboratorium komputer, perpustakaan, dan berbagai fasilitas penunjang lainnya untuk mendukung proses pembelajaran yang berkualitas.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.8,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _SectionTitle('Tonggak Sejarah'),
        const SizedBox(height: 16),
        ..._milestones.map(
          (m) => _MilestoneItem(
            year: m.$1,
            desc: m.$2,
            isLast: m == _milestones.last,
          ),
        ),
      ],
    );
  }

  static const _milestones = [
    ('1985', 'Pendirian SD Negeri Warialau dengan 3 ruang kelas pertama.'),
    ('1993', 'Pembangunan gedung tambahan dan penambahan tenaga pengajar.'),
    ('2002', 'Peraihan akreditasi B dari BAN-S/M untuk pertama kalinya.'),
    ('2010', 'Renovasi total gedung sekolah dengan dukungan APBD daerah.'),
    ('2018', 'Peraihan akreditasi A, tertinggi dalam sejarah sekolah.'),
    ('2024', 'Pengembangan laboratorium komputer berbasis teknologi terkini.'),
  ];
}

class _MilestoneItem extends StatelessWidget {
  final String year;
  final String desc;
  final bool isLast;

  const _MilestoneItem({
    required this.year,
    required this.desc,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Container(
                  width: 44,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    year,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 21,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textPrimary,
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

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4 — KONTAK
// ─────────────────────────────────────────────────────────────────────────────

class _KontakTab extends StatelessWidget {
  final _SekolahData? data;
  const _KontakTab({this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _SectionTitle('Hubungi Kami'),
        const SizedBox(height: 12),
        _InfoCard(
          children: [
            _ContactRow(
              icon: Icons.location_on_rounded,
              iconColor: AppColors.danger,
              label: 'Alamat',
              value: data?.alamat.isNotEmpty == true
                  ? data!.alamat
                  : 'Jl. Pendidikan No. 45, Warialau, Kab. Kepulauan Aru, Maluku',
            ),
            const _Divider(),
            _ContactRow(
              icon: Icons.call_rounded,
              iconColor: AppColors.success,
              label: 'Telepon',
              value: data?.kontak.isNotEmpty == true
                  ? data!.kontak
                  : '(0911) 123456',
            ),
            const _Divider(),
            _ContactRow(
              icon: Icons.mail_rounded,
              iconColor: AppColors.primary,
              label: 'Email',
              value: 'sdnwarialau@sch.id',
            ),
            const _Divider(),
            _ContactRow(
              icon: Icons.access_time_rounded,
              iconColor: AppColors.warning,
              label: 'Jam Operasional',
              value: 'Senin–Jumat, 07.00–14.00 WIT',
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Lokasi'),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Warialau, Maluku',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.map_rounded,
                          color: AppColors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Buka Peta',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionTitle('Media Sosial'),
        const SizedBox(height: 12),
        Row(
          children: [
            _SocialBtn(
              icon: Icons.facebook_rounded,
              label: 'Facebook',
              color: const Color(0xFF1877F2),
            ),
            const SizedBox(width: 10),
            _SocialBtn(
              icon: Icons.public_rounded,
              label: 'Website',
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            _SocialBtn(
              icon: Icons.mail_rounded,
              label: 'Email',
              color: AppColors.gold,
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8CCE8).withValues(alpha: 0.5)
      ..strokeWidth = 1;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: AppColors.divider,
    );
  }
}
