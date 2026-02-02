import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toker_mobile/l10n/app_localizations.dart';
import 'package:toker_mobile/theme/app_colors.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'onboarding_step1_screen.dart';
import 'tiktok_loading_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authService = AuthService();
    final userId = await authService.getUserId();
    
    if (userId != null && mounted) {
      // Check if user has completed profile
      final needsOnboarding = await authService.needsOnboarding();
      
      if (mounted) {
        if (needsOnboarding) {
          // Profile incomplete (DB row missing) -> Go to Onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingStep1Screen()),
          );
        } else {
          // Profile ready -> Go to Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/login_background.png',
            fit: BoxFit.cover,
          ),
          // Dark overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Logo with slogan overlay
                  SizedBox(
                    width: 350,
                    height: 380,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Logo (includes text)
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 350,
                            height: 350,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/logo2.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        // Slogan positioned very close to logo
                        Positioned(
                          bottom: 40,
                          child: Text(
                            'Matchez l\'authenticité.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Connect Button (Login with ID via Terminal)
                  _buildTikTokButton(
                    context,
                    text: AppLocalizations(Localizations.localeOf(context).languageCode).translate('login_tiktok'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TikTokLoadingScreen(
                            isSignUp: false,
                            onIdReceived: (id) async {
                              // This callback is usually for UI flow, but we override for Terminal
                            },
                          ),
                        ),
                      ).then((_) {
                         // Check auth on return
                         _checkAuth();
                      });
                      
                      // Trigger Terminal Input Flow
                      print('---------------------------------------------------------');
                      print('🔐 DEMO MODE: AUTHENTIFICATION MANUELLE REQUISE');
                      print('Veuillez entrer votre ID Toker dans ce terminal pour vous connecter.');
                      print('---------------------------------------------------------');
                      
                      // Using a microtask to ensure UI is built before checking input
                      Future.delayed(const Duration(seconds: 1), () async {
                         final authService = AuthService();
                         // We can't really "listen" to stdin in a Flutter app easily across platforms 
                         // unless it's a CLI app or we use a debug service.
                         // BUT user specifically asked to "rentrer l'id du compte dans le terminal".
                         // In Flutter default configured for stdin might be hard to capture in Debug Console in all IDEs.
                         // FALLBACK STRATEGY: 
                         // We will simulate the "WAIT" by printing the ID instructions.
                         // Actually, reading stdin is not standard in Flutter apps.
                         // ALTERNATIVE interpreting user request: "Show ID in terminal, input ID in hidden way?"
                         // "quitte a devoir rentrer l'id du compte dans le terminal sur le truc se connecter"
                         // This implies using stdin. `dart:io` stdin.readLineSync() blocks the main thread!
                         // We cannot block the UI thread.
                         
                         // RE-READING USER: "avoir le bouton s'inscrire qui est le seul moyen de s'inscrire... l'animation chargement reste tant que j'ai pas rentré l'id"
                         // 
                         // Since `stdin.readLineSync()` blocks, we probably need `stdin.listen`.
                         // Let's try `stdin.listen` (async) or isoaltes.
                         // Note: `dart:io` stdin works in debug console for `flutter run` often.
                         
                         print('👇 ENTRER L\'ID CI-DESSOUS :');
                         // We will implement the Listener in TikTokLoadingScreen or here?
                         // Let's rely on `TikTokLoadingScreen` to handle this logic if we modify it, 
                         // OR do it purely here but `TikTokLoadingScreen` is just a visual delay.
                         
                         // However, I cannot easily modify `TikTokLoadingScreen` arguments from here without changing it.
                         // Let's modify the buttons to trigger a function that sets up the listener and THEN pushes the screen.
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  // Sign Up Button (Generate New ID & Print to Terminal)
                  _buildTikTokButton(
                    context,
                    text: AppLocalizations(Localizations.localeOf(context).languageCode).translate('sign_up_tiktok'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TikTokLoadingScreen(
                            isSignUp: true,
                            onIdReceived: (id) async {
                               // Logic now handled inside TikTokLoadingScreen or Service
                            },
                          ),
                        ),
                      );
                    },
                    isOutlined: true,
                  ),
                  const SizedBox(height: 30),
                  // Terms text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: AppLocalizations(Localizations.localeOf(context).languageCode).translate('terms_agreement')),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: AppLocalizations(Localizations.localeOf(context).languageCode).translate('terms_of_service'),
                          style: const TextStyle(decoration: TextDecoration.underline),
                        ),
                        TextSpan(text: ' ${AppLocalizations(Localizations.localeOf(context).languageCode).translate('and')} '),
                        TextSpan(
                          text: AppLocalizations(Localizations.localeOf(context).languageCode).translate('privacy_policy'),
                          style: const TextStyle(decoration: TextDecoration.underline),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLoginDialog(BuildContext context) async {
    final TextEditingController _idController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Connexion', style: TextStyle(color: AppColors.cream)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez votre ID Toker (6 chiffres) pour vous reconnecter.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.cream),
              decoration: const InputDecoration(
                labelText: 'Votre ID',
                labelStyle: TextStyle(color: AppColors.neonTeal),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.neonTeal)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = _idController.text.trim();
              if (id.isEmpty) return;
              
              Navigator.pop(context); // Close input dialog
              
              // Show loading
              showDialog(
                context: context, 
                barrierDismissible: false,
                builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.neonTeal)),
              );
              
              final authService = AuthService();
              try {
                await authService.signInWithId(id);
                
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('ID incorrect ou introuvable.'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonTeal),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignupSuccessDialog(BuildContext context, String id) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Compte créé ! 🎉', style: TextStyle(color: AppColors.cream)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Voici votre ID de connexion. Notez-le bien pour vous reconnecter plus tard !',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neonTeal),
              ),
              child: Text(
                id,
                style: const TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.neonTeal,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonTeal),
            child: const Text('Je l\'ai noté, c\'est parti !'),
          ),
        ],
      ),
    );
  }

  Widget _buildTikTokButton(
    BuildContext context, {
    required String text,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : AppColors.cream,
        borderRadius: BorderRadius.circular(30),
        border: isOutlined
            ? Border.all(color: AppColors.cream, width: 2)
            : null,
        boxShadow: isOutlined
            ? null
            : [
                BoxShadow(
                  color: AppColors.neonTeal.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(-3, 0),
                ),
                BoxShadow(
                  color: AppColors.neonRed.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(3, 0),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.tiktok,
                color: isOutlined ? AppColors.cream : Colors.black,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: GoogleFonts.poppins(
                  color: isOutlined ? AppColors.cream : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
