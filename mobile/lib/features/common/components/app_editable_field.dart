import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final String? label;
  final String value;
  final bool canEdit;
  final bool isTitle;
  final VoidCallback? onEdit;
  final CrossAxisAlignment alignment;

  const EditableField({
    super.key,
    this.label,
    required this.value,
    this.canEdit = false,
    this.isTitle = false,
    this.onEdit,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    //width of icon + padding
    final double balanceWidth = isTitle ? 22.0 + 8.0 : 0.0;

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
              Text(
                value,
                textAlign: alignment == CrossAxisAlignment.center
                    ? TextAlign.center
                    : TextAlign.start,
                style: isTitle
                    ? tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      )
                    : tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
              ),
            ],
          ),
        ),

        if (canEdit) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primary,
            iconSize: isTitle ? 22 : 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    );
  }
}
