import 'package:bastetshelter/core/animations/stagger_entrance_mixin.dart';
import 'package:bastetshelter/core/animations/staggered_helper.dart';
import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/common/components/app_text_field.dart';
import 'package:bastetshelter/features/common/components/illustrated_header.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CodeScreenMode { volunteer, manager }

class CodeEntryScreen extends StatefulWidget {
  final CodeScreenMode mode;
  const CodeEntryScreen({super.key, required this.mode});

  @override
  State<CodeEntryScreen> createState() => _CodeEntryScreenState();
}

class _CodeEntryScreenState extends State<CodeEntryScreen>
    with TickerProviderStateMixin, StaggerEntranceMixin {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  final _repository = getIt<ShelterRepository>();

  bool _isLoading = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  static const _childCount = 2;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _shakeController.forward(from: 0);
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _isLoading = true);

    await genericApiCall(() async {
      switch (widget.mode) {
        case CodeScreenMode.volunteer:
          await _repository.joinAsVolunteer(code);
          break;
        case CodeScreenMode.manager:
          await _repository.joinAsManager(code);
          break;
      }
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isVolunteer = widget.mode == CodeScreenMode.volunteer;

    final s0 = staggerAnim(0, _childCount);
    final s2 = staggerAnim(3, _childCount);

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
                    const SizedBox(height: 8),

                    Staggered(
                      fade: s0.fade,
                      slide: s0.slide,
                      child: IllustratedHeader(
                        imageWidget: SvgPicture.asset(
                          isVolunteer
                              ? 'assets/images/Illustration-10.svg'
                              : 'assets/images/Illustration-1.svg',
                          height: 180,
                        ),
                        badgeLabel: isVolunteer ? 'VOLUNTEER' : 'MANAGER',
                        badgeColor: isVolunteer
                            ? AppColors.primary
                            : AppColors.secondary,
                        title:
                            'Join as\n${isVolunteer ? 'Volunteer' : 'Manager'}',
                        subtitle:
                            'Enter the unique code provided by the shelter to access their workspace.',
                      ),
                    ),
                    const SizedBox(height: 32),

                    Staggered(
                      fade: s2.fade,
                      slide: s2.slide,
                      child: AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(_shakeAnim.value, 0),
                          child: child,
                        ),
                        child: AppTextField(
                          controller: _codeController,
                          label: 'Shelter Code',
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          style: const TextStyle(
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Staggered(
                      fade: s2.fade,
                      slide: s2.slide,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Codes are case insensitive',
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
              child: PrimaryButton(
                label: 'Join Shelter',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
