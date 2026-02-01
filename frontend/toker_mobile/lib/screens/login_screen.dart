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
      // User is already logged in, redirect to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
                  // Connect Button
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
                              final authService = AuthService();
                              final isNewUser = await authService.simulateTikTokAuth(id);
                              
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => isNewUser 
                                          ? const OnboardingStep1Screen() 
                                          : const HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  // Sign Up Button
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
                              final authService = AuthService();
                              try {
                                // Pass forceNewUser: true for explicit Sign Up action
                                final isNewUser = await authService.simulateTikTokAuth(id, forceNewUser: true);
                                
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => isNewUser 
                                          ? const OnboardingStep1Screen() 
                                          : const HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context); // Close loading screen
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
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
