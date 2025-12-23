import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';

enum CustomButtonType { primary, secondary, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == CustomButtonType.primary
                    ? AppColors.primaryForeground
                    : AppColors.primary,
              ),
            ),
          )
        else if (icon != null) ...[
          icon!,
          const SizedBox(width: AppDimensions.spacingSm),
        ],
        if (!isLoading)
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
      ],
    );

    Widget button;

    switch (type) {
      case CustomButtonType.primary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          child: buttonChild,
        );
        break;

      case CustomButtonType.secondary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.secondaryForeground,
          ),
          child: buttonChild,
        );
        break;

      case CustomButtonType.outlined:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          child: buttonChild,
        );
        break;

      case CustomButtonType.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          child: buttonChild,
        );
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppDimensions.buttonHeightMd,
      child: button,
    );
  }
}
