import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/core/providers/shelter_notifier.dart';

import 'components/add_refuge_modal.dart';

class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelterAsync = ref.watch(shelterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: shelterAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(e.toString(), style: const TextStyle(color: Colors.red)),
          ),
          data: (shelter) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shelter Info', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _InfoRow(label: 'Name', value: shelter.name),
              const SizedBox(height: 12),
              _InfoRow(label: 'Location', value: shelter.province.name),
              const SizedBox(height: 12),
              _InfoRow(label: 'Volunteer Code', value: shelter.volunteerCode ?? 'Not available'),
              const SizedBox(height: 12),
              _InfoRow(label: 'Manager Code', value: shelter.managerCode ?? 'Not available'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref.read(shelterProvider.notifier).resetVolunteerCode(),
                child: const Text('Change Volunteer Code'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(shelterProvider.notifier).resetManagerCode(),
                child: const Text('Change Manager Code'),
              ),
              const SizedBox(height: 12),
              const Text('Refuges', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              for (final refuge in shelter.refuges) ...[
                _InfoRow(label: refuge.name, value: refuge.province.name),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const AddRefugeModal(),
                  );
                },
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Add Refuge'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}