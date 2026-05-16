import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/contract_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_common_info.dart';
import 'package:bastetshelter/features/common/pdf_viewer.dart';
import 'package:bastetshelter/providers/adoption/adoption_detail_provider.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContractStepView extends ConsumerWidget {
  const ContractStepView({
    super.key,
    required this.step,
    required this.processId,
  });

  final ContractStepDetails step;
  final int processId;

  //TODO: ON EMULTARO, IT CRASHES, TEST P
  Future<void> _downloadPdf(String rawUrl) async {
    //final parts = rawUrl.split('/upload/');
    //final downloadUrl = '${parts[0]}/upload/fl_attachment/${parts[1]}';
    //final uri = Uri.parse(downloadUrl);

    //if (!await canLaunchUrl(uri)) {
    //debugPrint('Cannot launch URL: $uri');
    //return;
    //}

    //  await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  void _viewPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(url: url, title: 'Contract'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasContract =
        step.contractUrl != null && step.contractUrl!.isNotEmpty;

    final isManager = ref.watch(isManagerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepCommonInfo(step: step, processId: processId),
          const SizedBox(height: 26),
          const Divider(),
          const SizedBox(height: 26),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                  ),
                  onPressed: hasContract
                      ? () => _viewPdf(context, step.contractUrl!)
                      : null,
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('View PDF', maxLines: 1),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                  ),
                  onPressed: hasContract
                      ? () => _downloadPdf(step.contractUrl!)
                      : null,
                  icon: const Icon(Icons.download, size: 20),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Download', maxLines: 1),
                  ),
                ),
              ),
            ],
          ),
          if (!hasContract)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Contract document has not been generated yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text('Signed by Shelter'),
                  value: step.signedByShelter ?? false,
                  onChanged: (bool? value) {
                    ref
                        .read(adoptionDetailProvider(processId).notifier)
                        .updateShelterSignature();
                  },
                ),
                const Divider(height: 1),
                CheckboxListTile(
                  title: const Text('Signed by Adoptant'),
                  value: step.signedByAdoptant ?? false,
                  onChanged: (bool? value) {
                    isManager
                        ? null
                        : ref
                              .read(adoptionDetailProvider(processId).notifier)
                              .updateAdoptantSignature();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
