import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class RejectionBanner extends StatelessWidget {
  final String reason;
  const RejectionBanner({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'This adoption process was rejected with the next reason: ',
              style: tt.bodyMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: reason,
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
