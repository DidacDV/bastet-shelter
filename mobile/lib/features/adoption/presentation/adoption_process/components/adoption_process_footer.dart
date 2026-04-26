import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/rejection_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:flutter/material.dart';

class AdoptionProcessFooter extends StatefulWidget {
  final Future<void> Function(String reason) onReject;
  final Future<void> Function(String? notes) onApprove;

  const AdoptionProcessFooter({
    super.key,
    required this.onReject,
    required this.onApprove,
  });

  @override
  State<AdoptionProcessFooter> createState() => _AdoptionProcessFooterState();
}

class _AdoptionProcessFooterState extends State<AdoptionProcessFooter> {
  bool _isApproving = false;

  Future<void> _handleApprove() async {
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: 'Approve',
      message:
          'Are you sure you want to approve this step? Make sure to add some notes!',
      isDestructive: false,
      confirmText: 'Approve',
    );

    if (!confirm) {
      return;
    }

    setState(() => _isApproving = true);
    try {
      await widget.onApprove(null);
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _isApproving
                      ? null
                      : () {
                          showRejectAdoptionBottomSheet(
                            context: context,
                            onReject: widget.onReject,
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    backgroundColor: AppColors.accentTint.withValues(
                      alpha: 0.05,
                    ),
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Reject & Notify',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: PrimaryButton(
                label: 'Approve & Continue',
                isLoading: _isApproving,
                onPressed: _handleApprove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
