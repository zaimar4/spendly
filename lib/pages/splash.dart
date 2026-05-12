import 'package:flutter/material.dart';
import 'package:la_logika/pages/home.dart';
import 'package:la_logika/pages/login.dart';
import 'package:la_logika/pages/slide.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

@override
void initState() {
  super.initState();

  // Animasi setup
  _controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: 2),
  );

  _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  _scaleAnimation = Tween(begin: 0.8, end: 1.2).animate(_controller);

  _controller.forward();

  // Jalankan logic app
  startAppFlow();
}
Future<void> startAppFlow() async {
  print("🔥 Splash started");

  try {
    // delay biar animasi kelihatan
    await Future.delayed(const Duration(seconds: 3));

    print("🔥 Delay selesai");

    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    print("🔥 isFirstTime: $isFirstTime");

    if (!mounted) return;

    // 🔥 pakai microtask biar Navigator aman
    Future.microtask(() {
      if (isFirstTime) {
        print("➡️ ke onboarding");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Slide()),
        );

      } else {
        final session = Supabase.instance.client.auth.currentSession;

        print("🔥 session: ${session?.user.email}");

        if (session != null) {
          print("➡️ ke home");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Home()),
          );

        } else {
          print("➡️ ke login");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    });

  } catch (e) {
    print("❌ ERROR di Splash: $e");

    if (!mounted) return;

    // fallback kalau error → ke login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      width: double.infinity,
      height: double.infinity,

      // 🔥 Background baru (soft gradient hijau)
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8F8F0), // hijau muda
            Color(0xFFFFFFFF), // putih
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),

      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // 🔥 Logo Container (lebih modern)
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color:Color(0xFFE8F8F0), // hijau muda
                  shape: BoxShape.circle,
                  
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 🔥 App Name
              const Text(
                "Spendly",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF24302C),
                ),
              ),

              const SizedBox(height: 8),

              // 🔥 Tagline (biar terasa profesional)
              const Text(
                "Track your money smartly",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 30),

              // 🔥 Loading indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF34C971),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
    }