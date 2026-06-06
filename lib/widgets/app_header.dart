import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;
  final Color? backgroundColor;

  const AppHeader({super.key, this.actions, this.leading, this.showLogo = true, this.backgroundColor});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? const Color(0xFFD6E8D6),
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
