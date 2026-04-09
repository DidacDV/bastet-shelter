import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/section_card.dart';
import 'package:bastetshelter/features/medical/presentation/manage_medicines_screen.dart';
import 'package:bastetshelter/features/traits/presentation/manage_traits_screen.dart';
import 'package:flutter/material.dart';

class ManagementCard extends StatelessWidget {
  const ManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Management',
      icon: Icons.admin_panel_settings_rounded,
      child: Column(
        children: [
          _NavTile(
            icon: Icons.medication_rounded,
            label: 'Medicines',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageMedicinesScreen()),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(height: 1),
          ),
          _NavTile(
            icon: Icons.label_rounded,
            label: 'Traits',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TraitsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
