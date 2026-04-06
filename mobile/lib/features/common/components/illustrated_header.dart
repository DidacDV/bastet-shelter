import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/first_steps/presentation/components/member_mode_display.dart';
import 'package:flutter/material.dart';

class IllustratedHeader extends StatelessWidget {
  final Widget imageWidget;
  final String? badgeLabel;
  final String title;
  final String subtitle;
  final Color? badgeColor;

  const IllustratedHeader({
    super.key,
    required this.imageWidget,
    required this.title,
    required this.subtitle,
    this.badgeColor,
    this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: imageWidget),
        const SizedBox(height: 36),

        if (badgeLabel != null) ...[
          SectionBadge(
            label: badgeLabel!,
            color: badgeColor ?? AppColors.primary,
          ),
          const SizedBox(height: 12),
        ],

        Text(
          title,
          style: tt.headlineLarge?.copyWith(height: 1.1, letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),

        Text(
          subtitle,
          style: tt.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
