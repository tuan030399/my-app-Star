import 'package:flutter/material.dart';
import 'package:qltinhoc/main.dart';
import 'package:qltinhoc/gaming_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    print('🎬 Splash: _startAnimation called');

    // Bỏ qua animation để tránh stuck
    print('⏳ Splash: Skipping animation, waiting 2 seconds...');
    await Future.delayed(const Duration(seconds: 2));
    print('⏰ Splash: Wait completed');

    print('🏠 Splash: About to navigate to HomeScreen...');
    if (mounted) {
      print('✅ Splash: Widget is mounted, navigating...');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      print('🎯 Splash: Navigation completed');
    } else {
      print('❌ Splash: Widget not mounted, cannot navigate');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Colors.deepPurple.shade900,
              Colors.blue.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo với animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.cyan.withOpacity(0.8),
                              Colors.purple.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.cyan,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(27),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.deepPurple.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Gaming fallback icon
                                return const Icon(
                                  Icons.games,
                                  size: 60,
                                  color: Colors.cyan,
                                  shadows: [
                                    Shadow(blurRadius: 10, color: Colors.cyan),
                                    Shadow(blurRadius: 20, color: Colors.purple),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              // Tên ứng dụng
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      '⭐ TIN HỌC NGÔI SAO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(blurRadius: 10, color: Colors.cyan),
                          Shadow(blurRadius: 20, color: Colors.purple),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'HỆ THỐNG QUẢN LÝ CÔNG VIỆC',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.cyan,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(blurRadius: 5, color: Colors.cyan),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 50),
              
              // Loading indicator
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const GamingLoadingWidget(
                          size: 50,
                          type: 'pulse',
                          primaryColor: Colors.cyan,
                          secondaryColor: Colors.purple,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '⚡ ĐANG KHỞI ĐỘNG HỆ THỐNG...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 5, color: Colors.cyan),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
