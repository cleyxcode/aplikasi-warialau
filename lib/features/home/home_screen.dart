import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
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

  static const _bannerImages = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD4s9jRwytGJd4Qlg3MneBhw8SPKopZ6Hrc8n7R-utsyQtiReT6-wRxDWchWrrmCM6RkgTi34mEm_Oqrdsc6CZiqTiKWDHG9Xr26iIgQe4I752XE9EAmnpzvzxGbapVz0yXpzdtQwcBXjT6Eduo0BjlUZHc4kqe2hUzHBRUWLlsnU9oD-GZ2BQVPzVCtGomdNiJv_LBfpdWwZ0uFUE7-szpb3ULBi3nYNZXX533ZutBqK_ZUlCryt7dP41hjM-1tRZ0k-uKOeb_Q9Bx',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBNYCK_1MClMGQNVHWHTfvL5OZO66bHGa5isIrkz-l0B0MdivNUnFGaX3O0jXkgV5-G9U2kREq6EqGMaczXjEChJhG6ezVqgjAp7OpExc4OzK02lp3bTx7e1vM6SmLYMTqV4POozTKTwm4Skd28_K5bNBwYEV3iqnazfl0PsvGWWSiHcOFUP9XkoWkxSwbWyNT_w70DdrFEZh_7H3lbWL_y-_FoxSvB-QaeDPknRVdetnK-A_PYw6xvtQEDxWFePpzx-gnNUgxLLofW',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAcgkc8MwKN7DcvPJa786E8fSCri8J2DOkY_FykLVyIdB7D3jRSmPgHD4JRLXLbreYgDxSjfgzvHimdEtw0Wb5FKZcomjEMNsYAslnKRvdhiJORDUXPp4ZkafyUs2XP9BLZYmNka16JTW-yzSLeJhv8GQMfEPMUsC9wtfMqc_cynjfqLdHOa_ceeY39uvx3akLz1KWL5fEfl60Zo_qejHQ_QuYq9UBrCWmATxrOgr01wg1Fs6YjJTHRQLUwG4HIRHUAYzYFjPUjOl5t',
  ];

  static const _beritaList = [
    _BeritaItem(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC1PqS3cEil3kyVA-HPjotC6DHemccf6KUv_3IC8hTm06sOREHqn5qJGcdp0EpG6UjT8w2tso8oq1eRWn-5D5-0gg2VtfIxB8q_iv4M15FMTS5Z-X63hKS0VhqQLJcP5R1WhpxJU84eBC-cm3WDaPIKXlsKYSOKrn2j1iTRANVu7BRTBmMsjAd7gEcKXOwwnDJeRm8UgCgiPS71MrTaK7KDzDXtnueoCY362Mv1WcrrO6CTs-CFCdyVwiFTxdHcWC8hubVtO-kDew7S',
      badge: 'PRESTASI',
      title: 'Juara 1 Lomba Lukis Tingkat Provinsi: Bakat Siswa SD Warialau',
      date: '12 Mei 2024',
    ),
    _BeritaItem(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA1XiMEZWTwUpS4csjpTeVGB9rqntmDqlD5V57F81smiZDYp7WQvVHw9Bn5e9SCwft3YJM1JDexsJZCj0IIR9j2BwmTQJrrJN_FIX83NRitNTHjisyM-6HoPTGdmlNui4D-8_wAGFKeqONqMdItRsLnp9lYY0AeBjUTqEazIff_-7ODQ1fG_QMhECoJZ0zGzXPhcIrJFHOY4sCTMSscS9Dzkbx73kg4eFp4cuN7dAOE9cMvgbpKfwOQ4UVSCq-i6ahqZVKekUZKaTfd',
      badge: 'KEGIATAN',
      title: 'Upacara Bendera Senin: Membangun Kedisiplinan Sejak Dini',
      date: '10 Mei 2024',
    ),
    _BeritaItem(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCmNW_0X-Hak6pv78v7kKiu7WFaoNfkTd2MfZQHwZ8FW2EUcRQ1mqW7OPngZVFrMTeOSLMurh0Nn_j2O9wFRCSe8mytV2rsrHJ63CAS99LU26S_VN2NKuaXzpgjzcjbui6OdVay7x7lekreg7_yfsSYWIbl9Kcu2ekJqNZtu7NNGgaWxZyeFzunKkVlygb-t-lCRCHpKh6o9COFj2TdYuUQeXu5ZfXRrAERkl5QGM2xeYDlvNCg8uC51_fOBWgyY8tWu0WihPRY5x19',
      badge: 'INFO',
      title: 'Pameran Sains Tahunan: Kreativitas Siswa dalam Dunia Ilmu Pengetahuan',
      date: '5 Mei 2024',
    ),
  ];

  static const _galeriImages = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAcgkc8MwKN7DcvPJa786E8fSCri8J2DOkY_FykLVyIdB7D3jRSmPgHD4JRLXLbreYgDxSjfgzvHimdEtw0Wb5FKZcomjEMNsYAslnKRvdhiJORDUXPp4ZkafyUs2XP9BLZYmNka16JTW-yzSLeJhv8GQMfEPMUsC9wtfMqc_cynjfqLdHOa_ceeY39uvx3akLz1KWL5fEfl60Zo_qejHQ_QuYq9UBrCWmATxrOgr01wg1Fs6YjJTHRQLUwG4HIRHUAYzYFjPUjOl5t',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDgoK4EdgBus2PNJsihLy1X4jN3tt9_s08w9XmAVV82WsmMqdq578PGsSOVFPx1eWB2VxIozDIEvYZVKRm0oejQvPQtJ5YAgcpN5vB4968il6Uej1N0SJBUJytCOV3TX6K3lGgXW2tv9NY7KxM3G7Sn_LTA9curgf48sc8eKoXnkpR36ioNSv2eI0fkYvlazzYkQwZYXCMLuvn2i8qziOaA3twdg1eAEauDfwypF7TX6aLxvQ8_h7utI5cvWRTiVq9mP8uHO3ggNKvV',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCmNW_0X-Hak6pv78v7kKiu7WFaoNfkTd2MfZQHwZ8FW2EUcRQ1mqW7OPngZVFrMTeOSLMurh0Nn_j2O9wFRCSe8mytV2rsrHJ63CAS99LU26S_VN2NKuaXzpgjzcjbui6OdVay7x7lekreg7_yfsSYWIbl9Kcu2ekJqNZtu7NNGgaWxZyeFzunKkVlygb-t-lCRCHpKh6o9COFj2TdYuUQeXu5ZfXRrAERkl5QGM2xeYDlvNCg8uC51_fOBWgyY8tWu0WihPRY5x19',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDWrefFolJ7Re2Ho2OXNlb-dtqNn9k0-mLTxDkNw2bHs4niaNKK8ZNHp6k4jQQWfO9N9Yi8YpPOyRgn-djqoK0LmeGu06vO7S59RYd30e9niOFcSV1vQolPgnJha2L-uwEUmUvH50Zo7KK3VmuCNmKsuBYn_BqTDNxIfbPqik2A1W5QkJu11MqltKlN81sPm6O3hSQZP1_7edAMkSQRwgChAndlHcROYHKJB4BT_wbLnnTswvDzEsCL74dXK3DIVf8_FKZ9uHRdl8JH',
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerCtrl.hasClients) return;
      final next = (_bannerIndex + 1) % _bannerImages.length;
      _bannerCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildPendaftaranCard(),
                ),
                const SizedBox(height: 24),
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
    final user = currentUser;
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
        ).then((_) => setState(() {})),
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
                child: Text(
                  user.initials,
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
                    'Halo, ${user.name.split(' ').first}! 👋',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    user.role,
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
                  currentUser.name.split(' ').take(2).join(' '),
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
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerCtrl,
            itemCount: _bannerImages.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: _bannerImages[index],
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
          children: List.generate(_bannerImages.length, (i) {
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
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _beritaList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _BeritaCard(item: _beritaList[i]),
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
                'Tahun Ajaran 2024/2025',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {},
                child: Container(
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Galeri List ───────────────────────────────────────────
  Widget _buildGaleriList() {
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _galeriImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: _galeriImages[i],
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
  final String imageUrl;
  final String badge;
  final String title;
  final String date;

  const _BeritaItem({
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
  };

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        _badgeColor[item.badge] ?? AppColors.gold;

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
