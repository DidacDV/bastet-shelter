import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/app_editable_field.dart';
import 'package:bastetshelter/features/common/components/edit_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnimalDetailsHeader extends StatelessWidget {
  final String name;
  final DateTime arrivalDate;
  final DateTime birthday;
  final bool canEdit;
  final Future<void> Function(DateTime)? onArrivalDateSave;
  final Future<void> Function(DateTime)? onBirthdaySave;
  final Future<void> Function(String)? onNameSave;

  const AnimalDetailsHeader({
    super.key,
    required this.name,
    required this.arrivalDate,
    required this.birthday,
    this.canEdit = false,
    this.onArrivalDateSave,
    this.onBirthdaySave,
    this.onNameSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/Illustration-13.svg',
          height: 100,
          width: 100,
        ),
        const SizedBox(height: 16),
        Center(
          child: EditableField(
            value: name,
            isTitle: true,
            canEdit: canEdit,
            onEdit: () => showEditBottomSheet(
              context: context,
              label: "Name",
              initialValue: name,
              onSave: (newVal) async {
                await onNameSave?.call(newVal);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DateChip(
                label: "Arrival",
                date: arrivalDate,
                canEdit: canEdit,
                onEdit: !canEdit
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: arrivalDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && onArrivalDateSave != null) {
                          await onArrivalDateSave!(picked);
                        }
                      },
              ),
              _DateChip(
                label: "Birthday",
                date: birthday,
                canEdit: canEdit,
                onEdit: !canEdit
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: birthday,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && onBirthdaySave != null) {
                          await onBirthdaySave!(picked);
                        }
                      },
              ),
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
  final bool canEdit;
  final VoidCallback? onEdit;

  const _DateChip({
    required this.label,
    required this.date,
    this.canEdit = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: tt.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            if (canEdit) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
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
