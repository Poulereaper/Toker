import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../models/swipe.dart';
import '../models/match.dart';
import '../services/auth_service.dart';
import '../services/like_service.dart';
import '../services/match_service.dart';
import '../services/profile_service.dart';
import 'chat_screen.dart';
import 'profile_detail_screen.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  final _likeService = LikeService();
  final _matchService = MatchService();
  final _authService = AuthService();
  final _profileService = ProfileService();
  
  List<Profile> _likesReceived = [];
  Profile? _currentUser;
  final List<String> _ignoredIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await _authService.getUserId() ?? 'user_1';
    
    // Load current user for compatibility calculation
    final currentUser = await _profileService.getCurrentUser(userId);
    
    // Load likes
    final likes = await _likeService.getLikesReceived(userId);
    
    if (mounted) {
      setState(() {
        _currentUser = currentUser;
        _likesReceived = likes;
        _isLoading = false;
      });
    }
  }

  Future<void> _likeBack(Profile profile) async {
    if (_currentUser == null) return;
    
    // Record the like (which creates a match in this context)
    final match = await _matchService.swipe(
      _currentUser!.id,
      profile.id,
      SwipeAction.like,
    );

    // Show match dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.neonTeal, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                color: AppColors.neonRed,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'C\'est un match !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu as matché avec ${profile.name}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _likesReceived.remove(profile);
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.textSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Plus tard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _likesReceived.remove(profile);
                        });
                        // Navigate to chat
                        if (match != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(match: match),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _ignore(Profile profile) {
    setState(() {
      _ignoredIds.add(profile.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${profile.name} ignoré(e)'),
        backgroundColor: AppColors.textSecondary,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Annuler',
          textColor: AppColors.neonTeal,
          onPressed: () {
            setState(() {
              _ignoredIds.remove(profile.id);
            });
          },
        ),
      ),
    );
  }

  Color _getColorForProfile(String id) {
    final colors = [
      AppColors.neonRed,
      AppColors.neonTeal,
      const Color(0xFFf59e0b),
      const Color(0xFF8b5cf6),
      const Color(0xFFec4899),
    ];
    return colors[id.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final visibleLikes = _likesReceived
        .where((profile) => !_ignoredIds.contains(profile.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Likes reçus',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${visibleLikes.length} ${visibleLikes.length > 1 ? "personnes t'ont" : "personne t'a"} liké',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.neonTeal))
                  : visibleLikes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun like pour le moment',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Continue de swiper !',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: visibleLikes.length,
                      itemBuilder: (context, index) {
                        final profile = visibleLikes[index];
                        return _buildLikeCard(profile);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeCard(Profile profile) {
    final compatibilityScore = _currentUser?.calculateCompatibility(profile) ?? 0.0;
    final color = _getColorForProfile(profile.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(
              profile: profile,
              onLike: () => _likeBack(profile),
              onNope: () => _ignore(profile),
              onSuperLike: () => _likeBack(profile),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonTeal.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo or avatar
              if (profile.photos.isNotEmpty)
                Image.network(
                  profile.photos.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Show colored placeholder with initials if image fails to load
                    return Container(
                      color: color.withOpacity(0.2),
                      child: Center(
                        child: Text(
                          profile.initials,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  color: color.withOpacity(0.2),
                  child: Center(
                    child: Text(
                      profile.initials,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.age} ans • ${profile.location.split(',').first}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Compatibility badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonTeal.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${compatibilityScore.toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Action buttons
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMiniActionButton(
                      icon: Icons.close,
                      color: AppColors.textSecondary,
                      onTap: () => _ignore(profile),
                    ),
                    _buildMiniActionButton(
                      icon: Icons.favorite,
                      color: AppColors.neonRed,
                      onTap: () => _likeBack(profile),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
