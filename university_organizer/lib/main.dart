import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'constants/app_constants.dart';
import 'utils/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/career_provider.dart';
import 'providers/notification_provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/career_service.dart';
import 'services/schedule_service.dart';
import 'services/grade_service.dart';
import 'services/notification_service.dart';
import 'services/academic_service.dart';
import 'providers/semester_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/period_provider.dart';
import 'providers/enrollment_provider.dart';
import 'providers/grade_provider.dart';
import 'providers/schedule_provider.dart';

// Import generated localizations
import 'generated/l10n/app_localizations.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),

        // API Client - create once and share
        // Initialize with token from AuthProvider
        ProxyProvider<AuthProvider, ApiClient>(
          update: (context, authProvider, previous) {
            debugPrint('🔄 ProxyProvider<ApiClient>: Updating...');
            debugPrint('  Previous: ${previous != null ? 'exists' : 'null'}');
            debugPrint('  AuthProvider.accessToken: ${authProvider.accessToken?.substring(0, 20) ?? 'null'}...');
            debugPrint('  AuthProvider.isAuthenticated: ${authProvider.isAuthenticated}');

            final apiClient = previous ?? ApiClient();

            // Update token whenever AuthProvider changes
            debugPrint('🔄 Calling apiClient.updateToken()...');
            apiClient.updateToken(authProvider.accessToken);

            // Set refresh token callbacks
            apiClient.setRefreshTokenCallbacks(
              onRefreshToken: (refreshToken) async {
                // Call auth service to refresh token
                final authService = AuthService(apiClient);
                return await authService.refreshToken(refreshToken: refreshToken);
              },
              onGetRefreshToken: () async {
                return authProvider.refreshToken;
              },
              onUpdateTokens: (accessToken, refreshToken) async {
                await authProvider.updateTokens(
                  accessToken: accessToken,
                  refreshToken: refreshToken,
                );
              },
              onLogout: () async {
                await authProvider.logout();
              },
            );

            return apiClient;
          },
        ),

        // Service providers
        ProxyProvider<ApiClient, CareerService>(
          update: (_, apiClient, __) => CareerService(apiClient),
        ),
        ProxyProvider<ApiClient, ScheduleService>(
          update: (_, apiClient, __) => ScheduleService(apiClient),
        ),
        ProxyProvider<ApiClient, GradeService>(
          update: (_, apiClient, __) => GradeService(apiClient),
        ),
        ProxyProvider<ApiClient, NotificationService>(
          update: (_, apiClient, __) => NotificationService(apiClient),
        ),
        ProxyProvider<ApiClient, AcademicService>(
          update: (_, apiClient, __) => AcademicService(apiClient),
        ),

        // Data providers
        // CareerProvider depends on CareerService which depends on ApiClient
        // Note: create uses temporary instance, update immediately replaces it with correct service
        ChangeNotifierProxyProvider<CareerService, CareerProvider>(
          create: (_) {
            debugPrint('🆕 Creating CareerProvider (temporary)...');
            // This is just a placeholder, update() will be called immediately
            return CareerProvider(CareerService(ApiClient()));
          },
          update: (_, service, previous) {
            debugPrint('🔄 ProxyProvider<CareerProvider>: Updating...');
            debugPrint('  Previous: ${previous != null ? 'exists' : 'null'}');
            debugPrint('  Service provided: ${service != null}');

            // IMPORTANT: Always create a new provider with the updated service
            // This ensures we use the service with the correct ApiClient from ProxyProvider
            return CareerProvider(service);
          },
        ),

        // NotificationProvider depends on NotificationService
        ChangeNotifierProxyProvider<NotificationService, NotificationProvider>(
          create: (_) => NotificationProvider(NotificationService(ApiClient())),
          update: (_, service, previous) => NotificationProvider(service),
        ),

        // Academic Providers - depend on AcademicService
        ChangeNotifierProxyProvider<AcademicService, SemesterProvider>(
          create: (_) => SemesterProvider(AcademicService(ApiClient())),
          update: (_, service, previous) => SemesterProvider(service),
        ),
        ChangeNotifierProxyProvider<AcademicService, SubjectProvider>(
          create: (_) => SubjectProvider(AcademicService(ApiClient())),
          update: (_, service, previous) => SubjectProvider(service),
        ),
        ChangeNotifierProxyProvider<AcademicService, PeriodProvider>(
          create: (_) => PeriodProvider(AcademicService(ApiClient())),
          update: (_, service, previous) => PeriodProvider(service),
        ),
        ChangeNotifierProxyProvider<AcademicService, EnrollmentProvider>(
          create: (_) => EnrollmentProvider(AcademicService(ApiClient())),
          update: (_, service, previous) => EnrollmentProvider(service),
        ),

        // GradeProvider depends on GradeService
        ChangeNotifierProxyProvider<GradeService, GradeProvider>(
          create: (_) => GradeProvider(GradeService(ApiClient())),
          update: (_, service, previous) => GradeProvider(service),
        ),

        // ScheduleProvider depends on ScheduleService
        ChangeNotifierProxyProvider<ScheduleService, ScheduleProvider>(
          create: (_) => ScheduleProvider(ScheduleService(ApiClient())),
          update: (_, service, previous) => ScheduleProvider(service),
        ),
      ],
      child: const AppView(),
    );
  }
}

/// Main app view with MaterialApp configuration
class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp.router(
      // App configuration
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Router configuration
      routerConfig: AppRouter.createRouter(authProvider),

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // Localization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
      ],
      locale: localeProvider.locale,

      // Builder for additional configuration
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // Prevent system text scaling
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
