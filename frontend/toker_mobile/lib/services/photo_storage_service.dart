/// Photo Storage Service Interface
/// 
/// This service abstracts photo storage to prepare for SQL database integration.
/// Currently uses mock URLs, but can be easily replaced with:
/// - Cloud storage (AWS S3, Google Cloud Storage, Azure Blob)
/// - CDN URLs
/// - Local file system references
/// - Base64 encoded images (not recommended for production)

abstract class PhotoStorageService {
  /// Upload a photo and return its storage URL/reference
  /// 
  /// [photoData] - The photo data (bytes, file path, etc.)
  /// [userId] - The user who owns this photo
  /// [position] - Position in the user's photo gallery (0-5)
  /// 
  /// Returns the URL or reference to the stored photo
  Future<String> uploadPhoto(dynamic photoData, String userId, int position);
  
  /// Get the full URL for a photo reference
  /// 
  /// [photoReference] - The stored photo reference/URL
  /// 
  /// Returns the complete URL to access the photo
  String getPhotoUrl(String photoReference);
  
  /// Delete a photo from storage
  /// 
  /// [photoReference] - The stored photo reference/URL
  Future<void> deletePhoto(String photoReference);
  
  /// Get all photos for a user
  /// 
  /// [userId] - The user ID
  /// 
  /// Returns list of photo URLs
  Future<List<String>> getUserPhotos(String userId);
}

/// Mock implementation for development
/// Uses placeholder image URLs (pravatar.cc)
class MockPhotoStorageService implements PhotoStorageService {
  // Base URL for mock photos
  static const String _baseUrl = 'https://i.pravatar.cc/400';
  
  // In-memory storage for demo
  final Map<String, List<String>> _userPhotos = {};
  
  @override
  Future<String> uploadPhoto(dynamic photoData, String userId, int position) async {
    // Simulate upload delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate a unique photo URL
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final photoUrl = '$_baseUrl?img=$timestamp$position';
    
    // Store in memory
    _userPhotos.putIfAbsent(userId, () => []);
    if (_userPhotos[userId]!.length > position) {
      _userPhotos[userId]![position] = photoUrl;
    } else {
      _userPhotos[userId]!.add(photoUrl);
    }
    
    return photoUrl;
  }
  
  @override
  String getPhotoUrl(String photoReference) {
    // In mock, the reference IS the URL
    return photoReference;
  }
  
  @override
  Future<void> deletePhoto(String photoReference) async {
    // Simulate deletion delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Remove from all users (simple implementation)
    _userPhotos.forEach((userId, photos) {
      photos.remove(photoReference);
    });
  }
  
  @override
  Future<List<String>> getUserPhotos(String userId) async {
    // Simulate fetch delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _userPhotos[userId] ?? [];
  }
}

/// Future SQL implementation example
/// 
/// ```dart
/// class SQLPhotoStorageService implements PhotoStorageService {
///   final Database db;
///   final String cdnBaseUrl;
///   
///   SQLPhotoStorageService(this.db, this.cdnBaseUrl);
///   
///   @override
///   Future<String> uploadPhoto(dynamic photoData, String userId, int position) async {
///     // 1. Upload to cloud storage (S3, GCS, etc.)
///     final cloudUrl = await _uploadToCloud(photoData);
///     
///     // 2. Store reference in database
///     await db.insert('photos', {
///       'id': Uuid().v4(),
///       'user_id': userId,
///       'photo_url': cloudUrl,
///       'position': position,
///       'created_at': DateTime.now().toIso8601String(),
///     });
///     
///     return cloudUrl;
///   }
///   
///   @override
///   String getPhotoUrl(String photoReference) {
///     // If stored as relative path, prepend CDN URL
///     if (!photoReference.startsWith('http')) {
///       return '$cdnBaseUrl/$photoReference';
///     }
///     return photoReference;
///   }
///   
///   @override
///   Future<void> deletePhoto(String photoReference) async {
///     // 1. Delete from cloud storage
///     await _deleteFromCloud(photoReference);
///     
///     // 2. Delete from database
///     await db.delete('photos', where: 'photo_url = ?', whereArgs: [photoReference]);
///   }
///   
///   @override
///   Future<List<String>> getUserPhotos(String userId) async {
///     final results = await db.query(
///       'photos',
///       where: 'user_id = ?',
///       whereArgs: [userId],
///       orderBy: 'position ASC',
///     );
///     
///     return results.map((row) => row['photo_url'] as String).toList();
///   }
/// }
/// ```
