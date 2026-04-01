import 'package:flutter/material.dart';
import 'package:la_logika/pages/slide.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 1. Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Load file .env
    await dotenv.load(fileName: ".env");

    await initializeDateFormatting('id_ID', null);

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '', 
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint("Error saat inisialisasi: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Slide(),
    );
  }
}