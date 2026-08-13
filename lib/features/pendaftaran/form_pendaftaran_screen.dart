import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/app_transitions.dart';
import 'riwayat_pendaftaran_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FormPendaftaranScreen extends StatefulWidget {
  const FormPendaftaranScreen({super.key});

  @override
  State<FormPendaftaranScreen> createState() => _FormPendaftaranScreenState();
}

class _FormPendaftaranScreenState extends State<FormPendaftaranScreen> {
  static const _maxFileBytes = 5 * 1024 * 1024;

  int _step = 0;
  bool _agreed = false;
  bool _isSubmitting = false;
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

  File? _dokumenKk;
  File? _dokumenAkta;
  File? _dokumenPasFoto;

  final _imagePicker = ImagePicker();

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
    if (_dokumenKk == null || _dokumenAkta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kartu Keluarga dan Akta Kelahiran wajib diunggah.',
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
      final formData = FormData.fromMap({
        'nama_anak': _namaAnakCtrl.text.trim(),
        'tempat_lahir': _tempatLahirCtrl.text.trim(),
        'tanggal_lahir': tgl,
        'jenis_kelamin': _jenisKelamin == 'Laki-laki' ? 'L' : 'P',
        'agama': _agama,
        if (_anakKeCtrl.text.isNotEmpty) 'anak_ke': _anakKeCtrl.text.trim(),
        if (_asalSekolahCtrl.text.isNotEmpty)
          'asal_sekolah': _asalSekolahCtrl.text.trim(),
        if (_nikCtrl.text.isNotEmpty) 'nik': _nikCtrl.text.trim(),
        if (_noKkCtrl.text.isNotEmpty) 'no_kk': _noKkCtrl.text.trim(),
        'alamat': _alamatCtrl.text.trim(),
        if (_namaAyahCtrl.text.isNotEmpty) 'nama_ayah': _namaAyahCtrl.text.trim(),
        if (_pkrjAyahCtrl.text.isNotEmpty)
          'pekerjaan_ayah': _pkrjAyahCtrl.text.trim(),
        if (_namaIbuCtrl.text.isNotEmpty) 'nama_ibu': _namaIbuCtrl.text.trim(),
        if (_pkrjIbuCtrl.text.isNotEmpty)
          'pekerjaan_ibu': _pkrjIbuCtrl.text.trim(),
        if (_namaWaliCtrl.text.isNotEmpty) 'nama_wali': _namaWaliCtrl.text.trim(),
        'no_hp': _noHpCtrl.text.trim(),
        'dokumen_kk': await MultipartFile.fromFile(
          _dokumenKk!.path,
          filename: _fileName(_dokumenKk!.path),
        ),
        'dokumen_akta': await MultipartFile.fromFile(
          _dokumenAkta!.path,
          filename: _fileName(_dokumenAkta!.path),
        ),
        if (_dokumenPasFoto != null)
          'dokumen_pas_foto': await MultipartFile.fromFile(
            _dokumenPasFoto!.path,
            filename: _fileName(_dokumenPasFoto!.path),
          ),
      });
      final response = await ApiService.instance.post('/pendaftaran', data: formData);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final body = response.data;
      String? nomor;
      String? wa;
      if (body is Map) {
        final pendaftaran = body['pendaftaran'];
        if (pendaftaran is Map) {
          nomor = pendaftaran['nomor_registrasi']?.toString();
        }
        wa = body['whatsapp_sekolah']?.toString();
      }
      _showSuccessDialog(
        nomorRegistrasi: nomor,
        whatsappUrl: wa,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final data = e.response?.data;
      String msg = 'Gagal mengirim pendaftaran. Periksa koneksi Anda.';
      if (data is Map) {
        msg = data['message']?.toString() ?? msg;
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            msg = first.first.toString();
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  void _showSuccessDialog({
    String? nomorRegistrasi,
    String? whatsappUrl,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'lib/animations/listberhasil.json',
                width: 180,
                height: 180,
                repeat: false,
              ),
              const SizedBox(height: 16),
              Text(
                'Pendaftaran Berhasil!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (nomorRegistrasi != null && nomorRegistrasi.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  nomorRegistrasi,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Data Anda sedang ditinjau oleh\ntim sekolah.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (whatsappUrl != null && whatsappUrl.isNotEmpty) ...[
                _SuccessBtn(
                  label: 'Hubungi Sekolah (WA)',
                  color: const Color(0xFF16A34A),
                  onTap: () async {
                    final uri = Uri.tryParse(whatsappUrl);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
              _SuccessBtn(
                label: 'Lihat Riwayat Pendaftaran',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    AppRoute(page: const RiwayatPendaftaranScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  String _fileName(String path) {
    final parts = path.split(Platform.pathSeparator);
    return parts.isNotEmpty ? parts.last : 'dokumen';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool _validateFileSize(File file) {
    final length = file.lengthSync();
    if (length > _maxFileBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ukuran file maksimal 5 MB.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _pickDokumenFile(void Function(File?) setFile) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    if (!_validateFileSize(file)) return;
    setState(() => setFile(file));
  }

  Future<void> _pickPasFoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (picked == null) return;
    final file = File(picked.path);
    if (!_validateFileSize(file)) return;
    setState(() => _dokumenPasFoto = file);
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: AppColors.textLight,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 10, right: 6),
        child: Icon(prefixIcon, color: AppColors.primary, size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 44),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.75),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Lengkapi data dengan benar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _formCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _choiceChipGroup({
    required String label,
    required List<String> options,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final selected = opt == value;
            return ChoiceChip(
              label: Text(opt),
              selected: selected,
              onSelected: (_) => onChanged(opt),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.inputBg,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : AppColors.divider,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            );
          }).toList(),
        ),
      ],
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF2A4F7A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: _prevStep,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Formulir Pendaftaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'SD Negeri Warialau · Langkah ${_step + 1}/3',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  '${((_step + 1) / 3 * 100).round()}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    const stepSubtitles = ['Data Anak', 'Orang Tua', 'Konfirmasi'];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (_step + 1) / 3,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(3, (i) {
              final isDone = i < _step;
              final isCurrent = i == _step;
              return Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone || isCurrent
                            ? AppColors.primary
                            : AppColors.inputBg,
                        border: Border.all(
                          color: isDone || isCurrent
                              ? AppColors.primary
                              : AppColors.divider,
                          width: 1.5,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : Text(
                                '${i + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isCurrent
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stepSubtitles[i],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              );
            }),
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
        child: _formCard(
          children: [
            _sectionHeader(
                'Data Anak', Icons.child_care_rounded, AppColors.primary),
            const SizedBox(height: 18),

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
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.primary, size: 20),
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

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _choiceChipGroup(
                label: 'Jenis Kelamin',
                options: const ['Laki-laki', 'Perempuan'],
                value: _jenisKelamin,
                onChanged: (v) => setState(() => _jenisKelamin = v),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _choiceChipGroup(
                label: 'Agama',
                options: const [
                  'Islam',
                  'Kristen',
                  'Katolik',
                  'Hindu',
                  'Buddha',
                  'Konghucu'
                ],
                value: _agama,
                onChanged: (v) => setState(() => _agama = v),
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
            TextFormField(
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
        child: _formCard(
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

            TextFormField(
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
                  _buildDocumentRow(
                    label: 'Kartu Keluarga',
                    required: true,
                    hint: 'PDF, JPG, atau PNG · maks. 5 MB',
                    file: _dokumenKk,
                    icon: Icons.picture_as_pdf_rounded,
                    iconColor: AppColors.danger,
                    onPick: () => _pickDokumenFile((f) => _dokumenKk = f),
                    onClear: () => setState(() => _dokumenKk = null),
                  ),
                  const SizedBox(height: 10),
                  _buildDocumentRow(
                    label: 'Akta Kelahiran',
                    required: true,
                    hint: 'PDF, JPG, atau PNG · maks. 5 MB',
                    file: _dokumenAkta,
                    icon: Icons.description_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    onPick: () => _pickDokumenFile((f) => _dokumenAkta = f),
                    onClear: () => setState(() => _dokumenAkta = null),
                  ),
                  const SizedBox(height: 10),
                  _buildDocumentRow(
                    label: 'Pas Foto',
                    required: false,
                    hint: 'Opsional · JPG/PNG · maks. 5 MB',
                    file: _dokumenPasFoto,
                    icon: Icons.image_rounded,
                    iconColor: AppColors.primary,
                    onPick: _pickPasFoto,
                    onClear: () => setState(() => _dokumenPasFoto = null),
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

  Widget _buildDocumentRow({
    required String label,
    required bool required,
    required String hint,
    required File? file,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    final hasFile = file != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasFile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
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
                        _fileName(file.path),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatFileSize(file.lengthSync()),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Hapus',
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: onPick,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.divider,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: iconColor.withValues(alpha: 0.85), size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hint,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(Icons.upload_file_rounded,
                      color: AppColors.primary, size: 22),
                ],
              ),
            ),
          ),
      ],
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

class _SuccessBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SuccessBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
