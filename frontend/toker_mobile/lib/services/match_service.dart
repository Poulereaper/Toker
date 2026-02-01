import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match.dart';
import '../models/profile.dart';
import '../models/swipe.dart';

/// Service to handle matches and swipes using Supabase
class MatchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all matches for a user
  Future<List<Match>> getMatches(String userId) async {
    try {
      // Use the view for efficient fetching
      final response = await _supabase
          .from('matches_with_messages')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('matched_at', ascending: false);

      final matchesData = response as List;
      List<Match> matches = [];

      for (var data in matchesData) {
        // Determine who the "other" user is
        final user1Id = data['user1_id'] as String;
        final user2Id = data['user2_id'] as String;
        final otherUserId = (user1Id == userId) ? user2Id : user1Id;

        // Fetch the other user's profile basics (optimized)
        // Ideally we would join this in the view, but for now we fetch individual
        final profileData = await _supabase
            .from('user_profiles_complete')
            .select()
            .eq('id', otherUserId)
            .maybeSingle();

        if (profileData != null) {
           final profile = _mapJsonToProfile(profileData);
           
           matches.add(Match(
             id: data['match_id'],
             profile: profile,
             matchedAt: DateTime.parse(data['matched_at']),
             compatibilityScore: (data['compatibility_score'] as num).toDouble(),
             lastMessage: data['last_message'],
             lastMessageTime: data['last_message_time'] != null 
                ? DateTime.parse(data['last_message_time']) 
                : null,
             isUnread: data['has_unread'] ?? false,
           ));
        }
      }
      return matches;

    } catch (e) {
      print('❌ Erreur getMatches: $e');
      return [];
    }
  }

  /// Record a swipe (like/pass/superlike)
  /// Returns true if it's a match
  Future<Match?> swipe(String swiperId, String swipedId, SwipeAction action) async {
    try {
      final String actionStr = action == SwipeAction.like ? 'like' : 
                               action == SwipeAction.superlike ? 'superlike' : 'pass';

      // 1. Insert or update the swipe
      // We assume there is a UNIQUE constraint on (from_user_id, to_user_id)
      await _supabase.from('swipes').upsert(
        {
          'from_user_id': swiperId,
          'to_user_id': swipedId,
          'action': actionStr,
        },
        onConflict: 'from_user_id, to_user_id', // Critical fix for duplicate key error
      );

      // 2. Check for reciprocal match (if like/superlike)
      if (action != SwipeAction.nope) {
        // Check if the other user also LIKED or SUPERLIKED us
        final reciprocalSwipe = await _supabase
            .from('swipes')
            .select()
            .eq('from_user_id', swipedId)
            .eq('to_user_id', swiperId)
            .or('action.eq.like,action.eq.superlike')
            .maybeSingle();

        if (reciprocalSwipe != null) {
          // 🎉 It's a match!
          
          final user1 = (swiperId.compareTo(swipedId) < 0) ? swiperId : swipedId;
          final user2 = (swiperId.compareTo(swipedId) < 0) ? swipedId : swiperId;

          // Calculate Real Compatibility
          final swiperProfileData = await _supabase
            .from('user_profiles_complete')
            .select()
            .eq('id', swiperId)
            .single();
          
          final swipedProfileData = await _supabase
            .from('user_profiles_complete')
            .select()
            .eq('id', swipedId)
            .single();

          final swiperProfile = _mapJsonToProfile(swiperProfileData);
          final swipedProfile = _mapJsonToProfile(swipedProfileData);

          final compatibilityScore = swiperProfile.calculateCompatibility(swipedProfile);

          // Create match record safely (ignore if already exists)
          // We assume unique constraint on (user1_id, user2_id) in matches table
          final matchRes = await _supabase.from('matches').upsert(
            {
               'user1_id': user1,
               'user2_id': user2,
               'compatibility_score': compatibilityScore,
            },
            onConflict: 'user1_id, user2_id',
          ).select().single();

          // Fetch profile to return full match object
          final profileData = await _supabase
            .from('user_profiles_complete')
            .select()
            .eq('id', swipedId)
            .single();
            
          return Match(
            id: matchRes['id'],
            profile: _mapJsonToProfile(profileData),
            matchedAt: DateTime.parse(matchRes['matched_at']),
            compatibilityScore: (matchRes['compatibility_score'] as num).toDouble(),
            isUnread: true,
          );
        }
      }
      return null;
    } catch (e) {
      print('❌ Erreur swipe: $e');
      // If error is duplicate key but we failed to catch it, prevent crash
      return null;
    }
  }

  // Helper (duplicated from ProfileService for now - should be shared util)
  Profile _mapJsonToProfile(Map<String, dynamic> json) {
     final photosList = json['photos'] as List?;
     String photoUrl = '';
     if (photosList != null && photosList.isNotEmpty) {
       // Handle both map (from view) and string (if raw)
       if (photosList[0] is Map) {
         photoUrl = photosList[0]['url'] ?? '';
       } else if (photosList[0] is String) {
         photoUrl = photosList[0];
       }
     }

     return Profile(
      id: json['id'],
      name: json['name'] ?? 'Inconnu',
      age: json['age'] ?? 18,
      gender: json['gender'] ?? 'Non-binary',
      bio: json['bio'] ?? '',
      interests: [], // Simplified for match list preview
      photos: [photoUrl],
      prompts: [],
      location: json['location'] ?? '',
      interestedIn: json['interested_in'] ?? 'Everyone',
    );
  }
}
