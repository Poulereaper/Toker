import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/prompt.dart';

/// Service to handle authentication using Supabase
/// Replaces the previous Mock AuthService
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Simulate TikTok Auth using Supabase (Anonymous for now)
  /// [forceNewUser] if true, ignores existing profile checking and treats as new user (for "Sign Up" button)
  /// Sign Up with a new random ID (Mock TikTok)
  Future<String?> signUp() async {
    print('🆕 Inscription nouveau compte...');
    try {
      // Generate a deterministic ID based on time or random for the demo
      // In reality, we rely on Supabase to generate the UUID
      // But we need a known email to log back in.
      // Strategy: Create a new user with random email/password
      
      final tempId = DateTime.now().millisecondsSinceEpoch.toString(); // Simple ID for email
      final email = 'user_$tempId@toker.app';
      final password = 'toker_password_secure'; // Hardcoded for demo simplicity

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Compte créé: ${response.user!.id} ($email)');
        return response.user!.id; // Return standard UUID
      }
      return null;
    } catch (e) {
      print('❌ Erreur Inscription: $e');
      throw Exception('Erreur création compte: $e');
    }
  }

  /// Sign In with existing ID
  /// The user inputs the ID (actually the 'user_<timestamp>' part or strictly the UUID?)
  /// Problem: UUID is hard to guess.
  /// Solution: We will use the UUID *as* the username if possible, or stick to the generated email.
  /// Since we generated `user_$tempId@toker.app`, the user needs to know `$tempId`. 
  /// BUT `tempId` is long (timestamp).
  /// BETTER: Let's assume the user copies the *Supabase UUID*? 
  /// No, you can't log in with UUID + Password easily without Email.
  /// 
  /// REVISED STRATEGY: 
  /// User enters "PseudoID" (e.g. 12345). We map `12345@toker.app`.
  /// Let's generate a 6-digit random ID for "Sign Up" that is easier to remember/type.
  
  Future<String?> signUpWithRandomId() async {
    try {
      // Generate 6-digit ID
      final shortId = (100000 + DateTime.now().microsecondsSinceEpoch % 900000).toString();
      final email = '$shortId@toker.app';
      final password = 'toker_secret_$shortId'; // Password linked to ID for simplicity

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Compte créé avec ID court: $shortId');
        return shortId; // We return the SHORT ID for the user to remember
      }
      return null;
    } catch (e) {
      print('❌ Erreur Inscription: $e');
      rethrow;
    }
  }

  Future<bool> signInWithId(String shortId) async {
    try {
      final email = '$shortId@toker.app';
      final password = 'toker_secret_$shortId';

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Connecté avec ID: $shortId (${response.user?.id})');
      return true; // Success
    } catch (e) {
      print('❌ Erreur Connexion avec user: $shortId@toker.app');
      print('❌ Erreur détails: $e');
      // "Invalid login credentials"
      if (e.toString().contains('Invalid login credentials')) {
         throw Exception('ID introuvable ou incorrect.');
      }
      rethrow;
    }
  }

  // Helper alias to keep compatibility if needed, or deprecate
  // Keeping 'simulateTikTokAuth' for backward compat but redirecting logic?
  // No, better to cleanly break and update LoginScreen.
  
  /// Get current TikTok secret ID (Simulated)
  Future<String?> getTikTokId() async {
    // Return email prefix as the "ID"
    final email = _supabase.auth.currentUser?.email;
    if (email != null && email.contains('@toker.app')) {
      return email.split('@')[0];
    }
    return _supabase.auth.currentUser?.id.substring(0, 5);
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
          .select('name')
          .eq('id', userId)
          .maybeSingle();
      
      // If row doesn't exist OR name is null/empty -> Needs onboarding
      if (data == null) return true;
      final name = data['name'] as String?;
      return name == null || name.isEmpty;
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
      // 1. Determine TikTok ID (Short ID preferred)
      // Extract Short ID from email if possible to store in tiktok_id for easy DB retrieval
      String tiktokIdDisplay = 'tiktok_simulated_${user.id}';
      if (user.email != null && user.email!.contains('@toker.app')) {
        final shortId = user.email!.split('@')[0];
        tiktokIdDisplay = shortId; // Store "123456" directly
      }

      // 2. Insert User Profile
      await _supabase.from('users').upsert({
        'id': user.id, // Use the Auth ID as the User ID
        'name': profile.name,
        'age': profile.age,
        'birthdate': profile.birthdate?.toIso8601String(),
        'gender': profile.gender,
        'bio': profile.bio,
        'location': profile.location,
        'interested_in': profile.interestedIn,
        'tiktok_id': tiktokIdDisplay, // Storing Short ID here!
      });

      // 3. Manage Photos
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

      // 4. Manage Interests
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

      // 5. Manage Prompts
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
