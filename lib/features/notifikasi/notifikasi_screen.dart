import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import 'notifikasi_model.dart';
import 'notifikasi_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen>
    with SingleTickerProviderStateMixin {
  // State
  List<NotifikasiModel> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _filter = 'Semua';

  // Pagination
  int _currentPage = 1;
  bool _hasNextPage = false;

  // Animation
  late AnimationController _listCtrl;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scrollCtrl.addListener(_onScroll);
    _loadNotifikasi(refresh: true);
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Data Loading ──────────────────────────────────────────

  Future<void> _loadNotifikasi({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = 1;
      });
    }

    try {
      final result = await NotifikasiService.getNotifikasi(
        page: refresh ? 1 : _currentPage,
      );

      if (!mounted) return;
      setState(() {
        if (refresh) {
          _items = result.data;
        } else {
          _items.addAll(result.data);
        }
        _currentPage = result.currentPage + 1;
        _hasNextPage = result.hasNextPage;
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = false;
      });

      // Animasi list masuk
      _listCtrl.reset();
      _listCtrl.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        if (refresh) {
          _hasError = true;
          _errorMessage = NotifikasiService.errorMessage(e);
        }
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasNextPage) return;
    setState(() => _isLoadingMore = true);
    await _loadNotifikasi();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _markRead(NotifikasiModel notif) async {
    if (notif.dibaca) {
      _navigateByType(notif);
      return;
    }
    // Optimistic update
    setState(() {
      final idx = _items.indexWhere((n) => n.id == notif.id);
      if (idx != -1) _items[idx] = _items[idx].copyWith(dibaca: true);
    });

    try {
      await NotifikasiService.markRead(notif.id);
    } catch (_) {
      // Rollback jika gagal
      if (mounted) {
        setState(() {
          final idx = _items.indexWhere((n) => n.id == notif.id);
          if (idx != -1) _items[idx] = _items[idx].copyWith(dibaca: false);
        });
      }
    }

    _navigateByType(notif);
  }

  Future<void> _markAllRead() async {
    // Optimistic update
    setState(() {
      _items = _items.map((n) => n.copyWith(dibaca: true)).toList();
    });
    try {
      await NotifikasiService.markAllRead();
    } catch (_) {
      // Silent fail — refresh untuk sync
      await _loadNotifikasi(refresh: true);
    }
  }

  void _removeItem(int id) {
    setState(() => _items.removeWhere((n) => n.id == id));
  }

  void _navigateByType(NotifikasiModel notif) {
    if (notif.tipe == 'berita' && notif.referensiId != null) {
      Navigator.pushNamed(
        context,
        '/detail-berita',
        arguments: notif.referensiId,
      );
    } else if (notif.tipe == 'pendaftaran' && notif.referensiId != null) {
      Navigator.pushNamed(
        context,
        '/detail-pendaftaran',
        arguments: notif.referensiId,
      );
    }
  }

  // ── Computed ──────────────────────────────────────────────

  List<NotifikasiModel> get _filtered {
    if (_filter == 'Belum Dibaca') return _items.where((n) => !n.dibaca).toList();
    return _items;
  }

  int get _unreadCount => _items.where((n) => !n.dibaca).length;

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _loadNotifikasi(refresh: true),
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildFilterRow()),
            if (_isLoading)
              _buildShimmerList()
            else if (_hasError)
              SliverFillRemaining(child: _buildErrorState())
            else if (_filtered.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              ..._buildGroupedList(),
            if (_isLoadingMore)
              const SliverToBoxAdapter(child: _LoadingMoreIndicator()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifikasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (_unreadCount > 0 && !_isLoading)
            Text(
              '$_unreadCount belum dibaca',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      actions: [
        if (_unreadCount > 0 && !_isLoading)
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              'Tandai semua',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  // ── Filter Row ────────────────────────────────────────────

  Widget _buildFilterRow() {
    const filters = ['Semua', 'Belum Dibaca'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: filters.map((f) {
          final active = f == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.divider,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Text(
                      f,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.bold : FontWeight.w500,
                        color: active ? AppColors.white : AppColors.textSecondary,
                      ),
                    ),
                    if (f == 'Belum Dibaca' && _unreadCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.gold
                              : AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$_unreadCount',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: active ? AppColors.primary : AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Shimmer Loading ───────────────────────────────────────

  SliverList _buildShimmerList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => const _ShimmerNotifCard(),
        childCount: 6,
      ),
    );
  }

  // ── Grouped List ──────────────────────────────────────────

  List<Widget> _buildGroupedList() {
    final filtered = _filtered;
    final groups = ['Hari Ini', 'Kemarin', 'Lebih Lama'];
    final result = <Widget>[];

    for (final group in groups) {
      final groupItems = filtered.where((n) => n.group == group).toList();
      if (groupItems.isEmpty) continue;

      result.add(_buildGroupHeader(group));
      result.add(_buildGroup(groupItems));
    }

    return result;
  }

  SliverToBoxAdapter _buildGroupHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Divider(color: AppColors.divider, height: 1)),
          ],
        ),
      ),
    );
  }

  SliverList _buildGroup(List<NotifikasiModel> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) {
          final notif = items[i];
          final delay = (i * 0.08).clamp(0.0, 0.6);
          final end = (delay + 0.4).clamp(0.0, 1.0);
          final fade = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
                parent: _listCtrl,
                curve: Interval(delay, end, curve: Curves.easeOut)),
          );
          final slide = Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: _listCtrl,
              curve: Interval(delay, end, curve: Curves.easeOut)));

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: _NotifCard(
                item: notif,
                onTap: () => _markRead(notif),
                onDismiss: () => _removeItem(notif.id),
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'lib/animations/empty.json',
            width: 160,
            height: 160,
            repeat: true,
          ),
          const SizedBox(height: 18),
          Text(
            _filter == 'Belum Dibaca'
                ? 'Semua notifikasi sudah dibaca'
                : 'Belum ada notifikasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami akan memberitahu Anda\njika ada informasi terbaru.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State (Lottie 404) ──────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'lib/animations/404.json',
              width: 220,
              height: 220,
              repeat: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal Memuat Notifikasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadNotifikasi(refresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Card ──────────────────────────────────────────────────────────────

class _ShimmerNotifCard extends StatelessWidget {
  const _ShimmerNotifCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon placeholder
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Body line 1
                  Container(
                    height: 11,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Body line 2 (shorter)
                  Container(
                    height: 11,
                    width: MediaQuery.of(context).size.width * 0.45,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Badge + time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 18,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Container(
                        height: 11,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
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
    );
  }
}

// ── Load More Indicator ───────────────────────────────────────────────────────

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const _ShimmerNotifCard(),
          const _ShimmerNotifCard(),
        ],
      ),
    );
  }
}

// ── Notif Card ────────────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final NotifikasiModel item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifCard({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.danger, size: 24),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.dibaca
                ? AppColors.white
                : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.dibaca
                  ? AppColors.divider
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: item.dibaca ? 0.04 : 0.07),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon bubble
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.iconColor.withValues(alpha: 0.12),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.judul,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: item.dibaca
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!item.dibaca)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.pesan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Kategori badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.kategoriLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: item.iconColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.access_time_rounded,
                            size: 11, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Text(
                          _formatTime(item.createdAt),
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
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notifDay = DateTime(dt.year, dt.month, dt.day);

    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    if (notifDay == today) return timeStr;

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
