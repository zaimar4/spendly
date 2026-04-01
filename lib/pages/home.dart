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
  final double balance;

  const Home({super.key, required this.namaUser, required this.balance});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double currentbalance;
  int selectedIndex = 0;
  List<String> categories = ["All", "Primary", "Secondary", "Lifestyle"];
  List<Expense> expense = [];
  final expense_service = ExpenseService();
 final TextEditingController addBalanceController = TextEditingController();
  Color getCategoryColor(String kategori) {
    switch (kategori) {
      case "Primary":
        return const Color(0xFF2E7D32);

      case "Secondary":
        return const Color(0xFF66BB6A);

      case "Lifestyle":
        return const Color(0xFFA5D6A7);

      default:
        return Colors.grey.shade400;
    }
  }

  List<Categorimodel> get categoryTotals {
    Map<String, double> totals = {};

    for (var item in expense) {
      totals.update(
        item.kategori,
        (value) => value + item.harga,
        ifAbsent: () => item.harga,
      );
    }

    return totals.entries.map((entry) {
      return Categorimodel(
        nama: entry.key,
        total: entry.value,
        color: getCategoryColor(entry.key),
      );
    }).toList();
  }

  void expenses() async {
    final data = await expense_service.getExpenses();
    setState(() {
      expense = data;
    });
  }

  Future<void> deleteExpense(String id) async {
    await expense_service.deleteExpense(id);
    expenses();
  }

  @override
  void initState() {
    super.initState();
    currentbalance = widget.balance;
    expenses();
  }

  double get totalPengeluaran {
    return expense.fold(0, (sum, item) => sum + item.harga);
  }

  void addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Addexpense()),
    );

    if (result == true) {
      expenses();
    }
  }

  void historyRoute() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void Logout() async {
  try {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
    
  } catch (e) {
    debugPrint("Error saat logout: $e");
  }
}

Future<void> Addbalance() async {
  try {
    double jumlah = double.tryParse(addBalanceController.text) ?? 0;

    if (jumlah <= 0) {
      throw Exception("Nilai tidak valid");
    }

    await expense_service.addBalance(nilai: jumlah); 

    expenses(); 
    addBalanceController.clear();
    Navigator.pop(context); 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saldo berhasil ditambahkan!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal: $e")),
    );
  }
}
void showBalancepopup() {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Your Balance"),
          content: TextField(
            controller: addBalanceController, 
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Input Saldo",
              prefixText: "Rp",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                addBalanceController.clear();
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: Addbalance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Expense> filteredExpenses = selectedIndex == 0
        ? expense
        : expense
              .where((item) => item.kategori == categories[selectedIndex])
              .toList();
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
            child: Text(
              "Hello, ${widget.namaUser} 👋",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(height: 25),
       Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: BalanceCard(
    // Sekarang gunakan currentbalance sebagai dasar saldo akhir
    currentBalance: currentbalance - totalPengeluaran, 
    totalExpense: totalPengeluaran,
    initialBalance: currentbalance, // Tampilkan saldo saat ini sebagai initial
  ),
),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Expense Overview",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(categories.length, (index) {
              return Buttoncategory(
                isSelected: selectedIndex == index,
                text: categories[index],
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              "Recent Transaction",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),

          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(child: Text("No items found"))
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8,
                    ),
                    child: Expenses(items: filteredExpenses),
                  ),
          ),
        ],
      ),
    );
  }
}
