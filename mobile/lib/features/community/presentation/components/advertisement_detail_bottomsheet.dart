import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/localization/localized_mappers.dart';
import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:bastetshelter/providers/community/advertisement_detail_provider.dart';
import 'package:bastetshelter/providers/community/advertisement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

//to separate the functionalities between "see your shelter adv.." and the normal community
enum AdSheetMode { browse, myAds }

void showAdvertisementDetailSheet(
  BuildContext context,
  int advertisementId, {
  AdSheetMode mode = AdSheetMode.browse,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _AdvertisementDetailSheet(advertisementId: advertisementId, mode: mode),
  );
}

class _AdvertisementDetailSheet extends ConsumerWidget {
  final int advertisementId;
  final AdSheetMode mode;

  const _AdvertisementDetailSheet({
    required this.advertisementId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      advertisementDetailControllerProvider(advertisementId),
    );
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: detailAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                context.l10n.t('community.detailsLoadError'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            data: (ad) => _SheetContent(
              ad: ad,
              scrollController: scrollController,
              mode: mode,
            ),
          ),
        );
      },
    );
  }
}

class _SheetContent extends ConsumerStatefulWidget {
  final AdvertisementDetail ad;
  final ScrollController scrollController;
  final AdSheetMode mode;

  const _SheetContent({
    required this.ad,
    required this.scrollController,
    required this.mode,
  });

  @override
  ConsumerState<_SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends ConsumerState<_SheetContent> {
  bool _deactivating = false;

  Future<void> _handleDeactivate() async {
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: context.l10n.t('community.deactivateAd'),
      message: context.l10n
          .t('community.deactivateAdMessage')
          .replaceAll('{ad}', widget.ad.title),
      confirmText: context.l10n.t('community.deactivate'),
      isDestructive: true,
    );

    if (confirm != true || !mounted) return;

    setState(() => _deactivating = true);
    await ref
        .read(advertisementsProvider.notifier)
        .deactivateAdvertisement(widget.ad.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        widget.ad.imageUrl != null && widget.ad.imageUrl!.startsWith('http');

    return Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Expanded(
          child: CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              if (hasImage)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.ad.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CategoryChip(category: widget.ad.category),
                          const Spacer(),
                          if (!widget.ad.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorTint,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                context.l10n.t('community.inactive'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        widget.ad.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.ad.provinceName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(widget.ad.publishedOn),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 16),

                      Text(
                        context.l10n.t('common.description'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.ad.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 16),

                      Text(
                        context.l10n.t('community.postedBy'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.pets_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          widget.ad.shelterName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          widget.ad.shelterEmail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          width: double.infinity,
          child: switch (widget.mode) {
            AdSheetMode.browse => FilledButton.icon(
              onPressed: () => _launchEmail(widget.ad.shelterEmail),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.mail_outline_rounded, size: 18),
              label: Text(
                context.l10n.t('community.contactShelter'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            AdSheetMode.myAds =>
              widget.ad.isActive
                  ? OutlinedButton.icon(
                      onPressed: _deactivating ? null : _handleDeactivate,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _deactivating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(Icons.visibility_off_outlined, size: 18),
                      label: Text(
                        _deactivating
                            ? context.l10n.t('community.deactivating')
                            : context.l10n.t('community.deactivateAd'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          context.l10n.t('community.adAlreadyInactive'),
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _CategoryChip extends StatelessWidget {
  final AdCategory category;

  const _CategoryChip({required this.category});

  static const _icons = <AdCategory, IconData>{
    AdCategory.food: Icons.restaurant_rounded,
    AdCategory.medicine: Icons.medical_services_rounded,
    AdCategory.equipment: Icons.build_rounded,
    AdCategory.toys: Icons.toys_rounded,
    AdCategory.other: Icons.category_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icons[category] ?? Icons.category_rounded,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            context.localizedAdCategory(category),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
