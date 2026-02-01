import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../services/mock_data_service.dart';
import 'onboarding_photos_screen.dart';

class OnboardingInterestsScreen extends StatefulWidget {
  final Profile profile;

  const OnboardingInterestsScreen({
    super.key,
    required this.profile,
  });

  @override
  State<OnboardingInterestsScreen> createState() => _OnboardingInterestsScreenState();
}

class _OnboardingInterestsScreenState extends State<OnboardingInterestsScreen> {
  // Curated list of 15 interests
  // Curated list of 15 interests (Values must match DB)
  final List<String> _curatedInterests = [
    'Voyage', 'Cuisine', 'Cinéma', 'Musique', 'Sport',
    'Lecture', 'Gaming', 'Art', 'Tech', 'Mode',
    'Aventure', 'Animaux', 'Photographie', 'Danse', 'Festivals'
  ];

  final Map<String, String> _interestEmojis = {
    'Voyage': '✈️', 'Cuisine': '🍳', 'Cinéma': '🎬', 'Musique': '🎵', 'Sport': '🏃',
    'Lecture': '📚', 'Gaming': '🎮', 'Art': '🎨', 'Tech': '💻', 'Mode': '👗',
    'Aventure': '🌿', 'Animaux': '🐶', 'Photographie': '📸', 'Danse': '💃', 'Festivals': '🎉'
  };

  late List<String> _selectedInterests;
  final int _minInterests = 4;
  final int _maxInterests = 8;

  @override
  void initState() {
    super.initState();
    _selectedInterests = [];
    
    // Randomly pre-select 4 interests
    final shuffled = List<String>.from(_curatedInterests)..shuffle();
    _selectedInterests = shuffled.take(_minInterests).toList();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        if (_selectedInterests.length < _maxInterests) {
          _selectedInterests.add(interest);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum $_maxInterests centres d\'intérêt'),
              backgroundColor: AppColors.neonRed,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    });
  }

  void _continue() {
    if (_selectedInterests.length < _minInterests) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sélectionne au moins $_minInterests centres d\'intérêt'),
            backgroundColor: AppColors.neonRed,
          ),
        );
        return;
    }

    final updatedProfile = widget.profile.copyWith(
      interests: _selectedInterests,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingPhotosScreen(profile: updatedProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tes Passions',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 16),
              
              // TikTok Analysis Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00f2ea).withOpacity(0.2), // TikTok Cyan
                      const Color(0xFFff0050).withOpacity(0.2), // TikTok Red
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analyse TikTok terminée',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Ces intérêts matchent avec ton profil viral',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Sélectionnes-en entre $_minInterests et $_maxInterests',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Interests grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _curatedInterests.length,
                  itemBuilder: (context, index) {
                    final interest = _curatedInterests[index];
                    final isSelected = _selectedInterests.contains(interest);
                    
                    return GestureDetector(
                      onTap: () => _toggleInterest(interest),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.neonTeal.withOpacity(0.2) : AppColors.cardBackground,
                          border: Border.all(
                            color: isSelected ? AppColors.neonTeal : AppColors.textSecondary.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            '${interest} ${_interestEmojis[interest] ?? ""}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.neonTeal : AppColors.cream,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Count
              Center(
                child: Text(
                  '${_selectedInterests.length} / $_maxInterests sélectionnés',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedInterests.length >= _minInterests 
                        ? AppColors.neonTeal 
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedInterests.length >= _minInterests ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonRed,
                    foregroundColor: AppColors.cream,
                    disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
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
    );
  }
}
