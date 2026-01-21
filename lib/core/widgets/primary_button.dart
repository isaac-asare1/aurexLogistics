import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outline;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outline = false,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(
                outline ? theme.colorScheme.primary : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: outline ? theme.colorScheme.primary : Colors.white,
          ),
          const SizedBox(width: 10),
        ],
        Text(label),
      ],
    );

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size(0, height)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 18),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      textStyle: WidgetStateProperty.all(
        theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );

    if (outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style.copyWith(
          side: WidgetStateProperty.all(
            BorderSide(color: theme.colorScheme.primary, width: 1.2),
          ),
          foregroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
        ),
        child: child,
      );
    }

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style.copyWith(
        backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
      child: child,
    );
  }
}
