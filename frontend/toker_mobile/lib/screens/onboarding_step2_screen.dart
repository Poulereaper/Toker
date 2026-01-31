import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../services/mock_data_service.dart';
import 'home_screen.dart';

class OnboardingStep2Screen extends StatefulWidget {
  final Profile profile;

  const OnboardingStep2Screen({
    super.key,
    required this.profile,
  });

  @override
  State<OnboardingStep2Screen> createState() => _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends State<OnboardingStep2Screen> {
  final _bioController = TextEditingController();
  final List<String> _selectedInterests = [];
  final mockService = MockDataService();

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        if (_selectedInterests.length < 10) {
          _selectedInterests.add(interest);
        }
      }
    });
  }

  void _finish() {
    if (_selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionne au moins 3 centres d\'intérêt'),
          backgroundColor: AppColors.neonRed,
        ),
      );
      return;
    }

    // Navigate to home screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
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
                'Tes centres d\'intérêt',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisis au moins 3 passions (max 10)',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Bio field (optional)
              const Text(
                'Bio (optionnel)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 150,
                style: const TextStyle(color: AppColors.cream),
                decoration: InputDecoration(
                  hintText: 'Quelques mots sur toi...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neonTeal, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neonTeal, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neonTeal, width: 2),
                  ),
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
                    childAspectRatio: 2.5,
                  ),
                  itemCount: mockService.allInterests.length,
                  itemBuilder: (context, index) {
                    final interest = mockService.allInterests[index];
                    final isSelected = _selectedInterests.contains(interest);
                    
                    return GestureDetector(
                      onTap: () => _toggleInterest(interest),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.neonRed.withOpacity(0.2)
                              : AppColors.cardBackground,
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.neonRed 
                                : AppColors.textSecondary.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            interest,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.neonRed : AppColors.cream,
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
              
              // Selected count
              Center(
                child: Text(
                  '${_selectedInterests.length}/10 sélectionnés',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedInterests.length >= 3 
                        ? AppColors.neonTeal 
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Finish button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedInterests.length >= 3 ? _finish : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonRed,
                    foregroundColor: AppColors.cream,
                    disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'C\'est parti !',
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
