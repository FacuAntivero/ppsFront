import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final Widget? suffixIcon;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.suffixIcon,
    required String? Function(dynamic v) validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      textAlignVertical: TextAlignVertical.center,
      autocorrect: false,
      cursorColor: Colors.teal,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsetsGeometry.zero,
      ),
    );
  }
}
