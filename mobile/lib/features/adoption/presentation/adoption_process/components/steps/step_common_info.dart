import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/step_notes_bottomsheet.dart';
import 'package:bastetshelter/providers/adoption/adoption_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StepCommonInfo extends ConsumerWidget {
  const StepCommonInfo({
    super.key,
    required this.step,
    required this.processId,
  });

  final AdoptionStepDetails step;
  final int processId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd MMM yyyy');
    final hasNotes = step.notes?.isNotEmpty == true;

    Future<void> saveNotes(String notes) async {
      await ref
          .read(adoptionDetailProvider(processId).notifier)
          .updateNotes(notes, step.id);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.getStepName(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _InfoBlock(
                label: 'Status',
                child: Text(
                  step.status.name[0].toUpperCase() +
                      step.status.name.substring(1),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _InfoBlock(
                label: 'Finish date',
                child: step.finishDate != null
                    ? Text(
                        fmt.format(step.finishDate!),
                        style: theme.textTheme.bodyMedium,
                      )
                    : Text(
                        'Not finished yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textHint,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        //nOTES SECTION
        if (hasNotes)
          _InfoBlock(
            label: 'Notes',
            trailing: InkWell(
              onTap: () => showStepNotesBottomSheet(
                context: context,
                initialNotes: step.notes,
                onSave: saveNotes,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                step.notes!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          )
        else
          _InfoBlock(
            label: 'Notes',
            child: IconButton(
              onPressed: () => showStepNotesBottomSheet(
                context: context,
                initialNotes: null,
                onSave: saveNotes,
              ),
              icon: const Icon(Icons.add_rounded, size: 24),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.all(2),
                shape: const CircleBorder(),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.child, this.trailing});

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
