import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:bastetshelter/features/community/presentation/components/advertisement_card.dart';
import 'package:bastetshelter/features/community/presentation/components/advertisement_detail_bottomsheet.dart';
import 'package:bastetshelter/features/community/presentation/my_advertisements_screen.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
import 'package:bastetshelter/providers/community/advertisement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String _searchQuery = '';
  AdCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(advertisementsProvider);
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      appBar: BastetAppBar(
        customTitle: context.l10n.t('community.marketplace'),
        showLogout: false,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyAdvertisementsScreen(),
                    ),
                  );
                },
                child: Text(
                  isManager
                      ? context.l10n.t('community.manageShelterAds')
                      : context.l10n.t('community.seeShelterAds'),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: context.l10n.t('community.searchHint'),
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<AdCategory?>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    initialValue: _selectedCategory,
                    hint: Text(context.l10n.t('community.category')),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(context.l10n.t('community.all')),
                      ),
                      ...AdCategory.values.map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(_localizedCategory(context, cat)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: adsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  context.l10n
                      .t('common.errorWithMessage')
                      .replaceAll('{error}', '$err'),
                ),
              ),
              data: (ads) {
                final filteredAds = ads.where((ad) {
                  final matchesSearch =
                      ad.provinceName.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      ad.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                  final matchesCategory =
                      _selectedCategory == null ||
                      ad.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredAds.isEmpty) {
                  return Center(
                    child: Text(context.l10n.t('community.noAdsFound')),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredAds.length,
                  itemBuilder: (context, index) {
                    final ad = filteredAds[index];
                    return AdvertisementCard(
                      advertisement: ad,
                      onTap: () => showAdvertisementDetailSheet(context, ad.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
