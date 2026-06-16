import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color fgColor;
  final VoidCallback onTap;
  final bool displayIcon;

  const StatCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.fgColor,
    required this.onTap,
    this.displayIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: fgColor.withValues(alpha: 0.1),
        highlightColor: fgColor.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: fgColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: fgColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: fgColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: fgColor),
              ),

              if (displayIcon) const SizedBox(width: 16),
              if (displayIcon)
                Container(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.arrow_forward, size: 32, color: fgColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
