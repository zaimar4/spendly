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
        .eq('user_id', user!.id)
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

  Future<void> addBalance({required double nilai}) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await supabase.from('income').insert({'user_id': user.id, 'nilai': nilai});
  }

}
