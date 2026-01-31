import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toker_mobile/l10n/app_localizations.dart';
import 'package:toker_mobile/screens/login_screen.dart';
import 'package:toker_mobile/services/language_service.dart';
import 'package:toker_mobile/theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageService(),
      child: const TokerApp(),
    ),
  );
}

class TokerApp extends StatelessWidget {
  const TokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
          title: 'Toker',
          debugShowCheckedModeBanner: false,
          locale: languageService.currentLocale,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr'),
            Locale('en'),
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.neonRed,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
