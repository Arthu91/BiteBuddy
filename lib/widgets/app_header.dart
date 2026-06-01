import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;

  const AppHeader({super.key, this.actions, this.leading, this.showLogo = true});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      automaticallyImplyLeading: true,
      title: showLogo ? Image.asset('assets/images/logo.png', height: 36) : null,
      centerTitle: false,
      actions: actions,
    );
  }
}
