import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/community/presentation/components/advertisement_card.dart';
import 'package:bastetshelter/providers/community/my_advertisements_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyAdvertisementsScreen extends ConsumerWidget {
  const MyAdvertisementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAdsAsync = ref.watch(myAdvertisementsProvider);

    return Scaffold(
      appBar: BastetAppBar(
        customTitle: 'My Shelter Ads',
        showBackButton: true,
        showLogout: false,
        showConfig: false,
      ),
      body: myAdsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (ads) {
          if (ads.isEmpty) {
            return const Center(
              child: Text('Your shelter has no active advertisements.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return AdvertisementCard(
                advertisement: ad,
                onTap: () {
                  // TODO: navigate to Advertisement Detail Screen
                },
              );
            },
          );
        },
      ),
    );
  }
}
