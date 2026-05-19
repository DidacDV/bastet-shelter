import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLanguage {
  final Locale locale;
  final String labelKey;

  const AppLanguage({required this.locale, required this.labelKey});
}

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _messages;

  const AppLocalizations(this.locale, this._messages);

  static const defaultLocale = Locale('en');
  static const supportedLanguages = [
    AppLanguage(locale: Locale('en'), labelKey: 'language.english'),
    AppLanguage(locale: Locale('ca'), labelKey: 'language.catalan'),
    AppLanguage(locale: Locale('es'), labelKey: 'language.spanish'),
  ];
  static const supportedLocales = [Locale('en'), Locale('ca'), Locale('es')];
  static const translatedLocales = [Locale('en'), Locale('ca')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  static bool isSupported(String languageCode) {
    return supportedLocales.any(
      (locale) => locale.languageCode == languageCode,
    );
  }

  static bool hasTranslations(String languageCode) {
    return translatedLocales.any(
      (locale) => locale.languageCode == languageCode,
    );
  }

  static AppLanguage languageFor(String languageCode) {
    return supportedLanguages.firstWhere(
      (language) => language.locale.languageCode == languageCode,
      orElse: () => supportedLanguages.first,
    );
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final languageCode = hasTranslations(locale.languageCode)
        ? locale.languageCode
        : defaultLocale.languageCode;
    final jsonString = await rootBundle.loadString(
      'assets/i18n/$languageCode.json',
    );
    final messages = (json.decode(jsonString) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return AppLocalizations(Locale(languageCode), messages);
  }

  String t(String key, {Map<String, String> params = const {}}) {
    var value = _messages[key] ?? key;
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.isSupported(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate _) => false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
