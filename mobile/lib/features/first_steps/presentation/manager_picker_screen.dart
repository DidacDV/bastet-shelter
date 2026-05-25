import 'package:bastetshelter/core/animations/stagger_entrance_mixin.dart';
import 'package:bastetshelter/core/animations/staggered_helper.dart';
import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/first_steps/presentation/components/animated_option_card.dart';
import 'package:flutter/material.dart';

class ManagerPickerScreen extends StatefulWidget {
  const ManagerPickerScreen({super.key});

  @override
  State<ManagerPickerScreen> createState() => _ManagerPickerScreenState();
}

class _ManagerPickerScreenState extends State<ManagerPickerScreen>
    with TickerProviderStateMixin, StaggerEntranceMixin {
  static const _childCount = 4;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final s0 = staggerAnim(0, _childCount);
    final s1 = staggerAnim(1, _childCount);
    final s2 = staggerAnim(2, _childCount);
    final s3 = staggerAnim(3, _childCount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Staggered(
                      fade: s0.fade,
                      slide: s0.slide,
                      child: Text(
                        context.l10n.t('firstSteps.managerQuestion'),
                        style: tt.headlineLarge?.copyWith(
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Staggered(
                      fade: s1.fade,
                      slide: s1.slide,
                      child: Text(
                        context.l10n.t('firstSteps.managerSubtitle'),
                        style: tt.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    Staggered(
                      fade: s2.fade,
                      slide: s2.slide,
                      child: AnimatedOptionCard(
                        label: context.l10n.t('firstSteps.joinShelterAction'),
                        icon: Icons.door_front_door,
                        onTap: () =>
                            Navigator.pushNamed(context, '/role/manager-code'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Staggered(
                      fade: s3.fade,
                      slide: s3.slide,
                      child: AnimatedOptionCard(
                        label: context.l10n.t('firstSteps.createShelterAction'),
                        icon: Icons.add_home,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/role/create-shelter',
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
