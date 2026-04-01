import 'package:flutter/material.dart';

class Categorycard extends StatelessWidget {
  final String judul;
  final IconData icon;
  final String isi;
  final bool isSelected;
  final VoidCallback ontap;
  const Categorycard({super.key,
  required this.judul,
  required this.icon,
  required this.isi,
  required this.isSelected,
  required this.ontap,
  
  });

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: ontap,
    child: SizedBox( 
      width: 100,
      height: 120,
      child: Card(
        color: isSelected ? Colors.green : Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                judul,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
