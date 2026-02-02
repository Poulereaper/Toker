import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'onboarding_step1_screen.dart';

class TikTokLoadingScreen extends StatefulWidget {
  final Future<void> Function(String) onIdReceived; // Kept for compatibility but unused in internal logic
  final bool isSignUp;
  
  const TikTokLoadingScreen({
    super.key,
    required this.onIdReceived,
    this.isSignUp = false,
  });

  @override
  State<TikTokLoadingScreen> createState() => _TikTokLoadingScreenState();
}

class _TikTokLoadingScreenState extends State<TikTokLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  final _authService = AuthService();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // 1. Setup Animation (Restoring the "Moving" Logo)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate( // Subtle rotation
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // 2. Start Logic
    _processAuth();
  }

  Future<void> _processAuth() async {
    // Artificial delay for "Authenticating..." vibe
    await Future.delayed(const Duration(seconds: 2));

    if (widget.isSignUp) {
      // --- SIGN UP FLOW (Automatic) ---
      try {
        final shortId = await _authService.signUpWithRandomId();
        if (shortId != null) {
          // Print Secret ID to Terminal
          print('\n\n\n');
          print('==========================================');
          print('🎉 COMPTE CRÉÉ AVEC SUCCÈS !');
          print('🔑 VOTRE ID DE CONNEXION :  $shortId');
          print('==========================================');
          print('\n\n\n');

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingStep1Screen()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        print('Erreur Inscription: $e');
        if (mounted) Navigator.pop(context);
      }
    } 
    // ELSE: LOGIN FLOW -> WAITS INDEFINITELY for Secret Gesture
  }

  // --- HIDDEN INPUT LOGIC ---
  void _showHiddenLoginDialog() {
    final TextEditingController _idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Mode Démo : Connexion', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _idController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Entrer ID Secret',
            labelStyle: TextStyle(color: AppColors.neonTeal),
            enabledBorder:  UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder:  UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonTeal)),
          ),
        ),
        actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
           ),
           TextButton(
             onPressed: () => _handleLogin(_idController.text),
             child: const Text('GO', style: TextStyle(color: AppColors.neonTeal, fontWeight: FontWeight.bold)),
           ),
        ],
      ),
    );
  }

  Future<void> _handleLogin(String id) async {
    if (id.isEmpty) return;
    Navigator.pop(context); // Close dialog

    setState(() => _isProcessing = true);
    
    try {
      await _authService.signInWithId(id.trim());
      // Success
      if (mounted) {
         Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Error
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ ID Incorrect'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // --- ANIMATED LOGO WITH SECRET GESTURE ---
            GestureDetector(
              onLongPress: () {
                if (!widget.isSignUp) {
                  print('🕵️‍♂️ Secret Gesture Detected!');
                  _showHiddenLoginDialog();
                }
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.neonTeal,
                              AppColors.neonRed,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonTeal.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: AppColors.neonRed.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          FontAwesomeIcons.tiktok,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Text Status
            if (_isProcessing)
              const CircularProgressIndicator(color: AppColors.neonTeal)
            else
              Column(
                children: [
                  Text(
                    widget.isSignUp 
                        ? 'Analyse de votre authenticité...' 
                        : 'Connexion en cours...',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.isSignUp 
                        ? 'Création du profil...' 
                        : 'En attente d\'authentification...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            
            const Spacer(),
            
            // Hint text (Optional - can be removed to be fully secret)
            if (!widget.isSignUp)
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Text(
                  '(Restez appuyé sur le logo pour forcer l\'accès)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.3),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
