import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/profile.dart';
import '../models/swipe.dart';
import '../services/mock_data_service.dart';

class ProfileDetailScreen extends StatefulWidget {
  final Profile profile;
  final bool isOwnProfile;
  final VoidCallback? onLike;
  final VoidCallback? onNope;
  final VoidCallback? onSuperLike;

  const ProfileDetailScreen({
    super.key,
    required this.profile,
    this.isOwnProfile = false,
    this.onLike,
    this.onNope,
    this.onSuperLike,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final mockService = MockDataService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleAction(SwipeAction action) {
    if (widget.isOwnProfile) return;

    mockService.recordSwipe(
      mockService.currentUser.id,
      widget.profile.id,
      action,
    );

    switch (action) {
      case SwipeAction.like:
        widget.onLike?.call();
        break;
      case SwipeAction.nope:
        widget.onNope?.call();
        break;
      case SwipeAction.superlike:
        widget.onSuperLike?.call();
        break;
    }

    Navigator.pop(context);
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
    final compatibilityScore = widget.isOwnProfile
        ? null
        : mockService.currentUser.calculateCompatibility(widget.profile);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (compatibilityScore != null)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.neonTeal.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${compatibilityScore.toInt()}% match',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Profile info section FIRST
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and age
                      Text(
                        '${widget.profile.name}, ${widget.profile.age}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cream,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.textSecondary, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            widget.profile.location,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Bio
                      if (widget.profile.bio.isNotEmpty) ...[
                        const Text(
                          'À propos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cream,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.profile.bio,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.cream,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Interests
                      const Text(
                        'Centres d\'intérêt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cream,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.profile.interests.map((interest) {
                          final isCommon = !widget.isOwnProfile &&
                              mockService.currentUser.interests.contains(interest);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isCommon
                                  ? AppColors.neonRed.withOpacity(0.2)
                                  : AppColors.cardBackground,
                              border: Border.all(
                                color: isCommon ? AppColors.neonRed : AppColors.textSecondary.withOpacity(0.3),
                                width: isCommon ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCommon ? FontWeight.bold : FontWeight.normal,
                                color: isCommon ? AppColors.neonRed : AppColors.cream,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Section divider
                      const Divider(color: AppColors.textSecondary, thickness: 0.5),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Photos and prompts alternated AFTER info
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Alternate between photos and prompts
                    final photoIndex = index ~/ 2;
                    final isPhoto = index % 2 == 0;

                    if (isPhoto) {
                      if (photoIndex >= widget.profile.photos.length) {
                        return null;
                      }
                      return _buildPhotoCard(widget.profile.photos[photoIndex]);
                    } else {
                      final promptIndex = photoIndex;
                      if (promptIndex >= widget.profile.prompts.length) {
                        return null;
                      }
                      return _buildPromptCard(widget.profile.prompts[promptIndex]);
                    }
                  },
                  childCount: (widget.profile.photos.length + widget.profile.prompts.length),
                ),
              ),

              // Bottom padding for action buttons
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // Action buttons (fixed at bottom)
          if (!widget.isOwnProfile)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withOpacity(0),
                      AppColors.background.withOpacity(0.9),
                      AppColors.background,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.close,
                      color: AppColors.textSecondary,
                      onTap: () => _handleAction(SwipeAction.nope),
                      size: 56,
                    ),
                    _buildActionButton(
                      icon: Icons.favorite,
                      color: AppColors.neonRed,
                      onTap: () => _handleAction(SwipeAction.like),
                      size: 64,
                    ),
                    _buildActionButton(
                      icon: Icons.star,
                      color: const Color(0xFFf59e0b),
                      onTap: () => _handleAction(SwipeAction.superlike),
                      size: 56,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String photoUrl) {
    return Container(
      height: 500,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(photoUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPromptCard(prompt) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonTeal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neonTeal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            prompt.answer,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.cream,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}
