import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/career.dart';

/// Career detail screen showing complete information about a career
class CareerDetailScreen extends StatefulWidget {
  final String careerId;

  const CareerDetailScreen({
    super.key,
    required this.careerId,
  });

  @override
  State<CareerDetailScreen> createState() => _CareerDetailScreenState();
}

class _CareerDetailScreenState extends State<CareerDetailScreen> {
  Career? _career;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCareerDetails();
  }

  Future<void> _loadCareerDetails() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load career from API
      // final career = await careerService.getCareerById(widget.careerId);

      // Mock data for now
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _career = Career(
          id: widget.careerId,
          userId: 'user-1',
          name: 'Computer Science',
          code: 'CS-2020',
          university: 'Tech University',
          faculty: 'Engineering',
          campus: 'Main Campus',
          totalCredits: 180,
          totalSemesters: 10,
          currentSemester: 5,
          gradeScale: GradeScale.five,
          minPassingGrade: 3.0,
          maxGrade: 5.0,
          startDate: DateTime(2020, 8, 1),
          expectedEndDate: DateTime(2025, 6, 30),
          status: CareerStatus.active,
          color: '#3B82F6',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load career: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getCareerColor() {
    if (_career?.color == null) return AppColors.primary;
    try {
      return Color(int.parse(_career!.color!.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  Color _getStatusColor() {
    switch (_career?.status) {
      case CareerStatus.active:
        return Colors.green;
      case CareerStatus.paused:
        return Colors.orange;
      case CareerStatus.completed:
      case CareerStatus.graduated:
        return Colors.blue;
      case CareerStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Career'),
        content: const Text(
          'Are you sure you want to delete this career? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Delete career
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Career deleted successfully'),
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
        appBar: AppBar(title: const Text('Career Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_career == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Career Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Career not found'),
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

    final career = _career!;
    final careerColor = _getCareerColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'Statistics',
            onPressed: () {
              context.push('/careers/${widget.careerId}/statistics');
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              // TODO: Navigate to edit career
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 12),
                    Text('View Statistics'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'subjects',
                child: Row(
                  children: [
                    Icon(Icons.book, size: 20),
                    SizedBox(width: 12),
                    Text('View Subjects'),
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
                    Text('Delete Career', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'statistics':
                  context.push('/careers/${widget.careerId}/statistics');
                  break;
                case 'subjects':
                  context.push('/careers/${widget.careerId}/subjects');
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
            // Header Card with Progress
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [careerColor, careerColor.withOpacity(0.7)],
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              career.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (career.code != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                career.code!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          career.statusDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    career.university,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Semester ${career.currentSemester} of ${career.totalSemesters}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${career.progressPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: career.progressPercentage / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Information Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: 'GENERAL INFORMATION'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.school,
                            label: 'Faculty',
                            value: career.faculty ?? 'Not specified',
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.location_on,
                            label: 'Campus',
                            value: career.campus ?? 'Not specified',
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.event,
                            label: 'Start Date',
                            value: DateFormat('MMM dd, yyyy').format(career.startDate),
                          ),
                          if (career.expectedEndDate != null) ...[
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.event_available,
                              label: 'Expected End',
                              value: DateFormat('MMM dd, yyyy').format(career.expectedEndDate!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Academic Information
                  const _SectionTitle(title: 'ACADEMIC INFORMATION'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.format_list_numbered,
                            label: 'Total Semesters',
                            value: '${career.totalSemesters}',
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.filter_none,
                            label: 'Current Semester',
                            value: '${career.currentSemester}',
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.stars,
                            label: 'Total Credits',
                            value: '${career.totalCredits}',
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.straighten,
                            label: 'Grade Scale',
                            value: career.gradeScaleDisplayName,
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.check_circle,
                            label: 'Passing Grade',
                            value: '${career.minPassingGrade} / ${career.maxGrade}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  const _SectionTitle(title: 'QUICK ACTIONS'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/careers/${widget.careerId}/subjects');
                          },
                          icon: const Icon(Icons.book),
                          label: const Text('View Subjects'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/careers/${widget.careerId}/statistics');
                          },
                          icon: const Icon(Icons.analytics),
                          label: const Text('Statistics'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
