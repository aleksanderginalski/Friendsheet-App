import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/providers/app_locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLocaleProvider', () {
    test('default locale is English', () {
      final provider = AppLocaleProvider();
      expect(provider.locale, const Locale('en'));
    });

    test('loadSavedLocale with no stored value keeps English', () async {
      final provider = AppLocaleProvider();
      await provider.loadSavedLocale();
      expect(provider.locale, const Locale('en'));
    });

    test('loadSavedLocale restores persisted locale', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'pl'});
      final provider = AppLocaleProvider();
      await provider.loadSavedLocale();
      expect(provider.locale, const Locale('pl'));
    });

    test('setLocale updates locale and persists it', () async {
      final provider = AppLocaleProvider();
      await provider.setLocale(const Locale('pl'));

      expect(provider.locale, const Locale('pl'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'pl');
    });

    test('setLocale with same locale does not notify', () async {
      final provider = AppLocaleProvider();
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.setLocale(const Locale('en'));

      expect(notified, isFalse);
    });

    test('full cycle: set Polish, reload, verify restored', () async {
      final provider = AppLocaleProvider();
      await provider.setLocale(const Locale('pl'));

      final provider2 = AppLocaleProvider();
      await provider2.loadSavedLocale();
      expect(provider2.locale, const Locale('pl'));
    });
  });
}
