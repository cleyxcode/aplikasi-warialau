import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/app_transitions.dart';
import 'galeri_model.dart';
import 'galeri_viewer_screen.dart';

class GaleriScreen extends StatefulWidget {
  const GaleriScreen({super.key});

  @override
  State<GaleriScreen> createState() => _GaleriScreenState();
}

class _GaleriScreenState extends State<GaleriScreen>
    with SingleTickerProviderStateMixin {
  String _activeCategory = 'Semua';
  late AnimationController _gridCtrl;
  bool _isLoading = false;
  bool _hasError = false;
  List<GaleriItem> _galeriList = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _gridCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fetchGaleri(1);
  }

  Future<void> _fetchGaleri(int page) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }
    try {
      final resp = await ApiService.instance.get(
        '/galeri',
        queryParameters: {'per_page': 12, 'page': page},
      );
      final data = resp.data as Map<String, dynamic>;
      final items = (data['data'] as List)
          .map((e) => GaleriItem.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        if (page == 1) {
          _galeriList = items;
        } else {
          _galeriList = [..._galeriList, ...items];
        }
        _currentPage = data['current_page'] as int;
        _lastPage = data['last_page'] as int;
        _isLoading = false;
        _isLoadingMore = false;
      });
      if (page == 1) _gridCtrl.forward(from: 0);
    } on DioException {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        if (page == 1) _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _gridCtrl.dispose();
    super.dispose();
  }

  List<GaleriItem> get _filtered {
    if (_activeCategory == 'Semua') return _galeriList;
    return _galeriList.where((g) => g.category == _activeCategory).toList();
  }

  void _changeCategory(String cat) {
    if (cat == _activeCategory) return;
    setState(() => _activeCategory = cat);
    _gridCtrl
      ..reset()
      ..forward();
  }

  void _openViewer(int index, List<GaleriItem> items) {
    Navigator.push(
      context,
      AppRouteFade(
        page: GaleriViewerScreen(items: items, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    // ── Loading state: shimmer skeleton ──
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(0),
            SliverToBoxAdapter(child: _buildCategoriesShimmer()),
            SliverToBoxAdapter(child: _buildShimmerGrid()),
          ],
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(0),
            SliverFillRemaining(child: _buildErrorState()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(items.length),
          SliverToBoxAdapter(child: _buildCategories()),
          if (items.isNotEmpty) ...[
            // Featured first item (full-width)
            SliverToBoxAdapter(
              child: _AnimatedGridItem(
                index: 0,
                controller: _gridCtrl,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _FeaturedTile(
                    item: items.first,
                    onTap: () => _openViewer(0, items),
                  ),
                ),
              ),
            ),
            // 2-column grid for the rest
            if (items.length > 1)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final item = items[i + 1];
                    return _AnimatedGridItem(
                      index: i + 1,
                      controller: _gridCtrl,
                      child: _GridTile(
                        item: item,
                        onTap: () => _openViewer(i + 1, items),
                      ),
                    );
                  }, childCount: items.length - 1),
                ),
              ),
            if (_currentPage < _lastPage)
              SliverToBoxAdapter(child: _buildLoadMoreButton()),
          ] else
            SliverFillRemaining(child: _buildEmptyState()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────

  SliverAppBar _buildAppBar(int count) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'Galeri Kegiatan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            _isLoading ? '...' : '$count foto',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.grid_view_rounded, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Categories ────────────────────────────────────────────

  Widget _buildCategories() {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: galeriCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = galeriCategories[i];
                final active = cat == _activeCategory;
                return GestureDetector(
                  onTap: () => _changeCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.bold : FontWeight.w500,
                        color: active
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Shimmer: Category bar skeleton ───────────────────────

  Widget _buildCategoriesShimmer() {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final widths = [60.0, 80.0, 70.0, 90.0, 65.0];
                return _ShimmerWrap(
                  child: Container(
                    width: widths[i],
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Shimmer: Full grid skeleton ───────────────────────────

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Featured tile shimmer
          _ShimmerWrap(
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 2-column grid shimmer (6 items)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, __) => _ShimmerWrap(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                // Bottom info skeleton overlay
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Load More ─────────────────────────────────────────────

  Widget _buildLoadMoreButton() {
    if (_isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: _ShimmerWrap(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: OutlinedButton.icon(
        onPressed: () => _fetchGaleri(_currentPage + 1),
        icon: const Icon(Icons.expand_more_rounded),
        label: Text(
          'Muat Lebih Banyak',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── States ────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'lib/animations/404.json',
            width: 200,
            height: 200,
            repeat: true,
          ),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat galeri',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Periksa koneksi internet Anda',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _fetchGaleri(1),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              'Coba Lagi',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'lib/animations/empty.json',
            width: 180,
            height: 180,
            repeat: true,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada foto',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Foto kategori ini belum tersedia',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
        ],
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

// ── Animated Grid Item ────────────────────────────────────────────────────────

class _AnimatedGridItem extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedGridItem({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.07).clamp(0.0, 0.65);
    final end = (delay + 0.4).clamp(0.0, 1.0);

    final fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, end, curve: Curves.easeOut),
      ),
    );
    final scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, end, curve: Curves.easeOutBack),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(scale: scale, child: child),
    );
  }
}

// ── Featured Tile (Full Width) ────────────────────────────────────────────────

class _FeaturedTile extends StatefulWidget {
  final GaleriItem item;
  final VoidCallback onTap;

  const _FeaturedTile({required this.item, required this.onTap});

  @override
  State<_FeaturedTile> createState() => _FeaturedTileState();
}

class _FeaturedTileState extends State<_FeaturedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) {
        _hoverCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _hoverCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Hero(
          tag: 'galeri-${widget.item.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.item.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: const Color(0xFFE8EDF2),
                    highlightColor: const Color(0xFFF5F7FA),
                    child: Container(height: 200, color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: AppColors.inputBg,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.textLight,
                      size: 40,
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // Featured badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 11,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'UNGGULAN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoryChip(widget.item.category),
                        const SizedBox(height: 6),
                        Text(
                          widget.item.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.item.date,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(child: Material(color: Colors.transparent)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Grid Tile ─────────────────────────────────────────────────────────────────

class _GridTile extends StatefulWidget {
  final GaleriItem item;
  final VoidCallback onTap;

  const _GridTile({required this.item, required this.onTap});

  @override
  State<_GridTile> createState() => _GridTileState();
}

class _GridTileState extends State<_GridTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Hero(
          tag: 'galeri-${widget.item.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: const Color(0xFFE8EDF2),
                    highlightColor: const Color(0xFFF5F7FA),
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.inputBg,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                // Gradient
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.72),
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
                // Info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoryChip(widget.item.category, small: true),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.date,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
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

// ── Category Chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String category;
  final bool small;

  const _CategoryChip(this.category, {this.small = false});

  static const _colors = {
    'Seni Budaya': Color(0xFFEC4899),
    'Akademik': Color(0xFF3B82F6),
    'Olahraga': Color(0xFF22C55E),
    'Pramuka': Color(0xFFF59E0B),
    'Lainnya': Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[category] ?? AppColors.gold;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category,
        style: GoogleFonts.plusJakartaSans(
          fontSize: small ? 8 : 9,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
