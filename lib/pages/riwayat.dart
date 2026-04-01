import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:la_logika/models/Expense.dart';
import 'package:la_logika/service/expense_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ExpenseService service = ExpenseService();

  List<Expense> expenses = [];
  List<Map<String, dynamic>> incomes = [];
  bool isLoading = true;

  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      // Mengambil data Expense dan Income secara paralel
      final results = await Future.wait([
        service.getExpenses(),
        service.getIncomes(),
      ]);

      setState(() {
        expenses = results[0] as List<Expense>;
        incomes = results[1] as List<Map<String, dynamic>>;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetchData: $e");
      setState(() => isLoading = false);
    }
  }

  // LOGIKA PERHITUNGAN
  double get totalIncome =>
      incomes.fold(0, (sum, item) => sum + (item['nilai'] ?? 0).toDouble());

  double get totalExpense =>
      expenses.fold(0, (sum, item) => sum + item.harga);

  double get netBalance => totalIncome - totalExpense;

  Color getCategoryColor(String kategori) {
    switch (kategori) {
      case "Primary":
        return const Color(0xFF2E7D32);
      case "Secondary":
        return const Color(0xFF66BB6A);
      case "Lifestyle":
        return const Color(0xFF1B5E20);
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F6B73),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Transaction History",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // RINGKASAN ATAS
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: "Total Income",
                        amount: totalIncome,
                        color: Colors.green.shade700,
                        icon: Icons.add_chart,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: "Total Expenses",
                        amount: totalExpense,
                        color: Colors.red.shade700,
                        icon: Icons.pie_chart_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _monthlySummaryCard(),
                const SizedBox(height: 25),

                const Text(
                  "All Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // DAFTAR TRANSAKSI GABUNGAN
                ..._groupedTransactions(),
              ],
            ),
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              rupiah.format(amount),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(icon, color: Colors.white38, size: 28),
          )
        ],
      ),
    );
  }

  Widget _monthlySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          const Text("Net Balance This Month",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            rupiah.format(netBalance),
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: netBalance >= 0 ? Colors.green.shade800 : Colors.red.shade800),
          ),
          const SizedBox(height: 12),
          Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  List<Widget> _groupedTransactions() {
    // 1. Gabungkan
    List<dynamic> allData = [];
    allData.addAll(expenses);
    allData.addAll(incomes);

    // 2. Sort Tanggal
    allData.sort((a, b) {
      DateTime dtA = (a is Expense) ? a.tanggal : DateTime.parse(a['created_at']);
      DateTime dtB = (b is Expense) ? b.tanggal : DateTime.parse(b['created_at']);
      return dtB.compareTo(dtA);
    });

    Map<String, List<dynamic>> grouped = {};
    for (var item in allData) {
      DateTime dt = (item is Expense) ? item.tanggal : DateTime.parse(item['created_at']);
      String key = DateFormat('dd MMMM yyyy').format(dt);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    List<Widget> widgets = [];
    grouped.forEach((date, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 8, left: 4),
          child: Text(date, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
      );

      for (var item in items) {
        bool isExpense = item is Expense;
        String title = isExpense ? item.nama : "Top Up Balance";
        double val = isExpense ? item.harga : (item['nilai'] ?? 0).toDouble();
        String category = isExpense ? item.kategori : "Income";
        String hour = DateFormat('HH:mm').format(isExpense ? item.tanggal : DateTime.parse(item['created_at']));

        widgets.add(
          Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isExpense ? getCategoryColor(category).withOpacity(0.2) : Colors.green.withOpacity(0.2),
                child: Icon(
                  isExpense ? Icons.shopping_bag_outlined : Icons.account_balance_wallet_outlined,
                  color: isExpense ? getCategoryColor(category) : Colors.green.shade700,
                ),
              ),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(hour, style: const TextStyle(fontSize: 12)),
              trailing: Text(
                isExpense ? "- ${rupiah.format(val)}" : "+ ${rupiah.format(val)}",
                style: TextStyle(
                  color: isExpense ? Colors.red.shade700 : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      }
    });

    if (allData.isEmpty) {
      widgets.add(const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text("No transactions yet"),
      )));
    }

    return widgets;
  }
}