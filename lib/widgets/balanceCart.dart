import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatefulWidget {
  final double totalExpense;
  final double initialBalance;
  final double currentBalance;

  const BalanceCard({
    super.key,
    required this.totalExpense,
    required this.initialBalance,
    required this.currentBalance,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  @override
  Widget build(BuildContext context) {
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );

    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Current Balance",
            style: TextStyle(color: Color.fromARGB(255, 117, 117, 117)),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rupiah.format(widget.currentBalance),
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 76, 175, 80),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(Icons.wallet, color: Colors.white, size: 30),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(thickness: 1),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text("Total expense"), Text("Initial Balance")],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rupiah.format(-widget.totalExpense),
                style: const TextStyle(color: Colors.red),
              ),
              Text(rupiah.format(widget.initialBalance)),
            ],
          ),
        ],
      ),
    );
  }
}
