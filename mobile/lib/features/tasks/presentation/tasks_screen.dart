import 'package:bastetshelter/core/constants.dart';
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
      appBar: const BastetAppBar(customTitle: 'Tasks', showLogout: false),
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
          const AppInfoBanner(
            message:
                'These tasks can then be used and assigned when creating volunteer shifts.',
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
              label: const Text('View My Assigned Tasks'),
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
                  return const AppEmptyState(
                    icon: Icons.assignment_rounded,
                    title: 'No tasks yet',
                    message: 'Tap "+" to create your first task.',
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
                          title: 'Delete Task',
                          message:
                              'Are you sure you want to delete "${task.title}"?',
                          isDestructive: true,
                          confirmText: 'Delete',
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
