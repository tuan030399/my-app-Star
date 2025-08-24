import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🎮 Gaming Loading Animations
class GamingLoadingWidget extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final String type; // 'pulse', 'orbit', 'matrix', 'neon'

  const GamingLoadingWidget({
    super.key,
    this.size = 60.0,
    this.primaryColor = Colors.cyan,
    this.secondaryColor = Colors.purple,
    this.type = 'pulse',
  });

  @override
  State<GamingLoadingWidget> createState() => _GamingLoadingWidgetState();
}

class _GamingLoadingWidgetState extends State<GamingLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case 'orbit':
        return _buildOrbitLoader();
      case 'matrix':
        return _buildMatrixLoader();
      case 'neon':
        return _buildNeonLoader();
      case 'pulse':
      default:
        return _buildPulseLoader();
    }
  }

  Widget _buildPulseLoader() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.primaryColor.withOpacity(0.8),
                widget.secondaryColor.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.6),
                blurRadius: 20 * _pulseAnimation.value,
                spreadRadius: 5 * _pulseAnimation.value,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Icon(
              Icons.games,
              size: widget.size * 0.5,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrbitLoader() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center core
              Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.primaryColor,
                      widget.secondaryColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Orbiting particles
              ...List.generate(3, (index) {
                final angle = _rotationAnimation.value + (index * 2 * math.pi / 3);
                final radius = widget.size * 0.35;
                return Transform.translate(
                  offset: Offset(
                    radius * math.cos(angle),
                    radius * math.sin(angle),
                  ),
                  child: Container(
                    width: widget.size * 0.15,
                    height: widget.size * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index.isEven ? widget.primaryColor : widget.secondaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: (index.isEven ? widget.primaryColor : widget.secondaryColor)
                              .withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatrixLoader() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: MatrixPainter(
              progress: _controller.value,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeonLoader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.primaryColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.8),
                  blurRadius: 15 * _pulseAnimation.value,
                  spreadRadius: 3 * _pulseAnimation.value,
                ),
                BoxShadow(
                  color: widget.secondaryColor.withOpacity(0.6),
                  blurRadius: 25 * _pulseAnimation.value,
                  spreadRadius: 5 * _pulseAnimation.value,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.flash_on,
                size: widget.size * 0.4,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: widget.primaryColor,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎨 Matrix Rain Effect Painter
class MatrixPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  MatrixPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw matrix-like grid
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        final x = (i / 7) * size.width;
        final y = (j / 7) * size.height;
        
        final distance = math.sqrt(
          math.pow(x - center.dx, 2) + math.pow(y - center.dy, 2)
        );
        
        final normalizedDistance = distance / radius;
        final animatedProgress = (progress + normalizedDistance) % 1.0;
        
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.2),
          secondaryColor.withOpacity(0.8),
          animatedProgress,
        )!;
        
        canvas.drawCircle(
          Offset(x, y),
          2 + (animatedProgress * 3),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 🎮 Gaming Button with Neon Effect
class GamingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color primaryColor;
  final Color secondaryColor;
  final double width;
  final double height;

  const GamingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.primaryColor = Colors.cyan,
    this.secondaryColor = Colors.purple,
    this.width = 200,
    this.height = 50,
  });

  @override
  State<GamingButton> createState() => _GamingButtonState();
}

class _GamingButtonState extends State<GamingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : 1.0,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    widget.primaryColor.withOpacity(0.8),
                    widget.secondaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: widget.primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.6 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 3 * _glowAnimation.value,
                  ),
                  BoxShadow(
                    color: widget.secondaryColor.withOpacity(0.4 * _glowAnimation.value),
                    blurRadius: 30 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                        shadows: [
                          Shadow(
                            color: widget.primaryColor,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: widget.primaryColor,
                            blurRadius: 5,
                          ),
                          Shadow(
                            color: widget.secondaryColor,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
