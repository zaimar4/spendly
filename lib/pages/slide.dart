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
    2, // index slide target
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );
}
void finishOnboarding() {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) =>  LoginPage(),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
         backgroundColor: const Color.fromARGB(255, 248, 255, 249),
      body: PageView(
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
    );
  }

  Widget buildSlide(
    SlideIcon iconType,
    String title,
    String subtitle,
    String buttonText,
    VoidCallback onPressed, {
    bool showSkip = true,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildSlideIcon(iconType),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Color(0xFF24302C),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34C971),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          showSkip
              ? Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextButton(
                    onPressed: skipToTarget,
                    style: TextButton.styleFrom(
                      overlayColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ================= ICON =================

  Widget buildSlideIcon(SlideIcon type) {
    Widget iconWidget;

    if (type == SlideIcon.wallet) {
      iconWidget = const Icon(
        size: 60,
        Icons.account_balance_wallet_outlined,
        color: Colors.white,
      );
    } else if (type == SlideIcon.trending) {
      iconWidget = const Icon(
        Icons.trending_down,
        size: 60,
        color: Colors.white,
      );
    } else {
      iconWidget = CustomPaint(
        size: const Size(60, 60),
        painter: TargetPainter(),
      );
    }

    return Container(
      width: 130,
      height: 130,
      decoration: iconBackground(type),
      child: Center(child: iconWidget),
    );
  }


  BoxDecoration iconBackground(SlideIcon type) {
    if (type == SlideIcon.wallet) {
      return const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF00F0B5), Color(0xFF1ED760)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      );
    } else if (type == SlideIcon.trending) {
      return const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00E6B8), Color(0xFF00C2A8)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      );
    } else {
      return const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1ED760), Color(0xFF00C2A8)],
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      );
    }
  }
}

enum SlideIcon { wallet, trending, target }

class WalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 15, size.width - 12, size.height - 25),
      const Radius.circular(8),
    );

    canvas.drawRRect(r, paint);
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.5),
      Offset(size.width * 0.85, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class TargetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.5, paint);
    canvas.drawCircle(size.center(Offset.zero), size.width / 4, paint);
    canvas.drawCircle(
      size.center(Offset.zero),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
