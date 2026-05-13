import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/shifts/presentation/components/shift_task_section.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'components/shift_overview_section.dart';
import 'components/shift_participants_section.dart';

class ShiftDetailScreen extends ConsumerWidget {
  final int shiftId;
  final String refugeName;
  final bool isManager;

  const ShiftDetailScreen({
    super.key,
    required this.shiftId,
    required this.refugeName,
    this.isManager = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(shiftDetailProvider(shiftId));
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BastetAppBar(
        customTitle: 'Shift Details',
        showBackButton: true,
        showLogout: false,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (shiftDetail) {
          final notifier = ref.read(shiftDetailProvider(shiftId).notifier);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShiftOverviewSection(
                  shiftId: shiftId,
                  shiftDetail: shiftDetail,
                  refugeName: refugeName,
                  isManager: isManager,
                ),
                const SizedBox(height: 6),

                ShiftParticipantsSection(
                  shiftId: shiftId,
                  shiftDetail: shiftDetail,
                  isManager: isManager,
                ),
                const SizedBox(height: 6),

                ShiftTasksSection(
                  shiftId: shiftId,
                  shiftDetail: shiftDetail,
                  isManager: isManager,
                ),

                const SizedBox(height: 32),

                PrimaryButton(
                  label: shiftDetail.isJoined ? 'Leave Shift' : 'Join Shift',
                  backgroundColor: shiftDetail.isJoined
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.primary,
                  textColor: shiftDetail.isJoined
                      ? AppColors.error
                      : AppColors.surface,

                  isLoading: false,
                  onPressed: () async {
                    if (shiftDetail.isJoined) {
                      final confirm = await ConfirmationDialog.show(
                        context: context,
                        title: 'Leave Shift?',
                        message:
                            'Are you sure you want to leave this shift? You will be unassigned from any tasks.',
                        confirmText: 'Leave',
                        isDestructive: true,
                      );

                      if (confirm) {
                        await notifier.leaveShift(shiftId);
                      }
                    } else {
                      await notifier.joinShift(shiftId);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
