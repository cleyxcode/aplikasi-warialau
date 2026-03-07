# CLAUDE.md — Flutter Mobile App SD Negeri Warialau
# Oleh: Bredcly Fransiscus Tuhuleruw (12155201220021)
# UKIM Ambon — 2026

---

## 📌 IDENTITAS PROJECT

- **Project:** mobile_apps_sd
- **Framework:** Flutter (Android only)
- **Font:** Plus Jakarta Sans (google_fonts)
- **Warna:** Deep Blue #1F3B61 + Gold #D4AF37

---

## 🚨 ATURAN WAJIB

1. Semua warna WAJIB dari AppColors
2. Font WAJIB Plus Jakarta Sans
3. UI WAJIB mirip persis dengan desain HTML yang sudah ada
4. Kerjakan BERURUTAN sesuai urutan di bawah

---

## 🚀 URUTAN PENGERJAAN

1. Setup pubspec.yaml (tambah package)
2. Buat AppColors, AppFonts, AppRoutes
3. Buat SplashScreen
4. Buat OnboardingScreen (3 slides)
5. Buat LoginScreen
6. Buat RegisterScreen
7. Buat ForgotPasswordScreen
8. Buat OtpScreen
9. Buat MainNavigation (bottom navbar)
10. Buat HomeScreen
11. Buat halaman lainnya

---

## 📦 PUBSPEC.YAML

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.0.0
  smooth_page_indicator: ^1.1.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  carousel_slider: ^4.2.0
  dio: ^5.4.0
  shared_preferences: ^2.2.0
  provider: ^6.1.0
  intl: ^0.19.0
```

---

## 🎨 AppColors

```dart
// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1F3B61);
  static const Color gold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color backgroundDark = Color(0xFF14181E);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);
}
```

---

## 📱 SCREEN 1 — SPLASH SCREEN

Referensi HTML: background Deep Blue, logo circle putih dengan glow, nama sekolah, progress bar gold animasi.

```dart
// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });

    // Navigate after done
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacementNamed(context, '/onboarding');
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Diagonal pattern overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  const Color(0xFF2D5A9B),
                ],
              ),
            ),
          ),

          // Decorative blobs
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with glow
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Logo circle
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAszatERUl6AuXqbahV1RqucUb0ZE49etzQvQlrjSWuW17luulHa2a6IRSE3JgZ6qWHa-JebTyBxxZgQkUKMrx4pk7tTGuw2iNk79m2xshQB89BcXN_hmLLp_L0Wif17jltORwtyVkHFZw_EXl7WpTNR3pHbBGW-kPMyNewVWc6rN2mrliG1riFIhYBT5rN-_zjLP8_CxMAvWozrjMDWAMN1XelgTZ5N52svBDps8YbThuDteUEjnZ_9hBj-nkE_GN7r9OTUVouwc6p',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.school,
                              size: 80,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Text
                FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text(
                        'SD Negeri Warialau',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kab. Kepulauan Aru, Maluku',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress bar bottom
          Positioned(
            bottom: 64,
            left: 32,
            right: 32,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MEMUAT...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '${(_progress.value * 100).toInt()}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progress.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📱 SCREEN 2 — ONBOARDING

Referensi HTML: 3 slide, background light, ilustrasi dengan gold blob, heading bold + gold accent, dot indicators, tombol arrow gold circle (slide 1&2), tombol "Mulai Sekarang" gold full width (slide 3).

```dart
// lib/features/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDWCNTZdDqWGWDKMnzbRrnz1LYzQ_6JaD-xgtH1qF0HIfhDuTPLskXVQIPQuzfZDmlkgRkt8Q3ODhjIhhvzKyYLnjNzwSRxWmDM8UeEWJRQ3o7vP0zoIo-cvNMzvjDpd0WIuRCqt2b9wmQJebNqmL2O_-25ro_zrQQpFx_Ng68B6-IG6yfHZoyB1La0ecjSCJmjXxQs6VF21efbNYzhIVNmjSF26kvUNhwaUYoXu-l9jyYiyCHemNivYMtj8vpGg5TSC1qrdBq-vDnj',
      titleNormal: 'Selamat Datang di ',
      titleGold: 'SD Negeri Warialau',
      titleNormalAfter: '',
      subtitle: 'Sistem informasi sekolah yang modern dan mudah digunakan',
    ),
    OnboardingData(
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAKcYlInvXwXbK6qVfb6bueulQlp1PsYoxtMjFKgb812UXq85-i_YLdkG1kCkyoYwYvlTL95W0nY4ZkS_Al1oY5yyn8fkz0sWtjy2ZmpDvJ8LkW7_WqVynOvDgS1StG-fMgJfe8gexw8hbIHJ818UHQAM8TAojr9srtLsv6mL3CvVpGwJydOPMnr-P6S8Pa5EPS6ZZHgCL6GfRkTR1WwWNLwI3CwZ2LnjPCTHgKGb90JOZyZyAZBJGAgvN0z2N5FnaiGRErBU6X_2aJ',
      titleNormal: 'Informasi ',
      titleGold: 'Terkini',
      titleNormalAfter: ' Sekolah',
      subtitle: 'Akses berita, pengumuman, dan galeri kegiatan sekolah kapan saja',
    ),
    OnboardingData(
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvZGbm19swgATyQG4i-esw5J9pQIumvpT37FHcEKD6O0b_sKK5Pt_dlNS66D3tQP2c-2HZY8_6XUwFoHbkQTjsHbAVIhblINldspyjM5-QIrdPQFrhAZkbTzkc1hhVPHJKHK2bU0mbGfeY8sLWyGPnQkZECbPDZVjNBk2SaxxJDh-70jthL2GPNa9YnO-P0G_WOdKS21FgSTiqzxY6nYHwMQxR1-CyQN3Y7qJ8rrTdx7wXTduUx99-8yU78Y2jdRsEChZ5YtjHMy3g',
      titleNormal: 'Daftar ',
      titleGold: 'Putra-Putri',
      titleNormalAfter: ' Anda',
      subtitle: 'Isi formulir pendaftaran siswa baru secara online dengan mudah dan cepat.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _getStarted() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: _currentPage > 0
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (_currentPage == 1)
                    Text(
                      'SD Negeri Warialau',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  GestureDetector(
                    onTap: _skip,
                    child: Text(
                      'Lewati',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Illustration
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Gold blob background
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold.withOpacity(0.12),
                                ),
                              ),
                              // Image
                              Image.network(
                                page.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.school,
                                  size: 120,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Text
                        Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                                children: [
                                  TextSpan(text: page.titleNormal),
                                  TextSpan(
                                    text: page.titleGold,
                                    style: const TextStyle(color: AppColors.gold),
                                  ),
                                  TextSpan(text: page.titleNormalAfter),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: _currentPage == index
                              ? AppColors.gold
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Button
                  if (_currentPage < _pages.length - 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _getStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.gold.withOpacity(0.4),
                        ),
                        child: Text(
                          'Mulai Sekarang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

class OnboardingData {
  final String imageUrl;
  final String titleNormal;
  final String titleGold;
  final String titleNormalAfter;
  final String subtitle;

  OnboardingData({
    required this.imageUrl,
    required this.titleNormal,
    required this.titleGold,
    required this.titleNormalAfter,
    required this.subtitle,
  });
}
```

---

## 📁 STRUKTUR FOLDER

```
lib/
├── main.dart
├── core/
│   └── constants/
│       └── app_colors.dart
├── features/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── otp_screen.dart
│   ├── main_navigation/
│   │   └── main_navigation.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── berita/
│   │   ├── berita_screen.dart
│   │   └── detail_berita_screen.dart
│   ├── galeri/
│   │   └── galeri_screen.dart
│   └── pendaftaran/
│       └── pendaftaran_screen.dart
```

---

## 📱 MAIN.DART

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

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
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const Placeholder(),
      },
    );
  }
}
```

---

## 📌 CATATAN

- Project: `~/project-flutter/mobile_apps_sd`
- Setelah splash & onboarding selesai, kirim HTML login untuk dikerjakan berikutnya
- Semua image URL pakai link dari Stitch yang sudah ada
- Ganti URL logo dengan asset lokal jika sudah ada file logo