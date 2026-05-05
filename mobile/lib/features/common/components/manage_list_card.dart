import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class ManageListCard extends StatelessWidget {
  final String title;
  final Widget? titleTrailing;
  final Widget? subtitle;
  final IconData leadingIcon;
  final bool isEven;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ManageListCard({
    super.key,
    required this.title,
    this.titleTrailing,
    this.subtitle,
    required this.leadingIcon,
    this.isEven = true,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cardColor = isEven ? Colors.transparent : AppColors.surface;

    final cardBorder = isEven
        ? BorderSide.none
        : const BorderSide(color: AppColors.divider, width: 1);

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: cardBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(leadingIcon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(title, style: theme.textTheme.titleMedium),
                      ),
                      if (titleTrailing != null) ...[
                        const SizedBox(width: 8),
                        titleTrailing!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    subtitle!,
                  ],
                ],
              ),
            ),

            IconButton(
              icon: Icon(
                Icons.edit_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: onEdit,
              tooltip: 'Edit',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_rounded,
                size: 20,
                color: theme.colorScheme.error,
              ),
              onPressed: onDelete,
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
