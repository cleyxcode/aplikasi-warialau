import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';

/// Widget empty state reusable dengan animasi Lottie.
class EmptyView extends StatelessWidget {
  final String message;
  final double lottieSize;

  const EmptyView({
    super.key,
    required this.message,
    this.lottieSize = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'lib/animations/empty.json',
            width: lottieSize,
            height: lottieSize,
            repeat: false,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
