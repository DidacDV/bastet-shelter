import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/medical/data/models/medicine_model.dart';
import 'package:bastetshelter/providers/medicine/medicine_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageMedicinesScreen extends ConsumerWidget {
  const ManageMedicinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(medicinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Medicines')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMedicineDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: medicinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error loading medicines: $error')),
        data: (medicines) {
          if (medicines.isEmpty) {
            return const Center(child: Text('No medicines found. Add one!'));
          }

          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return ListTile(
                title: Text(medicine.name),
                subtitle: Text('Current Stock: ${medicine.currentStock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.reddish),
                      onPressed: () => _showMedicineDialog(
                        context,
                        ref,
                        existingMedicine: medicine,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () async {
                        final confirm = await ConfirmationDialog.show(
                          context: context,
                          title: 'Delete medicine',
                          message:
                              'Are you sure you want to delete "${medicine.name}"?',
                          isDestructive: true,
                          confirmText: 'Delete',
                        );
                        if (confirm) {
                          await ref
                              .read(medicinesProvider.notifier)
                              .deleteMedicine(medicine.id);
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

  /// if existingMedicine is provided, it is for editing
  /// if existingMedicine is null, it is for adding a medicine
  void _showMedicineDialog(
    BuildContext context,
    WidgetRef ref, {
    Medicine? existingMedicine,
  }) {
    final nameController = TextEditingController(
      text: existingMedicine?.name ?? '',
    );
    final stockController = TextEditingController(
      text: existingMedicine?.currentStock.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existingMedicine == null ? 'Add Medicine' : 'Edit Medicine',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Amoxicillin,...',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'Current Stock',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final stockStr = stockController.text.trim();

                if (name.isNotEmpty && stockStr.isNotEmpty) {
                  final stock = int.parse(stockStr);

                  if (existingMedicine == null) {
                    ref
                        .read(medicinesProvider.notifier)
                        .addMedicine(name, stock);
                  } else {
                    ref
                        .read(medicinesProvider.notifier)
                        .updateMedicine(existingMedicine.id, name, stock);
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
