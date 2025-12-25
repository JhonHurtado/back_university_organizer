import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../models/subject.dart';

/// Subject detail screen showing complete information about a subject
class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  Subject? _subject;
  bool _isLoading = true;

  // Mock enrollment and grade data
  bool _isEnrolled = true;
  double? _currentGrade;
  String? _professorName;

  @override
  void initState() {
    super.initState();
    _loadSubjectDetails();
  }

  Future<void> _loadSubjectDetails() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load subject from API
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _subject = Subject(
          id: widget.subjectId,
          careerId: 'career-1',
          semesterId: 'semester-3',
          code: 'CS301',
          name: 'Data Structures and Algorithms',
          description: 'An in-depth study of fundamental data structures and algorithms, including arrays, linked lists, stacks, queues, trees, graphs, sorting, and searching algorithms.',
          credits: 4,
          hoursPerWeek: 6,
          subjectType: SubjectType.required,
          area: 'Programming',
          gradeWeights: {
            'midterm1': 25.0,
            'midterm2': 25.0,
            'finalExam': 30.0,
            'assignments': 20.0,
          },
          totalCuts: 3,
          isElective: false,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now(),
        );
        _currentGrade = 4.3;
        _professorName = 'Dr. Smith Johnson';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load subject: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getTypeColor(SubjectType type) {
    switch (type) {
      case SubjectType.required:
        return Colors.blue;
      case SubjectType.elective:
        return Colors.orange;
      case SubjectType.freeElective:
        return Colors.purple;
      case SubjectType.complementary:
        return Colors.green;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text(
          'Are you sure you want to delete this subject? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Delete subject
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subject deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subject Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_subject == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subject Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Subject not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final subject = _subject!;
    final typeColor = _getTypeColor(subject.subjectType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              // TODO: Navigate to edit subject
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'grades',
                child: Row(
                  children: [
                    Icon(Icons.grade, size: 20),
                    SizedBox(width: 12),
                    Text('View Grades'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'schedule',
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 20),
                    SizedBox(width: 12),
                    Text('View Schedule'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('Delete Subject', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'grades':
                  // TODO: Navigate to grades
                  break;
                case 'schedule':
                  // TODO: Navigate to schedule
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [typeColor, typeColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subject.code,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subject.subjectTypeDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (subject.isElective)
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_isEnrolled && _currentGrade != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.grade, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Current Grade:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentGrade!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description
            if (subject.description != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(title: 'DESCRIPTION'),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          subject.description!,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Subject Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: 'SUBJECT INFORMATION'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.stars,
                            label: 'Credits',
                            value: '${subject.credits}',
                          ),
                          if (subject.hoursPerWeek != null) ...[
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Hours per Week',
                              value: '${subject.hoursPerWeek}h',
                            ),
                          ],
                          if (subject.area != null) ...[
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.category,
                              label: 'Area',
                              value: subject.area!,
                            ),
                          ],
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.format_list_numbered,
                            label: 'Total Cuts',
                            value: '${subject.totalCuts}',
                          ),
                          if (_professorName != null) ...[
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.person,
                              label: 'Professor',
                              value: _professorName!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Grade Weights
                  if (subject.gradeWeights != null && subject.gradeWeights!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'GRADE DISTRIBUTION'),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: subject.gradeWeights!.entries.map((entry) {
                            final isLast = entry.key == subject.gradeWeights!.keys.last;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatWeightName(entry.key),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Text(
                                      '${entry.value}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (!isLast) const Divider(height: 24),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Quick Actions
                  const _SectionTitle(title: 'QUICK ACTIONS'),
                  const SizedBox(height: 12),
                  if (_isEnrolled) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to grades
                        },
                        icon: const Icon(Icons.grade),
                        label: const Text('View Grades'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to schedule
                            },
                            icon: const Icon(Icons.schedule),
                            label: const Text('Schedule'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to professor
                            },
                            icon: const Icon(Icons.person),
                            label: const Text('Professor'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Enroll in subject
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Enroll in Subject'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatWeightName(String name) {
    // Convert camelCase to Title Case
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondaryLight,
          ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
