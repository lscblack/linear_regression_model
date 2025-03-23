import 'package:client/screens/main/HomePage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
    
    // Navigate to HomePage after splash animation
    Timer(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the orange color as a constant to avoid null issues
    const Color orangeColor = Color.fromARGB(255, 185, 107, 6);
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 252, 255), // Dark background
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo/icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 8),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(80, 80),
                            painter: LinearRegressionPainter(
                              progress: _animationController.value,
                              primaryColor: orangeColor, // Using the const color
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // App name
                      const Text(
                        "Know Your'e Insurance ",
                        style: TextStyle(
                          color: Color.fromARGB(255, 62, 75, 102),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tagline
                      Text(
                        "regression insights at your fingertips with us",
                        style: TextStyle(
                          color: Color.fromARGB(255, 62, 75, 102).withOpacity(0.7),
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Loading indicator with orange color
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: _animationController.value,
                          backgroundColor: Color.fromARGB(255, 62, 75, 102).withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(orangeColor), // Using the const color
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom painter to draw a linear regression line animation
class LinearRegressionPainter extends CustomPainter {
  final double progress;
  final Color primaryColor; // Non-nullable field
  
  // Constructor with required primaryColor parameter
  LinearRegressionPainter({
    required this.progress, 
    required this.primaryColor, // Make required to avoid null
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint dotPaint = Paint()
      ..color = const Color(0xFF222222)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
      
    final Paint linePaint = Paint()
      ..color = primaryColor // Using the provided non-null color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
      
    final Paint shadowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3) // Using the provided non-null color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    // Draw data points
    final points = [
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.25),
    ];
    
    // Draw visible points based on animation progress
    int visiblePoints = (points.length * progress).ceil();
    for (int i = 0; i < visiblePoints && i < points.length; i++) {
      canvas.drawCircle(points[i], 4, dotPaint);
    }
    
    // Draw regression line
    if (progress > 0.5) {
      double lineProgress = (progress - 0.5) * 2; // Normalize to 0-1 range
      
      final start = Offset(size.width * 0.15, size.height * 0.75);
      final end = Offset(size.width * 0.85, size.height * 0.15);
      
      // Animated end point
      final currentEnd = Offset(
        start.dx + (end.dx - start.dx) * lineProgress,
        start.dy + (end.dy - start.dy) * lineProgress,
      );
      
      // Draw shadow first
      canvas.drawLine(start, currentEnd, shadowPaint);
      // Draw the line
      canvas.drawLine(start, currentEnd, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LinearRegressionPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.primaryColor != primaryColor;
  }
}

