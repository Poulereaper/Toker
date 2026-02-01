import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/prompt.dart';

/// Service to handle authentication using Supabase
/// Replaces the previous Mock AuthService
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Simulate TikTok Auth using Supabase (Anonymous for now)
  /// [forceNewUser] if true, ignores existing profile checking and treats as new user (for "Sign Up" button)
  Future<bool> simulateTikTokAuth(String tikTokSecretId, {bool forceNewUser = false}) async {
    print('🔄 Auth Supabase (Simulated via Anonymous Sign-in)...');
    
    // Check if we are already signed in
    if (_supabase.auth.currentUser == null) {
      try {
        final response = await _supabase.auth.signInAnonymously();
        print('✅ Connecté anonymement: ${response.user?.id}');
      } catch (e) {
        print('❌ Erreur connexion Supabase: $e');
        throw Exception('Impossible de se connecter à Supabase (Auth Anonyme). Vérifiez que l\'option est activée dans le dashboard Supabase.');
      }
    }

    final userId = _supabase.auth.currentUser!.id;
    
    if (forceNewUser) {
       print('⚠️ Force New User requested: treating as new user regardless of DB');
       return true;
    }

    // Check if profile exists AND is complete
    try {
      final profileData = await _supabase
          .from('users')
          .select('id, name')
          .eq('id', userId)
          .maybeSingle();

      if (profileData != null && profileData['name'] != null) {
        print('✅ Profil existant et complet pour: $userId');
        return false; // Not a new user
      } else {
        print('🆕 Profil inexistant ou incomplet pour: $userId');
        return true; // New user (needs onboarding)
      }
    } catch (e) {
      print('⚠️ Erreur vérification profil: $e');
      return true; // Assume new user on error to safe default
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentUser != null;
  }

  /// Get current TikTok secret ID (Simulated)
  Future<String?> getTikTokId() async {
    return "tiktok_simulated_${_supabase.auth.currentUser?.id.substring(0, 5)}";
  }

  /// Get current user ID
  Future<String?> getUserId() async {
    return _supabase.auth.currentUser?.id;
  }

  /// Check if user needs onboarding
  Future<bool> needsOnboarding() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return true;

    try {
      final data = await _supabase
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return data == null;
    } catch (e) {
      return true;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _supabase.auth.signOut();
    print('👋 Utilisateur déconnecté (Supabase)');
  }

  /// Save user profile after onboarding
  Future<void> saveUserProfile(Profile profile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Insert user
      await _supabase.from('users').upsert({
        'id': user.id, // Use the Auth ID as the User ID
        'name': profile.name,
        'age': profile.age,
        'birthdate': profile.birthdate?.toIso8601String(),
        'gender': profile.gender,
        'bio': profile.bio,
        'location': profile.location,
        'interested_in': profile.interestedIn,
        'tiktok_id': 'tiktok_simulated_${user.id}',
      });

      // 2. Manage Photos
      // First delete existing photos to ensure clean state (and handle order changes)
      await _supabase.from('user_photos').delete().eq('user_id', user.id);
      
      // Deduplicate and limit photos to 6
      final uniquePhotos = profile.photos.toSet().toList();
      final photosToSave = uniquePhotos.take(6).toList();

      if (photosToSave.isNotEmpty) {
        final photosData = photosToSave.asMap().entries.map((entry) {
          return {
            'user_id': user.id,
            'photo_url': entry.value,
            'position': entry.key, // 0 to 5 max
          };
        }).toList();
        
        await _supabase.from('user_photos').insert(photosData);
      }

      // 3. Manage Interests
      await _supabase.from('user_interests').delete().eq('user_id', user.id);

      // Limit interests if needed, though UI enforces it usually
      for (final interestName in profile.interests) {
        // Fetch interest ID first
        final interest = await _supabase
            .from('interests')
            .select('id')
            .eq('name', interestName)
            .maybeSingle();

        if (interest != null) {
          await _supabase.from('user_interests').insert({
            'user_id': user.id,
            'interest_id': interest['id'],
          });
        }
      }

      // 4. Manage Prompts
      await _supabase.from('user_prompts').delete().eq('user_id', user.id);

      // Unique prompts by question, limit to 3
      final uniquePrompts = <String, Prompt>{};
      for (final p in profile.prompts) {
        uniquePrompts[p.question] = p;
      }
      final promptsToSave = uniquePrompts.values.take(3).toList();

      for (final prompt in promptsToSave) {
        final promptRef = await _supabase
            .from('prompts')
            .select('id')
            .eq('question', prompt.question)
            .maybeSingle();

        if (promptRef != null) {
          await _supabase.from('user_prompts').insert({
            'user_id': user.id,
            'prompt_id': promptRef['id'],
            'answer': prompt.answer,
          });
        }
      }

      print('💾 Profil sauvegardé dans Supabase !');
    } catch (e) {
      print('❌ Erreur sauvegarde profil: $e');
      rethrow;
    }
  }
}
