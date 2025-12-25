import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../providers/auth_provider.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/preferences/preferences_screen.dart';
import '../screens/careers/careers_list_screen.dart';
import '../screens/careers/career_detail_screen.dart';
import '../screens/careers/career_statistics_screen.dart';
import '../screens/careers/create_career_screen.dart';
import '../screens/subjects/subjects_list_screen.dart';
import '../screens/subjects/subject_detail_screen.dart';
import '../screens/subjects/add_edit_subject_screen.dart';
import '../screens/grades/grades_overview_screen.dart';
import '../screens/grades/subject_grades_screen.dart';
import '../screens/grades/add_edit_grade_screen.dart';
import '../screens/grades/grade_calculator_screen.dart';
import '../screens/schedule/schedule_weekly_view.dart';
import '../screens/schedule/add_edit_schedule_screen.dart';
import '../screens/notifications/notifications_screen.dart';

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
          path: AppRoutes.editProfile,
          name: 'edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),

        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
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

        GoRoute(
          path: '/careers/create',
          name: 'create-career',
          builder: (context, state) => const CreateCareerScreen(),
        ),

        GoRoute(
          path: '/careers/:id',
          name: 'career-detail',
          builder: (context, state) {
            final careerId = state.pathParameters['id']!;
            return CareerDetailScreen(careerId: careerId);
          },
        ),

        GoRoute(
          path: '/careers/:id/statistics',
          name: 'career-statistics',
          builder: (context, state) {
            final careerId = state.pathParameters['id']!;
            return CareerStatisticsScreen(careerId: careerId);
          },
        ),

        GoRoute(
          path: '/careers/:id/subjects',
          name: 'career-subjects',
          builder: (context, state) {
            final careerId = state.pathParameters['id']!;
            return SubjectsListScreen(careerId: careerId);
          },
        ),

        // ==================== SUBJECT ROUTES ====================
        GoRoute(
          path: '/subjects',
          name: 'subjects',
          builder: (context, state) => const SubjectsListScreen(),
        ),

        GoRoute(
          path: '/subjects/:id',
          name: 'subject-detail',
          builder: (context, state) {
            final subjectId = state.pathParameters['id']!;
            return SubjectDetailScreen(subjectId: subjectId);
          },
        ),

        GoRoute(
          path: '/careers/:careerId/subjects/add',
          name: 'add-subject',
          builder: (context, state) {
            final careerId = state.pathParameters['careerId']!;
            return AddEditSubjectScreen(careerId: careerId);
          },
        ),

        GoRoute(
          path: '/subjects/:id/edit',
          name: 'edit-subject',
          builder: (context, state) {
            final subjectId = state.pathParameters['id']!;
            // careerId would normally come from the subject data
            return AddEditSubjectScreen(
              careerId: 'career-1',
              subjectId: subjectId,
            );
          },
        ),

        // ==================== GRADES ROUTES ====================
        GoRoute(
          path: AppRoutes.grades,
          name: 'grades',
          builder: (context, state) => const GradesOverviewScreen(),
        ),

        GoRoute(
          path: '/subjects/:id/grades',
          name: 'subject-grades',
          builder: (context, state) {
            final subjectId = state.pathParameters['id']!;
            return SubjectGradesScreen(subjectId: subjectId);
          },
        ),

        GoRoute(
          path: '/subjects/:id/grades/add',
          name: 'add-grade',
          builder: (context, state) {
            final subjectId = state.pathParameters['id']!;
            return AddEditGradeScreen(subjectId: subjectId);
          },
        ),

        GoRoute(
          path: '/subjects/:subjectId/grades/:gradeId/edit',
          name: 'edit-grade',
          builder: (context, state) {
            final subjectId = state.pathParameters['subjectId']!;
            final gradeId = state.pathParameters['gradeId']!;
            return AddEditGradeScreen(subjectId: subjectId, gradeId: gradeId);
          },
        ),

        GoRoute(
          path: '/grades/calculator',
          name: 'grade-calculator',
          builder: (context, state) => const GradeCalculatorScreen(),
        ),

        // ==================== SCHEDULE ROUTES ====================
        GoRoute(
          path: AppRoutes.schedule,
          name: 'schedule',
          builder: (context, state) => const ScheduleWeeklyView(),
        ),

        GoRoute(
          path: '/schedule/add',
          name: 'add-schedule',
          builder: (context, state) => const AddEditScheduleScreen(),
        ),

        GoRoute(
          path: '/schedule/:id/edit',
          name: 'edit-schedule',
          builder: (context, state) {
            final scheduleId = state.pathParameters['id']!;
            return AddEditScheduleScreen(scheduleId: scheduleId);
          },
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
        builder: (context, state) => const GradesOverviewScreen(),
      ),

      // ==================== SCHEDULE ROUTES ====================
      GoRoute(
        path: AppRoutes.schedule,
        name: 'schedule',
        builder: (context, state) => const ScheduleWeeklyView(),
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

// ForgotPasswordScreen moved to separate file
// PreferencesScreen moved to separate file
// GradesScreen moved to separate file (GradesOverviewScreen)
// ScheduleScreen moved to separate file (ScheduleWeeklyView)
// NotificationsScreen moved to separate file
