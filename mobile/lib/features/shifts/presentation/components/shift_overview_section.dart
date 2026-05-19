import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:bastetshelter/features/shifts/presentation/components/shift_time_bubble.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'shift_detail_shared.dart';

class ShiftOverviewSection extends ConsumerWidget {
  final int shiftId;
  final ShiftDetail shiftDetail;
  final String refugeName;
  final bool isManager;

  const ShiftOverviewSection({
    super.key,
    required this.shiftId,
    required this.shiftDetail,
    required this.refugeName,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final notifier = ref.read(shiftDetailProvider(shiftId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.t('shifts.overview'),
          tt: tt,
          trailing: isManager
              ? TextButton.icon(
                  onPressed: () async {
                    final confirm = await ConfirmationDialog.show(
                      context: context,
                      title: context.l10n.t('shifts.deleteShiftTitle'),
                      message: context.l10n.t('shifts.deleteShiftMessage'),
                      confirmText: context.l10n.t('profile.delete'),
                      isDestructive: true,
                    );

                    if (confirm && context.mounted) {
                      await notifier.deleteThisShift();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: Text(context.l10n.t('profile.delete')),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
        Card(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                EditableRow(
                  icon: Icons.home_work_outlined,
                  label: context.l10n.t('common.refuge'),
                  value: refugeName,
                  canEdit: false,
                  onEdit: () {},
                ),
                const Divider(height: 24, color: AppColors.outline),
                EditableRow(
                  icon: Icons.calendar_today_outlined,
                  label: context.l10n.t('common.date'),
                  value: dateFormat.format(shiftDetail.day),
                  canEdit: false,
                  onEdit: () {},
                ),
                const Divider(height: 24, color: AppColors.outline),
                EditableRow(
                  icon: Icons.access_time_rounded,
                  label: context.l10n.t('common.time'),
                  valueWidget: ShiftTimeBubble(
                    startTime: shiftDetail.startTime,
                    endTime: shiftDetail.endTime,
                  ),
                  canEdit: isManager,
                  onEdit: () async {
                    final startTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        shiftDetail.startTime,
                      ),
                      helpText: context.l10n.t('shifts.selectStartTime'),
                    );
                    if (startTime == null || !context.mounted) return;

                    final endTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(shiftDetail.endTime),
                      helpText: context.l10n.t('shifts.selectEndTime'),
                    );
                    if (endTime == null) return;

                    final newStart = DateTime(
                      shiftDetail.startTime.year,
                      shiftDetail.startTime.month,
                      shiftDetail.startTime.day,
                      startTime.hour,
                      startTime.minute,
                    );
                    final newEnd = DateTime(
                      shiftDetail.endTime.year,
                      shiftDetail.endTime.month,
                      shiftDetail.endTime.day,
                      endTime.hour,
                      endTime.minute,
                    );

                    notifier.updateShift(startTime: newStart, endTime: newEnd);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
