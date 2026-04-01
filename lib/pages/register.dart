import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

class Register_Page extends StatefulWidget {
  const Register_Page({super.key});

  @override
  State<Register_Page> createState() => _Register_PageState();
}

class _Register_PageState extends State<Register_Page> {
  final TextEditingController nama = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController balance = TextEditingController();

  final supabase = Supabase.instance.client;
  Future<void> register() async {
     try {
    if (email.text.isEmpty ||
        password.text.isEmpty ||
        nama.text.isEmpty ||
        balance.text.isEmpty) {
      throw Exception("Semua field wajib diisi");
    }

    final response = await supabase.auth.signUp(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    final user = response.user;

    if (user == null) {
      throw Exception("User gagal dibuat");
    }

    await supabase.from('profiles').insert({
      'id': user.id,
      'nama': nama.text,
      'balance': double.tryParse(balance.text) ?? 0,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Register berhasil")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error: $e")));
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
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF22C55E),
                child: Icon(Icons.person_add, color: Colors.white, size: 30),
              ),

              const SizedBox(height: 16),
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Start managing your expenses",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // NAME
              TextField(
                controller: nama,
                decoration: InputDecoration(
                  labelText: " Username",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // EMAIL
              TextField(
                controller: email,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // PASSWORD
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // INITIAL BALANCE
              TextField(
                controller: balance,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Initial Balance",
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed:register ,
                  child: const Text("Register", style: TextStyle(fontSize: 16,color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),

              // LOGIN LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF22C55E),
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
