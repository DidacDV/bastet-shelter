import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:flutter/material.dart';

class AdvertisementCard extends StatelessWidget {
  final AdvertisementSummary advertisement;
  final VoidCallback onTap;

  const AdvertisementCard({
    super.key,
    required this.advertisement,
    required this.onTap,
  });

  Widget _buildNoImage(BuildContext context, ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          context.l10n.t('community.noImage'),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasValidUrl =
        advertisement.imageUrl != null &&
        advertisement.imageUrl!.startsWith('http');

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: advertisement.isActive ? 1.0 : 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasValidUrl
                        ? Image.network(
                            advertisement.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildNoImage(context, theme);
                            },
                          )
                        : _buildNoImage(context, theme),

                    if (!advertisement.isActive)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            context.l10n.t('community.inactive').toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advertisement.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _localizedCategory(
                        context,
                        advertisement.category,
                      ).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      advertisement.provinceName.isEmpty
                          ? context.l10n.t('community.unknownLocation')
                          : advertisement.provinceName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedCategory(BuildContext context, AdCategory category) =>
      switch (category) {
        AdCategory.food => context.l10n.t('community.categoryFood'),
        AdCategory.medicine => context.l10n.t('community.categoryMedicine'),
        AdCategory.equipment => context.l10n.t('community.categoryEquipment'),
        AdCategory.toys => context.l10n.t('community.categoryToys'),
        AdCategory.other => context.l10n.t('community.categoryOther'),
      };
}
