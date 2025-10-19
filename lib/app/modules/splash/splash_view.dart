import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/values/colors.dart';
import 'splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Get.put(SplashController());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: _SplashAnimatedBody(),
    );
  }
}

class _SplashAnimatedBody extends StatefulWidget {
  @override
  _SplashAnimatedBodyState createState() => _SplashAnimatedBodyState();
}

class _SplashAnimatedBodyState extends State<_SplashAnimatedBody>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeOutController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade out controller
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Fade out animation
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startAnimationSequence() async {
    try {
      // Start logo animation
      if (_logoAnimationController.isAnimating ||
          !_logoAnimationController.isCompleted) {
        await _logoAnimationController.forward();
      }

      // Wait a bit to show the logo
      await Future.delayed(const Duration(milliseconds: 800));

      // Start fade out before navigation
      if (_fadeOutController.isAnimating || !_fadeOutController.isCompleted) {
        await _fadeOutController.forward();
      }
    } catch (e) {
      // Handle any animation errors
      print('Animation error: $e');
    }
  }

  @override
  void dispose() {
    try {
      _logoAnimationController.dispose();
    } catch (e) {
      print('Logo controller dispose error: $e');
    }

    try {
      _fadeOutController.dispose();
    } catch (e) {
      print('Fade controller dispose error: $e');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeOutAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeOutAnimation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 30),
                          _buildLoadingIndicator(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 160,
      height: 160,
      child: Image.asset(
        'assets/images/logo-02.png',
        width: 160,
        height: 160,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildTextLogo();
        },
      ),
    );
  }

  Widget _buildTextLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Arabic text
          const Text(
            'خبير',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              fontFamily: 'Cairo',
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          // English text
          Text(
            'KHABIR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withOpacity(0.7),
              fontFamily: 'Cairo',
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 60,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: AnimatedBuilder(
        animation: _logoAnimationController,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                width: 60 * _logoAnimationController.value,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
