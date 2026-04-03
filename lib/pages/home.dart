import 'package:flutter/material.dart';
import 'package:la_logika/models/Expense.dart';
import 'package:la_logika/models/categoriModel.dart';
import 'package:la_logika/pages/addexpense.dart';
import 'package:la_logika/pages/login.dart';
import 'package:la_logika/pages/riwayat.dart';
import 'package:la_logika/service/expense_service.dart';
import 'package:la_logika/widgets/Expenses.dart';
import 'package:la_logika/widgets/balanceCart.dart';
import 'package:la_logika/widgets/buttonCategory.dart';
import 'package:la_logika/widgets/navigationbutton.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  final String namaUser;
  final double balance; // Ini saldo awal saat pendaftaran/login

  const Home({super.key, required this.namaUser, required this.balance});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double currentbalance; // Kita gunakan ini untuk menyimpan (Balance Awal + Total Income)
  int selectedIndex = 0;
  List<String> categories = ["All", "Primary", "Secondary", "Lifestyle"];
  List<Expense> expense = [];
  final expense_service = ExpenseService();
  final TextEditingController addBalanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentbalance = widget.balance;
    refreshAllData(); // Ambil semua data saat pertama kali buka
  }

  // FUNGSI UTAMA: Mengambil data pengeluaran DAN tambahan saldo terbaru dari DB
  void refreshAllData() async {
    final expensesData = await expense_service.getExpenses();
    final totalTambahanSaldo = await expense_service.getTotalIncome();
    
    setState(() {
      expense = expensesData;
      // Saldo dasar + semua topup yang ada di tabel income
      currentbalance = widget.balance + totalTambahanSaldo;
    });
  }

  double get totalPengeluaran {
    return expense.fold(0.0, (sum, item) => sum + item.harga);
  }

  Future<void> deleteExpense(String id) async {
    await expense_service.deleteExpense(id);
    refreshAllData(); 
  }

  Future<void> Addbalance() async {
    try {
      double jumlah = double.tryParse(addBalanceController.text) ?? 0;
      if (jumlah <= 0) return;

      await expense_service.addBalance(nilai: jumlah);
      
      addBalanceController.clear();
      if (mounted) Navigator.pop(context);
      
      refreshAllData(); // Refresh untuk mendapatkan currentbalance terbaru dari DB

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saldo berhasil ditambahkan!")),
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // --- Fungsi Navigasi ---
  void addExpense() async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => const Addexpense()),
    );
    if (result == true) refreshAllData();
  }

  void historyRoute() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
    refreshAllData(); // Refresh saat balik dari halaman riwayat
  }

  void Logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false,
    );
  }

  void showBalancepopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Your Balance"),
        content: TextField(
          controller: addBalanceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Input Saldo", prefixText: "Rp ", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: Addbalance,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Expense> filteredExpenses = selectedIndex == 0
        ? expense
        : expense.where((item) => item.kategori == categories[selectedIndex]).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 255, 249),
      floatingActionButton: Navigationbutton(
        logout: Logout,
        addExpenses: addExpense,
        addBalance: showBalancepopup,
        historPage: historyRoute,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text("Hello, ${widget.namaUser} 👋", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BalanceCard(
              currentBalance: currentbalance - totalPengeluaran,
              totalExpense: totalPengeluaran,
              initialBalance: currentbalance,
            ),
          ),
          const SizedBox(height: 15),
          // Filter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(categories.length, (index) {
              return Buttoncategory(
                isSelected: selectedIndex == index,
                text: categories[index],
                onTap: () => setState(() => selectedIndex = index),
              );
            }),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(child: Text("No items found"))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Expenses(items: filteredExpenses, onDeleted: refreshAllData),
                  ),
          ),
        ],
      ),
    );
  }
}