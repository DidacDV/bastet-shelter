import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:bastetshelter/features/community/presentation/components/advertisement_card.dart';
import 'package:bastetshelter/features/community/presentation/my_advertisements_screen.dart';
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

    final isManager = true;

    return Scaffold(
      appBar: BastetAppBar(
        customTitle: 'Community Marketplace',
        showLogout: false,
      ),

      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              heroTag: 'community_fab',
              onPressed: () {},
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 2,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'New Ad',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            )
          : null,

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
                child: const Text('See your shelter advertisements'),
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
                    decoration: const InputDecoration(
                      hintText: 'Search title...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
                    hint: const Text('Category'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...AdCategory.values.map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name.toUpperCase()),
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
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (ads) {
                final filteredAds = ads.where((ad) {
                  final matchesSearch = ad.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                  final matchesCategory =
                      _selectedCategory == null ||
                      ad.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredAds.isEmpty) {
                  return const Center(child: Text('No advertisements found.'));
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
                    return AdvertisementCard(advertisement: ad, onTap: () {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
