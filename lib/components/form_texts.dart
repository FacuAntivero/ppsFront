// lib/components/form_texts.dart
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final double height;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.suffixIcon,
    this.validator,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        textAlignVertical: TextAlignVertical.center,
        autocorrect: false,
        cursorColor: Colors.teal,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
