import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class AppTableHeader extends StatelessWidget {
  final List<AppTableColumn> columns;

  const AppTableHeader({super.key, required this.columns});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: columns
            .map(
              (col) => Expanded(
                flex: col.flex,
                child: Text(
                  col.label,
                  textAlign: col.textAlign,
                  style: headerStyle,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class AppTableColumn {
  final String label;
  final int flex;
  final TextAlign textAlign;

  const AppTableColumn({
    required this.label,
    this.flex = 1,
    this.textAlign = TextAlign.left,
  });
}
