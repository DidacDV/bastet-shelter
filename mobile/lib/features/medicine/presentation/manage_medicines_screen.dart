import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/app_statuses/empty_state.dart';
import 'package:bastetshelter/features/common/components/app_statuses/error_state.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/manage_list_card.dart';
import 'package:bastetshelter/features/medicine/data/models/medicine_model.dart';
import 'package:bastetshelter/providers/medicine/medicine_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageMedicinesScreen extends ConsumerWidget {
  const ManageMedicinesScreen({super.key});

  Color _stockColor(int stock) {
    if (stock == 0) return AppColors.error;
    if (stock <= 5) return AppColors.warning;
    return AppColors.accent;
  }

  Color _stockTint(int stock) {
    if (stock == 0) return AppColors.errorTint;
    if (stock <= 5) return AppColors.warningTint;
    return AppColors.accentTint;
  }

  String _stockLabel(BuildContext context, int stock) {
    if (stock == 0) return context.l10n.t('medicine.outOfStock');
    if (stock <= 5) return context.l10n.t('medicine.lowStock');
    return context.l10n.t('medicine.inStock');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(medicinesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('medicine.title'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMedicineDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        child: const Icon(Icons.add_rounded),
      ),
      body: medicinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorState(message: error.toString()),
        data: (medicines) {
          if (medicines.isEmpty) {
            return AppEmptyState(
              icon: Icons.medical_information_outlined,
              title: context.l10n.t('medicine.emptyTitle'),
              message: context.l10n.t('medicine.emptyMessage'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              final stock = medicine.currentStock;

              return ManageListCard(
                title: medicine.name,
                leadingIcon: Icons.medication_rounded,
                isEven: index.isEven,
                subtitle: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _stockTint(stock),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _stockLabel(context, stock),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _stockColor(stock),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n
                          .t('medicine.unitsCount')
                          .replaceAll('{count}', '$stock'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                onEdit: () => _showMedicineDialog(
                  context,
                  ref,
                  existingMedicine: medicine,
                ),
                onDelete: () async {
                  final confirm = await ConfirmationDialog.show(
                    context: context,
                    title: context.l10n.t('medicine.deleteMedicine'),
                    message: context.l10n
                        .t('medicine.deleteMedicineMessage')
                        .replaceAll('{medicine}', medicine.name),
                    isDestructive: true,
                    confirmText: context.l10n.t('profile.delete'),
                  );
                  if (confirm) {
                    await ref
                        .read(medicinesProvider.notifier)
                        .deleteMedicine(medicine.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

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
    final isEditing = existingMedicine != null;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                      Icons.medication_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing
                        ? context.l10n.t('medicine.editMedicine')
                        : context.l10n.t('medicine.newMedicine'),
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.t('medicine.name'),
                  hintText: context.l10n.t('medicine.nameHint'),
                  prefixIcon: const Icon(
                    Icons.medication_liquid_rounded,
                    size: 20,
                  ),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                decoration: InputDecoration(
                  labelText: context.l10n.t('medicine.currentStock'),
                  hintText: context.l10n.t('medicine.stockHint'),
                  prefixIcon: const Icon(Icons.inventory_2_rounded, size: 20),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.t('common.cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
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
                                .updateMedicine(
                                  existingMedicine.id,
                                  name,
                                  stock,
                                );
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        isEditing
                            ? context.l10n.t('common.save')
                            : context.l10n.t('common.add'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
