import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import 'profile_service.dart';

/// Service to handle received likes via Supabase
class LikeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();

  /// Get profiles who liked the current user (where action='like' and to_user_id=current_user)
  Future<List<Profile>> getLikesReceived(String userId) async {
    try {
      // 1. Fetch swipe records
      final response = await _supabase
          .from('swipes')
          .select('from_user_id')
          .eq('to_user_id', userId)
          .eq('action', 'like');

      final fromUserIds = (response as List)
          .map((r) => r['from_user_id'] as String)
          .toSet() // Deduplicate
          .toList();

      if (fromUserIds.isEmpty) return [];

      // 2. Fetch full profiles
      print('❤️ Fetching ${fromUserIds.length} likes for user $userId');
      return await _profileService.getProfilesByIds(fromUserIds);
      
    } catch (e) {
      print('❌ Error fetching likes: $e');
      return [];
    }
  }
}
