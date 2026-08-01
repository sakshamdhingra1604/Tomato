import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3500), () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        final authType = await authService.getAuthType();
        if (authType == 'vendor') {
          context.go('/vendor_dashboard');
        } else {
          context.go('/dashboard');
        }
      } else {
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
        final isFirstRun = prefs.getBool('is_first_run') ?? 
            ((prefs.containsKey('college_name') || prefs.containsKey('user_name') || prefs.containsKey('roll_no')) ? false : true);

        if (hasSeenOnboarding || !isFirstRun) {
          context.go('/login');
        } else {
          await prefs.setBool('is_first_run', false);
          await prefs.setBool('has_seen_onboarding', true);
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.takeout_dining_rounded, 
                        size: 100, 
                        color: Theme.of(context).primaryColor
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Tomato',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Skip the Queue, Not the Food.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
