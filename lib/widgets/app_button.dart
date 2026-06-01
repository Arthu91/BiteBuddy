import 'package:flutter/material.dart';
import '../core/app_colors.dart';

enum AppButtonVariant { primary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final Widget? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bg = switch (variant) {
      AppButtonVariant.primary => AppColors.orange,
      AppButtonVariant.danger  => const Color(0xFFDC3545),
      _                        => Colors.transparent,
    };
    final fg = switch (variant) {
      AppButtonVariant.outline => AppColors.forestGreen,
      AppButtonVariant.ghost   => AppColors.textMuted,
      AppButtonVariant.danger  => AppColors.white,
      _                        => AppColors.white,
    };
    final border = variant == AppButtonVariant.outline
        ? Border.all(color: AppColors.forestGreen, width: 1.5)
        : null;

    return SizedBox(
      width: width,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: (loading || onPressed == null) ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: border,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    IconTheme(data: IconThemeData(color: fg, size: 18), child: icon!),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
