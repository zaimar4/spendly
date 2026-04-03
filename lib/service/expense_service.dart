import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/Expense.dart';

class ExpenseService {
  final supabase = Supabase.instance.client;
  Future<List<Expense>> getExpenses() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }
    final data = await supabase
        .from('expenses')
        .select('id, nama_expense, harga, kategori, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (data as List).map((item) => Expense.fromJson(item)).toList();
  }

  Future<void> deleteExpense(String id) async {
    await supabase.from('expenses').delete().eq('id', id);
  }

  Future<void> addExpense({
    required String nama,
    required double harga,
    required String kategori,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await supabase.from('expenses').insert({
      'user_id': user.id,
      'nama_expense': nama,
      'harga': harga,
      'kategori': kategori,
    });
  }
// Di ExpenseService
Future<void> addBalance({required double nilai}) async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  await supabase.from('income').insert({
    'user_id': user.id, 
    'nilai': nilai,
  });
}
Future<List<Map<String, dynamic>>> getIncomes() async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return [];


    final response = await supabase
        .from('income') 
        .select()
        .eq('user_id', user.id) 
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print("Error Get Incomes: $e");
    return [];
  }
}
Future<double> getTotalIncome() async {
  final user = supabase.auth.currentUser;
  if (user == null) return 0;

  final data = await supabase
      .from('income')
      .select('nilai')
      .eq('user_id', user.id);

  double total = 0;
  for (var item in data) {
    total += (item['nilai'] as num).toDouble();
  }
  return total;
}
  }


