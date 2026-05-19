import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePreferenceKey = 'app_locale';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadSavedLocale();
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (AppLocalizations.isSupported(platformLocale.languageCode)) {
      return Locale(platformLocale.languageCode);
    }
    return AppLocalizations.defaultLocale;
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localePreferenceKey);
    if (languageCode == null || !AppLocalizations.isSupported(languageCode)) {
      return;
    }
    state = Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    final languageCode = AppLocalizations.isSupported(locale.languageCode)
        ? locale.languageCode
        : AppLocalizations.defaultLocale.languageCode;
    final nextLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePreferenceKey, languageCode);
    state = nextLocale;
  }
}
