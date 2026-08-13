import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'berita_service.dart';
import 'detail_berita_screen.dart';

/// Loads berita by id then shows [DetailBeritaScreen] (used by notification deep links).
class DetailBeritaLoaderScreen extends StatefulWidget {
  final int beritaId;

  const DetailBeritaLoaderScreen({super.key, required this.beritaId});

  @override
  State<DetailBeritaLoaderScreen> createState() =>
      _DetailBeritaLoaderScreenState();
}

class _DetailBeritaLoaderScreenState extends State<DetailBeritaLoaderScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final berita = await BeritaService.getDetailBerita(widget.beritaId);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DetailBeritaScreen(berita: berita)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = BeritaService.errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Berita',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator(color: AppColors.primary)
            : Padding(
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
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _load();
                      },
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
