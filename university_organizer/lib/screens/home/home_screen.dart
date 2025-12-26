import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/career_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/grade_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../careers/careers_list_screen.dart';
import '../grades/grades_overview_screen.dart';
import '../schedule/schedule_weekly_view.dart';
import '../profile/profile_screen.dart';

/// Home screen - Main dashboard of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardTab(),      // Inicio
    ScheduleTab(),       // Horario
    CareersTab(),        // Materias
    GradesTab(),         // Notas
    ProfileTab(),        // Perfil
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<AuthProvider, NotificationProvider>(
      builder: (context, authProvider, notificationProvider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            user: authProvider.currentUser,
            unreadNotifications: notificationProvider.unreadCount,
            onNotificationTap: () {
              // TODO: Navigate to notifications
            },
          ),
          body: _screens[_selectedIndex],
          bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16161D) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2A2A35) : const Color(0xFFDEE2E6),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: _selectedIndex == 0
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              selectedIcon: Icon(
                Icons.home,
                color: AppColors.primary,
              ),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.calendar_today_outlined,
                color: _selectedIndex == 1
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              selectedIcon: Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              label: 'Horario',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.menu_book_outlined,
                color: _selectedIndex == 2
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              selectedIcon: Icon(
                Icons.menu_book,
                color: AppColors.primary,
              ),
              label: 'Materias',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.bar_chart_outlined,
                color: _selectedIndex == 3
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              selectedIcon: Icon(
                Icons.bar_chart,
                color: AppColors.primary,
              ),
              label: 'Notas',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: _selectedIndex == 4
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              selectedIcon: Icon(
                Icons.person,
                color: AppColors.primary,
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}

// ==================== DASHBOARD TAB ====================

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    // Load data when tab initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();

      // Only load data if user is authenticated
      if (authProvider.isAuthenticated) {
        context.read<CareerProvider>().loadCareers();
        context.read<NotificationProvider>().loadNotifications();
        context.read<ScheduleProvider>().loadSchedules();

        // Load grades for the first active career if available
        final careerProvider = context.read<CareerProvider>();
        if (careerProvider.activeCareers.isNotEmpty) {
          final careerId = careerProvider.activeCareers.first.id;
          context.read<GradeProvider>().loadCareerGPA(careerId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer5<AuthProvider, CareerProvider, NotificationProvider, GradeProvider, ScheduleProvider>(
        builder: (context, authProvider, careerProvider, notificationProvider, gradeProvider, scheduleProvider, child) {
          final user = authProvider.currentUser;
          final activeCareersCount = careerProvider.activeCareers.length;
          final unreadNotifications = notificationProvider.unreadCount;

          // Get GPA from grade provider
          final gpa = gradeProvider.gpaData?['gpa'] ?? 0.0;
          final gpaStr = gpa > 0 ? gpa.toStringAsFixed(2) : '0.0';

          // Get today's classes count from schedule provider
          final todayClasses = scheduleProvider.getTodaySchedules();
          final todayClassesCount = todayClasses.length;

          return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                // Quick Stats - Modern Gradient Cards
                Row(
                  children: [
                    Expanded(
                      child: GradientStatCard(
                        title: 'Active Careers',
                        value: '$activeCareersCount',
                        icon: Icons.school,
                        gradient: AppGradients.primary,
                        onTap: () {
                          // Switch to Materias tab
                          final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                          homeState?._onItemTapped(2);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GradientStatCard(
                        title: 'Current GPA',
                        value: gpaStr,
                        icon: Icons.grade,
                        gradient: AppGradients.success,
                        onTap: () {
                          // Switch to Notas tab
                          final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                          homeState?._onItemTapped(3);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GradientStatCard(
                        title: 'Today Classes',
                        value: '$todayClassesCount',
                        icon: Icons.calendar_today,
                        gradient: AppGradients.info,
                        onTap: () {
                          // Switch to Horario tab
                          final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                          homeState?._onItemTapped(1);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GradientStatCard(
                        title: 'Notifications',
                        value: '$unreadNotifications',
                        icon: Icons.notifications,
                        gradient: AppGradients.warning,
                        onTap: () => context.push(AppRoutes.notifications),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Recent Activity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (notificationProvider.notifications.isNotEmpty)
                      TextButton(
                        onPressed: () => context.push(AppRoutes.notifications),
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (notificationProvider.notifications.isEmpty)
                  ModernCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recent activity',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...notificationProvider.notifications.take(5).map(
                        (notification) => ModernListCard(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: notification.isRead
                                  ? Colors.grey.withOpacity(0.1)
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              notification.isRead
                                  ? Icons.notifications_outlined
                                  : Icons.notifications_active,
                              color: notification.isRead ? Colors.grey : AppColors.primary,
                              size: 24,
                            ),
                          ),
                          title: notification.title,
                          subtitle: notification.message,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(notification.createdAt),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              if (!notification.isRead) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () => context.push(AppRoutes.notifications),
                        ),
                      ),
                    ],
                  ),
          );
        },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ==================== OTHER TABS ====================

class CareersTab extends StatelessWidget {
  const CareersTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the actual CareersListScreen without AppBar and FloatingActionButton
    // since we're embedding it in a tab
    return const CareersListScreen();
  }
}

class GradesTab extends StatelessWidget {
  const GradesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the actual GradesOverviewScreen
    return const GradesOverviewScreen();
  }
}

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the actual ScheduleWeeklyView
    return const ScheduleWeeklyView();
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the actual ProfileScreen
    return const ProfileScreen();
  }
}
