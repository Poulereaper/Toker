import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';

/// Service to handle authentication with simulated TikTok OAuth
/// In production, this would integrate with real TikTok API
class AuthService {
  // In-memory storage for demo reliability
  static String? _mockTikTokId;
  static String? _mockUserId;
  static bool _mockIsNewUser = true;

  /// Simulate TikTok authentication with a secret ID
  Future<bool> simulateTikTokAuth(String tikTokSecretId) async {
    print('🔄 Simulation Auth TikTok (Mode RAM)...');
    
    // Simuler un léger délai pour le réalisme (mais court)
    await Future.delayed(const Duration(milliseconds: 500));

    _mockTikTokId = tikTokSecretId;
    
    if (_mockUserId != null) {
      print('✅ Utilisateur existant (RAM): $_mockUserId');
      _mockIsNewUser = false;
      return false; 
    } else {
      final userId = const Uuid().v4();
      _mockUserId = userId;
      _mockIsNewUser = true;
      print('✅ Nouvel utilisateur créé (RAM): $userId');
      return true;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _mockTikTokId != null;
  }

  /// Get current TikTok secret ID
  Future<String?> getTikTokId() async {
    return _mockTikTokId;
  }

  /// Get current user ID
  Future<String?> getUserId() async {
    return _mockUserId;
  }

  /// Check if user needs onboarding
  Future<bool> needsOnboarding() async {
    return _mockIsNewUser;
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    _mockIsNewUser = false;
  }

  /// Logout user
  Future<void> logout() async {
    _mockTikTokId = null;
    _mockUserId = null;
    _mockIsNewUser = true;
    print('👋 Utilisateur déconnecté (RAM)');
  }

  /// Save user profile after onboarding
  Future<void> saveUserProfile(Profile profile) async {
    await completeOnboarding();
    print('💾 Profil sauvegardé (RAM)');
  }
}
