import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/app_info_banner.dart';
import 'package:bastetshelter/features/common/components/app_statuses/empty_state.dart';
import 'package:bastetshelter/features/common/components/app_statuses/error_state.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/common/components/manage_list_card.dart';
import 'package:bastetshelter/features/tasks/presentation/components/task_form_bottomsheet.dart';
import 'package:bastetshelter/features/tasks/presentation/my_tasks_screen.dart';
import 'package:bastetshelter/providers/tasks/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BastetAppBar(
        customTitle: context.l10n.t('tasks.title'),
        showLogout: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "tasks_floatingActBtn",
        onPressed: () => showTaskFormBottomSheet(context: context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInfoBanner(
            message: context.l10n.t('tasks.infoBanner'),
            margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ).copyWith(bottom: 8),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MyTasksScreen())),
              icon: const Icon(Icons.assignment_ind_rounded),
              label: Text(context.l10n.t('tasks.viewMyAssigned')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppErrorState(message: error.toString()),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.assignment_rounded,
                    title: context.l10n.t('tasks.emptyTitle'),
                    message: context.l10n.t('tasks.emptyMessage'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return ManageListCard(
                      title: task.title,
                      titleTrailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.group_outlined,
                            size: 16,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.numPeople}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textHint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      leadingIcon: Icons.assignment_rounded,
                      isEven: index.isEven,
                      subtitle: Text(
                        task.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onEdit: () => showTaskFormBottomSheet(
                        context: context,
                        existingTask: task,
                      ),
                      onDelete: () async {
                        final confirm = await ConfirmationDialog.show(
                          context: context,
                          title: context.l10n.t('tasks.deleteTitle'),
                          message: context.l10n
                              .t('tasks.deleteMessage')
                              .replaceAll('{task}', task.title),
                          isDestructive: true,
                          confirmText: context.l10n.t('profile.delete'),
                        );
                        if (confirm) {
                          ref.read(tasksProvider.notifier).deleteTask(task.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
