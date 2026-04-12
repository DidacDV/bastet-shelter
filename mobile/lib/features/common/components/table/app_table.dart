import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class AppTable extends StatelessWidget {
  final int itemCount;
  final Widget header;
  final Widget Function(BuildContext context, int index) rowBuilder;
  final int headerOverflow = 1;

  const AppTable({
    super.key,
    required this.itemCount,
    required this.header,
    required this.rowBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Scrollbar(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: itemCount + headerOverflow, //+1 for header
            separatorBuilder: (_, index) => index == 0
                ? const Divider(
                    height: 16,
                    thickness: 1,
                    color: AppColors.divider,
                  )
                : Divider(
                    height: 16,
                    thickness: 0.5,
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
            itemBuilder: (context, index) {
              if (index == 0) return header;
              return rowBuilder(context, index - headerOverflow);
            },
          ),
        ),
      ),
    );
  }
}
