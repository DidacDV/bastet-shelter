import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnimalDetailsHeader extends StatelessWidget {
  final String name;
  final DateTime arrivalDate;
  final DateTime birthday;

  const AnimalDetailsHeader({
    super.key,
    required this.name,
    required this.arrivalDate,
    required this.birthday,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/Illustration-13.svg',
          height: 130,
          width: 130,
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: tt.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DateChip(label: "Arrival", date: arrivalDate),
              _DateChip(label: "Birthday", date: birthday),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime date;

  const _DateChip({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: tt.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          MaterialLocalizations.of(context).formatMediumDate(date),
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
