import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/themes/app_theme.dart';
import 'presentation/providers/auth_providers.dart';
import 'presentation/screens/auth/login_screen_fresh.dart';
import 'presentation/screens/home/home_screen_fresh.dart';
import 'presentation/widgets/common/loading_indicator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'University Organizer',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedInAsync = ref.watch(isLoggedInProvider);

    return isLoggedInAsync.when(
      data: (isLoggedIn) {
        if (isLoggedIn) {
          return const HomeScreenFresh();
        } else {
          return const LoginScreenFresh();
        }
      },
      loading: () => const Scaffold(
        body: LoadingIndicator(
          message: 'Cargando...',
        ),
      ),
      error: (error, stack) => const LoginScreenFresh(),
    );
  }
}
