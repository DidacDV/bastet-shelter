import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class AppTabLayout extends StatelessWidget {
  final Widget? header;
  final List<Tab> tabs;
  final List<Widget> tabViews;

  const AppTabLayout({
    super.key,
    this.header,
    required this.tabs,
    required this.tabViews,
  }) : assert(
         tabs.length == tabViews.length,
         'The number of tabs must match the number of tabViews',
       );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          ?header,

          TabBar(
            labelStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            dividerColor: AppColors.outline,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3.0,
            tabs: tabs,
          ),

          Expanded(
            child: Container(
              color: AppColors.background,
              child: TabBarView(children: tabViews),
            ),
          ),
        ],
      ),
    );
  }
}
