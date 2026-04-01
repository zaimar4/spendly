import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:la_logika/service/expense_service.dart';
import 'package:la_logika/widgets/Categorycard.dart';
import 'package:la_logika/widgets/InputExpense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Addexpense extends StatefulWidget {
  const Addexpense({super.key});

  @override
  State<Addexpense> createState() => _AddexpenseState();
}

class _AddexpenseState extends State<Addexpense> {
  final TextEditingController namaExpense = TextEditingController();
  final TextEditingController hargaExpense = TextEditingController();
  final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  String selectedCategory = "";
  final supabase = Supabase.instance.client;
  final expenseService = ExpenseService();

  Future<void> addExpense() async {
    try {
      if (namaExpense.text.isEmpty ||
          hargaExpense.text.isEmpty ||
          selectedCategory.isEmpty) {
        throw Exception("All Field Must be Filled in");
      }
     expenseService.addExpense(nama: namaExpense.text.trim(), harga:double.tryParse(hargaExpense.text) ?? 0, kategori: selectedCategory);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense added succesfully")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("New expense fail to added : ${e}")),
      );
    }
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 255, 249),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Add Expense",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: AlignmentGeometry.topRight,
                        child: Text(dateFormat.format(DateTime.now())),
                      ),
                    ),
                    const Text("Expense Name"),
                    const SizedBox(height: 8),

                    Inputexpense(
                      controller: namaExpense,
                      hintText: "e.g Grocery Shopping",
                      prefixicon: const Icon(Icons.shopping_bag),
                    ),
                    const SizedBox(height: 20),
                    const Text("Amount"),
                    const SizedBox(height: 8),
                    Inputexpense(
                      controller: hargaExpense,
                      inputType: TextInputType.number,
                      hintText: "Add cost",
                      prefixicon: const Icon(Icons.attach_money),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Category",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Categorycard(
                            judul: "Primary",
                            isi: "Essential Expense",
                            icon: Icons.home,
                            isSelected: selectedCategory == "Primary",
                            ontap: () => selectCategory("Primary"),
                          ),
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Categorycard(
                            judul: "Sekunder",
                            isi: "Optional Expense",
                            icon: Icons.shopping_cart,
                            isSelected: selectedCategory == "Secondary",
                            ontap: () => selectCategory("Secondary"),
                          ),
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Categorycard(
                            judul: "Lifestyle",
                            isi: "Entertainment",
                            icon: Icons.sports_esports,
                            isSelected: selectedCategory == "Lifestyle",
                            ontap: () => selectCategory("Lifestyle"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            SizedBox(height: 35),
            Align(
              alignment: AlignmentGeometry.bottomCenter,
              child: ElevatedButton(
                onPressed: addExpense,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  backgroundColor: Color.fromARGB(255, 76, 175, 80),
                  foregroundColor: Colors.white,
                ),
                child: Text("Save Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
