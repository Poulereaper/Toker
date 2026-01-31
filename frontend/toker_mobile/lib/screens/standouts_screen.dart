import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../models/match.dart';
import '../services/auth_service.dart';
import '../services/match_service.dart';
import '../services/profile_service.dart';
import 'profile_detail_screen.dart';
import '../models/swipe.dart';

class StandoutsScreen extends StatefulWidget {
  const StandoutsScreen({super.key});

  @override
  State<StandoutsScreen> createState() => _StandoutsScreenState();
}

class _StandoutsScreenState extends State<StandoutsScreen> {
  final _profileService = ProfileService();
  final _matchService = MatchService();
  final _authService = AuthService();
  
  List<Profile> _standouts = [];
  Profile? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStandouts();
  }

  Future<void> _loadStandouts() async {
    setState(() => _isLoading = true);
    
    final userId = await _authService.getUserId() ?? 'user_1';
    
    // Load current user and standouts
    final currentUser = await _profileService.getCurrentUser(userId);
    final standouts = await _profileService.getStandoutProfiles(userId);
    
    if (mounted) {
      setState(() {
        _currentUser = currentUser;
        _standouts = standouts;
        _isLoading = false;
      });
    }
  }

  Future<void> _onSuperLike(Profile profile) async {
    if (_currentUser == null) return;
    
    await _matchService.swipe(
      _currentUser!.id,
      profile.id,
      SwipeAction.superlike,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Super Like envoyé à ${profile.name} ! ⭐'),
          backgroundColor: const Color(0xFFF59E0B),
          duration: const Duration(seconds: 2),
        ),
      );

      // Remove from standouts
      setState(() {
        _standouts.remove(profile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Standouts',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.cream,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonTeal),
            )
          : _standouts.isEmpty
              ? _buildEmptyState()
              : _buildStandoutsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star_border,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun Standout pour le moment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.cream,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Les profils avec une très haute compatibilité apparaîtront ici',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandoutsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Profils avec compatibilité exceptionnelle (80%+)',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _standouts.length,
            itemBuilder: (context, index) {
              final profile = _standouts[index];
              final compatibilityScore =
                  _currentUser?.calculateCompatibility(profile) ?? 0.0;

              return _buildStandoutCard(profile, compatibilityScore);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStandoutCard(Profile profile, double compatibilityScore) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(
              profile: profile,
              onLike: () async {
                if (_currentUser != null) {
                   await _matchService.swipe(
                    _currentUser!.id,
                    profile.id,
                    SwipeAction.like,
                  );
                }
                if (context.mounted) Navigator.pop(context);
                setState(() {
                  _standouts.remove(profile);
                });
              },
              onNope: () async {
                if (_currentUser != null) {
                  await _matchService.swipe(
                    _currentUser!.id,
                    profile.id,
                    SwipeAction.nope,
                  );
                }
                if (context.mounted) Navigator.pop(context);
                setState(() {
                  _standouts.remove(profile);
                });
              },
              onSuperLike: () {
                _onSuperLike(profile);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF59E0B).withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  Image.network(
                    profile.photos.first,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: AppColors.background,
                        child: Center(
                          child: Text(
                            profile.initials,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cream,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Compatibility badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${compatibilityScore.toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${profile.name}, ${profile.age}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cream,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.bio,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Super Like button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _onSuperLike(profile),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Super Like',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
