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
    final data = await service.getExpenses();
    setState(() {
      expenses = data;
      isLoading = false;
    });
  }

 
  double get totalExpense =>
      expenses.fold(0, (sum, item) => sum + item.harga);

  double get totalIncome => 0; 

  double get netBalance => totalIncome - totalExpense;

  

  Color getCategoryColor(String kategori) {
    switch (kategori) {
      case "Primary":
        return const Color(0xFF2E7D32);
      case "Secondary":
        return const Color(0xFF66BB6A);
      case "Lifestyle":
        return const Color(0xFFA5D6A7);
      default:
        return Colors.grey;
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
          "History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.filter_alt_outlined),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: "Total Income :",
                        amount: totalIncome,
                        color: Colors.green,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: "Total Expenses",
                        amount: totalExpense,
                        color: Colors.red,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =============================
                // MONTHLY SUMMARY
                // =============================
                _monthlySummaryCard(),

                const SizedBox(height: 20),

                const Text(
                  "All Transactions",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ..._groupedTransactions(),
              ],
            ),
    );
  }

  // =============================
  // SUMMARY CARD
  // =============================

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
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            rupiah.format(amount),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(icon, color: Colors.white),
          )
        ],
      ),
    );
  }

  // =============================
  // MONTHLY SUMMARY CARD
  // =============================

  Widget _monthlySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Monthly Summary",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Net Balance: ${rupiah.format(netBalance)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // =============================
  // GROUPED TRANSACTIONS
  // =============================

  List<Widget> _groupedTransactions() {
    Map<String, List<Expense>> grouped = {};

    for (var item in expenses) {
      String dateKey =
          DateFormat('dd MMM yyyy').format(item.tanggal);

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(item);
    }

    List<Widget> widgets = [];

    grouped.forEach((date, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            date,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );

      for (var item in items) {
        widgets.add(
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    getCategoryColor(item.kategori),
                child: Text(
                  item.kategori[0],
                  style:
                      const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(item.nama),
              subtitle: Text(
                  DateFormat('HH:mm').format(item.tanggal)),
              trailing: Text(
                "- ${rupiah.format(item.harga)}",
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }
    });

    return widgets;
  }
}