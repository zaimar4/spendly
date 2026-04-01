import 'package:flutter/material.dart';
import 'package:la_logika/pages/login.dart';

class Slide extends StatefulWidget {
  const Slide({super.key});

  @override
  State<Slide> createState() => _SlideState();
}

class _SlideState extends State<Slide> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _controller.dispose(); // Memastikan memory bersih saat pindah halaman
    super.dispose();
  }

  void nextPage() {
    if (currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipToTarget() {
    _controller.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void finishOnboarding() {
    // Navigasi yang aman: menghapus semua history slide agar tidak bisa back
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 255, 249),
      body: Stack(
        children: [
          // 1. PAGE VIEW (Konten Utama)
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => currentPage = i),
            children: [
              buildSlide(
                SlideIcon.wallet,
                "Manage Your Expenses",
                "Keep track of all your spending in one place with ease and simplicity.",
                "Next",
                nextPage,
              ),
              buildSlide(
                SlideIcon.trending,
                "Track Spending Habits",
                "Understand where your money goes and make informed financial decisions.",
                "Next",
                nextPage,
              ),
              buildSlide(
                SlideIcon.target,
                "Improve Financial Awareness",
                "Build better money habits and achieve your financial goals effortlessly.",
                "Get Started",
                finishOnboarding,
                showSkip: false,
              ),
            ],
          ),

          // 2. DOTS INDICATOR (Penanda Halaman)
          Positioned(
            bottom: 140, // Posisi di atas tombol utama
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? const Color(0xFF34C971)
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGET BUILDER =================

  Widget buildSlide(
    SlideIcon iconType,
    String title,
    String subtitle,
    String buttonText,
    VoidCallback onPressed, {
    bool showSkip = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          buildSlideIcon(iconType),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF24302C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const Spacer(flex: 2),
          
          // Tombol Utama
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34C971),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Tombol Skip
          if (showSkip)
            TextButton(
              onPressed: skipToTarget,
              child: const Text(
                "Skip",
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
              ),
            )
          else
            const SizedBox(height: 48), // Padding bawah agar seimbang
            
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================= ICON HANDLER =================

  Widget buildSlideIcon(SlideIcon type) {
    IconData d;
    if (type == SlideIcon.wallet) d = Icons.account_balance_wallet_outlined;
    else if (type == SlideIcon.trending) d = Icons.trending_up;
    else d = Icons.ads_click; // Ikon Target

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF34C971), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34C971).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Icon(d, size: 60, color: Colors.white),
    );
  }
}

enum SlideIcon { wallet, trending, target }