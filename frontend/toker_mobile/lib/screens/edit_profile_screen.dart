import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../models/prompt.dart';
import '../models/prompt.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'onboarding_photos_screen.dart';
import 'onboarding_prompts_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  
  Profile? _profile;
  bool _isLoading = true;

  late TextEditingController _bioController;
  late List<String> _selectedInterests;
  late String _interestedIn;
  
  final List<String> _allInterests = [
    'Voyage', 'Cuisine', 'Cinéma', 'Musique', 'Sport',
    'Lecture', 'Gaming', 'Art', 'Tech', 'Mode',
    'Aventure', 'Animaux', 'Photographie', 'Danse', 'Festivals'
  ];

  final Map<String, String> _interestEmojis = {
    'Voyage': '✈️', 'Cuisine': '🍳', 'Cinéma': '🎬', 'Musique': '🎵', 'Sport': '🏃',
    'Lecture': '📚', 'Gaming': '🎮', 'Art': '🎨', 'Tech': '💻', 'Mode': '👗',
    'Aventure': '🌿', 'Animaux': '🐶', 'Photographie': '📸', 'Danse': '💃', 'Festivals': '🎉'
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = await _authService.getUserId();
    if (userId != null) {
      try {
        final profile = await _profileService.getCurrentUser(userId);
        setState(() {
          _profile = profile;
          _bioController = TextEditingController(text: profile.bio);
          _selectedInterests = List.from(profile.interests);
          _interestedIn = profile.interestedIn;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading profile: $e');
        // Handle error (maybe pop)
      }
    }
  }

  @override
  void dispose() {
    if (_profile != null) _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_profile == null) return;

    final updatedProfile = _profile!.copyWith(
      bio: _bioController.text,
      interests: _selectedInterests,
      interestedIn: _interestedIn,
    );
    
    try {
      await _authService.saveUserProfile(updatedProfile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour !'),
            backgroundColor: AppColors.neonTeal,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  void _editPhotos() async {
    if (_profile == null) return;
    final updatedProfile = await Navigator.push<Profile>(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingPhotosScreen(
          profile: _profile!,
          isEditing: true,
        ),
      ),
    );

    if (updatedProfile != null && mounted) {
      setState(() {
        _profile = updatedProfile;
      });
    }
  }

  void _editPrompts() async {
    if (_profile == null) return;
    final updatedProfile = await Navigator.push<Profile>(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingPromptsScreen(
          profile: _profile!,
          isEditing: true,
        ),
      ),
    );

    if (updatedProfile != null && mounted) {
      setState(() {
        _profile = updatedProfile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.neonTeal)),
      );
    }

    final profile = _profile!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.cream),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            color: AppColors.cream,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Enregistrer',
              style: TextStyle(
                color: AppColors.neonTeal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos Section
            _buildSectionTitle('Photos'),
            const SizedBox(height: 12),
            _buildEditCard(
              icon: Icons.photo_library,
              title: 'Modifier mes photos',
              subtitle: '${profile.photos.length} photo(s)',
              onTap: _editPhotos,
            ),
            const SizedBox(height: 24),
            
            // Prompts Section
            _buildSectionTitle('Accroches'),
            const SizedBox(height: 12),
            _buildEditCard(
              icon: Icons.chat_bubble_outline,
              title: 'Modifier mes accroches',
              subtitle: '${profile.prompts.length} accroche(s)',
              onTap: _editPrompts,
            ),
            const SizedBox(height: 24),
            
            // Bio Section
            _buildSectionTitle('À propos'),
            const SizedBox(height: 12),
            TextField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 150,
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: 'Parlez-nous de vous...',
                hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neonTeal, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Interested In Section
            _buildSectionTitle('Je cherche'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInterestedInOption('Men', 'Hommes'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInterestedInOption('Women', 'Femmes'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInterestedInOption('Everyone', 'Tous'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Interests Section
            _buildSectionTitle('Centres d\'intérêt'),
            const SizedBox(height: 8),
            Text(
              'Détectés automatiquement depuis TikTok 🎵',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.neonTeal.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sélectionnez entre 4 et 8 centres d\'intérêt',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        if (_selectedInterests.length > 4) {
                          _selectedInterests.remove(interest);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vous devez avoir au moins 4 centres d\'intérêt'),
                              backgroundColor: AppColors.neonRed,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        if (_selectedInterests.length < 8) {
                          _selectedInterests.add(interest);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Maximum 8 centres d\'intérêt'),
                              backgroundColor: AppColors.neonRed,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.neonRed.withOpacity(0.2)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.neonRed : AppColors.textSecondary.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      '${interest} ${_interestEmojis[interest] ?? ""}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.neonRed : AppColors.cream,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.cream,
      ),
    );
  }

  Widget _buildEditCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neonTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.neonTeal, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestedInOption(String value, String label) {
    final isSelected = _interestedIn == value;
    return GestureDetector(
      onTap: () => setState(() => _interestedIn = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.neonTeal.withOpacity(0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.neonTeal : AppColors.textSecondary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.neonTeal : AppColors.cream,
            ),
          ),
        ),
      ),
    );
  }
}
