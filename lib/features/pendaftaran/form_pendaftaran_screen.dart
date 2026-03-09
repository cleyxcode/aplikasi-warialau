import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/app_transitions.dart';
import 'riwayat_pendaftaran_screen.dart';

class FormPendaftaranScreen extends StatefulWidget {
  const FormPendaftaranScreen({super.key});

  @override
  State<FormPendaftaranScreen> createState() => _FormPendaftaranScreenState();
}

class _FormPendaftaranScreenState extends State<FormPendaftaranScreen> {
  int _step = 0;
  bool _agreed = false;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  late PageController _pageCtrl;

  // Step 1 controllers
  final _s1Key = GlobalKey<FormState>();
  final _namaAnakCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  DateTime? _tglLahir;
  String _jenisKelamin = 'Laki-laki';
  String _agama = 'Islam';
  final _anakKeCtrl = TextEditingController();
  final _asalSekolahCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _noKkCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  // Step 2 controllers
  final _s2Key = GlobalKey<FormState>();
  final _namaAyahCtrl = TextEditingController();
  final _pkrjAyahCtrl = TextEditingController();
  final _namaIbuCtrl = TextEditingController();
  final _pkrjIbuCtrl = TextEditingController();
  final _namaWaliCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _namaAnakCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _anakKeCtrl.dispose();
    _asalSekolahCtrl.dispose();
    _nikCtrl.dispose();
    _noKkCtrl.dispose();
    _alamatCtrl.dispose();
    _namaAyahCtrl.dispose();
    _pkrjAyahCtrl.dispose();
    _namaIbuCtrl.dispose();
    _pkrjIbuCtrl.dispose();
    _namaWaliCtrl.dispose();
    _noHpCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0) {
      if (!(_s1Key.currentState?.validate() ?? false)) return;
    } else if (_step == 1) {
      if (!(_s2Key.currentState?.validate() ?? false)) return;
    }
    setState(() => _step++);
    _pageCtrl.animateToPage(
      _step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap setujui pernyataan kebenaran data terlebih dahulu.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final tgl = _tglLahir != null
          ? '${_tglLahir!.year}-${_tglLahir!.month.toString().padLeft(2, '0')}-${_tglLahir!.day.toString().padLeft(2, '0')}'
          : '';
      await ApiService.instance.post('/pendaftaran', data: {
        'nama_anak': _namaAnakCtrl.text.trim(),
        'tempat_lahir': _tempatLahirCtrl.text.trim(),
        'tanggal_lahir': tgl,
        'jenis_kelamin': _jenisKelamin == 'Laki-laki' ? 'L' : 'P',
        'agama': _agama,
        if (_anakKeCtrl.text.isNotEmpty) 'anak_ke': int.tryParse(_anakKeCtrl.text),
        if (_asalSekolahCtrl.text.isNotEmpty) 'asal_sekolah': _asalSekolahCtrl.text.trim(),
        if (_nikCtrl.text.isNotEmpty) 'nik': _nikCtrl.text.trim(),
        if (_noKkCtrl.text.isNotEmpty) 'no_kk': _noKkCtrl.text.trim(),
        'alamat': _alamatCtrl.text.trim(),
        if (_namaAyahCtrl.text.isNotEmpty) 'nama_ayah': _namaAyahCtrl.text.trim(),
        if (_pkrjAyahCtrl.text.isNotEmpty) 'pekerjaan_ayah': _pkrjAyahCtrl.text.trim(),
        if (_namaIbuCtrl.text.isNotEmpty) 'nama_ibu': _namaIbuCtrl.text.trim(),
        if (_pkrjIbuCtrl.text.isNotEmpty) 'pekerjaan_ibu': _pkrjIbuCtrl.text.trim(),
        if (_namaWaliCtrl.text.isNotEmpty) 'nama_wali': _namaWaliCtrl.text.trim(),
        'no_hp': _noHpCtrl.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final msg = (e.response?.data as Map?)?['message'] as String? ??
          'Gagal mengirim pendaftaran. Periksa koneksi Anda.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: AppColors.danger,
      ));
      return;
    }
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      AppRoute(page: const RiwayatPendaftaranScreen()),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: AppColors.textLight,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.textLight, size: 20),
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value, {bool last = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value.isEmpty ? '-' : value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!last)
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
      ],
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    if (_showSuccess) {
      return Scaffold(
        backgroundColor: const Color(0xFF0C1E36),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'lib/animations/listberhasil.json',
                width: 280,
                height: 280,
                repeat: false,
              ),
              const SizedBox(height: 16),
              Text(
                'Pendaftaran Berhasil!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Data Anda sedang ditinjau oleh tim sekolah.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildAppBar(),
          _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
          _buildBottomBar(bottomPad),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.white,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: _prevStep,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Formulir Pendaftaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            Text(
              'SDN Warialau',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    const stepTitles = [
      'Langkah 1',
      'Langkah 2',
      'Langkah 3',
    ];
    const stepSubtitles = [
      'Data Anak',
      'Data Orang Tua',
      'Konfirmasi',
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (i) {
              final isDone = i < _step;
              final isCurrent = i == _step;

              Widget circle = Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.primary
                      : isCurrent
                          ? AppColors.gold
                          : AppColors.divider,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.white, size: 16)
                      : Text(
                          '${i + 1}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                ),
              );

              if (i < 2) {
                return Expanded(
                  child: Row(
                    children: [
                      circle,
                      Expanded(
                        child: Container(
                          height: 3,
                          width: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            color: i < _step
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return circle;
            }),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stepTitles[_step],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '\u2014 ${stepSubtitles[_step]}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 1 ────────────────────────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Form(
        key: _s1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
                'Data Anak', Icons.child_care_rounded, AppColors.primary),
            const SizedBox(height: 16),

            // Nama Lengkap
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _namaAnakCtrl,
                decoration: _fieldDecoration(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap anak',
                  prefixIcon: Icons.person_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
            ),

            // Tempat Lahir + Tanggal Lahir
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempatLahirCtrl,
                      decoration: _fieldDecoration(
                        label: 'Tempat Lahir',
                        hint: 'Kota lahir',
                        prefixIcon: Icons.location_city_rounded,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: AppColors.textPrimary),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Wajib diisi'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2017, 1, 1),
                          firstDate: DateTime(2010),
                          lastDate: DateTime(2020),
                          builder: (ctx, child) {
                            return Theme(
                              data: Theme.of(ctx).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => _tglLahir = picked);
                        }
                      },
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.textLight, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _tglLahir == null
                                    ? 'Tanggal Lahir'
                                    : '${_tglLahir!.day.toString().padLeft(2, '0')}/${_tglLahir!.month.toString().padLeft(2, '0')}/${_tglLahir!.year}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: _tglLahir == null
                                      ? AppColors.textLight
                                      : AppColors.textPrimary,
                                ),
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

            // Jenis Kelamin
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                initialValue: _jenisKelamin,
                decoration: _fieldDecoration(
                  label: 'Jenis Kelamin',
                  hint: '',
                  prefixIcon: Icons.wc_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                dropdownColor: AppColors.white,
                items: ['Laki-laki', 'Perempuan']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _jenisKelamin = v!),
              ),
            ),

            // Agama
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                initialValue: _agama,
                decoration: _fieldDecoration(
                  label: 'Agama',
                  hint: '',
                  prefixIcon: Icons.church_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                dropdownColor: AppColors.white,
                items: [
                  'Islam',
                  'Kristen',
                  'Katolik',
                  'Hindu',
                  'Buddha',
                  'Konghucu'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _agama = v!),
              ),
            ),

            // Anak Ke + Asal Sekolah
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _anakKeCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: _fieldDecoration(
                        label: 'Anak Ke-',
                        hint: 'Contoh: 1',
                        prefixIcon: Icons.tag_rounded,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: AppColors.textPrimary),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Wajib diisi'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _asalSekolahCtrl,
                      decoration: _fieldDecoration(
                        label: 'Asal TK/PAUD',
                        hint: 'Opsional',
                        prefixIcon: Icons.school_rounded,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // NIK
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _nikCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: _fieldDecoration(
                  label: 'NIK',
                  hint: '16 digit NIK anak',
                  prefixIcon: Icons.badge_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'NIK wajib diisi';
                  if (v.length != 16) return 'NIK harus 16 digit';
                  return null;
                },
              ),
            ),

            // No KK
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _noKkCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: _fieldDecoration(
                  label: 'No. KK',
                  hint: '16 digit nomor kartu keluarga',
                  prefixIcon: Icons.family_restroom_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'No. KK wajib diisi';
                  if (v.length != 16) return 'No. KK harus 16 digit';
                  return null;
                },
              ),
            ),

            // Alamat
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _alamatCtrl,
                maxLines: 3,
                decoration: _fieldDecoration(
                  label: 'Alamat',
                  hint: 'Masukkan alamat lengkap',
                  prefixIcon: Icons.home_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Alamat wajib diisi'
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2 ────────────────────────────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Form(
        key: _s2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
                'Data Ayah', Icons.person_rounded, AppColors.primary),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _namaAyahCtrl,
                decoration: _fieldDecoration(
                  label: 'Nama Ayah',
                  hint: 'Masukkan nama lengkap ayah',
                  prefixIcon: Icons.person_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama ayah wajib diisi'
                    : null,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _pkrjAyahCtrl,
                decoration: _fieldDecoration(
                  label: 'Pekerjaan Ayah',
                  hint: 'Contoh: Wiraswasta',
                  prefixIcon: Icons.work_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Pekerjaan ayah wajib diisi'
                    : null,
              ),
            ),

            _sectionHeader(
                'Data Ibu', Icons.person_rounded, AppColors.gold),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _namaIbuCtrl,
                decoration: _fieldDecoration(
                  label: 'Nama Ibu',
                  hint: 'Masukkan nama lengkap ibu',
                  prefixIcon: Icons.person_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama ibu wajib diisi'
                    : null,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _pkrjIbuCtrl,
                decoration: _fieldDecoration(
                  label: 'Pekerjaan Ibu',
                  hint: 'Contoh: Ibu Rumah Tangga',
                  prefixIcon: Icons.work_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Pekerjaan ibu wajib diisi'
                    : null,
              ),
            ),

            _sectionHeader(
                'Kontak & Wali', Icons.contact_phone_rounded, AppColors.primary),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _namaWaliCtrl,
                decoration: _fieldDecoration(
                  label: 'Nama Wali',
                  hint: 'Opsional',
                  prefixIcon: Icons.person_add_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _noHpCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _fieldDecoration(
                  label: 'No. HP',
                  hint: 'Nomor aktif yang bisa dihubungi',
                  prefixIcon: Icons.phone_rounded,
                ),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textPrimary),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'No. HP wajib diisi';
                  }
                  if (v.length < 10) return 'No. HP minimal 10 digit';
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3 ────────────────────────────────────────────────────────────────

  Widget _buildStep3() {
    final tglStr = _tglLahir == null
        ? '-'
        : '${_tglLahir!.day.toString().padLeft(2, '0')}/'
            '${_tglLahir!.month.toString().padLeft(2, '0')}/'
            '${_tglLahir!.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data Anak review card
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                left: BorderSide(color: AppColors.primary, width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Data Anak',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _step = 0);
                          _pageCtrl.animateToPage(0,
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeInOut);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_rounded,
                                  color: AppColors.gold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                      height: 1, thickness: 1, color: AppColors.divider),
                  _reviewRow('Nama Lengkap', _namaAnakCtrl.text),
                  _reviewRow(
                      'Tempat, Tgl Lahir',
                      '${_tempatLahirCtrl.text}, $tglStr'),
                  _reviewRow('Jenis Kelamin', _jenisKelamin),
                  _reviewRow('Agama', _agama),
                  _reviewRow('Anak Ke-', _anakKeCtrl.text),
                  _reviewRow('Asal TK/PAUD',
                      _asalSekolahCtrl.text.isEmpty ? '-' : _asalSekolahCtrl.text),
                  _reviewRow('NIK', _nikCtrl.text),
                  _reviewRow('No. KK', _noKkCtrl.text),
                  _reviewRow('Alamat', _alamatCtrl.text, last: true),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Data Orang Tua review card
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                left: BorderSide(color: AppColors.gold, width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Data Orang Tua',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _step = 1);
                          _pageCtrl.animateToPage(1,
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeInOut);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_rounded,
                                  color: AppColors.gold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                      height: 1, thickness: 1, color: AppColors.divider),
                  _reviewRow('Nama Ayah', _namaAyahCtrl.text),
                  _reviewRow('Pekerjaan Ayah', _pkrjAyahCtrl.text),
                  _reviewRow('Nama Ibu', _namaIbuCtrl.text),
                  _reviewRow('Pekerjaan Ibu', _pkrjIbuCtrl.text),
                  _reviewRow('Nama Wali',
                      _namaWaliCtrl.text.isEmpty ? '-' : _namaWaliCtrl.text),
                  _reviewRow('No. HP', _noHpCtrl.text, last: true),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dokumen card
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.description_rounded,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Dokumen Lampiran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDocItem(
                    icon: Icons.picture_as_pdf_rounded,
                    iconColor: AppColors.danger,
                    name: 'Kartu_Keluarga.pdf',
                    size: '1.2 MB',
                  ),
                  const SizedBox(height: 8),
                  _buildDocItem(
                    icon: Icons.image_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    name: 'Akte_Kelahiran.jpg',
                    size: '850 KB',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Declaration checkbox
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _agreed
                    ? AppColors.primary.withValues(alpha: 0.04)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _agreed
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: _agreed ? AppColors.gold : AppColors.inputBg,
                      border: Border.all(
                        color: _agreed ? AppColors.gold : AppColors.divider,
                      ),
                    ),
                    child: _agreed
                        ? const Icon(Icons.check_rounded,
                            color: AppColors.primary, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Saya menyatakan bahwa semua data yang saya isi adalah benar dan dapat dipertanggungjawabkan sesuai dengan dokumen aslinya.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem({
    required IconData icon,
    required Color iconColor,
    required String name,
    required String size,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  size,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(double bottomPad) {
    final isLastStep = _step == 2;
    final List<Color> gradientColors = isLastStep
        ? [AppColors.gold, const Color(0xFFE8C53A)]
        : [AppColors.primary, const Color(0xFF2D5A9B)];
    final Color labelColor =
        isLastStep ? AppColors.primary : AppColors.white;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isLastStep ? _submit : _nextStep,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: gradientColors),
              ),
              child: _isSubmitting
                  ? Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: labelColor,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? 'Kirim Pendaftaran' : 'Lanjut',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastStep
                              ? Icons.send_rounded
                              : Icons.arrow_forward_rounded,
                          color: labelColor,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          if (_step > 0) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _prevStep,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_rounded,
                      color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Kembali',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
