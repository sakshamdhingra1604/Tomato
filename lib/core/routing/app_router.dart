import 'package:go_router/go_router.dart';
import 'package:tomato/features/dashboard/screens/main_layout_screen.dart';
import 'package:tomato/features/student_details/screens/student_details_screen.dart';
import '../../features/auth/screens/vendor_login_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';

import '../../features/dashboard/data/canteen_data.dart';
import '../../features/dashboard/screens/canteen_detail_screen.dart';

import '../../features/dashboard/screens/search_screen.dart';
import '../../features/dashboard/screens/notification_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/vendor_login',
        builder: (context, state) => const VendorLoginScreen(),
      ),
      GoRoute(
        path: '/student_details',
        builder: (context, state) => const StudentDetailsScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainLayoutScreen(),
      ),
      GoRoute(
        path: '/canteen_detail',
        builder: (context, state) {
          final canteen = state.extra as Canteen;
          return CanteenDetailScreen(canteen: canteen);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.extra as String? ?? '';
          return SearchScreen(initialQuery: query);
        },
      ),
      GoRoute(
        path: '/notification',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
  );
}
