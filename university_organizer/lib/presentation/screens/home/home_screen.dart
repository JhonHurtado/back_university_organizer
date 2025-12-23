import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';
import '../../providers/auth_state_notifier.dart';
import '../../widgets/common/custom_button.dart';
import '../auth/login_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('University Organizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateNotifierProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome card
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user?.firstName[0].toUpperCase() ?? 'U',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.primaryForeground,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, ${user?.firstName ?? 'Usuario'}!',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (user?.subscription != null) ...[
                    const SizedBox(height: AppDimensions.spacingMd),
                    const Divider(),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Text(
                          'Plan: ${user!.subscription!.plan}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user.subscription!.status == 'active'
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                          ),
                          child: Text(
                            user.subscription!.status,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: user.subscription!.status == 'active'
                                          ? AppColors.success
                                          : AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),

            // Quick actions
            Text(
              'Acciones rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppDimensions.spacingMd,
                crossAxisSpacing: AppDimensions.spacingMd,
                children: [
                  _QuickActionCard(
                    icon: Icons.calendar_today,
                    title: 'Horarios',
                    color: AppColors.chart1,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.grade,
                    title: 'Calificaciones',
                    color: AppColors.chart2,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.notifications,
                    title: 'Notificaciones',
                    color: AppColors.chart3,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.person,
                    title: 'Perfil',
                    color: AppColors.chart4,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
