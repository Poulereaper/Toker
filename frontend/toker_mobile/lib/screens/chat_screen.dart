import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/match.dart';
import '../models/message.dart';
import '../services/auth_service.dart';
import '../services/message_service.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final Match match;

  const ChatScreen({
    super.key,
    required this.match,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageService = MessageService();
  final _authService = AuthService();
  List<Message> _messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription? _messageSubscription;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    _subscribeToMessages();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = await _authService.getUserId() ?? 'user_1';
    setState(() {});
  }
  
  Future<void> _loadMessages() async {
    final messages = await _messageService.getMessages(widget.match.id);
    if (mounted) {
      setState(() {
        _messages = messages;
      });
      // Scroll to bottom after loading
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _scrollToBottom();
      });
    }
  }

  void _subscribeToMessages() {
    _messageSubscription = _messageService.subscribeToMessages(widget.match.id).listen((message) {
      if (mounted) {
        setState(() {
          _messages.add(message);
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _scrollToBottom();
        });
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageService.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserId == null) return;
    
    final content = _messageController.text.trim();
    _messageController.clear();

    // Optimistic UI update (optional, but good for UX)
    // We rely on the service to return the message or confirm sending
    
    await _messageService.sendMessage(
      widget.match.id,
      _currentUserId!,
      content,
    );
    
    // Subscription will handle adding message to list if service broadcasts it
    // Or we can add it manually here if service returns it
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd/MM HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColorForProfile(widget.match.profile.id),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.match.profile.initials,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.match.profile.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                  Text(
                    '${widget.match.compatibilityScore.toStringAsFixed(0)}% compatible',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neonTeal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.cream),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun message',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSentByMe = message.isSentByMe(_currentUserId ?? 'user_1');
                
                // Show date separator if day changed
                bool showDateSeparator = false;
                if (index == 0) {
                  showDateSeparator = true;
                } else {
                  final prevMessage = _messages[index - 1];
                  final prevDate = DateTime(
                    prevMessage.timestamp.year,
                    prevMessage.timestamp.month,
                    prevMessage.timestamp.day,
                  );
                  final currentDate = DateTime(
                    message.timestamp.year,
                    message.timestamp.month,
                    message.timestamp.day,
                  );
                  showDateSeparator = prevDate != currentDate;
                }

                return Column(
                  children: [
                    if (showDateSeparator) _buildDateSeparator(message.timestamp),
                    _buildMessageBubble(message, isSentByMe),
                  ],
                );
              },
            ),
          ),
          
          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: AppColors.cream),
                    decoration: InputDecoration(
                      hintText: 'Écris un message...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.neonRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonRed.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Aujourd\'hui';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Hier';
    } else {
      dateText = DateFormat('dd MMMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isSentByMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isSentByMe 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isSentByMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getColorForProfile(widget.match.profile.id),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.match.profile.initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSentByMe 
                    ? AppColors.neonRed 
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isSentByMe ? 20 : 4),
                  bottomRight: Radius.circular(isSentByMe ? 4 : 20),
                ),
                border: isSentByMe 
                    ? null 
                    : Border.all(
                        color: AppColors.textSecondary.withOpacity(0.2),
                        width: 1,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSentByMe ? Colors.white : AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSentByMe 
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForProfile(String id) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
    ];
    final hash = id.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
