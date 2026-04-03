import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Navigationbutton extends StatelessWidget {
  final VoidCallback addExpenses;
  final VoidCallback addBalance;
  final VoidCallback historPage;
  final VoidCallback logout;

  const Navigationbutton({
    super.key,
    required this.addExpenses,
    required this.addBalance,
    required this.historPage,
    required this.logout
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      icon: Icons.add,
      children: [
        SpeedDialChild(
          child: Icon(Icons.logout, color: Colors.green),
          label: "Log out",
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          onTap: logout,
        ),
        SpeedDialChild(
          child: Icon(Icons.attach_money, color: Colors.green),
          label: "Add Expense",
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          onTap: addExpenses,
        ),
        SpeedDialChild(
          child: Icon(Icons.balance, color: Colors.green),
          label: "Add Balance",
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          onTap: addBalance,
        ),
        SpeedDialChild(
          child: Icon(Icons.history, color: Colors.green),
          label: "History",
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          onTap: historPage,
        ),
      ],
    );
  }
}
