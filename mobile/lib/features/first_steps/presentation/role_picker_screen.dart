import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/first_steps/presentation/components/animated_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RolePickerScreen extends StatefulWidget {
  const RolePickerScreen({super.key});

  @override
  State<RolePickerScreen> createState() => _RolePickerScreenState();
}

class _RolePickerScreenState extends State<RolePickerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final assetName = 'assets/images/Illustration-17.svg';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.l10n.t('firstSteps.getStarted'))),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SvgPicture.asset(
                    assetName,
                    semanticsLabel: 'Dart Logo',
                    height: 140,
                    width: 500,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    context.l10n.t('firstSteps.roleQuestion'),
                    style: tt.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.t('firstSteps.roleSubtitle'),
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  AnimatedOptionCard(
                    label: context.l10n.t('firstSteps.volunteer'),
                    icon: Icons.volunteer_activism,
                    onTap: () =>
                        Navigator.pushNamed(context, '/role/volunteer-code'),
                  ),
                  const SizedBox(height: 16),
                  AnimatedOptionCard(
                    label: context.l10n.t('firstSteps.manager'),
                    icon: Icons.manage_accounts,
                    onTap: () =>
                        Navigator.pushNamed(context, '/role/manager-picker'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
