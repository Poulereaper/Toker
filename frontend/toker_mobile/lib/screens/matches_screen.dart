import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../models/match.dart';
import '../models/profile.dart'; // Added Profile model import
import '../services/match_service.dart';
import '../services/profile_service.dart'; // Added ProfileService import
import 'chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final _matchService = MatchService();
  final _authService = AuthService();
  final _profileService = ProfileService(); // Added ProfileService
  List<Match> _matches = [];
  Profile? _currentUser; // Added _currentUser
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final userId = await _authService.getUserId() ?? 'user_1';
    
    // Fetch both matches and current user for live score calculation
    final results = await Future.wait([
      _matchService.getMatches(userId),
      _profileService.getCurrentUser(userId),
    ]);
    
    final matches = results[0] as List<Match>;
    final currentUser = results[1] as Profile;

    if (mounted) {
      setState(() {
        _matches = matches;
        _currentUser = currentUser;
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tes Matchs',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_matches.length} connexions',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Matches List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.neonTeal))
                  : RefreshIndicator(
                      onRefresh: _loadMatches,
                      color: AppColors.neonTeal,
                      backgroundColor: AppColors.cardBackground,
                      child: _matches.isEmpty
                          ? LayoutBuilder(
                              builder: (context, constraints) => SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                  child: const Center(
                                    child: Text(
                                      'Pas encore de matchs... Continue de swiper !',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              itemCount: _matches.length,
                              itemBuilder: (context, index) {
                                final match = _matches[index];
                                return _buildMatchCard(match);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    // Calculate live compatibility if user is loaded, otherwise fallback to stored score
    final compatibilityScore = _currentUser != null 
        ? _currentUser!.calculateCompatibility(match.profile)
        : match.compatibilityScore;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(match: match),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: match.isUnread 
                ? AppColors.neonTeal.withOpacity(0.5)
                : AppColors.textSecondary.withOpacity(0.2),
            width: match.isUnread ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getColorForProfile(match.profile.id),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  match.profile.initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          match.profile.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cream,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neonTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${compatibilityScore.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neonTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (match.lastMessage != null)
                    Text(
                      match.lastMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: match.isUnread 
                            ? AppColors.cream 
                            : AppColors.textSecondary,
                        fontWeight: match.isUnread 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    const Text(
                      'Nouveau match ! Dis bonjour 👋',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.neonTeal,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Timestamp
            Column(
              children: [
                if (match.lastMessageTime != null)
                  Text(
                    _formatTimestamp(match.lastMessageTime!),
                    style: TextStyle(
                      fontSize: 12,
                      color: match.isUnread 
                          ? AppColors.neonTeal 
                          : AppColors.textSecondary,
                      fontWeight: match.isUnread 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                if (match.isUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.neonTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
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
}
