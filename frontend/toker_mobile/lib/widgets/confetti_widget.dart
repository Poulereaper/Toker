import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const ConfettiWidget({
    super.key,
    required this.onComplete,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Generate confetti particles
    for (int i = 0; i < 100; i++) {
      _particles.add(ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1,
        color: _getRandomColor(),
        size: 5 + _random.nextDouble() * 10,
        rotation: _random.nextDouble() * 2 * pi,
        velocityX: (_random.nextDouble() - 0.5) * 2,
        velocityY: 0.5 + _random.nextDouble() * 1.5,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      ));
    }

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFF006B), // Neon Red
      const Color(0xFF00D9C0), // Neon Teal
      const Color(0xFFF59E0B), // Golden
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Green
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  double rotation;
  final double velocityX;
  final double velocityY;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.velocityX,
    required this.velocityY,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position
      final currentY = particle.y + (particle.velocityY * progress);
      final currentX = particle.x + (particle.velocityX * progress * 0.3);
      final currentRotation = particle.rotation + (particle.rotationSpeed * progress);

      if (currentY > 1.2) continue; // Don't draw if off screen

      final paint = Paint()
        ..color = particle.color.withOpacity(1 - (progress * 0.5))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
        currentX * size.width,
        currentY * size.height,
      );
      canvas.rotate(currentRotation);

      // Draw confetti as small rectangles
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
