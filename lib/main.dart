import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/utils/app_transitions.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/main_navigation/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SD Negeri Warialau',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/onboarding':
            page = const OnboardingScreen();
          case '/login':
            page = const LoginScreen();
          case '/register':
            page = const RegisterScreen();
          case '/forgot-password':
            page = const ForgotPasswordScreen();
          case '/otp':
            page = const OtpScreen();
          case '/reset-password':
            page = const ResetPasswordScreen();
          case '/home':
            page = const MainNavigation();
          default:
            page = const SplashScreen();
        }
        // Splash uses no transition (initial route)
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        }
        return AppRoute(page: page, settings: settings);
      },
    );
  }
}
