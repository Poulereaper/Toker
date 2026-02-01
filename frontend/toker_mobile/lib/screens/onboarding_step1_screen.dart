import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../services/mock_data_service.dart';
import 'onboarding_interests_screen.dart';

class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _birthdate;
  String _selectedGender = 'Male';
  String _interestedIn = 'Women';

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  int? get _age {
    if (_birthdate == null) return null;
    final now = DateTime.now();
    int age = now.year - _birthdate!.year;
    if (now.month < _birthdate!.month || 
        (now.month == _birthdate!.month && now.day < _birthdate!.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectBirthdate() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? eighteenYearsAgo,
      firstDate: hundredYearsAgo,
      lastDate: eighteenYearsAgo,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonTeal,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.cream,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _birthdate = picked);
    }
  }

  void _continue() async {
    if (_formKey.currentState!.validate()) {
      if (_birthdate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sélectionne ta date de naissance'),
            backgroundColor: AppColors.neonRed,
          ),
        );
        return;
      }

      // Show age confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Confirmation',
            style: TextStyle(color: AppColors.cream),
          ),
          content: Text(
            'Tu as bien $_age ans ?',
            style: const TextStyle(color: AppColors.cream),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonTeal,
              ),
              child: const Text('Oui', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Create fresh profile
      final mockService = MockDataService();
      final newProfile = Profile(
        id: mockService.currentUser.id, // Keep ID from auth/mock
        name: _nameController.text,
        age: _age!,
        birthdate: _birthdate,
        gender: _selectedGender,
        interestedIn: _interestedIn,
        bio: _bioController.text.trim(),
        location: 'Paris, France', // Default or fetch
        photos: [], // Start empty
        interests: [], // Start empty
        prompts: [], // Start empty
        photoCaptions: {},
      );
      
      // Update the singleton with this fresh profile
      mockService.updateCurrentUser(newProfile);
      
      // Save done above

      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingInterestsScreen(profile: newProfile),
        ),
      );
    }
  }

  void _showMoreGenderOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plus d\'options',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 20),
              _buildModalOption('Non-binaire', 'Non-binary'),
              const SizedBox(height: 12),
              _buildModalOption('Autre', 'Other'),
              const SizedBox(height: 12),
              _buildModalOption('Préfère ne pas dire', 'Prefer not to say'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption(String label, String value) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedGender = value);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonTeal.withOpacity(0.2) : AppColors.background,
          border: Border.all(
            color: isSelected ? AppColors.neonTeal : AppColors.textSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.neonTeal : AppColors.cream,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.neonTeal, size: 20),
          ],
        ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Créer ton profil',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Commence par les bases',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Name field
                  _buildLabel('Prénom'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Ton prénom',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entre ton prénom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Birthdate field
                  _buildLabel('Date de naissance'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectBirthdate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neonTeal,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.neonTeal, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _birthdate == null
                                  ? 'Sélectionne ta date de naissance'
                                  : '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}${_age != null ? " ($_age ans)" : ""}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _birthdate == null ? AppColors.textSecondary : AppColors.cream,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Gender
                  _buildLabel('Je suis'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Homme',
                          isSelected: _selectedGender == 'Male',
                          onTap: () => setState(() => _selectedGender = 'Male'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Femme',
                          isSelected: _selectedGender == 'Female',
                          onTap: () => setState(() => _selectedGender = 'Female'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Plus',
                          isSelected: _selectedGender != 'Male' && _selectedGender != 'Female',
                          onTap: _showMoreGenderOptions,
                          icon: Icons.add,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Interested in
                  _buildLabel('Je cherche'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Hommes',
                          isSelected: _interestedIn == 'Men',
                          onTap: () => setState(() => _interestedIn = 'Men'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Femmes',
                          isSelected: _interestedIn == 'Women',
                          onTap: () => setState(() => _interestedIn = 'Women'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Tous',
                          isSelected: _interestedIn == 'Everyone',
                          onTap: () => setState(() => _interestedIn = 'Everyone'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // Bio
                  _buildLabel('Ma Bio'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _bioController,
                    hint: 'Dis-nous en plus sur toi...',
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    maxLength: 150,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonRed,
                        foregroundColor: AppColors.cream,
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
                  const SizedBox(height: 24), // Extra padding at bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: AppColors.cream),
      decoration: InputDecoration(
        hintText: hint,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonRed, width: 2),
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonTeal.withOpacity(0.2) : AppColors.cardBackground,
          border: Border.all(
            color: isSelected ? AppColors.neonTeal : AppColors.textSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? AppColors.neonTeal : AppColors.cream,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.neonTeal : AppColors.cream,
                      ),
                    ),
                  ],
                )
              : Text(
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
