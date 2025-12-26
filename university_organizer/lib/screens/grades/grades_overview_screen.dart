import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../widgets/modern_card.dart';

/// Grades overview screen showing all grades summary
class GradesOverviewScreen extends StatefulWidget {
  const GradesOverviewScreen({super.key});

  @override
  State<GradesOverviewScreen> createState() => _GradesOverviewScreenState();
}

class _GradesOverviewScreenState extends State<GradesOverviewScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;

  // Mock data
  final Map<String, dynamic> _summary = {
    'currentGPA': 4.2,
    'overallAverage': 4.3,
    'totalSubjects': 15,
    'passedSubjects': 12,
    'failedSubjects': 1,
    'inProgressSubjects': 2,
  };

  final List<Map<String, dynamic>> _subjectGrades = [
    {
      'id': 'sub-1',
      'name': 'Data Structures',
      'code': 'CS301',
      'currentGrade': 4.5,
      'maxGrade': 5.0,
      'status': 'in_progress',
      'credits': 4,
      'period': 'Current',
    },
    {
      'id': 'sub-2',
      'name': 'Algorithms',
      'code': 'CS302',
      'currentGrade': 4.2,
      'maxGrade': 5.0,
      'status': 'in_progress',
      'credits': 4,
      'period': 'Current',
    },
    {
      'id': 'sub-3',
      'name': 'Database Systems',
      'code': 'CS201',
      'currentGrade': 4.8,
      'maxGrade': 5.0,
      'status': 'passed',
      'credits': 3,
      'period': 'Semester 4',
    },
    {
      'id': 'sub-4',
      'name': 'Web Development',
      'code': 'CS202',
      'currentGrade': 4.5,
      'maxGrade': 5.0,
      'status': 'passed',
      'credits': 3,
      'period': 'Semester 4',
    },
    {
      'id': 'sub-5',
      'name': 'Operating Systems',
      'code': 'CS203',
      'currentGrade': 2.8,
      'maxGrade': 5.0,
      'status': 'failed',
      'credits': 4,
      'period': 'Semester 3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGrades();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load grades from API
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredGrades {
    switch (_tabController.index) {
      case 0: // All
        return _subjectGrades;
      case 1: // Current
        return _subjectGrades.where((g) => g['status'] == 'in_progress').toList();
      case 2: // Completed
        return _subjectGrades.where((g) => g['status'] == 'passed' || g['status'] == 'failed').toList();
      default:
        return _subjectGrades;
    }
  }

  Color _getGradeColor(double grade, double maxGrade) {
    final percentage = (grade / maxGrade) * 100;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'passed':
        return Icons.check_circle;
      case 'failed':
        return Icons.cancel;
      case 'in_progress':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'passed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // TabBar
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  onTap: (_) => setState(() {}),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Current'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadGrades,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards with Modern Design
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GradientStatCard(
                                      icon: Icons.school,
                                      title: 'Current GPA',
                                      value: _summary['currentGPA'].toStringAsFixed(2),
                                      gradient: AppGradients.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GradientStatCard(
                                      icon: Icons.grade,
                                      title: 'Average',
                                      value: _summary['overallAverage'].toStringAsFixed(1),
                                      gradient: AppGradients.success,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: InfoCard(
                                      icon: Icons.check_circle,
                                      title: 'Passed',
                                      value: '${_summary['passedSubjects']} subjects',
                                      iconColor: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InfoCard(
                                      icon: Icons.pending,
                                      title: 'In Progress',
                                      value: '${_summary['inProgressSubjects']} subjects',
                                      iconColor: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InfoCard(
                                      icon: Icons.cancel,
                                      title: 'Failed',
                                      value: '${_summary['failedSubjects']} subjects',
                                      iconColor: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Grades List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SUBJECTS',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              if (_filteredGrades.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.grade_outlined,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No grades found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _filteredGrades.length,
                                  itemBuilder: (context, index) {
                                    final subject = _filteredGrades[index];
                                    return _SubjectGradeCard(
                                      subjectId: subject['id'],
                                      name: subject['name'],
                                      code: subject['code'],
                                      currentGrade: subject['currentGrade'],
                                      maxGrade: subject['maxGrade'],
                                      status: subject['status'],
                                      credits: subject['credits'],
                                      period: subject['period'],
                                      gradeColor: _getGradeColor(
                                        subject['currentGrade'],
                                        subject['maxGrade'],
                                      ),
                                      statusIcon: _getStatusIcon(subject['status']),
                                      statusColor: _getStatusColor(subject['status']),
                                      onTap: () {
                                        // TODO: Navigate to subject grades detail
                                        context.push('/subjects/${subject['id']}/grades');
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}


class _SubjectGradeCard extends StatelessWidget {
  final String subjectId;
  final String name;
  final String code;
  final double currentGrade;
  final double maxGrade;
  final String status;
  final int credits;
  final String period;
  final Color gradeColor;
  final IconData statusIcon;
  final Color statusColor;
  final VoidCallback onTap;

  const _SubjectGradeCard({
    required this.subjectId,
    required this.name,
    required this.code,
    required this.currentGrade,
    required this.maxGrade,
    required this.status,
    required this.credits,
    required this.period,
    required this.gradeColor,
    required this.statusIcon,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ((currentGrade / maxGrade) * 100).toStringAsFixed(0);

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with code and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradeColor, gradeColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, size: 20, color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subject name and grade
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          period,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Grade display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradeColor.withOpacity(0.1),
                      gradeColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      currentGrade.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/$maxGrade',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info chips
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '$credits Credits',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gradeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.percent, size: 14, color: gradeColor),
                    const SizedBox(width: 4),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 12,
                        color: gradeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ],
      ),
    );
  }
}

