import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:la_logika/models/Expense.dart';
import 'package:la_logika/service/expense_service.dart';

// Mode filter yang tersedia
enum StatPeriod { all, today, thisWeek, thisMonth, lastMonth }

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  final ExpenseService service = ExpenseService();

  List<Expense> allExpenses = [];
  bool isLoading = true;
  StatPeriod selectedPeriod = StatPeriod.thisMonth;
  int touchedIndex = -1;

  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final Map<String, Color> categoryColors = {
    "Primary": const Color(0xFF2E7D32),
    "Secondary": const Color(0xFF66BB6A),
    "Lifestyle": const Color(0xFF1B5E20),
  };

  final List<Color> fallbackColors = [
    const Color(0xFF43A047),
    const Color(0xFF1B5E20),
    const Color(0xFF66BB6A),
  ];

  final List<String> _bulanNames = [
    "Januari", "Februari", "Maret", "April",
    "Mei", "Juni", "Juli", "Agustus",
    "September", "Oktober", "November", "Desember",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await service.getExpenses();
      setState(() {
        allExpenses = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load statistik: $e");
      setState(() => isLoading = false);
    }
  }

  // ===== FILTER RANGE — null = All =====
  DateTimeRange? get _filterRange {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case StatPeriod.all:
        return null;

      case StatPeriod.today:
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: start, end: start.add(const Duration(days: 1)));

      case StatPeriod.thisWeek:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        return DateTimeRange(start: start, end: start.add(const Duration(days: 7)));

      case StatPeriod.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 1),
        );

      case StatPeriod.lastMonth:
        final lastMonthDate = DateTime(now.year, now.month - 1, 1);
        final nextMonth = lastMonthDate.month == 12 ? 1 : lastMonthDate.month + 1;
        final nextYear = lastMonthDate.month == 12 ? lastMonthDate.year + 1 : lastMonthDate.year;
        return DateTimeRange(
          start: DateTime(lastMonthDate.year, lastMonthDate.month, 1),
          end: DateTime(nextYear, nextMonth, 1),
        );
    }
  }

  List<Expense> get _filteredExpenses {
    final range = _filterRange;
    if (range == null) return List.from(allExpenses);
    return allExpenses
        .where((e) => e.tanggal.isAfter(range.start) && e.tanggal.isBefore(range.end))
        .toList();
  }

  double get _totalPengeluaran =>
      _filteredExpenses.fold(0, (sum, e) => sum + e.harga);

  Map<String, double> get _byCategory {
    final Map<String, double> map = {};
    for (var e in _filteredExpenses) {
      map[e.kategori] = (map[e.kategori] ?? 0) + e.harga;
    }
    return map;
  }

  // Tren: per jam (today), per hari (week), per tanggal (month/pickMonth), per bulan (all)
  Map<String, double> get _trendData {
    Map<String, double> map = {};
    if (selectedPeriod == StatPeriod.today) {
      for (var e in _filteredExpenses) {
        final key = DateFormat('HH:00').format(e.tanggal);
        map[key] = (map[key] ?? 0) + e.harga;
      }
    } else if (selectedPeriod == StatPeriod.thisWeek) {
      for (var e in _filteredExpenses) {
        final key = DateFormat('EEE\nd MMM').format(e.tanggal);
        map[key] = (map[key] ?? 0) + e.harga;
      }
    } else if (selectedPeriod == StatPeriod.all) {
      // Per bulan — "Jan 2024"
      for (var e in _filteredExpenses) {
        final key = DateFormat('MMM yyyy').format(e.tanggal);
        map[key] = (map[key] ?? 0) + e.harga;
      }
    } else {
      for (var e in _filteredExpenses) {
        final key = DateFormat('dd MMM').format(e.tanggal);
        map[key] = (map[key] ?? 0) + e.harga;
      }
    }
    return map;
  }

  String get _biggestCategory {
    if (_byCategory.isEmpty) return "—";
    return _byCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double get _biggestCategoryAmount {
    if (_byCategory.isEmpty) return 0;
    return _byCategory.entries.reduce((a, b) => a.value > b.value ? a : b).value;
  }

  double get _biggestCategoryPercent {
    if (_totalPengeluaran == 0) return 0;
    return (_biggestCategoryAmount / _totalPengeluaran) * 100;
  }

  int get _transactionCount => _filteredExpenses.length;

  String get _periodLabel {
    switch (selectedPeriod) {
      case StatPeriod.all:       return "Semua Waktu";
      case StatPeriod.today:     return "Hari Ini";
      case StatPeriod.thisWeek:  return "Minggu Ini";
      case StatPeriod.thisMonth: return "Bulan Ini";
      case StatPeriod.lastMonth: 
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return "${_bulanNames[lastMonth.month - 1]} ${lastMonth.year}";
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
          "Statistik",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFilterRow(),
                  const SizedBox(height: 20),
                  _buildTotalCard(),
                  const SizedBox(height: 20),
                  _buildInsightRow(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Pengeluaran per Kategori"),
                  const SizedBox(height: 12),
                  _buildPieChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Tren Pengeluaran"),
                  const SizedBox(height: 12),
                  _buildTrendChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Rincian per Kategori"),
                  const SizedBox(height: 12),
                  _buildCategoryBreakdown(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ===== FILTER ROW =====
  Widget _buildFilterRow() {
    final staticFilters = [
      (StatPeriod.all,       "All"),
      (StatPeriod.today,     "Hari Ini"),
      (StatPeriod.thisWeek,  "Minggu Ini"),
      (StatPeriod.thisMonth, "Bulan Ini"),
      (StatPeriod.lastMonth, "Bulan Lalu"),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: staticFilters.map((entry) {
          final period = entry.$1;
          final label = entry.$2;
          final isSelected = selectedPeriod == period;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() {
                selectedPeriod = period;
                touchedIndex = -1;
              }),
              child: _filterChip(label: label, isSelected: isSelected),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.shade700 : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.green.shade200, blurRadius: 8, offset: const Offset(0, 3))]
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
    );
  }

  // ===== TOTAL CARD =====
  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.green.shade200, blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Pengeluaran – $_periodLabel",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              rupiah.format(_totalPengeluaran),
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$_transactionCount transaksi tercatat",
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ===== INSIGHT ROW =====
  Widget _buildInsightRow() {
    return Row(
      children: [
        Expanded(
          child: _insightCard(
            icon: Icons.emoji_events_outlined,
            iconColor: Colors.orange.shade700,
            bgColor: Colors.orange.shade50,
            label: "Kategori Terbesar",
            value: _biggestCategory,
            sub: rupiah.format(_biggestCategoryAmount),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _insightCard(
            icon: Icons.percent_rounded,
            iconColor: Colors.blue.shade700,
            bgColor: Colors.blue.shade50,
            label: "Porsi Terbesar",
            value: "${_biggestCategoryPercent.toStringAsFixed(1)}%",
            sub: _biggestCategory,
          ),
        ),
      ],
    );
  }

  Widget _insightCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(sub, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  // ===== PIE CHART =====
  Widget _buildPieChart() {
    final byCategory = _byCategory;
    if (byCategory.isEmpty) return _emptyChart("Tidak ada data untuk ditampilkan");
    final categories = byCategory.keys.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 3,
                    centerSpaceRadius: 55,
                    sections: List.generate(categories.length, (i) {
                      final cat = categories[i];
                      final val = byCategory[cat]!;
                      final pct = _totalPengeluaran > 0 ? val / _totalPengeluaran * 100 : 0.0;
                      final isTouched = touchedIndex == i;
                      final color = categoryColors[cat] ?? fallbackColors[i % fallbackColors.length];

                      return PieChartSectionData(
                        color: color,
                        value: val,
                        title: "${pct.toStringAsFixed(1)}%",
                        radius: isTouched ? 75 : 60,
                        titleStyle: const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Total", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 2),
                    FittedBox(
                      child: Text(
                        rupiah.format(_totalPengeluaran),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: categories.map((cat) {
              final color = categoryColors[cat] ?? Colors.grey;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(cat, style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===== TREND CHART =====
  Widget _buildTrendChart() {
    final trendData = _trendData;
    if (trendData.isEmpty) return _emptyChart("Tidak ada data tren");

    final keys = trendData.keys.toList()..sort();
    final maxVal = trendData.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      decoration: _cardDecoration(),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: maxVal * 1.3,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.green.shade800,
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  rupiah.format(rod.toY),
                  const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 52,
                  getTitlesWidget: (val, _) {
                    if (val == 0) return const Text('');
                    String label;
                    if (val >= 1000000) {
                      label = "${(val / 1000000).toStringAsFixed(1)}jt";
                    } else if (val >= 1000) {
                      label = "${(val / 1000).toStringAsFixed(0)}rb";
                    } else {
                      label = val.toStringAsFixed(0);
                    }
                    return Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (val, _) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= keys.length) return const Text('');
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        keys[idx],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(keys.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: trendData[keys[i]]!,
                    color: Colors.green.shade600,
                    width: _barWidth(keys.length),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxVal * 1.3,
                      color: Colors.grey.shade100,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  double _barWidth(int count) {
    if (count <= 7) return 20;
    if (count <= 14) return 14;
    return 8;
  }

  // ===== CATEGORY BREAKDOWN =====
  Widget _buildCategoryBreakdown() {
    final byCategory = _byCategory;
    if (byCategory.isEmpty) return _emptyChart("Tidak ada data");

    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: sorted.map((entry) {
          final pct = _totalPengeluaran > 0 ? entry.value / _totalPengeluaran : 0.0;
          final color = categoryColors[entry.key] ?? Colors.grey;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ]),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(rupiah.format(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("${(pct * 100).toStringAsFixed(1)}%",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===== HELPERS =====
  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _emptyChart(String msg) {
    return Container(
      height: 120,
      decoration: _cardDecoration(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined, color: Colors.grey.shade400, size: 36),
            const SizedBox(height: 8),
            Text(msg, style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}