import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import 'pendaftaran_status.dart';

/// Detail pendaftaran by id — used by notification deep links.
class DetailPendaftaranScreen extends StatefulWidget {
  final int pendaftaranId;

  const DetailPendaftaranScreen({super.key, required this.pendaftaranId});

  @override
  State<DetailPendaftaranScreen> createState() =>
      _DetailPendaftaranScreenState();
}

class _DetailPendaftaranScreenState extends State<DetailPendaftaranScreen> {
  bool _loading = true;
  bool _uploading = false;
  String? _error;
  Map<String, dynamic>? _item;
  File? _kk;
  File? _akta;
  File? _pasFoto;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp =
          await ApiService.instance.get('/pendaftaran/${widget.pendaftaranId}');
      if (!mounted) return;
      setState(() {
        _item = resp.data as Map<String, dynamic>;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = (e.response?.data as Map?)?['message']?.toString() ??
            'Gagal memuat detail pendaftaran.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat detail pendaftaran.';
      });
    }
  }

  Color _statusColor(String? status) => PendaftaranStatus.color(status);

  String _statusLabel(String? status) => PendaftaranStatus.label(status);

  String _fmt(dynamic raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw.toString());
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

  Future<File?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return File(path);
  }

  Future<void> _resubmit() async {
    if (_kk == null && _akta == null && _pasFoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu dokumen.')),
      );
      return;
    }
    setState(() => _uploading = true);
    try {
      final form = FormData.fromMap({
        if (_kk != null)
          'dokumen_kk': await MultipartFile.fromFile(
            _kk!.path,
            filename: _kk!.path.split('/').last,
          ),
        if (_akta != null)
          'dokumen_akta': await MultipartFile.fromFile(
            _akta!.path,
            filename: _akta!.path.split('/').last,
          ),
        if (_pasFoto != null)
          'dokumen_pas_foto': await MultipartFile.fromFile(
            _pasFoto!.path,
            filename: _pasFoto!.path.split('/').last,
          ),
      });
      await ApiService.instance
          .post('/pendaftaran/${widget.pendaftaranId}/dokumen', data: form);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dokumen dikirim ulang.')),
      );
      setState(() {
        _kk = null;
        _akta = null;
        _pasFoto = null;
      });
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data as Map?)?['message']?.toString() ??
          'Gagal mengirim dokumen.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/bukti-${widget.pendaftaranId}.pdf';
      await ApiService.instance.download(
        '/pendaftaran/${widget.pendaftaranId}/bukti-pdf',
        path,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF disimpan: $path')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengunduh bukti PDF.')),
      );
    }
  }

  Future<void> _openWa() async {
    final item = _item;
    if (item == null) return;
    final nomor = item['nomor_registrasi']?.toString() ?? '';
    final nama = item['nama_anak']?.toString() ?? '';
    // School WA comes from info endpoint; fallback generic message via profil later.
    try {
      final info = await ApiService.instance.get('/info-pendaftaran');
      final wa = (info.data as Map?)?['whatsapp_sekolah']?.toString();
      if (wa != null && wa.isNotEmpty) {
        final uri = Uri.parse(wa.contains('text=')
            ? wa
            : '$wa?text=${Uri.encodeComponent('Halo, saya ingin menanyakan PPDB${nomor.isNotEmpty ? ' No. $nomor' : ''} atas nama $nama.')}');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nomor WhatsApp sekolah belum tersedia.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Detail Pendaftaran',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _load, child: const Text('Coba lagi')),
                      ],
                    ),
                  ),
                )
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final item = _item!;
    final status = item['status']?.toString();
    final catatan = item['catatan_verifikasi']?.toString();
    final nomor = item['nomor_registrasi']?.toString();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _statusColor(status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _statusColor(status).withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_rounded, color: _statusColor(status)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusLabel(status),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: _statusColor(status),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              if (nomor != null && nomor.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  nomor,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _downloadPdf,
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Bukti PDF'),
            ),
            OutlinedButton.icon(
              onPressed: _openWa,
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: const Text('Hubungi WA'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _timeline(item),
        if (status == 'perlu_perbaikan') ...[
          const SizedBox(height: 16),
          _card('Unggah Ulang Dokumen', [
            if (catatan != null && catatan.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Catatan: $catatan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            _filePickRow('Kartu Keluarga', _kk, () async {
              final f = await _pickFile();
              if (f != null) setState(() => _kk = f);
            }),
            _filePickRow('Akta Kelahiran', _akta, () async {
              final f = await _pickFile();
              if (f != null) setState(() => _akta = f);
            }),
            _filePickRow('Pas Foto', _pasFoto, () async {
              final f = await _pickFile();
              if (f != null) setState(() => _pasFoto = f);
            }),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _uploading ? null : _resubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(_uploading ? 'Mengirim...' : 'Kirim Ulang'),
            ),
          ]),
        ],
        const SizedBox(height: 16),
        _card('Data Anak', [
          _row('Nama', item['nama_anak']),
          _row('Tempat Lahir', item['tempat_lahir']),
          _row('Tanggal Lahir', _fmt(item['tanggal_lahir'])),
          _row('Jenis Kelamin', item['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan'),
          _row('Agama', item['agama']),
          _row('No. HP', item['no_hp']),
        ]),
        if (catatan != null && catatan.isNotEmpty && status != 'perlu_perbaikan') ...[
          const SizedBox(height: 16),
          _card('Catatan Verifikasi', [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                catatan,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ]),
        ],
        const SizedBox(height: 16),
        _card('Dokumen', [
          _docRow('Kartu Keluarga', item['dokumen_kk_url'] ?? item['dokumen_kk']),
          _docRow('Akta Kelahiran', item['dokumen_akta_url'] ?? item['dokumen_akta']),
          _docRow('Pas Foto', item['dokumen_pas_foto_url'] ?? item['dokumen_pas_foto']),
          _row(
            'Kelengkapan',
            (item['dokumen_lengkap'] == true) ? 'Lengkap' : 'Belum lengkap',
          ),
        ]),
      ],
    );
  }

  Widget _filePickRow(String label, File? file, VoidCallback onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              file == null ? label : '$label: ${file.path.split('/').last}',
              style: GoogleFonts.plusJakartaSans(fontSize: 12),
            ),
          ),
          TextButton(onPressed: onPick, child: const Text('Pilih')),
        ],
      ),
    );
  }

  Widget _timeline(Map<String, dynamic> item) {
    final status = item['status']?.toString();
    final verifiedAt = item['verified_at'];
    final createdAt = item['created_at'];
    final catatan = item['catatan_verifikasi']?.toString();
    final hasCatatan = catatan != null && catatan.isNotEmpty;
    final isPerbaikan = status == 'perlu_perbaikan';
    final steps = <_TimelineStep>[
      _TimelineStep(
        label: 'Diajukan',
        desc: _fmtDateTime(createdAt),
        done: true,
      ),
      _TimelineStep(
        label: isPerbaikan ? 'Perlu Perbaikan' : 'Verifikasi',
        desc: status == 'pending'
            ? 'Sedang diproses sekolah'
            : isPerbaikan
                ? (hasCatatan ? catatan! : 'Unggah ulang dokumen')
                : _fmtDateTime(verifiedAt),
        done: status == 'diterima' || status == 'ditolak',
        active: status == 'pending' || isPerbaikan,
        danger: isPerbaikan,
      ),
      _TimelineStep(
        label: status == 'diterima'
            ? 'Diterima'
            : status == 'ditolak'
                ? 'Ditolak'
                : 'Hasil',
        desc: status == 'diterima'
            ? (hasCatatan ? catatan! : 'Selamat, pendaftaran diterima')
            : status == 'ditolak'
                ? (hasCatatan ? catatan! : 'Pendaftaran tidak diterima')
                : 'Menunggu pengumuman',
        done: status == 'diterima' || status == 'ditolak',
        danger: status == 'ditolak',
      ),
    ];

    return _card(
      'Alur Status',
      [
        const SizedBox(height: 4),
        ...List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;
          final color = step.danger
              ? AppColors.danger
              : step.done
                  ? const Color(0xFF16A34A)
                  : step.active
                      ? const Color(0xFFD97706)
                      : AppColors.textLight;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: step.done
                          ? Icon(
                              step.danger ? Icons.close : Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : step.active
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: step.done
                              ? const Color(0xFF16A34A).withValues(alpha: 0.35)
                              : AppColors.divider,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.desc,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
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
    );
  }

  String _fmtDateTime(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '—';
    try {
      return DateFormat('d MMM yyyy, HH:mm').format(DateTime.parse(raw.toString()));
    } catch (_) {
      return raw.toString();
    }
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              (value == null || value.toString().isEmpty) ? '—' : value.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docRow(String label, dynamic value) {
    final has = value != null && value.toString().isNotEmpty;
    return _row(label, has ? 'Tersedia' : '—');
  }
}

class _TimelineStep {
  final String label;
  final String desc;
  final bool done;
  final bool active;
  final bool danger;

  const _TimelineStep({
    required this.label,
    required this.desc,
    this.done = false,
    this.active = false,
    this.danger = false,
  });
}
