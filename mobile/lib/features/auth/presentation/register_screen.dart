import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/validators.dart';
import 'package:bastetshelter/features/auth/data/auth_repository.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _privacyPolicyUrl =
      'https://www.privacypolicies.com/live/75468d8c-1322-4ce6-9a85-696c1015c3f4';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastname1Controller = TextEditingController();
  final _lastname2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repository = getIt<AuthRepository>();
  bool _isLoading = false;
  bool _acceptedGdpr = false;
  bool _showGdprError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastname1Controller.dispose();
    _lastname2Controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(_privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _register() async {
    if (!_acceptedGdpr) {
      setState(() => _showGdprError = true);
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await genericApiCall(() async {
        await _repository.register(
          _nameController.text,
          _lastname1Controller.text,
          _lastname2Controller.text,
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/role/picker');
        }
      });

      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.l10n.t('auth.register'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.t('auth.createAccount'),
                  style: tt.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.t('auth.registerSubtitle'),
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _nameController,
                  label: context.l10n.t('auth.firstName'),
                  validator: (value) =>
                      Validators.validateRequired(value, 'first name'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _lastname1Controller,
                  label: context.l10n.t('auth.firstLastName'),
                  validator: (value) =>
                      Validators.validateRequired(value, 'first last name'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _lastname2Controller,
                  label: context.l10n.t('auth.secondLastNameOptional'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _emailController,
                  label: context.l10n.t('auth.email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passwordController,
                  label: context.l10n.t('auth.password'),
                  obscure: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () => setState(() {
                    _acceptedGdpr = !_acceptedGdpr;
                    if (_acceptedGdpr) _showGdprError = false;
                  }),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _acceptedGdpr,
                          onChanged: (v) => setState(() {
                            _acceptedGdpr = v ?? false;
                            if (_acceptedGdpr) _showGdprError = false;
                          }),
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide(
                            color: _showGdprError
                                ? AppColors.error
                                : AppColors.outline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: tt.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: context.l10n.t('auth.privacyPrefix'),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: _openPrivacyPolicy,
                                  child: Text(
                                    context.l10n.t('auth.privacyPolicy'),
                                    style: tt.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: context.l10n.t('auth.privacySuffix'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_showGdprError) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 34),
                    child: Text(
                      context.l10n.t('auth.privacyRequired'),
                      style: tt.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                PrimaryButton(
                  label: context.l10n.t('auth.register'),
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
