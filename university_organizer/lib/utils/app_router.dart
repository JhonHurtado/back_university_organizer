import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../providers/auth_provider.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/careers/careers_list_screen.dart';

/// Application router configuration using GoRouter
class AppRouter {
  AppRouter._();

  // Router key for navigator
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Create router with auth provider
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      debugLogDiagnostics: true,
      initialLocation: AppRoutes.splash,
      refreshListenable: authProvider,

      // Redirect logic
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation.startsWith('/login') ||
            state.matchedLocation.startsWith('/register') ||
            state.matchedLocation.startsWith('/forgot-password');
        final isSplashRoute = state.matchedLocation == AppRoutes.splash;

        // Allow splash screen
        if (isSplashRoute) return null;

        // If not authenticated and trying to access protected route, redirect to login
        if (!isAuthenticated && !isAuthRoute) {
          return AppRoutes.login;
        }

        // If authenticated and on auth route, redirect to home
        if (isAuthenticated && isAuthRoute) {
          return AppRoutes.home;
        }

        return null;
      },

      // Error page
      errorBuilder: (context, state) => ErrorScreen(error: state.error.toString()),

      // Routes
      routes: [
        // ==================== SPLASH ====================
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // ==================== AUTH ROUTES ====================
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),

        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // ==================== MAIN APP ROUTES ====================
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // ==================== PROFILE ROUTES ====================
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        GoRoute(
          path: AppRoutes.preferences,
          name: 'preferences',
          builder: (context, state) => const PreferencesScreen(),
        ),

        // ==================== CAREER ROUTES ====================
        GoRoute(
          path: AppRoutes.careers,
          name: 'careers',
          builder: (context, state) => const CareersListScreen(),
        ),

        // ==================== GRADES ROUTES ====================
        GoRoute(
          path: AppRoutes.grades,
          name: 'grades',
          builder: (context, state) => const GradesScreen(),
        ),

        // ==================== SCHEDULE ROUTES ====================
        GoRoute(
          path: AppRoutes.schedule,
          name: 'schedule',
          builder: (context, state) => const ScheduleScreen(),
        ),

        // ==================== NOTIFICATIONS ROUTES ====================
        GoRoute(
          path: AppRoutes.notifications,
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    );
  }

  /// Configure and return GoRouter instance (deprecated, use createRouter instead)
  @Deprecated('Use createRouter(authProvider) instead')
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,

    // Redirect logic
    redirect: (context, state) {
      // TODO: Add authentication redirect logic
      // For now, allow all routes
      return null;
    },

    // Error page
    errorBuilder: (context, state) => ErrorScreen(error: state.error.toString()),

    // Routes
    routes: [
      // ==================== SPLASH ====================
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ==================== AUTH ROUTES ====================
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ==================== MAIN APP ROUTES ====================
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ==================== PROFILE ROUTES ====================
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: AppRoutes.preferences,
        name: 'preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),

      // ==================== CAREER ROUTES ====================
      GoRoute(
        path: AppRoutes.careers,
        name: 'careers',
        builder: (context, state) => const CareersListScreen(),
      ),

      // ==================== GRADES ROUTES ====================
      GoRoute(
        path: AppRoutes.grades,
        name: 'grades',
        builder: (context, state) => const GradesScreen(),
      ),

      // ==================== SCHEDULE ROUTES ====================
      GoRoute(
        path: AppRoutes.schedule,
        name: 'schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),

      // ==================== NOTIFICATIONS ROUTES ====================
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}

// ==================== PLACEHOLDER SCREENS ====================
// These will be replaced with actual implementations

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: const Center(child: Text('Forgot Password Screen - Coming Soon')),
    );
  }
}

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: const Center(child: Text('Preferences Screen - Coming Soon')),
    );
  }
}


class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grades')),
      body: const Center(child: Text('Grades Screen - Coming Soon')),
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: const Center(child: Text('Schedule Screen - Coming Soon')),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Notifications Screen - Coming Soon')),
    );
  }
}
