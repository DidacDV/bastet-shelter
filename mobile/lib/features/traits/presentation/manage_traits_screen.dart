import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
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
      appBar: AppBar(title: const Text('Manage Traits')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTraitDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: traitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error loading traits: $error')),
        data: (traits) {
          if (traits.isEmpty) {
            return const Center(child: Text('No traits found. Add one!'));
          }

          return ListView.builder(
            itemCount: traits.length,
            itemBuilder: (context, index) {
              final trait = traits[index];
              return ListTile(
                title: Text(trait.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.reddish),
                      onPressed: () =>
                          _showTraitDialog(context, ref, existingTrait: trait),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () async {
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
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  ///if existingTrait is provided, it is for editing
  ///if existingTrait is null, it is for adding a trait
  void _showTraitDialog(
    BuildContext context,
    WidgetRef ref, {
    Trait? existingTrait,
  }) {
    final textController = TextEditingController(
      text: existingTrait?.name ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingTrait == null ? 'Add Trait' : 'Edit Trait'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'e.g. Playful, Shy, Energetic...',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
