import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _currentLocale = const Locale('fr'); // French by default
  
  Locale get currentLocale => _currentLocale;
  
  LanguageService() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'fr';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;
    
    _currentLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    notifyListeners();
  }
  
  String get currentLanguageName {
    switch (_currentLocale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }
}
