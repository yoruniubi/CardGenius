import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  String _languageCode = 'system';

  Locale? get locale => _locale;
  String get languageCode => _languageCode;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString('language_code') ?? 'system';
    _updateLocale();
  }

  void setLanguage(String code) async {
    _languageCode = code;
    _updateLocale();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
  }

  void _updateLocale() {
    if (_languageCode == 'system') {
      _locale = null;
    } else {
      _locale = Locale(_languageCode);
    }
    notifyListeners();
  }
}

final localeProvider = LocaleProvider();
