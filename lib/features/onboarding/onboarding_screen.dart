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

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDWCNTZdDqWGWDKMnzbRrnz1LYzQ_6JaD-xgtH1qF0HIfhDuTPLskXVQIPQuzfZDmlkgRkt8Q3ODhjIhhvzKyYLnjNzwSRxWmDM8UeEWJRQ3o7vP0zoIo-cvNMzvjDpd0WIuRCqt2b9wmQJebNqmL2O_-25ro_zrQQpFx_Ng68B6-IG6yfHZoyB1La0ecjSCJmjXxQs6VF21efbNYzhIVNmjSF26kvUNhwaUYoXu-l9jyYiyCHemNivYMtj8vpGg5TSC1qrdBq-vDnj',
      titleNormal: 'Selamat Datang di ',
      titleGold: 'SD Negeri Warialau',
      titleNormalAfter: '',
      subtitle: 'Sistem informasi sekolah yang modern dan mudah digunakan',
    ),
    _OnboardingData(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAKcYlInvXwXbK6qVfb6bueulQlp1PsYoxtMjFKgb812UXq85-i_YLdkG1kCkyoYwYvlTL95W0nY4ZkS_Al1oY5yyn8fkz0sWtjy2ZmpDvJ8LkW7_WqVynOvDgS1StG-fMgJfe8gexw8hbIHJ818UHQAM8TAojr9srtLsv6mL3CvVpGwJydOPMnr-P6S8Pa5EPS6ZZHgCL6GfRkTR1WwWNLwI3CwZ2LnjPCTHgKGb90JOZyZyAZBJGAgvN0z2N5FnaiGRErBU6X_2aJ',
      titleNormal: 'Informasi ',
      titleGold: 'Terkini',
      titleNormalAfter: ' Sekolah',
      subtitle:
          'Akses berita, pengumuman, dan galeri kegiatan sekolah kapan saja',
    ),
    _OnboardingData(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvZGbm19swgATyQG4i-esw5J9pQIumvpT37FHcEKD6O0b_sKK5Pt_dlNS66D3tQP2c-2HZY8_6XUwFoHbkQTjsHbAVIhblINldspyjM5-QIrdPQFrhAZkbTzkc1hhVPHJKHK2bU0mbGfeY8sLWyGPnQkZECbPDZVjNBk2SaxxJDh-70jthL2GPNa9YnO-P0G_WOdKS21FgSTiqzxY6nYHwMQxR1-CyQN3Y7qJ8rrTdx7wXTduUx99-8yU78Y2jdRsEChZ5YtjHMy3g',
      titleNormal: 'Daftar ',
      titleGold: 'Putra-Putri',
      titleNormalAfter: ' Anda',
      subtitle:
          'Isi formulir pendaftaran siswa baru secara online dengan mudah dan cepat.',
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

  void _skip() => Navigator.pushReplacementNamed(context, '/login');
  void _getStarted() => Navigator.pushReplacementNamed(context, '/login');

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
                          color: AppColors.primary.withValues(alpha: 0.1),
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

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold.withValues(alpha: 0.12),
                                ),
                              ),
                              Image.network(
                                page.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.school,
                                  size: 120,
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

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
                                    style: const TextStyle(
                                        color: AppColors.gold),
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

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
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
                                  color: AppColors.gold.withValues(alpha: 0.3),
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
                          shadowColor: AppColors.gold.withValues(alpha: 0.4),
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

class _OnboardingData {
  final String imageUrl;
  final String titleNormal;
  final String titleGold;
  final String titleNormalAfter;
  final String subtitle;

  _OnboardingData({
    required this.imageUrl,
    required this.titleNormal,
    required this.titleGold,
    required this.titleNormalAfter,
    required this.subtitle,
  });
}
