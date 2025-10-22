// lib/components/responsive_login_layout.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ResponsiveLoginLayout extends StatelessWidget {
  final Widget form;
  final String imageAsset;
  final double formWidth;
  final double imageMaxWidthFraction;
  final double imageMaxWidthPx;
  final double spacing;
  final double desktopBreakpoint;
  final double? imageHeight;

  const ResponsiveLoginLayout({
    super.key,
    required this.form,
    this.imageAsset = 'assets/images/LogoCircular.png',
    this.formWidth = 450,
    this.imageMaxWidthFraction = 0.35,
    this.imageMaxWidthPx = 360,
    this.spacing = 60,
    this.desktopBreakpoint = 800,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > desktopBreakpoint;
      if (!isDesktop) return form;

      final imageMaxWidth = math.min(
          constraints.maxWidth * imageMaxWidthFraction, imageMaxWidthPx);

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: imageMaxWidth,
            height: imageHeight,
            child: Image.asset(imageAsset, fit: BoxFit.contain),
          ),
          SizedBox(width: spacing),
          SizedBox(width: formWidth, child: form),
        ],
      );
    });
  }
}
