import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:la_logika/models/Expense.dart';
import 'package:la_logika/service/expense_service.dart';

class Expenses extends StatelessWidget {
  final List<Expense> items;
  // TAMBAHKAN INI: Callback untuk memberitahu Home bahwa data berubah
  final VoidCallback onDeleted;

  const Expenses({super.key, required this.items, required this.onDeleted});

  IconData getIconkategori(String kategori) {
    switch (kategori) {
      case "Primary":
        return Icons.home_outlined;
      case "Secondary":
        return Icons.shopping_bag_outlined;
      case "Lifestyle": // Perhatikan case-sensitive: Lifestyle (L besar)
        return Icons.sports_esports_outlined;
      default:
        return Icons.category_outlined;
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
          // Gunakan ID yang unik agar Flutter tidak bingung saat list berubah
          key: Key(item.id), 
          direction: DismissDirection.endToStart,
          background: Container(
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          onDismissed: (direction) async {
            // 1. Hapus dari Database
            await ExpenseService().deleteExpense(item.id);
            
            // 2. Panggil Callback untuk refresh data di Home.dart
            onDeleted();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${item.nama} dihapus")),
              );
            }
          },

          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(
                radius: 22,
                backgroundColor: Color.fromARGB(255, 76, 175, 80),
                child: Icon(Icons.receipt_long, color: Colors.white), // Atau gunakan getIconkategori
              ),
              title: Text(item.nama),
              subtitle: Text(dateFormat.format(item.tanggal)),
              trailing: Text(
                rupiah.format(-item.harga),
                style: const TextStyle(
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