import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/career_provider.dart';
import '../../models/career.dart';
import 'create_career_screen.dart';

/// Careers list screen
class CareersListScreen extends StatefulWidget {
  const CareersListScreen({super.key});

  @override
  State<CareersListScreen> createState() => _CareersListScreenState();
}

class _CareersListScreenState extends State<CareersListScreen> {
  @override
  void initState() {
    super.initState();
    // Load careers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();

      // Only load careers if user is authenticated
      if (authProvider.isAuthenticated) {
        context.read<CareerProvider>().loadCareers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Careers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CareerProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<CareerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasCareers) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No careers yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first career to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreateCareer(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Career'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.careers.length,
              itemBuilder: (context, index) {
                final career = provider.careers[index];
                return _CareerCard(career: career);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCareer(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToCreateCareer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateCareerScreen(),
      ),
    );
  }
}

class _CareerCard extends StatelessWidget {
  final Career career;

  const _CareerCard({required this.career});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to career detail
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Color indicator
                  Container(
                    width: 4,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(career.color!.replaceFirst('#', '0xFF')),
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Career info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          career.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          career.university,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  _StatusBadge(status: career.status),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Semester ${career.currentSemester} of ${career.totalSemesters}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${career.progressPercentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: career.progressPercentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(
                        int.parse(career.color!.replaceFirst('#', '0xFF')),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Additional info
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.credit_card,
                    label: '${career.totalCredits} credits',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.grade,
                    label: career.gradeScaleDisplayName,
                  ),
                  if (career.faculty != null) ...[
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.business,
                      label: career.faculty!,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CareerStatus? status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status ?? CareerStatus.active) {
      case CareerStatus.active:
        color = AppColors.success;
        label = 'Active';
        break;
      case CareerStatus.completed:
        color = AppColors.primary;
        label = 'Completed';
        break;
      case CareerStatus.paused:
        color = AppColors.warning;
        label = 'Paused';
        break;
      case CareerStatus.cancelled:
        color = AppColors.error;
        label = 'Cancelled';
        break;
      case CareerStatus.graduated:
        color = AppColors.success;
        label = 'Graduated';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
