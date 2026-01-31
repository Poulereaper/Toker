import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/profile.dart'; // Explicit import if needed
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'premium_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  
  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = await _authService.getUserId() ?? 'user_1';
    final profile = await _profileService.getCurrentUser(userId);
    
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.neonTeal),
        ),
      );
    }
    
    final profile = _profile!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mon Profil',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cream,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: AppColors.cream),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Profile Avatar
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _getColorForProfile(profile.id),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neonTeal,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonTeal.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        profile.initials,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Name and Age
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cream,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.location,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Bio Section
                _buildSection(
                  title: 'À propos',
                  child: Text(
                    profile.bio,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.cream,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Interests Section
                _buildSection(
                  title: 'Centres d\'intérêt',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: profile.interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.neonRed,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neonRed,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Preferences Section
                _buildSection(
                  title: 'Préférences',
                  child: Column(
                    children: [
                      _buildPreferenceRow(
                        icon: Icons.person,
                        label: 'Je suis',
                        value: profile.gender == 'Male' ? 'Homme' : 'Femme',
                      ),
                      const SizedBox(height: 12),
                      _buildPreferenceRow(
                        icon: Icons.favorite,
                        label: 'Je cherche',
                        value: profile.interestedIn == 'Men' 
                            ? 'Hommes' 
                            : profile.interestedIn == 'Women' 
                                ? 'Femmes' 
                                : 'Tous',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Premium Section
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.neonTeal.withOpacity(0.3),
                          AppColors.neonRed.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.neonTeal,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.neonTeal.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: AppColors.neonTeal,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Passer à Premium',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cream,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Débloquez toutes les fonctionnalités',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.neonTeal,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Superlikes Section
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppColors.cardBackground,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return SingleChildScrollView(
                          child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.neonTeal,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Acheter des Superlikes',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cream,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Démarquez-vous auprès de vos coups de cœur',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildSuperlikeOption(context, '5 Superlikes', '4,99 €'),
                              const SizedBox(height: 12),
                              _buildSuperlikeOption(context, '10 Superlikes', '8,99 €', savings: 'Économisez 10%'),
                              const SizedBox(height: 12),
                              _buildSuperlikeOption(context, '25 Superlikes', '19,99 €', savings: 'Économisez 20%'),
                              const SizedBox(height: 24),
                            ],
                          ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.neonTeal.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.neonTeal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: AppColors.neonTeal,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Acheter des Superlikes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cream,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '1 gratuit par semaine',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      ).then((_) {
                        // Rebuild to show updated profile
                        setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Modifier le profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                      // Clear auth state would happen here in a real app
                      // but AuthService uses shared prefs so we might want to clear that

                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neonRed,
                      side: const BorderSide(color: AppColors.neonRed, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildPreferenceRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonTeal, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForProfile(String id) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
    ];
    final hash = id.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Widget _buildSuperlikeOption(BuildContext context, String title, String price, {String? savings}) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Achat de $title pour $price'),
            backgroundColor: AppColors.neonTeal,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.neonTeal.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                  if (savings != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      savings,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.neonTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
