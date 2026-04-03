import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/first_steps/presentation/components/animated_option_card.dart';
import 'package:flutter/material.dart';

class ManagerPickerScreen extends StatefulWidget {
  const ManagerPickerScreen({super.key});

  @override
  State<ManagerPickerScreen> createState() => _ManagerPickerScreenState();
}

class _ManagerPickerScreenState extends State<ManagerPickerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

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
      appBar: AppBar(title: const Text('Manager Options')),
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
                  Text(
                    'What would you like to do?',
                    style: tt.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select how you want to proceed',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  AnimatedOptionCard(
                    label: 'Join a Shelter',
                    icon: Icons.door_front_door,
                    onTap: () =>
                        Navigator.pushNamed(context, '/role/manager-code'),
                  ),
                  const SizedBox(height: 16),
                  AnimatedOptionCard(
                    label: 'Create a Shelter',
                    icon: Icons.add_home,
                    onTap: () =>
                        Navigator.pushNamed(context, '/role/create-shelter'),
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
