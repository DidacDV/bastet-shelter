import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class AppTabLayout extends StatefulWidget {
  final Widget? header;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;

  final bool showOnlySelectedLabel;

  const AppTabLayout({
    super.key,
    this.header,
    required this.tabs,
    required this.tabViews,
    this.initialIndex = 0,
    this.onTabChanged,
    this.showOnlySelectedLabel = false,
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
    if (_tabController.index != _currentIndex) {
      setState(() {
        _currentIndex = _tabController.index;
      });
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

    //if showOnlySelected label is set, we search for the selected tab and only show its text
    final List<Widget> displayTabs = widget.showOnlySelectedLabel
        ? widget.tabs.asMap().entries.map((entry) {
            final isSelected = entry.key == _currentIndex;
            final originalText = entry.value.text;

            return Tab(
              icon: entry.value.icon,
              child: isSelected && originalText != null
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(originalText),
                    )
                  : null,
            );
          }).toList()
        : widget.tabs;

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
          tabs: displayTabs,
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
