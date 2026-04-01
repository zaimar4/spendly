import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:la_logika/models/categoriModel.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Categorimodel> data;

  const ExpensePieChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: const Text("No data"),
      );
    }

    return SizedBox(
      height: 100,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 20, 
          sections: data.map((category) {
            return PieChartSectionData(
              value: category.total,
              color: category.color,
              radius: 40,
              title: "",
            );
          }).toList(),
        ),
      ),
    );
  }
}