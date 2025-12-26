import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/career_provider.dart';
import '../../models/career.dart';
import '../../widgets/modern_card.dart';
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
    return Consumer<CareerProvider>(
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
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No careers yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create your first career to get started\nand track your academic journey',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => _navigateToCreateCareer(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Career'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Color get _careerColor {
    try {
      return Color(int.parse(career.color!.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  LinearGradient get _cardGradient {
    return LinearGradient(
      colors: [
        _careerColor.withOpacity(0.05),
        _careerColor.withOpacity(0.02),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () {
        // TODO: Navigate to career detail
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with career name and status
          Row(
            children: [
              // Color indicator circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_careerColor, _careerColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _careerColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Career info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      career.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            career.university,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              _StatusBadge(status: career.status),
            ],
          ),
          const SizedBox(height: 20),

          // Progress section with modern design
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _cardGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timeline,
                          size: 16,
                          color: _careerColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Semester ${career.currentSemester} of ${career.totalSemesters}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _careerColor,
                              ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _careerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${career.progressPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: career.progressPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_careerColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Additional info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ModernInfoChip(
                icon: Icons.credit_card,
                label: '${career.totalCredits} credits',
                color: AppColors.primary,
              ),
              _ModernInfoChip(
                icon: Icons.grade,
                label: career.gradeScaleDisplayName,
                color: AppColors.success,
              ),
              if (career.faculty != null)
                _ModernInfoChip(
                  icon: Icons.business,
                  label: career.faculty!,
                  color: AppColors.secondary,
                ),
            ],
          ),
        ],
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

class _ModernInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ModernInfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
