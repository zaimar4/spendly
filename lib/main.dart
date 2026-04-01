import 'package:flutter/material.dart';
import 'package:la_logika/pages/home.dart';
import 'package:la_logika/pages/login.dart';
import 'package:la_logika/pages/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/slide.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://qlcvcdrrqgmbljcppcgv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsY3ZjZHJycWdtYmxqY3BwY2d2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwOTY5NDgsImV4cCI6MjA4NjY3Mjk0OH0.uMAi_5cDNaK3l6efQpttqu8f7ssU9Ll_mEJV2fxzoJo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:LoginPage()
    );
  }
}
