import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:la_logika/models/Expense.dart';
import 'package:la_logika/service/expense_service.dart';

class Expenses extends StatelessWidget {
  final List<Expense> items;

  const Expenses({super.key, required this.items});
  IconData getIconkategori(String kategori) {
    switch (kategori) {
      case "Primary":
        return Icons.home;
      case "Secondary":
        return Icons.shopping_cart;
      case "LifeStyle":
        return Icons.sports_esports;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Dismissible(
          key: Key(item.nama + index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            padding: EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delete, color: Colors.white),
          ),

          onDismissed: (direction) {
            // panggil delete dari supabase disini
            ExpenseService().deleteExpense(item.id);

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("${item.nama} dihapus")));
          },

          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  offset: Offset(0, 6),
                  color: const Color.fromARGB(
                    255,
                    190,
                    190,
                    190,
                  ).withOpacity(0.3),
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: Color.fromARGB(255, 76, 175, 80),
                child: Icon(
                  getIconkategori(item.kategori),
                  color: Colors.white,
                ),
              ),
              title: Text(item.nama),
              subtitle: Text(dateFormat.format(item.tanggal)),
              trailing: Text(
                rupiah.format(-item.harga),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
