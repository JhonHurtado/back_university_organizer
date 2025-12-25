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
            final apiClient = previous ?? ApiClient();

            // Update token whenever AuthProvider changes
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

        // Data providers
        ChangeNotifierProxyProvider<CareerService, CareerProvider>(
          create: (context) => CareerProvider(
            CareerService(ApiClient()),
          ),
          update: (_, service, previous) =>
              previous ?? CareerProvider(service),
        ),

        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..loadNotifications(),
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
