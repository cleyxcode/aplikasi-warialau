import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _filter = 'Semua';
  late List<_NotifItem> _items;
  late AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    _items = List.from(_dummyNotifs);
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    _listCtrl.forward();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  List<_NotifItem> get _filtered {
    if (_filter == 'Semua') return _items;
    if (_filter == 'Belum Dibaca') return _items.where((n) => !n.isRead).toList();
    return _items;
  }

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final item in _items) {
        item.isRead = true;
      }
    });
  }

  void _markRead(int id) {
    setState(() {
      final idx = _items.indexWhere((n) => n.id == id);
      if (idx != -1) _items[idx].isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Notifikasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        body: Center(
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
                'Memuat Notifikasi...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filtered;
    final today = filtered.where((n) => n.group == 'Hari Ini').toList();
    final yesterday = filtered.where((n) => n.group == 'Kemarin').toList();
    final older = filtered.where((n) => n.group == 'Minggu Ini').toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildFilterRow()),
          if (filtered.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else ...[
            if (today.isNotEmpty) ...[
              _buildGroupHeader('Hari Ini'),
              _buildGroup(today),
            ],
            if (yesterday.isNotEmpty) ...[
              _buildGroupHeader('Kemarin'),
              _buildGroup(yesterday),
            ],
            if (older.isNotEmpty) ...[
              _buildGroupHeader('Minggu Ini'),
              _buildGroup(older),
            ],
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────
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
          if (_unreadCount > 0)
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
        if (_unreadCount > 0)
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

  // ── Filter Row ───────────────────────────────────────────
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
                          )
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
                        color:
                            active ? AppColors.white : AppColors.textSecondary,
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
                            color:
                                active ? AppColors.primary : AppColors.gold,
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
            const Expanded(
                child: Divider(color: AppColors.divider, height: 1)),
          ],
        ),
      ),
    );
  }

  SliverList _buildGroup(List<_NotifItem> items) {
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
                onTap: () => _markRead(notif.id),
                onDismiss: () {
                  setState(() => _items.removeWhere((n) => n.id == notif.id));
                },
              ),
            ),
          );
        },
        childCount: items.length,
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
}

// ── Notif Card ────────────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
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
            color: item.isRead
                ? AppColors.white
                : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead
                  ? AppColors.divider
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: item.isRead ? 0.04 : 0.07),
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
                  color: item.color.withValues(alpha: 0.12),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
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
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!item.isRead)
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
                      item.body,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: item.color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.access_time_rounded,
                            size: 11, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Text(
                          item.time,
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
}

// ── Data Model ────────────────────────────────────────────────────────────────

class _NotifItem {
  final int id;
  final String title;
  final String body;
  final String category;
  final String time;
  final String group;
  final IconData icon;
  final Color color;
  bool isRead;

  _NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.time,
    required this.group,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

final _dummyNotifs = <_NotifItem>[
  _NotifItem(
    id: 1,
    title: 'Pendaftaran Siswa Baru Dibuka!',
    body: 'PPDB Tahun Ajaran 2024/2025 resmi dibuka mulai hari ini hingga 30 Juni 2024.',
    category: 'Pendaftaran',
    time: '09:15',
    group: 'Hari Ini',
    icon: Icons.how_to_reg_rounded,
    color: AppColors.gold,
    isRead: false,
  ),
  _NotifItem(
    id: 2,
    title: 'Berita Terbaru: Juara 1 Lomba Lukis',
    body: 'Siswa SD Negeri Warialau meraih Juara 1 dalam Lomba Lukis Tingkat Provinsi Maluku.',
    category: 'Berita',
    time: '07:30',
    group: 'Hari Ini',
    icon: Icons.newspaper_rounded,
    color: AppColors.primary,
    isRead: false,
  ),
  _NotifItem(
    id: 3,
    title: 'Pengumuman Jadwal Ujian',
    body: 'Ujian Akhir Semester (UAS) akan dilaksanakan mulai tanggal 10 s.d 15 Juni 2024.',
    category: 'Pengumuman',
    time: '14:00',
    group: 'Kemarin',
    icon: Icons.campaign_rounded,
    color: const Color(0xFF3B82F6),
    isRead: false,
  ),
  _NotifItem(
    id: 4,
    title: 'Galeri Kegiatan Diperbarui',
    body: 'Foto kegiatan Pentas Seni HUT Sekolah telah ditambahkan ke galeri.',
    category: 'Galeri',
    time: '10:22',
    group: 'Kemarin',
    icon: Icons.photo_library_rounded,
    color: const Color(0xFFEC4899),
    isRead: true,
  ),
  _NotifItem(
    id: 5,
    title: 'Libur Hari Raya Waisak',
    body: 'Sekolah diliburkan pada tanggal 23 Mei 2024 dalam rangka Hari Raya Waisak.',
    category: 'Pengumuman',
    time: '08:00',
    group: 'Minggu Ini',
    icon: Icons.event_rounded,
    color: const Color(0xFF22C55E),
    isRead: true,
  ),
  _NotifItem(
    id: 6,
    title: 'Pengumuman Kelulusan Kelas VI',
    body: 'Seluruh siswa kelas VI dinyatakan LULUS 100%. Selamat kepada para siswa!',
    category: 'Pengumuman',
    time: '13:00',
    group: 'Minggu Ini',
    icon: Icons.school_rounded,
    color: AppColors.gold,
    isRead: true,
  ),
  _NotifItem(
    id: 7,
    title: 'Rapat Orang Tua Wali Murid',
    body: 'Rapat wali murid dijadwalkan pada Sabtu, 1 Juni 2024 pukul 09.00 WIT di aula sekolah.',
    category: 'Kegiatan',
    time: '11:30',
    group: 'Minggu Ini',
    icon: Icons.groups_rounded,
    color: const Color(0xFF8B5CF6),
    isRead: true,
  ),
];
