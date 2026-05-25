import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AppLocalizations? _cachedLocalizations;

class _TestAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _TestAppLocalizationsDelegate(this.localizations);

  final AppLocalizations localizations;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => localizations;

  @override
  bool shouldReload(_TestAppLocalizationsDelegate old) => false;
}

Future<AppLocalizations> loadTestLocalizations() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  _cachedLocalizations ??= await AppLocalizations.load(const Locale('en'));
  return _cachedLocalizations!;
}

Future<void> pumpLocalizedWidget(WidgetTester tester, Widget child) async {
  final localizations = await loadTestLocalizations();
  const delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        locale: localizations.locale,
        localizationsDelegates: [
          _TestAppLocalizationsDelegate(localizations),
          ...delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(child: SizedBox(width: 420, child: child)),
      ),
    ),
  );
  await tester.pump();
}

Future<void> pumpSimpleWidget(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Material(child: SizedBox(width: 420, child: child)),
    ),
  );
  await tester.pump();
}
