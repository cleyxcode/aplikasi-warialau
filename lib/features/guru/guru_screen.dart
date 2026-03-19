import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/empty_view.dart';
import 'guru_model.dart';
import 'guru_service.dart';

class GuruScreen extends StatefulWidget {
  const GuruScreen({super.key});

  @override
  State<GuruScreen> createState() => _GuruScreenState();
}

class _GuruScreenState extends State<GuruScreen> {
  List<GuruModel> _allGuru = [];
  List<GuruModel> _filtered = [];
  bool _isLoading = true;
  String? _error;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGuru();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchGuru() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await GuruService.getGuru();
      if (!mounted) return;
      setState(() {
        _allGuru = data;
        _filtered = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = GuruService.errorMessage(e);
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allGuru.where((g) {
        return g.nama.toLowerCase().contains(q) ||
            (g.mataPelajaran?.toLowerCase().contains(q) ?? false) ||
            g.jabatan.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + Title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Guru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'SD NEGERI WARIALAU',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Cari nama atau mata pelajaran...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textLight,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildShimmer();
    if (_error != null) return _buildError();
    if (_filtered.isEmpty) return _buildEmpty();
    return _buildList();
  }

  // ── Shimmer loading ──────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: 86,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 13, width: 140, color: Colors.white),
                    const SizedBox(height: 7),
                    Container(
                        height: 11, width: 100, color: Colors.white),
                    const SizedBox(height: 7),
                    Container(
                        height: 18, width: 80, color: Colors.white,
                        margin: EdgeInsets.zero),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error state ──────────────────────────────────────────
  Widget _buildError() {
    return ErrorView(
      message: _error ?? 'Terjadi kesalahan',
      onRetry: _fetchGuru,
    );
  }

  // ── Empty state ──────────────────────────────────────────
  Widget _buildEmpty() {
    return const EmptyView(message: 'Guru tidak ditemukan');
  }

  // ── List ─────────────────────────────────────────────────
  Widget _buildList() {
    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: _fetchGuru,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _GuruCard(guru: _filtered[i]),
      ),
    );
  }
}

// ── Guru Card ─────────────────────────────────────────────────────────────────

class _GuruCard extends StatelessWidget {
  final GuruModel guru;
  const _GuruCard({required this.guru});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              _buildAvatar(),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: guru.isAktif
                        ? AppColors.success
                        : AppColors.textLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        guru.nama,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      guru.isAktif ? 'Aktif' : 'Non-Aktif',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: guru.isAktif
                            ? AppColors.success
                            : AppColors.textLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  guru.jabatan,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (guru.mataPelajaran != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      guru.mataPelajaran!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (guru.foto != null && guru.foto!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: guru.fotoUrl,
        imageBuilder: (_, img) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: img, fit: BoxFit.cover),
          ),
        ),
        placeholder: (_, __) => _avatarPlaceholder(),
        errorWidget: (_, __, ___) => _avatarInitials(),
      );
    }
    return _avatarInitials();
  }

  Widget _avatarPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _avatarInitials() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF2D5A9B)],
        ),
      ),
      child: Center(
        child: Text(
          guru.initials,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
