import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/modern_card.dart';

/// Profile screen for user information and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header with Gradient
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.primary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? 'Usuario',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.email ?? 'user@example.com',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Free Plan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  // Account Section
                  _SectionHeader(title: 'Account'),
                  ModernCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.edit, color: AppColors.primary),
                          ),
                          title: 'Edit Profile',
                          trailing: const Icon(Icons.chevron_right),
                          margin: EdgeInsets.zero,
                          onTap: () => context.push(AppRoutes.editProfile),
                        ),
                        const Divider(height: 1),
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.lock, color: AppColors.warning),
                          ),
                          title: 'Change Password',
                          trailing: const Icon(Icons.chevron_right),
                          margin: EdgeInsets.zero,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.email, color: AppColors.success),
                          ),
                          title: 'Email Preferences',
                          trailing: const Icon(Icons.chevron_right),
                          margin: EdgeInsets.zero,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Settings
                  _SectionHeader(title: 'App Settings'),
                  ModernCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.settings, color: AppColors.primary),
                          ),
                          title: 'Settings',
                          trailing: const Icon(Icons.chevron_right),
                          margin: EdgeInsets.zero,
                          onTap: () => context.push(AppRoutes.settings),
                        ),
                        const Divider(height: 1),
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune, color: AppColors.secondary),
                          ),
                          title: 'Preferences',
                          trailing: const Icon(Icons.chevron_right),
                          margin: EdgeInsets.zero,
                          onTap: () => context.push(AppRoutes.preferences),
                        ),
                        const Divider(height: 1),
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.notifications, color: AppColors.warning),
                          ),
                          title: 'Notifications',
                          trailing: const Icon(Icons.chevron_right),
                          margin: EdgeInsets.zero,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.language, color: AppColors.info),
                          ),
                          title: 'Language',
                          trailing: const Text('English'),
                          margin: EdgeInsets.zero,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About
                  _SectionHeader(title: 'About'),
                  ModernCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.info, color: AppColors.primary),
                          ),
                          title: 'About App',
                          trailing: const Icon(Icons.chevron_right),
                          margin: EdgeInsets.zero,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.privacy_tip, color: AppColors.success),
                          ),
                          title: 'Privacy Policy',
                          trailing: const Icon(Icons.chevron_right),
                          margin: EdgeInsets.zero,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.info_outline, color: Colors.grey),
                          ),
                          title: 'Version',
                          trailing: const Text('1.0.0'),
                          margin: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final apiClient = context.read<ApiClient>();
                        await context.read<AuthProvider>().logout();
                        apiClient.clearToken();
                        if (context.mounted) {
                          context.go(AppRoutes.login);
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
                ),
              ],
            ),
          );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryLight,
              ),
        ),
      ),
    );
  }
}
