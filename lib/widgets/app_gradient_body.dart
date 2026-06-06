import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AppGradientBody extends StatelessWidget {
  final Widget child;
  const AppGradientBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        top: 0, left: 0, right: 0,
        height: 220,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD6E8D6), AppColors.cream],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      Positioned.fill(child: child),
    ],
  );
}
