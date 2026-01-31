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
  final mockService = MockDataService();
  late List<String> _detectedInterests;
  late List<String> _removedInterests;
  int _maxRemovable = 2;

  @override
  void initState() {
    super.initState();
    // Simulate "auto-detected" interests (5-7 random interests)
    _detectedInterests = _generateAutoDetectedInterests();
    _removedInterests = [];
  }

  List<String> _generateAutoDetectedInterests() {
    final allInterests = mockService.allInterests;
    final count = 5 + (widget.profile.id.hashCode % 3); // 5-7 interests
    final selected = <String>[];
    
    while (selected.length < count && selected.length < allInterests.length) {
      final interest = allInterests[(widget.profile.id.hashCode + selected.length) % allInterests.length];
      if (!selected.contains(interest)) {
        selected.add(interest);
      }
    }
    
    return selected;
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_removedInterests.contains(interest)) {
        _removedInterests.remove(interest);
      } else {
        if (_removedInterests.length < _maxRemovable) {
          _removedInterests.add(interest);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tu peux retirer maximum $_maxRemovable centres d\'intérêt'),
              backgroundColor: AppColors.neonRed,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _addInterest() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final availableToAdd = mockService.allInterests
            .where((i) => !_detectedInterests.contains(i))
            .toList();

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajouter un centre d\'intérêt',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: availableToAdd.length,
                  itemBuilder: (context, index) {
                    final interest = availableToAdd[index];
                    return GestureDetector(
                      onTap: () {
                        final currentCount = _detectedInterests.length;
                        if (currentCount >= 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Maximum 8 centres d\'intérêt'),
                              backgroundColor: AppColors.neonRed,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            _detectedInterests.add(interest);
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.neonTeal.withOpacity(0.2),
                          border: Border.all(color: AppColors.neonTeal, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            interest,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neonTeal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _continue() {
    final finalInterests = _detectedInterests
        .where((i) => !_removedInterests.contains(i))
        .toList();

    final updatedProfile = widget.profile.copyWith(
      interests: finalInterests,
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
    final activeInterests = _detectedInterests
        .where((i) => !_removedInterests.contains(i))
        .length;

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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.neonTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonTeal.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.neonTeal, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Voici tes centres d\'intérêt détectés automatiquement',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.cream.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tu peux en retirer jusqu\'à $_maxRemovable ou en ajouter',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              
              // Interests grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _detectedInterests.length + 1, // +1 for add button
                  itemBuilder: (context, index) {
                    if (index == _detectedInterests.length) {
                      // Add button
                      return GestureDetector(
                        onTap: _addInterest,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            border: Border.all(
                              color: AppColors.neonTeal,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(Icons.add, color: AppColors.neonTeal, size: 24),
                          ),
                        ),
                      );
                    }

                    final interest = _detectedInterests[index];
                    final isRemoved = _removedInterests.contains(interest);
                    
                    return GestureDetector(
                      onTap: () => _toggleInterest(interest),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isRemoved 
                              ? AppColors.cardBackground
                              : AppColors.neonRed.withOpacity(0.2),
                          border: Border.all(
                            color: isRemoved 
                                ? AppColors.textSecondary.withOpacity(0.3)
                                : AppColors.neonRed,
                            width: isRemoved ? 1 : 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                interest,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isRemoved ? FontWeight.normal : FontWeight.bold,
                                  color: isRemoved ? AppColors.textSecondary : AppColors.neonRed,
                                  decoration: isRemoved ? TextDecoration.lineThrough : null,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (isRemoved)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                              ),
                          ],
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
                  '$activeInterests centres d\'intérêt sélectionnés',
                  style: TextStyle(
                    fontSize: 14,
                    color: activeInterests >= 3 
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
                  onPressed: activeInterests >= 3 ? _continue : null,
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
