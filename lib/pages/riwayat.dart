import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:la_logika/models/Expense.dart';
import 'package:la_logika/service/expense_service.dart';

// Enum untuk pilihan filter periode
enum FilterPeriod { today, thisWeek, thisMonth, lastMonth }

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

  // Filter aktif, default "Bulan Ini"
  FilterPeriod selectedFilter = FilterPeriod.thisMonth;

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

  // --- LOGIKA FILTER RENTANG TANGGAL ---
  DateTimeRange get _filterRange {
    final now = DateTime.now();
    switch (selectedFilter) {
      case FilterPeriod.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return DateTimeRange(start: start, end: end);

      case FilterPeriod.thisWeek:
        // Mulai dari hari Senin minggu ini
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        final end = start.add(const Duration(days: 7));
        return DateTimeRange(start: start, end: end);

      case FilterPeriod.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: start, end: end);

      case FilterPeriod.lastMonth:
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final lastYear = now.month == 1 ? now.year - 1 : now.year;
        final start = DateTime(lastYear, lastMonth, 1);
        final end = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: start, end: end);
    }
  }

  // Filter expense berdasarkan rentang
  List<Expense> get filteredExpenses {
    final range = _filterRange;
    return expenses.where((e) {
      return e.tanggal.isAfter(range.start) &&
          e.tanggal.isBefore(range.end);
    }).toList();
  }

  // Filter income berdasarkan rentang
  List<Map<String, dynamic>> get filteredIncomes {
    final range = _filterRange;
    return incomes.where((i) {
      final dt = DateTime.parse(i['created_at']);
      return dt.isAfter(range.start) && dt.isBefore(range.end);
    }).toList();
  }

  // --- PERHITUNGAN DARI DATA YANG SUDAH DIFILTER ---
  double get totalIncome =>
      filteredIncomes.fold(0, (sum, item) => sum + (item['nilai'] ?? 0).toDouble());

  double get totalExpense =>
      filteredExpenses.fold(0, (sum, item) => sum + item.harga);

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

  String get _filterLabel {
    switch (selectedFilter) {
      case FilterPeriod.today:
        return "Hari Ini";
      case FilterPeriod.thisWeek:
        return "Minggu Ini";
      case FilterPeriod.thisMonth:
        return "Bulan Ini";
      case FilterPeriod.lastMonth:
        return "Bulan Lalu";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF2F3F5),
        centerTitle: true,
        title: const Text(
          "Transaction History",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ===== FILTER CHIP ROW =====
                _buildFilterRow(),
                const SizedBox(height: 16),

                // ===== SUMMARY CARDS =====
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
                _netBalanceCard(),
                const SizedBox(height: 25),

                Text(
                  "Transaksi – $_filterLabel",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                ..._groupedTransactions(),
              ],
            ),
    );
  }

  // ===== WIDGET FILTER ROW =====
  Widget _buildFilterRow() {
    final filters = [
      (FilterPeriod.today, "Hari Ini"),
      (FilterPeriod.thisWeek, "Minggu Ini"),
      (FilterPeriod.thisMonth, "Bulan Ini"),
      (FilterPeriod.lastMonth, "Bulan Lalu"),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((entry) {
          final period = entry.$1;
          final label = entry.$2;
          final isSelected = selectedFilter == period;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.shade700 : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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

  Widget _netBalanceCard() {
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
          Text("Net Balance – $_filterLabel",
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            rupiah.format(netBalance),
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: netBalance >= 0
                    ? Colors.green.shade800
                    : Colors.red.shade800),
          ),
        ],
      ),
    );
  }

  // ===== GROUPED TRANSACTIONS (PAKAI DATA YANG SUDAH DIFILTER) =====
  List<Widget> _groupedTransactions() {
    List<dynamic> allData = [];
    allData.addAll(filteredExpenses);
    allData.addAll(filteredIncomes);

    if (allData.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  "Tidak ada transaksi\npada periode ini",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
              ],
            ),
          ),
        )
      ];
    }

    allData.sort((a, b) {
      DateTime dtA =
          (a is Expense) ? a.tanggal : DateTime.parse(a['created_at']);
      DateTime dtB =
          (b is Expense) ? b.tanggal : DateTime.parse(b['created_at']);
      return dtB.compareTo(dtA);
    });

    Map<String, List<dynamic>> grouped = {};
    for (var item in allData) {
      DateTime dt =
          (item is Expense) ? item.tanggal : DateTime.parse(item['created_at']);
      String key = DateFormat('dd MMMM yyyy').format(dt);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    List<Widget> widgets = [];
    grouped.forEach((date, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 8, left: 4),
          child: Text(date,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
      );

      for (var item in items) {
        bool isExpense = item is Expense;
        String title = isExpense ? item.nama : "Top Up Balance";
        double val =
            isExpense ? item.harga : (item['nilai'] ?? 0).toDouble();
        String category = isExpense ? item.kategori : "Income";
        String hour = DateFormat('HH:mm').format(isExpense
            ? item.tanggal
            : DateTime.parse(item['created_at']));

        widgets.add(
          Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isExpense
                    ? getCategoryColor(category).withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                child: Icon(
                  isExpense
                      ? Icons.shopping_bag_outlined
                      : Icons.account_balance_wallet_outlined,
                  color: isExpense
                      ? getCategoryColor(category)
                      : Colors.green.shade700,
                ),
              ),
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                "$hour  •  $category",
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                isExpense
                    ? "- ${rupiah.format(val)}"
                    : "+ ${rupiah.format(val)}",
                style: TextStyle(
                  color: isExpense
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      }
    });

    return widgets;
  }
}