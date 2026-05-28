import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/common/components/section_card.dart';
import 'package:bastetshelter/features/shelter/data/external_integration_model.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExternalIntegrationCard extends StatefulWidget {
  const ExternalIntegrationCard({super.key, this.showHeader = true});

  final bool showHeader;

  @override
  State<ExternalIntegrationCard> createState() =>
      _ExternalIntegrationCardState();
}

class _ExternalIntegrationCardState extends State<ExternalIntegrationCard> {
  final _repository = getIt<ShelterRepository>();
  ExternalIntegration? _integration;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIntegration();
  }

  Future<void> _loadIntegration() async {
    try {
      final integration = await _repository.getExternalIntegrationInfo();
      if (mounted) {
        setState(() {
          _integration = integration;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard(String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Text(_error!, style: const TextStyle(color: Colors.red))
        : _integration == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.t('shelter.externalIntegrationDescription'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _CopyField(
                label: context.l10n.t('shelter.urlPattern'),
                value: _integration!.urlPattern,
                onCopy: () => _copyToClipboard(
                  _integration!.urlPattern,
                  context.l10n.t('shelter.linkCopied'),
                ),
              ),
              const SizedBox(height: 12),
              _CopyField(
                label: context.l10n.t('shelter.htmlButtonSnippet'),
                value: _integration!.buttonHtmlTemplate,
                onCopy: () => _copyToClipboard(
                  _integration!.buttonHtmlTemplate,
                  context.l10n.t('shelter.snippetCopied'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _integration!.usageHint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                _integration!.duplicateNameHint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
              ),
            ],
          );

    if (!widget.showHeader) {
      return content;
    }

    return SectionCard(
      title: context.l10n.t('shelter.externalIntegration'),
      icon: Icons.link_rounded,
      child: content,
    );
  }
}

class _CopyField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _CopyField({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: context.l10n.t('common.copy'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
