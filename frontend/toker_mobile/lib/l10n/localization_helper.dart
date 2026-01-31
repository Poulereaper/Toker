import 'package:flutter/material.dart';
import 'app_localizations.dart';

// Helper extension to simplify translation access
extension LocalizationHelper on BuildContext {
  String tr(String key) {
    return AppLocalizations(Localizations.localeOf(this).languageCode).translate(key);
  }
}
