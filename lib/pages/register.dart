import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Register_Page extends StatefulWidget {
  const Register_Page({super.key});

  @override
  State<Register_Page> createState() => _Register_PageState();
}

class _Register_PageState extends State<Register_Page> {
  final supabase = Supabase.instance.client;
  
  // Controller untuk mengambil input dari user
  final TextEditingController nama = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    // 1. Validasi awal: pastikan semua field terisi
    if (email.text.isEmpty || password.text.isEmpty || nama.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data harus diisi ya!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 2. Proses pendaftaran ke Supabase Auth
      final response = await supabase.auth.signUp(
        email: email.text.trim(),
        password: password.text.trim(),
        data: {'nama': nama.text.trim()}, // Menyimpan nama ke user metadata
      );

      final user = response.user;
      if (user == null) throw Exception("Pendaftaran gagal, coba lagi nanti.");

      // 3. Simpan data tambahan ke tabel 'profiles'
      // Pastikan tabel 'profiles' sudah kamu buat di dashboard Supabase
      await supabase.from('profiles').insert({
        'id': user.id,
        'nama': nama.text.trim(),
        'balance': 0, // Set saldo awal otomatis 0
      });

      if (!mounted) return;

      // Berhasil -> Beri tahu user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi berhasil! Silakan login."),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman Login
      Navigator.pop(context);

    } on AuthException catch (e) {
      // 4. Tangkap error spesifik pendaftaran (Ubah ke Bahasa Indonesia)
      String pesanError = "Gagal mendaftar";

      if (e.message.contains("User already registered")) {
        pesanError = "Email ini sudah terdaftar. Gunakan email lain ya.";
      } else if (e.message.contains("Password should be at least 6 characters")) {
        pesanError = "Kata sandi terlalu pendek, minimal 6 karakter.";
      } else if (e.message.contains("Invalid format")) {
        pesanError = "Format email salah. Contoh: nama@email.com";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesanError), backgroundColor: Colors.redAccent),
      );

    } catch (e) {
      // 5. Tangkap error umum (Masalah koneksi atau database)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan server. Cek internetmu."),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                 
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 35, color: Colors.white),
              ),

              const SizedBox(height: 20),
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Daftar sekarang untuk mulai mencatat pengeluaranmu.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Field Nama
              TextField(
                controller: nama,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline),
                  hintText: "Nama Lengkap",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),

              // Field Email
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  hintText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),

              // Field Password
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: "Password (Min. 6 Karakter)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Register
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Daftar Sekarang",
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Login di sini",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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