import 'package:flutter/material.dart';

class Buttoncategory extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSelected;
  const Buttoncategory({
    super.key,
   required this.text,
   required this.onTap,
    required this.isSelected 
   });

  @override
  Widget build(BuildContext context) {
    return  TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black
      ),
      child: Text(text),

    );
  }
}
