import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/school_map_card.dart';
import '../guru/guru_screen.dart';

class _Milestone {
  final String tahun;
  final String deskripsi;
  const _Milestone({required this.tahun, required this.deskripsi});
}

class _SekolahData {
  final String namaSekolah;
  final String? logo;
  final String kepalaSekolah;
  final String akreditasi;
  final String tahunBerdiri;
  final int jumlahRuangKelas;
  final String visi;
  final List<String> misiList;
  final String tujuan;
  final String sejarah;
  final List<_Milestone> tonggakSejarah;
  final String alamat;
  final String kontak;
  final String? emailSekolah;
  final String? jamOperasional;
  final String? latitude;
  final String? longitude;
  final String? mapsUrl;
  final String? mapsEmbed;
  final String? facebookUrl;
  final String? instagramUrl;

  const _SekolahData({
    required this.namaSekolah,
    this.logo,
    required this.kepalaSekolah,
    required this.akreditasi,
    required this.tahunBerdiri,
    required this.jumlahRuangKelas,
    required this.visi,
    required this.misiList,
    required this.tujuan,
    required this.sejarah,
    required this.tonggakSejarah,
    required this.alamat,
    required this.kontak,
    this.emailSekolah,
    this.jamOperasional,
    this.latitude,
    this.longitude,
    this.mapsUrl,
    this.mapsEmbed,
    this.facebookUrl,
    this.instagramUrl,
  });

  factory _SekolahData.fromJson(Map<String, dynamic> j) {
    final misiRaw = j['misi'] as String? ?? '';
    final misiLines = misiRaw
        .split('\n')
        .map((s) => s.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final tonggakRaw = (j['tonggak_sejarah'] as List<dynamic>?) ?? [];
    final tonggak = tonggakRaw.map((e) {
      final m = e as Map<String, dynamic>;
      return _Milestone(
        tahun: m['tahun']?.toString() ?? '',
        deskripsi: m['deskripsi'] as String? ?? '',
      );
    }).where((m) => m.tahun.isNotEmpty && m.deskripsi.isNotEmpty).toList();

    return _SekolahData(
      namaSekolah: j['nama_sekolah'] as String? ?? 'SD Negeri Warialau',
      logo: j['logo'] as String?,
      kepalaSekolah: j['kepala_sekolah'] as String? ?? '—',
      akreditasi: j['akreditasi'] as String? ?? '—',
      tahunBerdiri: j['tahun_berdiri'] as String? ?? '—',
      jumlahRuangKelas: (j['jumlah_ruang_kelas'] as num?)?.toInt() ?? 0,
      visi: j['visi'] as String? ?? '',
      misiList: misiLines,
      tujuan: j['tujuan'] as String? ?? '',
      sejarah: j['sejarah'] as String? ?? '',
      tonggakSejarah: tonggak,
      alamat: j['alamat'] as String? ?? '',
      kontak: j['kontak'] as String? ?? '',
      emailSekolah: j['email_sekolah'] as String?,
      jamOperasional: j['jam_operasional'] as String?,
      latitude: j['latitude']?.toString(),
      longitude: j['longitude']?.toString(),
      mapsUrl: j['maps_url'] as String?,
      mapsEmbed: j['maps_embed'] as String?,
      facebookUrl: j['facebook_url'] as String?,
      instagramUrl: j['instagram_url'] as String?,
    );
  }

  String get logoUrl => AppConstants.imageUrl(logo);

  String? get resolvedMapsUrl {
    if (mapsUrl != null && mapsUrl!.isNotEmpty) return mapsUrl;
    if (latitude != null &&
        longitude != null &&
        latitude!.isNotEmpty &&
        longitude!.isNotEmpty) {
      return 'https://www.google.com/maps?q=$latitude,$longitude';
    }
    return null;
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
  bool _isLoading = true;
  bool _hasError = false;

  static const _tabs = ['Profil', 'Visi Misi', 'Sejarah', 'Kontak'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _fetchProfil();
  }

  Future<void> _fetchProfil() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final resp = await ApiService.instance.get('/profil-sekolah');
      if (!mounted) return;
      final raw = resp.data;
      if (raw is Map<String, dynamic>) {
        setState(() {
          _data = _SekolahData.fromJson(raw);
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = _data == null;
        });
      }
    } on DioException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = _data == null;
      });
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchProfil,
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
              : _hasError
                  ? _buildErrorBody()
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
      ),
    );
  }

  Widget _buildErrorBody() {
    final navBarHeight = 64.0 + 12.0 + MediaQuery.of(context).padding.bottom;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24, 48, 24, navBarHeight + 24),
      children: [
        Icon(Icons.cloud_off_rounded,
            size: 56, color: AppColors.textLight.withValues(alpha: 0.7)),
        const SizedBox(height: 16),
        Text(
          'Gagal memuat profil',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Periksa koneksi internet lalu coba lagi.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: _fetchProfil,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              'Coba Lagi',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
    final nama = _data?.namaSekolah ?? 'SD Negeri Warialau';
    final logoUrl = _data?.logoUrl ?? '';
    final akreditasi = _data?.akreditasi;

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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
              child: Column(
                children: [
                  // Title row — root tab: no back button
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Profil Sekolah',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _fetchProfil,
                            borderRadius: BorderRadius.circular(22),
                            child: Ink(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                              child: Icon(
                                Icons.refresh_rounded,
                                color: AppColors.white.withValues(alpha: 0.9),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      child: logoUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: logoUrl,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Shimmer.fromColors(
                                baseColor: const Color(0xFFE0E6EF),
                                highlightColor: const Color(0xFFF2F5F9),
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (_, __, ___) =>
                                  _logoFallback(),
                            )
                          : _logoFallback(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      nama,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                  ),
                  if (akreditasi != null && akreditasi.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Akreditasi $akreditasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoFallback() {
    return Container(
      width: 88,
      height: 88,
      color: AppColors.inputBg,
      child: const Icon(
        Icons.school_rounded,
        size: 42,
        color: AppColors.primary,
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
                      ? const SizedBox(width: 8)
                      : const SizedBox.shrink();
                  return [
                    Expanded(
                      child: _ShimmerWrap(
                        child: Container(
                          height: 96,
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
                    value: _data?.akreditasi ?? '—',
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Berdiri',
                    value: _data?.tahunBerdiri ?? '—',
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    icon: Icons.meeting_room_rounded,
                    label: 'Kelas',
                    value: _data != null ? '${_data!.jumlahRuangKelas}' : '—',
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
    return Material(
      color: AppColors.backgroundLight,
      elevation: overlapsContent ? 1 : 0,
      shadowColor: Colors.black26,
      child: TabBar(
        controller: tabController,
        isScrollable: false,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textLight,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.divider,
        labelPadding: EdgeInsets.zero,
        tabs: tabs
            .map(
              (t) => Tab(
                height: 46,
                child: Text(
                  t,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
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
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
    final navBarHeight = 64.0 + 12.0 + MediaQuery.of(context).padding.bottom;
    final nama = data?.namaSekolah ?? 'SD Negeri Warialau';

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, navBarHeight + 24),
      children: [
        const SizedBox(height: 4),
        _SectionTitle('Informasi Umum'),
        const SizedBox(height: 12),
        _InfoCard(
          children: [
            _InfoRow(
              icon: Icons.apartment_rounded,
              label: 'Nama Sekolah',
              value: nama,
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.person_rounded,
              label: 'Kepala Sekolah',
              value: data?.kepalaSekolah ?? '—',
            ),
            if (data?.alamat.isNotEmpty == true) ...[
              const _Divider(),
              _InfoRow(
                icon: Icons.location_on_rounded,
                label: 'Alamat',
                value: data!.alamat,
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Ringkasan'),
        const SizedBox(height: 12),
        _InfoCard(
          children: [
            _InfoRow(
              icon: Icons.verified_rounded,
              label: 'Akreditasi',
              value: data?.akreditasi ?? '—',
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.calendar_month_rounded,
              label: 'Tahun Berdiri',
              value: data?.tahunBerdiri ?? '—',
            ),
            const _Divider(),
            _InfoRow(
              icon: Icons.meeting_room_rounded,
              label: 'Ruang Kelas',
              value: data != null
                  ? '${data!.jumlahRuangKelas} Ruang'
                  : '—',
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Akreditasi badge
        Container(
          padding: const EdgeInsets.all(18),
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
                width: 56,
                height: 56,
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
                    data?.akreditasi ?? '—',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terakreditasi ${data?.akreditasi ?? '—'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
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
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: AppColors.gold,
                size: 26,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionTitle('Tenaga Pengajar'),
        const SizedBox(height: 12),
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GuruScreen()),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Guru',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Lihat semua guru aktif',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textLight,
                    size: 22,
                  ),
                ],
              ),
            ),
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
    final navBarHeight = 64.0 + 12.0 + MediaQuery.of(context).padding.bottom;
    final visi = data?.visi.trim() ?? '';
    final misiList = data?.misiList ?? const <String>[];
    final tujuan = data?.tujuan.trim() ?? '';

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, navBarHeight + 24),
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
                visi.isNotEmpty
                    ? '"$visi"'
                    : 'Visi belum diatur di panel admin.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontStyle: visi.isNotEmpty ? FontStyle.italic : FontStyle.normal,
                  height: 1.7,
                  color: visi.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
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
              if (misiList.isEmpty)
                Text(
                  'Misi belum diatur di panel admin.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                ...misiList.asMap().entries.map((e) {
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
        if (tujuan.isNotEmpty) ...[
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
              tujuan,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — SEJARAH
// ─────────────────────────────────────────────────────────────────────────────

class _SejarahTab extends StatelessWidget {
  final _SekolahData? data;
  const _SejarahTab({this.data});

  @override
  Widget build(BuildContext context) {
    final navBarHeight = 64.0 + 12.0 + MediaQuery.of(context).padding.bottom;
    final sejarah = data?.sejarah.trim() ?? '';
    final milestones = data?.tonggakSejarah ?? const <_Milestone>[];

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, navBarHeight + 24),
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
            sejarah.isNotEmpty
                ? sejarah
                : 'Sejarah sekolah belum diatur di panel admin.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.8,
              color: sejarah.isNotEmpty
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        if (milestones.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle('Tonggak Sejarah'),
          const SizedBox(height: 16),
          ...milestones.asMap().entries.map(
            (e) => _MilestoneItem(
              year: e.value.tahun,
              desc: e.value.deskripsi,
              isLast: e.key == milestones.length - 1,
            ),
          ),
        ],
      ],
    );
  }
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

  Future<void> _launch(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchTel(String? phone) async {
    if (phone == null || phone.isEmpty || phone == '-') return;
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) return;
    await _launch('tel:$cleaned');
  }

  Future<void> _launchMail(String? email) async {
    if (email == null || email.isEmpty) return;
    await _launch('mailto:$email');
  }

  @override
  Widget build(BuildContext context) {
    final navBarHeight = 64.0 + 12.0 + MediaQuery.of(context).padding.bottom;
    final alamat = data?.alamat.trim() ?? '';
    final kontak = data?.kontak.trim() ?? '';
    final email = data?.emailSekolah?.trim() ?? '';
    final jam = data?.jamOperasional?.trim() ?? '';
    final sekolahNama = data?.namaSekolah ?? 'SD Negeri Warialau';

    final contactChildren = <Widget>[];
    void addRow(Widget row) {
      if (contactChildren.isNotEmpty) contactChildren.add(const _Divider());
      contactChildren.add(row);
    }

    if (alamat.isNotEmpty) {
      addRow(_ContactRow(
        icon: Icons.location_on_rounded,
        iconColor: AppColors.danger,
        label: 'Alamat',
        value: alamat,
      ));
    }
    if (kontak.isNotEmpty) {
      addRow(_ContactRow(
        icon: Icons.call_rounded,
        iconColor: AppColors.success,
        label: 'Telepon',
        value: kontak,
        onTap: () => _launchTel(kontak),
      ));
    }
    if (email.isNotEmpty) {
      addRow(_ContactRow(
        icon: Icons.mail_rounded,
        iconColor: AppColors.primary,
        label: 'Email',
        value: email,
        onTap: () => _launchMail(email),
      ));
    }
    if (jam.isNotEmpty) {
      addRow(_ContactRow(
        icon: Icons.access_time_rounded,
        iconColor: AppColors.warning,
        label: 'Jam Operasional',
        value: jam,
      ));
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, navBarHeight + 24),
      children: [
        _SectionTitle('Hubungi Kami'),
        const SizedBox(height: 12),
        if (contactChildren.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Kontak sekolah belum diatur di panel admin.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          _InfoCard(children: contactChildren),
        const SizedBox(height: 20),
        _SectionTitle('Lokasi'),
        const SizedBox(height: 12),
        SchoolMapCard(
          latitude: data?.latitude,
          longitude: data?.longitude,
          mapsUrl: data?.resolvedMapsUrl,
          mapsEmbed: data?.mapsEmbed,
          title: sekolahNama,
          height: 200,
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
              onTap: data?.facebookUrl != null && data!.facebookUrl!.isNotEmpty
                  ? () => _launch(data!.facebookUrl)
                  : null,
            ),
            const SizedBox(width: 8),
            _SocialBtn(
              icon: Icons.camera_alt_rounded,
              label: 'Instagram',
              color: const Color(0xFFE4405F),
              onTap: data?.instagramUrl != null &&
                      data!.instagramUrl!.isNotEmpty
                  ? () => _launch(data!.instagramUrl)
                  : null,
            ),
            const SizedBox(width: 8),
            _SocialBtn(
              icon: Icons.mail_rounded,
              label: 'Email',
              color: AppColors.gold,
              onTap: email.isNotEmpty ? () => _launchMail(email) : null,
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
  final VoidCallback? onTap;

  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Expanded(
      child: Material(
        color: color.withValues(alpha: enabled ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: enabled ? 0.2 : 0.1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: enabled ? color : color.withValues(alpha: 0.4),
                  size: 22,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: enabled ? color : color.withValues(alpha: 0.45),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    height: 1.35,
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
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Padding(
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
                    color: onTap != null
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    height: 1.5,
                    decoration: onTap != null
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor:
                        AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: AppColors.textLight,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: child),
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
