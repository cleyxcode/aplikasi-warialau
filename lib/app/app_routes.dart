import 'package:flutter/material.dart';
import '../core/utils/app_transitions.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/shell/main_navigation.dart';
import '../features/notifikasi/notifikasi_screen.dart';
import '../features/berita/detail_berita_loader_screen.dart';
import '../features/pendaftaran/detail_pendaftaran_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const notifikasi = '/notifikasi';
  static const detailBerita = '/detail-berita';
  static const detailPendaftaran = '/detail-pendaftaran';

  static Route<dynamic> generate(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case onboarding:
        page = const OnboardingScreen();
      case login:
        page = const LoginScreen();
      case register:
        page = const RegisterScreen();
      case forgotPassword:
        page = const ForgotPasswordScreen();
      case otp:
        page = const OtpScreen();
      case resetPassword:
        page = const ResetPasswordScreen();
      case home:
        page = const MainNavigation();
      case notifikasi:
        page = const NotifikasiScreen();
      case detailBerita:
        final id = _asInt(settings.arguments);
        page = id == null
            ? const NotifikasiScreen()
            : DetailBeritaLoaderScreen(beritaId: id);
      case detailPendaftaran:
        final id = _asInt(settings.arguments);
        page = id == null
            ? const NotifikasiScreen()
            : DetailPendaftaranScreen(pendaftaranId: id);
      default:
        page = const SplashScreen();
    }

    if (settings.name == splash) {
      return MaterialPageRoute(builder: (_) => page, settings: settings);
    }
    return AppRoute(page: page, settings: settings);
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return int.tryParse(value?.toString() ?? '');
  }
}
