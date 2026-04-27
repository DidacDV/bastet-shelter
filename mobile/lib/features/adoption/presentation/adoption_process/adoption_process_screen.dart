import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/adoption_process_body.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/adoption_process_footer.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/adoption_process_header.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/rejection_banner.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/providers/adoption/adoption_detail_provider.dart';
import 'package:bastetshelter/providers/adoption/adoption_screen_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptionProcessScreen extends ConsumerWidget {
  final int adoptionProcessId;

  const AdoptionProcessScreen({super.key, required this.adoptionProcessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenDataAsync = ref.watch(
      adoptionScreenDataProvider(adoptionProcessId),
    );

    return Scaffold(
      appBar: const BastetAppBar(
        customTitle: 'Adoption Process',
        showBackButton: true,
      ),
      body: screenDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading data')),
        data: (data) {
          final isDone =
              data.process.status.name == 'rejected' ||
              data.process.status.name == 'completed';
          final isRejected = data.process.status.name == 'rejected';
          return Column(
            children: [
              AdoptionProcessHeader(
                process: data.process,
                animalName: data.animal.name,
                adoptantName: data.adoptant.name,
                animalImageUrl: data.animal.primaryImageUrl,
              ),
              if (isRejected)
                RejectionBanner(
                  reason:
                      data.process.rejectionReason ??
                      'No reason provided for this rejection.',
                ),
              Expanded(
                child: AdoptionProcessBody(
                  steps: data.process.steps,
                  processId: data.process.id,
                ),
              ),
              if (!isDone)
                AdoptionProcessFooter(
                  onReject: (reason) async {
                    await ref
                        .read(
                          adoptionDetailProvider(adoptionProcessId).notifier,
                        )
                        .rejectProcess(reason);
                  },
                  onApprove: (notes) async {
                    await ref
                        .read(
                          adoptionDetailProvider(adoptionProcessId).notifier,
                        )
                        .advanceStep(notes: notes);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
