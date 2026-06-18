import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/contract_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_common_info.dart';
import 'package:bastetshelter/features/common/pdf_viewer.dart';
import 'package:bastetshelter/providers/adoption/adoption_detail_provider.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
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

  Future<void> _downloadPdf(String rawUrl) async {
    final parts = rawUrl.split('/upload/');
    final downloadUrl = '${parts[0]}/upload/fl_attachment/${parts[1]}';
    final uri = Uri.parse(downloadUrl);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Cannot launch URL: $uri — $e');
    }
  }

  void _viewPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          url: url,
          title: context.l10n.t('adoption.contract'),
        ),
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
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      context.l10n.t('adoption.viewPdf'),
                      maxLines: 1,
                    ),
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
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      context.l10n.t('adoption.download'),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!hasContract)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                context.l10n.t('adoption.contractNotGenerated'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                  title: Text(context.l10n.t('adoption.signedByShelter')),
                  value: step.signedByShelter ?? false,
                  onChanged: (bool? value) {
                    ref
                        .read(adoptionDetailProvider(processId).notifier)
                        .updateShelterSignature();
                  },
                ),
                const Divider(height: 1),
                CheckboxListTile(
                  title: Text(context.l10n.t('adoption.signedByAdoptant')),
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
