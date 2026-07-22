import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final String? label;
  final String value;
  final bool canEdit;
  final bool isTitle;
  final VoidCallback? onEdit;
  final CrossAxisAlignment alignment;

  // Optional sizing parameters
  final double? customFontSize;
  final double? customIconSize;

  // When true, the value wraps normally onto multiple lines instead of
  // being shrunk to fit on one line. Good for longer free-text values
  // like descriptions.
  final bool wrapText;

  const EditableField({
    super.key,
    this.label,
    required this.value,
    this.canEdit = false,
    this.isTitle = false,
    this.onEdit,
    this.alignment = CrossAxisAlignment.start,
    this.customFontSize,
    this.customIconSize,
    this.wrapText = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final double finalIconSize = customIconSize ?? (isTitle ? 22.0 : 20.0);
    final double balanceWidth = isTitle ? finalIconSize + 8.0 : 0.0;

    final textStyle = isTitle
        ? tt.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      fontSize: customFontSize,
    )
        : tt.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontSize: customFontSize,
    );

    final valueText = Text(
      value,
      textAlign: alignment == CrossAxisAlignment.center
          ? TextAlign.center
          : TextAlign.start,
      softWrap: wrapText,
      style: textStyle,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (canEdit && isTitle) SizedBox(width: balanceWidth),

        Flexible(
          child: Column(
            crossAxisAlignment: alignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null) ...[
                Text(
                  label!.toUpperCase(),
                  textAlign: alignment == CrossAxisAlignment.center
                      ? TextAlign.center
                      : TextAlign.start,
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              wrapText
                  ? valueText
                  : FittedBox(
                fit: BoxFit.scaleDown,
                alignment: alignment == CrossAxisAlignment.center
                    ? Alignment.center
                    : Alignment.centerLeft,
                child: valueText,
              ),
            ],
          ),
        ),

        if (canEdit) ...[
          const SizedBox(width: 2),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primary,
            iconSize: finalIconSize,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    );
  }
}