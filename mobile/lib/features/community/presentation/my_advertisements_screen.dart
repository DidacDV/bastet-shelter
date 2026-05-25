import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/community/presentation/components/advertisement_card.dart';
import 'package:bastetshelter/features/community/presentation/components/create_advertisement_bottomsheet.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
import 'package:bastetshelter/providers/community/my_advertisements_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'components/advertisement_detail_bottomsheet.dart';

class MyAdvertisementsScreen extends ConsumerStatefulWidget {
  const MyAdvertisementsScreen({super.key});

  @override
  ConsumerState<MyAdvertisementsScreen> createState() =>
      _MyAdvertisementsScreenState();
}

class _MyAdvertisementsScreenState
    extends ConsumerState<MyAdvertisementsScreen> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final myAdsAsync = ref.watch(myAdvertisementsProvider);
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      appBar: BastetAppBar(
        customTitle: context.l10n.t('community.myShelterAds'),
        showBackButton: true,
        showLogout: false,
        showConfig: false,
      ),

      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              heroTag: 'community_fab',
              onPressed: () {
                showCreateAdvertisementSheet(context);
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 2,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                context.l10n.t('community.newAd'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            )
          : null,

      body: myAdsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            context.l10n
                .t('common.errorWithMessage')
                .replaceAll('{error}', '$err'),
          ),
        ),
        data: (ads) {
          final filteredAds = _showInactive
              ? ads
              : ads.where((ad) => ad.isActive).toList();

          return Column(
            children: [
              SwitchListTile(
                title: Text(context.l10n.t('community.showInactiveAds')),
                value: _showInactive,
                onChanged: (val) {
                  setState(() {
                    _showInactive = val;
                  });
                },
              ),

              Expanded(
                child: filteredAds.isEmpty
                    ? Center(
                        child: Text(
                          _showInactive
                              ? context.l10n.t('community.noShelterAds')
                              : context.l10n.t('community.noActiveShelterAds'),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                            onTap: () => showAdvertisementDetailSheet(
                              context,
                              ad.id,
                              mode: AdSheetMode.myAds,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
