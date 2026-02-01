import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/prompt.dart';

/// Service to handle profile fetching and management via Supabase
class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get profiles for Discover feed (compatibility >= 40%)
  /// Uses the 'user_profiles_complete' view
  Future<List<Profile>> getDiscoverProfiles(String currentUserId) async {
    try {
      // 1. Fetch current user & Swipes
      print('👤 Fetching current user & swipes...');
      final currentUser = await getCurrentUser(currentUserId);
      
      // Fetch IDs already swiped
      final swipesResponse = await _supabase
          .from('swipes')
          .select('to_user_id')
          .eq('from_user_id', currentUserId);
          
      final swipedIds = (swipesResponse as List)
          .map((s) => s['to_user_id'] as String)
          .toSet();

      print('🚫 Excluding ${swipedIds.length} already swiped profiles');

      // 2. Build query based on preferences
      var query = _supabase
          .from('user_profiles_complete')
          .select()
          .neq('id', currentUserId); // Always exclude self

      // Apply Gender Filter
      if (currentUser.interestedIn == 'Men') {
        query = query.eq('gender', 'Male');
      } else if (currentUser.interestedIn == 'Women') {
        query = query.eq('gender', 'Female');
      }

      // 3. Execute query
      final response = await query.limit(50); // Fetch more to allow for local filtering

      final profiles = (response as List).map((data) {
        try { return _mapJsonToProfile(data); } catch(e) { return null; }
      }).whereType<Profile>().toList();

      // 4. Filter out swiped users & locally filter by compatibility
      final filtered = profiles.where((profile) {
        if (swipedIds.contains(profile.id)) return false; // Exclude swiped
        
        // Strict gender check fallback (in case DB filter missed or 'Everyone' logic needs refinement)
        if (currentUser.interestedIn == 'Men' && profile.gender != 'Male') return false;
        if (currentUser.interestedIn == 'Women' && profile.gender != 'Female') return false;

        final score = currentUser.calculateCompatibility(profile);
        return score >= 0.0; // Show all non-swiped profiles for now
      }).toList();
      
      return filtered.take(20).toList(); // Return top 20

    } catch (e) {
      print('❌ Erreur Discover: $e');
      return [];
    }
  }

  /// Get profiles for Standouts feed (compatibility >= 80%)
  Future<List<Profile>> getStandoutProfiles(String currentUserId) async {
    try {
      final currentUser = await getCurrentUser(currentUserId);
      
      // Fetch IDs already swiped
       final swipesResponse = await _supabase
          .from('swipes')
          .select('to_user_id')
          .eq('from_user_id', currentUserId);
          
      final swipedIds = (swipesResponse as List)
          .map((s) => s['to_user_id'] as String)
          .toSet();

      // Build query
      var query = _supabase
          .from('user_profiles_complete')
          .select()
          .neq('id', currentUserId);

      // Apply Gender Filter
      if (currentUser.interestedIn == 'Men') {
        query = query.eq('gender', 'Male');
      } else if (currentUser.interestedIn == 'Women') {
        query = query.eq('gender', 'Female');
      }

      final response = await query.limit(50);

      final profiles = (response as List).map((data) {
         try { return _mapJsonToProfile(data); } catch(e) { return null; }
      }).whereType<Profile>().toList();
      
      return profiles.where((profile) {
        if (swipedIds.contains(profile.id)) return false;
        
        final score = currentUser.calculateCompatibility(profile);
        return score >= 80.0; // Lowered threshold slightly to ensure matches show up
      }).toList();

    } catch (e) {
      print('❌ Erreur Standouts: $e');
      return [];
    }
  }

  /// Get a single profile by ID
  Future<Profile?> getProfile(String id) async {
    try {
      final data = await _supabase
          .from('user_profiles_complete')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) {
        print('⚠️ Profile not found in DB: $id');
        return null;
      }
      return _mapJsonToProfile(data);
    } catch (e) {
      print('❌ Erreur getProfile: $e');
      return null;
    }
  }

  /// Get multiple profiles by IDs
  Future<List<Profile>> getProfilesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final response = await _supabase
          .from('user_profiles_complete')
          .select()
          .inFilter('id', ids);

      return (response as List).map((data) {
        try { return _mapJsonToProfile(data); } catch(e) { return null; }
      }).whereType<Profile>().toList();
    } catch (e) {
      print('❌ Erreur getProfilesByIds: $e');
      return [];
    }
  }

  /// Get current user profile
  Future<Profile> getCurrentUser(String userId) async {
    final profile = await getProfile(userId);
    if (profile == null) {
      // In production, force a logout or error screen
      print('❌ CRITICAL: Current User Profile NOT FOUND: $userId');
      throw Exception('Profil utilisateur non trouvé: $userId');
    }
    return profile;
  }

  /// Update user profile
  /// Update user profile (including relations)
  Future<void> updateProfile(Profile profile) async {
    try {
      // 1. Update core user data
      await _supabase.from('users').update({
        'name': profile.name,
        'bio': profile.bio,
        'location': profile.location,
        'interested_in': profile.interestedIn,
      }).eq('id', profile.id);

      // 2. Update Interests
      // Delete existing
      await _supabase.from('user_interests').delete().eq('user_id', profile.id);
      
      // Insert new (if any)
      if (profile.interests.isNotEmpty) {
        // Fetch IDs for the interest names
        final interestsData = await _supabase
            .from('interests')
            .select('id')
            .inFilter('name', profile.interests);
        
        final interestIds = (interestsData as List).map((i) => i['id'] as String).toList();
        
        if (interestIds.isNotEmpty) {
          await _supabase.from('user_interests').insert(
            interestIds.map((id) => {
              'user_id': profile.id,
              'interest_id': id,
            }).toList(),
          );
        }
      }

      // 3. Update Photos & Captions
      // Delete existing
      await _supabase.from('user_photos').delete().eq('user_id', profile.id);
      
      // Insert new
      if (profile.photos.isNotEmpty) {
          final photosToInsert = [];
          for (int i = 0; i < profile.photos.length; i++) {
              final caption = profile.photoCaptions[i];
              photosToInsert.add({
                  'user_id': profile.id,
                  'photo_url': profile.photos[i],
                  'position': i,
                  'caption': caption, 
              });
          }
          await _supabase.from('user_photos').insert(photosToInsert);
      }

      // 4. Update Prompts
      // Delete existing
      await _supabase.from('user_prompts').delete().eq('user_id', profile.id);
      
      // Insert new
      if (profile.prompts.isNotEmpty) {
         // Get Prompt IDs from questions
         final questions = profile.prompts.map((p) => p.question).toList();
         final promptsData = await _supabase
            .from('prompts')
            .select('id, question')
            .inFilter('question', questions);
            
         // Map question to ID
         final questionToId = {
           for (var item in promptsData as List) item['question'] as String: item['id'] as String
         };

         final promptsToInsert = [];
         for (var p in profile.prompts) {
           final pId = questionToId[p.question];
           if (pId != null) {
             promptsToInsert.add({
               'user_id': profile.id,
               'prompt_id': pId,
               'answer': p.answer,
             });
           }
         }
         
         if (promptsToInsert.isNotEmpty) {
           await _supabase.from('user_prompts').insert(promptsToInsert);
         }
      }
      
      print('💾 Profil complet (relations incluses) mis à jour pour: ${profile.id}');

    } catch (e) {
      print('❌ Erreur updateProfile: $e');
      rethrow;
    }
  }

  // --- Helper Mapping ---

  Profile _mapJsonToProfile(Map<String, dynamic> json) {
    try {
      // Parse photos from view structure OR fallback
      final photosList = (json['photos'] as List?) ?? [];
      List<String> photoUrls = [];
      if (photosList.isNotEmpty && photosList[0] is Map) {
           photoUrls = photosList.map((p) => p['url'] as String).toList();
      } else if (photosList.isNotEmpty && photosList[0] is String) {
           photoUrls = List<String>.from(photosList);
      }

      // Parse prompts
      final promptsList = (json['prompts'] as List?) ?? [];
      final prompts = <Prompt>[];
      final seenQuestions = <String>{};

      for (var p in promptsList) {
        final question = p['question'] ?? 'Question inconnue';
        if (!seenQuestions.contains(question)) {
          seenQuestions.add(question);
          prompts.add(Prompt(
            question: question,
            answer: p['answer'] ?? '',
          ));
        }
      }

      // Deduplicate photos (and enforce max 6)
      photoUrls = photoUrls.toSet().toList();
      if (photoUrls.length > 6) {
        photoUrls = photoUrls.take(6).toList();
      }

      return Profile(
        id: json['id'],
        name: json['name'] ?? 'Inconnu',
        age: json['age'] ?? 18,
        birthdate: json['birthdate'] != null ? DateTime.parse(json['birthdate']) : null,
        gender: json['gender'] ?? 'Non-binary',
        bio: json['bio'] ?? '',
        interests: List<String>.from(json['interests'] ?? []),
        photos: photoUrls,
        prompts: prompts,
        location: json['location'] ?? '',
        interestedIn: json['interested_in'] ?? 'Everyone',
      );
    } catch (e) {
       print('💥 Crash mapping profile ${json['id']}: $e');
       rethrow;
    }
  }
}
