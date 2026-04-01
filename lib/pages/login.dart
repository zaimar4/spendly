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
  final TextEditingController email =  TextEditingController();
  final TextEditingController password =  TextEditingController();

 Future<void> login() async {
  try {
  
    final response = await supabase.auth.signInWithPassword(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    final user = response.user;

    if (user == null) {
      throw Exception("Login gagal");
    }

    
    final data = await supabase
        .from('profiles') 
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      throw Exception("Profile belum ada. Silakan register ulang.");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Home(
          namaUser: data['nama'],
          balance: (data['balance'] as num).toDouble(),
        ),
      ),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login gagal: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 35, color: Colors.white),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Login Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // Email Field
              TextField(
                controller: email,
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

              // Button Login
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
                  onPressed:login,
                  child: const Text("Login", style: TextStyle(fontSize: 16,color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),

              // Back to Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Register_Page())
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
