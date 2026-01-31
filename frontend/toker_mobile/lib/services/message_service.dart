import 'dart:async';
import '../models/message.dart';
import 'mock_data_service.dart';

/// Service to handle messaging
/// Simulates WebSocket connection for real-time chat
class MessageService {
  final MockDataService _mockData = MockDataService();
  final _messageController = StreamController<Message>.broadcast();

  /// Get messages for a match
  Future<List<Message>> getMessages(String matchId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In real app: GET /messages?match_id=X
    return _mockData.getMessagesForMatch(matchId);
  }

  /// Send a message
  Future<Message> sendMessage(String matchId, String senderId, String content) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    // In real app: POST /messages
    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: 'receiver_id', // In real app, derived from matchId
      content: content,
      timestamp: DateTime.now(),
    );
    
    // Add to local mock data
    // _mockData.addMessage(matchId, message); // Need to implement this in MockDataService if we want it to work
    
    // Notify subscribers (WebSocket simulation)
    _messageController.add(message);
    
    return message;
  }

  /// Subscribe to new messages (WebSocket)
  Stream<Message> subscribeToMessages(String matchId) {
    return _messageController.stream;
  }
  
  void dispose() {
    _messageController.close();
  }
}
