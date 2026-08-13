import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/app_colors.dart';

/// Peta sekolah dari data admin (latitude/longitude / maps_url).
class SchoolMapCard extends StatefulWidget {
  final String? latitude;
  final String? longitude;
  final String? mapsUrl;
  final String? mapsEmbed;
  final String title;
  final double height;

  const SchoolMapCard({
    super.key,
    this.latitude,
    this.longitude,
    this.mapsUrl,
    this.mapsEmbed,
    this.title = 'Lokasi Sekolah',
    this.height = 200,
  });

  @override
  State<SchoolMapCard> createState() => _SchoolMapCardState();
}

class _SchoolMapCardState extends State<SchoolMapCard> {
  WebViewController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  @override
  void didUpdateWidget(covariant SchoolMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.mapsEmbed != widget.mapsEmbed) {
      _initMap();
    }
  }

  String? get _osmEmbedUrl {
    final lat = double.tryParse(widget.latitude ?? '');
    final lng = double.tryParse(widget.longitude ?? '');
    if (lat == null || lng == null) return null;
    const d = 0.012;
    return 'https://www.openstreetmap.org/export/embed.html'
        '?bbox=${lng - d}%2C${lat - d}%2C${lng + d}%2C${lat + d}'
        '&layer=mapnik&marker=$lat%2C$lng';
  }

  String? get _resolvedMapsUrl {
    if (widget.mapsUrl != null && widget.mapsUrl!.isNotEmpty) {
      return widget.mapsUrl;
    }
    final lat = widget.latitude;
    final lng = widget.longitude;
    if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
      return 'https://www.google.com/maps?q=$lat,$lng';
    }
    return null;
  }

  Future<void> _initMap() async {
    final url = _osmEmbedUrl;
    if (url == null) {
      setState(() {
        _failed = true;
        _ready = false;
      });
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFE8EEF7))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _ready = true);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _failed = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      _controller = controller;
      _failed = false;
      _ready = false;
    });
  }

  Future<void> _openExternal() async {
    final url = _resolvedMapsUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (_controller != null && !_failed)
                WebViewWidget(controller: _controller!),
              if (!_ready && !_failed)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              if (_failed)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_rounded,
                          size: 40,
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (widget.latitude != null && widget.longitude != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${widget.latitude}, ${widget.longitude}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        widget.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_resolvedMapsUrl != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openExternal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                'Buka di Google Maps',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
