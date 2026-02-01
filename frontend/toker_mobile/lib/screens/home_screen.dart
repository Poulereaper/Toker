import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../models/swipe.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/match_service.dart';
import '../widgets/swipeable_card.dart';
import '../widgets/confetti_widget.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'likes_screen.dart';
import 'standouts_screen.dart';
import 'profile_detail_screen.dart';
import 'onboarding_step1_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _profileService = ProfileService();
  final _matchService = MatchService();
  final _authService = AuthService();
  
  List<Profile> _profiles = [];
  Profile? _currentUser;
  bool _isLoading = true;
  int _currentProfileIndex = 0;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }
  
  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    
    // Get current user ID (Supabase Auth)
    final userId = await _authService.getUserId();

    if (userId == null) {
       // Not authenticated, redirect to Login
       if (mounted) {
         Navigator.pushReplacementNamed(context, '/login'); // Ensure route exists or push logic
         // Fallback manual push if route not named
         /* Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); */
       }
       return;
    }
    
    // Load current user profile
    try {
      final currentUser = await _profileService.getCurrentUser(userId);
      final profiles = await _profileService.getDiscoverProfiles(userId);
      
      if (mounted) {
        setState(() {
          _currentUser = currentUser;
          _profiles = profiles;
          _isLoading = false;
          _currentProfileIndex = 0;
        });
      }
    } catch (e) {
      print('❌ HomeScreen loading error: $e');
      
      // Check if error is "Profile not found"
      if (e.toString().contains('Profil utilisateur non trouvé')) {
         print('⚠️ Profile missing, redirecting to Onboarding...');
         if (mounted) {
           Navigator.pushReplacement(
             context, 
             MaterialPageRoute(builder: (context) => const OnboardingStep1Screen())
           );
         }
         return;
      }
      
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onSwipe(SwipeAction action) async {
    final profile = _profiles[_currentProfileIndex];
    final currentUserId = await _authService.getUserId();
    if (currentUserId == null) return;
    
    // Record the swipe via service
    final match = await _matchService.swipe(
      currentUserId,
      profile.id,
      action,
    );

    if (mounted) {
      setState(() {
        if (_currentProfileIndex < _profiles.length - 1) {
          _currentProfileIndex++;
        } else {
          // Reload more profiles
          _loadProfiles();
        }
      });
    }

    if (match != null) {
      // Show confetti animation
      if (mounted) {
        setState(() {
          _showConfetti = true;
        });
        
        // Show match dialog
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _showMatchDialog(profile);
        });
      }
    } else if (action == SwipeAction.like || action == SwipeAction.superlike) {
      if (mounted) {
        final message = action == SwipeAction.superlike 
            ? 'Super Like envoyé ! ⭐' 
            : 'Like envoyé ! ❤️';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: action == SwipeAction.superlike 
                ? const Color(0xFFf59e0b)
                : AppColors.neonTeal,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showMatchDialog(Profile profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.neonTeal,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                color: AppColors.neonRed,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'C\'est un match !',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tu as matché avec ${profile.name}',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _showConfetti = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.textSecondary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Plus tard'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() {
                          _showConfetti = false;
                        });
                        
                        // Fetch the match object again if needed or use the one from swipe
                        // The localized _onSwipe function doesn't easily pass the match object here
                        // without refactoring _showMatchDialog params.
                        // For now, we'll navigate to the Matches tab (Index 3)
                        // Or better: pass match to _showMatchDialog?
                        
                        setState(() {
                            _currentIndex = 3; // Correct index for MatchesScreen
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Discuter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      const LikesScreen(),
      const StandoutsScreen(),
      const MatchesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.neonRed,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Découvrir',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Likes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Standouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Matchs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    if (_currentProfileIndex >= _profiles.length) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neonTeal),
      );
    }

    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = _profiles[_currentProfileIndex];
    final compatibilityScore = _currentUser!.calculateCompatibility(profile);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left spacer for balance
                const SizedBox(width: 80),
                // Centered logo
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo2.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Match score on the right
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neonTeal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonTeal, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.neonTeal, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${compatibilityScore.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.neonTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Profile Card
            Expanded(
              child: _buildProfileCard(profile, compatibilityScore),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.close,
                  color: AppColors.neonRed,
                  onTap: () => _onSwipe(SwipeAction.nope),
                ),
                _buildActionButton(
                  icon: Icons.favorite,
                  color: AppColors.neonTeal,
                  size: 70,
                  iconSize: 35,
                  onTap: () => _onSwipe(SwipeAction.like),
                ),
                _buildActionButton(
                  icon: Icons.star,
                  color: const Color(0xFFf59e0b),
                  onTap: () => _onSwipe(SwipeAction.superlike),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Profile profile, double compatibilityScore) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(
              profile: profile,
              currentUser: _currentUser,
              onLike: () => _onSwipe(SwipeAction.like),
              onNope: () => _onSwipe(SwipeAction.nope),
              onSuperLike: () => _onSwipe(SwipeAction.superlike),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neonTeal.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonTeal.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
          children: [
            // Avatar (placeholder with initials)
            Expanded(
              flex: 3,
              child: Container(
                color: _getColorForProfile(profile.id),
                child: Center(
                  child: Text(
                    profile.initials,
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            // Profile Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${profile.name}, ${profile.age}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cream,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: AppColors.neonTeal, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Gender & Location
                    Row(
                      children: [
                        Icon(
                           profile.gender == 'Male' ? Icons.male : 
                           profile.gender == 'Female' ? Icons.female : Icons.transgender,
                          color: AppColors.neonTeal,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.gender == 'Male' ? 'Homme' : 
                            profile.gender == 'Female' ? 'Femme' : 'Non-binaire',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.neonTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                         const SizedBox(width: 12),
                        const Icon(Icons.location_on, color: AppColors.textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          profile.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.bio,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.cream,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 34,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                        children: profile.interests.take(5).map((interest) {
                        final isCommon = _currentUser?.interests.contains(interest) ?? false;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCommon 
                                ? AppColors.neonRed.withOpacity(0.2)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCommon ? AppColors.neonRed : AppColors.textSecondary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              fontSize: 12,
                              color: isCommon ? AppColors.neonRed : AppColors.cream,
                              fontWeight: isCommon ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                        }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 60,
    double iconSize = 30,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }

  Color _getColorForProfile(String id) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF3B82F6), // Blue
    ];
    final hash = id.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
