import 'package:flutter/material.dart';
import 'package:la_logika/pages/home.dart';
import 'package:la_logika/pages/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  
  // State untuk mencegah freeze dan memberi feedback ke user
  bool isLoading = false;

  Future<void> login() async {
    // 1. Validasi input kosong
    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password tidak boleh kosong!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 2. Proses Login ke Supabase
      final response = await supabase.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = response.user;
      if (user == null) throw Exception("User tidak ditemukan");

      // 3. Ambil data profil (Nama & Saldo)
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        throw Exception("Profil tidak ditemukan. Silakan register ulang.");
      }

      if (!mounted) return;

      // 4. Navigasi ke Home (Hapus history agar tidak bisa back ke login)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => Home(
            namaUser: data['nama'] ?? "User",
            balance: (data['balance'] ?? 0 as num).toDouble(),
          ),
        ),
        (route) => false,
      );

    } on AuthException catch (e) {
      // 5. UBAH PESAN ERROR SUPABASE KE BAHASA INDONESIA
      String pesanKustom = "Gagal masuk: Periksa kembali akunmu";

      if (e.message.contains("Invalid login credentials")) {
        pesanKustom = "Email atau kata sandi salah, nih. Coba cek lagi.";
      } else if (e.message.contains("Email not confirmed")) {
        pesanKustom = "Email kamu belum dikonfirmasi. Cek kotak masuk emailmu ya.";
      } else if (e.message.contains("Too many requests")) {
        pesanKustom = "Terlalu banyak mencoba login. Tunggu sebentar ya, Boss.";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesanKustom),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      // 6. Error umum (koneksi internet/server)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Koneksi bermasalah. Pastikan internetmu aktif!"),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      // Matikan loading spinner
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Header
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 35, color: Colors.white),
              ),

              const SizedBox(height: 20),

              const Text(
                "Login Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // Email Field
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Login dengan Loading Spinner
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Link ke Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Register_Page()),
                      );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}