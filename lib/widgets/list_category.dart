import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:la_logika/models/categoriModel.dart';

class CategoryList extends StatelessWidget {
  final List<Categorimodel> data;

  const CategoryList({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );
    return Column(
      children: data.map((category) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: category.color,
            radius: 10,
          ),
          title: Text(category.nama,
          // overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12),
          ),
          
          trailing: Text(
            rupiah.format(category.total.toInt()),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }
}