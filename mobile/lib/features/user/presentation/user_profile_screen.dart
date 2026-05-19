import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/localization/locale_provider.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/auth/data/auth_repository.dart';
import 'package:bastetshelter/features/auth/presentation/login_screen.dart';
import 'package:bastetshelter/features/common/components/app_statuses/error_state.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/user/data/user_model.dart';
import 'package:bastetshelter/features/user/data/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _repository = getIt<UserRepository>();

  UserProfile? _profile;
  bool _loading = true;
  final bool _hasError = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await genericApiCall(() async {
      final profile = await _repository.getMyProfile();
      if (mounted) setState(() => _profile = profile);
    });
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _handleDeleteAccount() async {
    final l10n = context.l10n;
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: l10n.t('profile.deleteAccount'),
      message: l10n.t('profile.deleteAccountMessage'),
      confirmText: l10n.t('profile.delete'),
      isDestructive: true,
    );

    if (!confirm || !mounted) return;

    setState(() => _deleting = true);

    bool success = false;

    await genericApiCall(() async {
      await _repository.deleteUser();
      await getIt<AuthRepository>().logout();
      success = true;
    });

    if (mounted) setState(() => _deleting = false);

    if (success && mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('profile.title')),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _hasError || _profile == null
          ? AppErrorState(message: l10n.t('profile.loadError'))
          : _buildContent(tt),
    );
  }

  Widget _buildContent(TextTheme tt) {
    final user = _profile!;
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryTint,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: tt.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.fullName,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.person_outline_rounded,
                label: l10n.t('profile.firstName'),
                value: user.name,
              ),
              const Divider(height: 1, indent: 56, color: AppColors.divider),
              _InfoRow(
                icon: Icons.badge_outlined,
                label: l10n.t('profile.firstSurname'),
                value: user.lastName1,
              ),
              if (user.lastName2 != null) ...[
                const Divider(height: 1, indent: 56, color: AppColors.divider),
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: l10n.t('profile.secondSurname'),
                  value: user.lastName2!,
                ),
              ],
              const Divider(height: 1, indent: 56, color: AppColors.divider),
              _InfoRow(
                icon: Icons.mail_outline_rounded,
                label: l10n.t('profile.email'),
                value: user.email,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        Text(
          l10n.t('profile.preferencesSection'),
          style: tt.labelSmall?.copyWith(
            color: AppColors.textHint,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _LanguageCard(tt: tt),

        const SizedBox(height: 40),

        Text(
          l10n.t('profile.accountSection'),
          style: tt.labelSmall?.copyWith(
            color: AppColors.textHint,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: ListTile(
            leading: _deleting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
            title: Text(
              l10n.t('profile.deleteAccount'),
              style: tt.bodyMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.t('profile.deleteAccountSubtitle'),
              style: tt.bodySmall?.copyWith(color: AppColors.textHint),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
            ),
            onTap: _deleting ? null : _handleDeleteAccount,
          ),
        ),
      ],
    );
  }
}

class _LanguageCard extends ConsumerWidget {
  final TextTheme tt;

  const _LanguageCard({required this.tt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: ListTile(
        leading: const Icon(Icons.language_rounded, color: AppColors.primary),
        title: Text(
          l10n.t('profile.language'),
          style: tt.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          l10n.t('profile.languageSubtitle'),
          style: tt.bodySmall?.copyWith(color: AppColors.textHint),
        ),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: locale.languageCode,
            borderRadius: BorderRadius.circular(12),
            items: AppLocalizations.supportedLanguages
                .map(
                  (language) => DropdownMenuItem(
                    value: language.locale.languageCode,
                    child: Text(l10n.t(language.labelKey)),
                  ),
                )
                .toList(),
            onChanged: (languageCode) {
              if (languageCode == null) return;
              ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
            },
          ),
        ),
      ),
    );
  }
}

//i dont want to adapt info_row to this layout, ill leave this here
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(color: AppColors.textHint),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
