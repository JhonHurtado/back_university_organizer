import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades Overview'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Current'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGrades,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.school,
                                  title: 'GPA',
                                  value: _summary['currentGPA'].toStringAsFixed(2),
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.grade,
                                  title: 'Average',
                                  value: _summary['overallAverage'].toStringAsFixed(1),
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.check_circle,
                                  title: 'Passed',
                                  value: '${_summary['passedSubjects']}',
                                  color: Colors.green,
                                  compact: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.pending,
                                  title: 'In Progress',
                                  value: '${_summary['inProgressSubjects']}',
                                  color: Colors.orange,
                                  compact: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.cancel,
                                  title: 'Failed',
                                  value: '${_summary['failedSubjects']}',
                                  color: Colors.red,
                                  compact: true,
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
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool compact;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          children: [
            Icon(icon, size: compact ? 24 : 32, color: color),
            SizedBox(height: compact ? 4 : 8),
            Text(
              value,
              style: TextStyle(
                fontSize: compact ? 18 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: compact ? 2 : 4),
            Text(
              title,
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: gradeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(statusIcon, size: 20, color: statusColor),
                ],
              ),
              const SizedBox(height: 12),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          period,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currentGrade.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(icon: Icons.stars, label: '$credits Credits'),
                  const SizedBox(width: 12),
                  _InfoChip(icon: Icons.percent, label: '$percentage%'),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
