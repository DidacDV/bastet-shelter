import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/contract_step_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ContractStepView extends ConsumerWidget {
  const ContractStepView({
    super.key,
    required this.step,
    required this.processId,
  });

  final ContractStepDetails step;
  final int processId;

  //TODO: FIX
  Future<void> _downloadPdf(String rawUrl) async {
    final parts = rawUrl.split('/upload/');
    final downloadUrl = '${parts[0]}/upload/fl_attachment/${parts[1]}';
    final uri = Uri.parse(downloadUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  void _viewPdf(BuildContext context, String url) {
    //TODO: USE PDFRX TO DISPLAY PREVIEW
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasContract =
        step.contractUrl != null && step.contractUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Contract Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: hasContract
                    ? () => _viewPdf(context, step.contractUrl!)
                    : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('View PDF'),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: hasContract
                ? () => _downloadPdf(step.contractUrl!)
                : null,
            icon: const Icon(Icons.download),
            label: const Text('Download'),
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
                  subtitle: const Text('Manager signature verified'),
                  value: step.signedByShelter ?? false,
                  onChanged: (bool? value) {
                    //     ref
                    //           .read(adoptionDetailProvider(processId).notifier)
                    //             .updateShelterSignature(value ?? false);
                  },
                ),
                const Divider(height: 1),
                CheckboxListTile(
                  title: const Text('Signed by Adoptant'),
                  subtitle: const Text('Adoptant signature verified'),
                  value: step.signedByAdoptant ?? false,
                  onChanged: (bool? value) {
                    //       ref
                    //       .read(adoptionDetailProvider(processId).notifier)
                    //         .updateAdoptantSignature(value ?? false);
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
