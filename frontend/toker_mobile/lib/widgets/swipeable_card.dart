import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';
import '../models/profile.dart';

enum SwipeDirection { none, left, right, up }

class SwipeableCard extends StatefulWidget {
  final Profile profile;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;
  final Widget child;

  const SwipeableCard({
    super.key,
    required this.profile,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
    required this.child,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    // Determine swipe direction
    if (_position.dx.abs() > threshold || _position.dy.abs() > threshold) {
      if (_position.dy < -threshold) {
        // Swipe UP - Super Like
        _animateSwipe(SwipeDirection.up);
      } else if (_position.dx > threshold) {
        // Swipe RIGHT - Like
        _animateSwipe(SwipeDirection.right);
      } else if (_position.dx < -threshold) {
        // Swipe LEFT - Nope
        _animateSwipe(SwipeDirection.left);
      } else {
        _resetPosition();
      }
    } else {
      _resetPosition();
    }
  }

  void _animateSwipe(SwipeDirection direction) {
    final screenSize = MediaQuery.of(context).size;
    Offset endPosition;

    switch (direction) {
      case SwipeDirection.left:
        endPosition = Offset(-screenSize.width * 1.5, _position.dy);
        break;
      case SwipeDirection.right:
        endPosition = Offset(screenSize.width * 1.5, _position.dy);
        break;
      case SwipeDirection.up:
        endPosition = Offset(_position.dx, -screenSize.height * 1.5);
        break;
      case SwipeDirection.none:
        endPosition = Offset.zero;
    }

    _animation = Tween<Offset>(
      begin: _position,
      end: endPosition,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward(from: 0).then((_) {
      // Call appropriate callback
      switch (direction) {
        case SwipeDirection.left:
          widget.onSwipeLeft();
          break;
        case SwipeDirection.right:
          widget.onSwipeRight();
          break;
        case SwipeDirection.up:
          widget.onSwipeUp();
          break;
        case SwipeDirection.none:
          break;
      }
      _animationController.reset();
      setState(() {
        _position = Offset.zero;
      });
    });
  }

  void _resetPosition() {
    _animation = Tween<Offset>(
      begin: _position,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward(from: 0).then((_) {
      _animationController.reset();
      setState(() {
        _position = Offset.zero;
      });
    });
  }

  double get _rotation {
    const maxRotation = 0.3;
    final screenWidth = MediaQuery.of(context).size.width;
    return (_position.dx / screenWidth) * maxRotation;
  }

  double get _opacity {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;
    return (_position.dx.abs() / threshold).clamp(0.0, 1.0);
  }

  Color get _overlayColor {
    if (_position.dx > 0) {
      return AppColors.neonTeal; // Like
    } else if (_position.dx < 0) {
      return AppColors.neonRed; // Nope
    } else if (_position.dy < 0) {
      return const Color(0xFFF59E0B); // Super Like
    }
    return Colors.transparent;
  }

  String get _overlayText {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.15;

    if (_position.dy < -threshold) {
      return 'SUPER LIKE';
    } else if (_position.dx > threshold) {
      return 'LIKE';
    } else if (_position.dx < -threshold) {
      return 'NOPE';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = _animationController.isAnimating
        ? _animation.value
        : _position;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: currentPosition,
        child: Transform.rotate(
          angle: _rotation,
          child: Stack(
            children: [
              widget.child,
              // Overlay for swipe feedback
              if (_overlayText.isNotEmpty)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _overlayColor,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: _position.dx > 0 ? -0.3 : 0.3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _overlayColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _overlayText,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
