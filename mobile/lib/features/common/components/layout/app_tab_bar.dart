import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class AppTabLayout extends StatefulWidget {
  final Widget? header;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final int initialIndex;

  final ValueChanged<int>? onTabChanged;

  const AppTabLayout({
    super.key,
    this.header,
    required this.tabs,
    required this.tabViews,
    this.initialIndex = 0,
    this.onTabChanged,
  }) : assert(
         tabs.length == tabViews.length,
         'The number of tabs must match the number of tabViews',
       );

  @override
  State<AppTabLayout> createState() => _AppTabLayoutState();
}

class _AppTabLayoutState extends State<AppTabLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );

    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    //(flutter fires this listener multiple times during a swipe animation)
    if (_tabController.index != _currentIndex) {
      _currentIndex = _tabController.index;
      widget.onTabChanged?.call(_currentIndex);
    }
  }

  @override
  void didUpdateWidget(covariant AppTabLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _tabController.index = widget.initialIndex;
      _currentIndex = widget.initialIndex;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        if (widget.header != null) widget.header!,

        TabBar(
          controller: _tabController,
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
          tabs: widget.tabs,
        ),

        Expanded(
          child: Container(
            color: AppColors.background,
            child: TabBarView(
              controller: _tabController,
              children: widget.tabViews,
            ),
          ),
        ),
      ],
    );
  }
}
