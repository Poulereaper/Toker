import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';

class TikTokLoadingScreen extends StatefulWidget {
  final Future<void> Function(String) onIdReceived;
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

  bool _showButton = false;
  bool _isProcessing = false;
  String? _demoId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Simulate auth process
    _simulateAuth();
  }

  void _simulateAuth() async {
    // Wait for "authentication"
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _demoId = 'tiktok_user_${DateTime.now().millisecondsSinceEpoch}';
        _showButton = true;
      });
    }
  }

  void _onContinue() async {
    if (_demoId != null && !_isProcessing) {
       setState(() {
        _isProcessing = true;
      });
      
      // Call the callback which handles the async auth logic
      await widget.onIdReceived(_demoId!);
      
      // If we're still mounted (though navigation usually happens), reset state
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Animated TikTok-style logo
            AnimatedBuilder(
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
                        gradient: LinearGradient(
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
            
            const SizedBox(height: 40),
            
            // Text changes based on state
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _showButton 
                  ? Column(
                      key: const ValueKey('success'),
                      children: [
                        Text(
                          'Connexion réussie !',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bienvenue ${_demoId?.split('_').last}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('loading'),
                      children: [
                        Text(
                          widget.isSignUp ? 'Création de compte...' : 'Connexion à TikTok...',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.isSignUp ? 'Configuration du profil...' : 'Authentification en cours',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
            ),
            
            const SizedBox(height: 40),
            
            // Action or Loading
            SizedBox(
              height: 55,
              width: 260,
              child: _showButton 
                  ? ElevatedButton(
                      onPressed: _isProcessing ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 5,
                        padding: _isProcessing 
                            ? EdgeInsets.zero 
                            : const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isProcessing 
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Continuer vers Toker',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    )
                  : Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonTeal),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
            ),
            
            const Spacer(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
