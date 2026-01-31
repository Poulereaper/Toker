import '../models/profile.dart';
import 'mock_data_service.dart';

/// Service to handle received likes
class LikeService {
  final MockDataService _mockData = MockDataService();

  /// Get profiles who liked the current user
  Future<List<Profile>> getLikesReceived(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // In real app: GET /likes/received?user_id=X
    return _mockData.getLikesReceived(userId);
  }
}
