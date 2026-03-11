import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';

class RiwayatPendaftaranScreen extends StatefulWidget {
  const RiwayatPendaftaranScreen({super.key});

  @override
  State<RiwayatPendaftaranScreen> createState() =>
      _RiwayatPendaftaranScreenState();
}

class _RiwayatPendaftaranScreenState extends State<RiwayatPendaftaranScreen>
    with SingleTickerProviderStateMixin {
  bool _dokumenExpanded = false;
  bool _hasRegistration = false;
  bool _isLoading = true;
  Map<String, dynamic>? _registration;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);
    try {
      final resp = await ApiService.instance.get('/pendaftaran/riwayat');
      final list = resp.data as List;
      setState(() {
        _isLoading = false;
        if (list.isNotEmpty) {
          _hasRegistration = true;
          _registration = list.first as Map<String, dynamic>;
        } else {
          _hasRegistration = false;
        }
      });
      _fadeCtrl.forward();
    } on DioException {
      setState(() { _isLoading = false; _hasRegistration = false; });
      _fadeCtrl.forward();
    }
  }

  static String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) { return raw; }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          if (!_hasRegistration)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBadge(),
                        const SizedBox(height: 20),
                        _buildTimeline(),
                        const SizedBox(height: 20),
                        _buildDetailCard(),
                        const SizedBox(height: 16),
                        _buildDokumenCard(),
                        const SizedBox(height: 24),
                        _buildContactFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F3B61), Color(0xFF0C1E36)],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circle top-right
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.07),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Pendaftaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tahun Ajaran 2024/2025',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        collapseMode: CollapseMode.pin,
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('lib/animations/empty.json',
              width: 180, height: 180, repeat: true),
          const SizedBox(height: 16),
          Text(
            'Belum ada pendaftaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda belum mengajukan pendaftaran siswa baru.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Badge ────────────────────────────────────────────────────────────

  Widget _buildStatusBadge() {
    final status = _registration?['status'] as String? ?? 'pending';
    final cfg = _statusConfig(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cfg.bgLight, cfg.bgDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: cfg.color.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: cfg.color.withValues(alpha: 0.15)),
            child: Icon(cfg.icon, color: cfg.color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cfg.label, style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: cfg.color)),
                const SizedBox(height: 4),
                Text(cfg.sub, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: cfg.color.withValues(alpha: 0.8), height: 1.4)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: cfg.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cfg.color.withValues(alpha: 0.4)),
            ),
            child: Text(cfg.chip, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: cfg.color)),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case 'diterima':
        return _StatusConfig(
          color: AppColors.success, icon: Icons.check_circle_rounded,
          label: 'Diterima', sub: 'Selamat! Pendaftaran Anda telah diterima',
          chip: 'Diterima', bgLight: const Color(0xFFDCFCE7), bgDark: const Color(0xFFF0FDF4),
        );
      case 'ditolak':
        return _StatusConfig(
          color: AppColors.danger, icon: Icons.cancel_rounded,
          label: 'Ditolak', sub: 'Maaf, pendaftaran Anda tidak dapat diproses',
          chip: 'Ditolak', bgLight: const Color(0xFFFEE2E2), bgDark: const Color(0xFFFFF1F2),
        );
      default:
        return _StatusConfig(
          color: const Color(0xFFD97706), icon: Icons.hourglass_top_rounded,
          label: 'Sedang Ditinjau', sub: 'Berkas sedang diproses oleh tim sekolah',
          chip: 'Proses', bgLight: const Color(0xFFFEF9C3), bgDark: const Color(0xFFFFF7ED),
        );
    }
  }

  // ── Timeline ────────────────────────────────────────────────────────────────

  Widget _buildTimeline() {
    final status = _registration?['status'] as String? ?? 'pending';
    final tglDaftar = _fmtDate(_registration?['created_at'] as String?);
    final isDiterima = status == 'diterima';
    final isDitolak = status == 'ditolak';
    final isDone = isDiterima || isDitolak;

    final steps = [
      _TimelineStep(
        icon: Icons.send_rounded,
        label: 'Formulir Dikirim',
        sub: tglDaftar,
        done: true,
      ),
      _TimelineStep(
        icon: Icons.find_in_page_rounded,
        label: 'Sedang Ditinjau',
        sub: isDone ? 'Selesai ditinjau' : 'Tim sedang memverifikasi',
        done: isDone,
        active: !isDone,
      ),
      _TimelineStep(
        icon: isDiterima ? Icons.how_to_reg_rounded : isDitolak ? Icons.cancel_rounded : Icons.how_to_reg_rounded,
        label: 'Keputusan',
        sub: isDiterima ? 'Diterima' : isDitolak ? 'Ditolak' : 'Menunggu hasil tinjauan',
        done: isDone,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progres Pendaftaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final s = steps[i];
            final isLast = i == steps.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dot + line
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.done
                              ? AppColors.success
                              : s.active
                                  ? AppColors.gold
                                  : AppColors.divider,
                          boxShadow: s.active
                              ? [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          s.done ? Icons.check_rounded : s.icon,
                          color: s.done || s.active
                              ? AppColors.white
                              : AppColors.textLight,
                          size: 18,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: s.done
                                ? AppColors.success.withValues(alpha: 0.3)
                                : AppColors.divider,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Text
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0 : 20,
                        top: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: s.active || s.done
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: s.active
                                  ? AppColors.primary
                                  : s.done
                                      ? AppColors.success
                                      : AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.sub,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Detail Card ─────────────────────────────────────────────────────────────

  Widget _buildDetailCard() {
    final r = _registration ?? {};
    final info = r['info_pendaftaran'] as Map? ?? {};
    final rows = [
      ['Nama Anak', r['nama_anak'] as String? ?? '-'],
      ['Tahun Ajaran', info['tahun_ajaran'] as String? ?? '-'],
      ['Tanggal Daftar', _fmtDate(r['created_at'] as String?)],
      ['No. Registrasi', '#SD-${r['id'] ?? '-'}'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Informasi Pendaftaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Column(
              children: List.generate(rows.length, (i) {
                final isLast = i == rows.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            rows[i][0],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            rows[i][1],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                          height: 1, thickness: 1, color: AppColors.divider),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dokumen Card ─────────────────────────────────────────────────────────────

  Widget _buildDokumenCard() {
    final docs = [
      _DokumenItem(
        icon: Icons.family_restroom_rounded,
        name: 'Kartu Keluarga (KK)',
        status: 'Terverifikasi',
        verified: true,
      ),
      _DokumenItem(
        icon: Icons.badge_rounded,
        name: 'Akta Kelahiran',
        status: 'Terverifikasi',
        verified: true,
      ),
      _DokumenItem(
        icon: Icons.photo_camera_rounded,
        name: 'Pas Foto 3x4',
        status: 'Menunggu',
        verified: false,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Header (tap to expand)
          GestureDetector(
            onTap: () =>
                setState(() => _dokumenExpanded = !_dokumenExpanded),
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded,
                      color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dokumen Pendaftaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _dokumenExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: docs
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildDokumenItem(d),
                        ))
                    .toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _dokumenExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }

  Widget _buildDokumenItem(_DokumenItem d) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(d.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              d.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: d.verified
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  d.verified
                      ? Icons.check_circle_rounded
                      : Icons.schedule_rounded,
                  size: 12,
                  color: d.verified ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  d.status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color:
                        d.verified ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact Footer ───────────────────────────────────────────────────────────

  Widget _buildContactFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.headset_mic_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh bantuan?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hubungi Admin Sekolah untuk informasi lebih lanjut.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
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

// ── Data models ──────────────────────────────────────────────────────────────

class _StatusConfig {
  final Color color;
  final IconData icon;
  final String label;
  final String sub;
  final String chip;
  final Color bgLight;
  final Color bgDark;

  const _StatusConfig({
    required this.color,
    required this.icon,
    required this.label,
    required this.sub,
    required this.chip,
    required this.bgLight,
    required this.bgDark,
  });
}

class _TimelineStep {
  final IconData icon;
  final String label;
  final String sub;
  final bool done;
  final bool active;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.sub,
    this.done = false,
    this.active = false,
  });
}

class _DokumenItem {
  final IconData icon;
  final String name;
  final String status;
  final bool verified;

  const _DokumenItem({
    required this.icon,
    required this.name,
    required this.status,
    required this.verified,
  });
}
