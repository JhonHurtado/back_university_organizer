import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/grade.dart';
import '../../models/subject.dart';

/// Subject grades screen showing detailed grade breakdown by cuts
class SubjectGradesScreen extends StatefulWidget {
  final String subjectId;

  const SubjectGradesScreen({
    super.key,
    required this.subjectId,
  });

  @override
  State<SubjectGradesScreen> createState() => _SubjectGradesScreenState();
}

class _SubjectGradesScreenState extends State<SubjectGradesScreen> {
  bool _isLoading = true;
  Subject? _subject;
  List<Grade> _grades = [];
  Map<String, List<GradeItem>> _gradeItems = {};

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load subject and grades from API
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _subject = Subject(
          id: widget.subjectId,
          careerId: 'career-1',
          semesterId: 'semester-3',
          code: 'CS301',
          name: 'Data Structures and Algorithms',
          credits: 4,
          hoursPerWeek: 6,
          subjectType: SubjectType.required,
          totalCuts: 3,
          isElective: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _grades = [
          Grade(
            id: 'grade-1',
            enrollmentId: 'enroll-1',
            cutNumber: 1,
            cutName: 'First Cut',
            weight: 30.0,
            grade: 4.5,
            maxGrade: 5.0,
            gradedAt: DateTime.now().subtract(const Duration(days: 30)),
            createdAt: DateTime.now().subtract(const Duration(days: 35)),
            updatedAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          Grade(
            id: 'grade-2',
            enrollmentId: 'enroll-1',
            cutNumber: 2,
            cutName: 'Second Cut',
            weight: 35.0,
            grade: 4.2,
            maxGrade: 5.0,
            gradedAt: DateTime.now().subtract(const Duration(days: 10)),
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            updatedAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
          Grade(
            id: 'grade-3',
            enrollmentId: 'enroll-1',
            cutNumber: 3,
            cutName: 'Final Cut',
            weight: 35.0,
            grade: 0.0,
            maxGrade: 5.0,
            gradedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        _gradeItems = {
          'grade-1': [
            GradeItem(
              id: 'item-1',
              gradeId: 'grade-1',
              name: 'Midterm Exam 1',
              type: GradeItemType.exam,
              weight: 50.0,
              grade: 4.8,
              maxGrade: 5.0,
              dueDate: DateTime.now().subtract(const Duration(days: 35)),
              submittedAt: DateTime.now().subtract(const Duration(days: 35)),
              createdAt: DateTime.now().subtract(const Duration(days: 40)),
              updatedAt: DateTime.now().subtract(const Duration(days: 35)),
            ),
            GradeItem(
              id: 'item-2',
              gradeId: 'grade-1',
              name: 'Assignment 1',
              type: GradeItemType.assignment,
              weight: 30.0,
              grade: 4.5,
              maxGrade: 5.0,
              dueDate: DateTime.now().subtract(const Duration(days: 40)),
              submittedAt: DateTime.now().subtract(const Duration(days: 39)),
              createdAt: DateTime.now().subtract(const Duration(days: 45)),
              updatedAt: DateTime.now().subtract(const Duration(days: 39)),
            ),
            GradeItem(
              id: 'item-3',
              gradeId: 'grade-1',
              name: 'Quiz 1',
              type: GradeItemType.quiz,
              weight: 20.0,
              grade: 4.0,
              maxGrade: 5.0,
              dueDate: DateTime.now().subtract(const Duration(days: 42)),
              submittedAt: DateTime.now().subtract(const Duration(days: 42)),
              createdAt: DateTime.now().subtract(const Duration(days: 45)),
              updatedAt: DateTime.now().subtract(const Duration(days: 42)),
            ),
          ],
          'grade-2': [
            GradeItem(
              id: 'item-4',
              gradeId: 'grade-2',
              name: 'Midterm Exam 2',
              type: GradeItemType.exam,
              weight: 50.0,
              grade: 4.3,
              maxGrade: 5.0,
              dueDate: DateTime.now().subtract(const Duration(days: 12)),
              submittedAt: DateTime.now().subtract(const Duration(days: 12)),
              createdAt: DateTime.now().subtract(const Duration(days: 17)),
              updatedAt: DateTime.now().subtract(const Duration(days: 12)),
            ),
            GradeItem(
              id: 'item-5',
              gradeId: 'grade-2',
              name: 'Assignment 2',
              type: GradeItemType.assignment,
              weight: 30.0,
              grade: 4.0,
              maxGrade: 5.0,
              dueDate: DateTime.now().subtract(const Duration(days: 15)),
              submittedAt: DateTime.now().subtract(const Duration(days: 14)),
              createdAt: DateTime.now().subtract(const Duration(days: 20)),
              updatedAt: DateTime.now().subtract(const Duration(days: 14)),
            ),
            GradeItem(
              id: 'item-6',
              gradeId: 'grade-2',
              name: 'Lab Project',
              type: GradeItemType.lab,
              weight: 20.0,
              grade: 4.2,
              maxGrade: 5.0,
              dueDate: DateTime.now().subtract(const Duration(days: 18)),
              submittedAt: DateTime.now().subtract(const Duration(days: 17)),
              createdAt: DateTime.now().subtract(const Duration(days: 23)),
              updatedAt: DateTime.now().subtract(const Duration(days: 17)),
            ),
          ],
        };

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _currentAverage {
    if (_grades.isEmpty) return 0.0;

    double totalWeighted = 0.0;
    double totalWeight = 0.0;

    for (final grade in _grades) {
      if (grade.grade > 0) {
        totalWeighted += grade.weightedContribution;
        totalWeight += grade.weight;
      }
    }

    if (totalWeight == 0) return 0.0;
    return totalWeighted;
  }

  Color _getGradeColor(double grade, double maxGrade) {
    final percentage = (grade / maxGrade) * 100;
    if (percentage >= 85) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getItemTypeIcon(GradeItemType type) {
    switch (type) {
      case GradeItemType.exam:
        return Icons.quiz;
      case GradeItemType.quiz:
        return Icons.help_outline;
      case GradeItemType.assignment:
        return Icons.assignment;
      case GradeItemType.project:
        return Icons.folder_special;
      case GradeItemType.lab:
        return Icons.science;
      case GradeItemType.presentation:
        return Icons.present_to_all;
      case GradeItemType.participation:
        return Icons.people;
      case GradeItemType.other:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subject Grades')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_subject == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subject Grades')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Subject not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Grades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Grade Analytics',
            onPressed: () {
              // TODO: Navigate to grade analytics
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGrades,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _subject!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subject!.code,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.grade, color: Colors.white, size: 32),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Average',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentAverage.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'of',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${_subject!.totalCuts} cuts',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Grades by Cut
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GRADE BREAKDOWN',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _grades.length,
                      itemBuilder: (context, index) {
                        final grade = _grades[index];
                        final items = _gradeItems[grade.id] ?? [];
                        final gradeColor = _getGradeColor(grade.grade, grade.maxGrade);

                        return _GradeCutCard(
                          grade: grade,
                          gradeItems: items,
                          gradeColor: gradeColor,
                          getItemTypeIcon: _getItemTypeIcon,
                          getGradeColor: _getGradeColor,
                          onAddItem: () {
                            // TODO: Navigate to add grade item
                          },
                          onEditGrade: () {
                            // TODO: Navigate to edit grade
                          },
                          onEditItem: (item) {
                            // TODO: Navigate to edit grade item
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add grade
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Grade'),
      ),
    );
  }
}

class _GradeCutCard extends StatefulWidget {
  final Grade grade;
  final List<GradeItem> gradeItems;
  final Color gradeColor;
  final IconData Function(GradeItemType) getItemTypeIcon;
  final Color Function(double, double) getGradeColor;
  final VoidCallback onAddItem;
  final VoidCallback onEditGrade;
  final Function(GradeItem) onEditItem;

  const _GradeCutCard({
    required this.grade,
    required this.gradeItems,
    required this.gradeColor,
    required this.getItemTypeIcon,
    required this.getGradeColor,
    required this.onAddItem,
    required this.onEditGrade,
    required this.onEditItem,
  });

  @override
  State<_GradeCutCard> createState() => _GradeCutCardState();
}

class _GradeCutCardState extends State<_GradeCutCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasGrade = widget.grade.grade > 0;
    final percentage = widget.grade.percentage.toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: widget.gradeColor, width: 4),
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.grade.cutDisplayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${widget.grade.weight}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Graded: ${DateFormat('MMM dd, yyyy').format(widget.grade.gradedAt)}',
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
                          if (hasGrade)
                            Text(
                              widget.grade.grade.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: widget.gradeColor,
                              ),
                            )
                          else
                            Text(
                              'N/A',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                              ),
                            ),
                          if (hasGrade)
                            Text(
                              '/$percentage%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),
                    ],
                  ),
                  if (hasGrade) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.trending_up, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Contribution: ${widget.grade.weightedContribution.toStringAsFixed(2)} points',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grade Items (${widget.gradeItems.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.onAddItem,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Item'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.gradeItems.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'No grade items yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: widget.gradeItems.map((item) {
                        final itemColor = widget.getGradeColor(item.grade, item.maxGrade);
                        return _GradeItemTile(
                          item: item,
                          icon: widget.getItemTypeIcon(item.type),
                          color: itemColor,
                          onTap: () => widget.onEditItem(item),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.onEditGrade,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Cut Grade'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GradeItemTile extends StatelessWidget {
  final GradeItem item;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GradeItemTile({
    required this.item,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = item.percentage.toStringAsFixed(0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        item.typeDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.weight}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.grade.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
