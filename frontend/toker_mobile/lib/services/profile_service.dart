import '../models/profile.dart';
import '../models/swipe.dart';
import 'mock_data_service.dart';

/// Service to handle profile fetching and management
/// Acts as a data layer abstraction (currently using MockDataService)
class ProfileService {
  final MockDataService _mockData = MockDataService();

  /// Get profiles for Discover feed (compatibility >= 40%)
  Future<List<Profile>> getDiscoverProfiles(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get all potential profiles
    final allProfiles = _mockData.getDisplayProfiles(userId);
    final currentUser = _mockData.currentUser; // In real app, fetch from DB

    // Filter by compatibility >= 40%
    return allProfiles.where((profile) {
      final score = currentUser.calculateCompatibility(profile);
      return score >= 40.0;
    }).toList();
  }

  /// Get profiles for Standouts feed (compatibility >= 90%)
  Future<List<Profile>> getStandoutProfiles(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final allProfiles = _mockData.getDisplayProfiles(userId);
    final currentUser = _mockData.currentUser;

    // Filter by compatibility >= 90%
    return allProfiles.where((profile) {
      final score = currentUser.calculateCompatibility(profile);
      return score >= 90.0;
    }).toList();
  }

  /// Get a single profile by ID
  Future<Profile?> getProfile(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockData.getProfile(id);
    } catch (e) {
      return null;
    }
  }

  // In-memory storage for the current user's profile
  static Profile? _currentUser;

  /// Get current user profile
  Future<Profile> getCurrentUser(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    // If we have an updated profile in memory, return it
    if (_currentUser != null) {
      return _currentUser!;
    }

    try {
      return _mockData.getProfile(userId);
    } catch (e) {
      // Fallback for demo
      return _mockData.currentUser;
    }
  }

  /// Update user profile
  Future<void> updateProfile(Profile profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Save to in-memory storage
    _currentUser = profile;
    print('💾 Profil mis à jour (RAM): ${profile.id}');
  }


}
