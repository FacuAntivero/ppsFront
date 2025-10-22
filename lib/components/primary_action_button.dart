import 'package:flutter/material.dart';

class PrimaryActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;
  final double height;
  final double borderRadius;

  const PrimaryActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.loading = false,
    this.height = 52,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
    );
  }
}
