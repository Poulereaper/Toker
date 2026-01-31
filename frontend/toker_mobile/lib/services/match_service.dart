import '../models/match.dart';
import '../models/profile.dart';
import '../models/swipe.dart';
import 'mock_data_service.dart';

/// Service to handle matches and swipes
class MatchService {
  final MockDataService _mockData = MockDataService();

  /// Get all matches for a user
  Future<List<Match>> getMatches(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    // In real app: GET /matches?user_id=X
    return _mockData.matches;
  }

  /// Record a swipe (like/nope/superlike)
  /// Returns true if it's a match
  Future<Match?> swipe(String swiperId, String swipedId, SwipeAction action) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In real app: POST /swipes
    _mockData.recordSwipe(swiperId, swipedId, action);
    
    // Check if it's a match (simulated logic)
    // In real app, the backend returns if it's a match
    if (action == SwipeAction.like || action == SwipeAction.superlike) {
      // Simplistic check: if user likes us back (or random for demo)
      // For demo, we just say "Like" works randomly or if we force it
      // Let's assume 30% chance of match for demo purposes
      final isMatch = true; // Force match for demo ease, or add random logic
      
      if (isMatch) {
         // Create match object
         final swipedProfile = _mockData.getProfile(swipedId);
         final match = Match(
            id: 'match_${swiperId}_$swipedId',
            profile: swipedProfile,
            matchedAt: DateTime.now(),
            compatibilityScore: _mockData.currentUser.calculateCompatibility(swipedProfile),
            isUnread: true,
         );
         
         // Add to local matches list (mock)
         _mockData.matches.insert(0, match);
         
         return match;
      }
    }
    
    return null;
  }
}
