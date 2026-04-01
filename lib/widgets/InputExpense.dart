import 'package:flutter/material.dart';

class Inputexpense extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType inputType;
  final String hintText;
  final Icon prefixicon;
  const Inputexpense({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixicon,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        hintText: hintText,
        prefixIcon: prefixicon,
      ),
    );
  }
}
