import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/app_statuses/empty_state.dart';
import 'package:bastetshelter/features/common/components/app_statuses/error_state.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/manage_list_card.dart';
import 'package:bastetshelter/features/traits/data/trait_model.dart';
import 'package:bastetshelter/providers/traits/trait_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TraitsScreen extends ConsumerWidget {
  const TraitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final traitsAsync = ref.watch(traitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Traits')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTraitDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        child: const Icon(Icons.add_rounded),
      ),
      body: traitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorState(message: error.toString()),
        data: (traits) {
          if (traits.isEmpty) {
            return const AppEmptyState(
              icon: Icons.pets_rounded,
              title: 'No traits yet',
              message: 'Tap "Add" to create your first trait.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: traits.length,
            itemBuilder: (context, index) {
              final trait = traits[index];

              return ManageListCard(
                title: trait.name,
                leadingIcon: Icons.label_rounded,
                isEven: index.isEven,
                onEdit: () =>
                    _showTraitDialog(context, ref, existingTrait: trait),
                onDelete: () async {
                  final confirm = await ConfirmationDialog.show(
                    context: context,
                    title: 'Delete trait',
                    message:
                        'Are you sure you want to delete the "${trait.name}" trait?',
                    isDestructive: true,
                    confirmText: 'Delete',
                  );
                  if (confirm) {
                    await ref
                        .read(traitsProvider.notifier)
                        .deleteTrait(trait.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showTraitDialog(
    BuildContext context,
    WidgetRef ref, {
    Trait? existingTrait,
  }) {
    final textController = TextEditingController(
      text: existingTrait?.name ?? '',
    );
    final isEditing = existingTrait != null;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.label_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Trait' : 'New Trait',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Trait name',
                    hintText: 'e.g. Playful, Shy...',
                    prefixIcon: Icon(Icons.edit_note_rounded, size: 20),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final name = textController.text.trim();
                          if (name.isNotEmpty) {
                            if (existingTrait == null) {
                              ref.read(traitsProvider.notifier).addTrait(name);
                            } else {
                              ref
                                  .read(traitsProvider.notifier)
                                  .updateTrait(existingTrait.id, name);
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text(isEditing ? 'Save' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
