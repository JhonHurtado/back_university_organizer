import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../models/subject.dart';

/// Subjects list screen showing all subjects for a career
class SubjectsListScreen extends StatefulWidget {
  final String? careerId;

  const SubjectsListScreen({
    super.key,
    this.careerId,
  });

  @override
  State<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends State<SubjectsListScreen> with SingleTickerProviderStateMixin {
  List<Subject> _subjects = [];
  bool _isLoading = true;
  String _searchQuery = '';
  SubjectType? _filterType;

  late TabController _tabController;
  final List<String> _semesters = ['All', 'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _semesters.length, vsync: this);
    _loadSubjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load subjects from API
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        // Mock data
        _subjects = List.generate(
          15,
          (index) => Subject(
            id: 'subject-$index',
            careerId: widget.careerId ?? 'career-1',
            semesterId: 'semester-${(index % 5) + 1}',
            code: 'CS${100 + index}',
            name: _getMockSubjectName(index),
            description: 'Description for ${_getMockSubjectName(index)}',
            credits: (index % 4) + 2,
            hoursPerWeek: (index % 3) + 3,
            subjectType: _getMockSubjectType(index),
            area: _getMockArea(index),
            totalCuts: 3,
            isElective: index % 5 == 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getMockSubjectName(int index) {
    final names = [
      'Introduction to Programming',
      'Data Structures',
      'Algorithms',
      'Database Systems',
      'Web Development',
      'Mobile Development',
      'Software Engineering',
      'Operating Systems',
      'Computer Networks',
      'Artificial Intelligence',
      'Machine Learning',
      'Computer Graphics',
      'Cybersecurity',
      'Cloud Computing',
      'DevOps Practices',
    ];
    return names[index % names.length];
  }

  SubjectType _getMockSubjectType(int index) {
    final types = [
      SubjectType.required,
      SubjectType.required,
      SubjectType.elective,
      SubjectType.required,
      SubjectType.freeElective,
    ];
    return types[index % types.length];
  }

  String _getMockArea(int index) {
    final areas = ['Programming', 'Theory', 'Systems', 'Development', 'Data Science'];
    return areas[index % areas.length];
  }

  List<Subject> get _filteredSubjects {
    var filtered = _subjects.where((subject) {
      final matchesSearch = _searchQuery.isEmpty ||
          subject.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          subject.code.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType = _filterType == null || subject.subjectType == _filterType;

      return matchesSearch && matchesType;
    }).toList();

    // Filter by semester if not "All"
    if (_tabController.index > 0) {
      final semesterIndex = _tabController.index;
      filtered = filtered.where((subject) {
        return subject.semesterId == 'semester-$semesterIndex';
      }).toList();
    }

    return filtered;
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<SubjectType?>(
              title: const Text('All'),
              value: null,
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<SubjectType?>(
              title: const Text('Required'),
              value: SubjectType.required,
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<SubjectType?>(
              title: const Text('Elective'),
              value: SubjectType.elective,
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<SubjectType?>(
              title: const Text('Free Elective'),
              value: SubjectType.freeElective,
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<SubjectType?>(
              title: const Text('Complementary'),
              value: SubjectType.complementary,
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _semesters.map((semester) => Tab(text: semester)).toList(),
          onTap: (_) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _filterType != null ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search subjects...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Subjects List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSubjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No subjects found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSubjects,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = _filteredSubjects[index];
                            return _SubjectCard(
                              subject: subject,
                              typeColor: _getTypeColor(subject.subjectType),
                              onTap: () {
                                // TODO: Navigate to subject detail
                                context.push('/subjects/${subject.id}');
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add subject
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final Color typeColor;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.typeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      subject.code,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      subject.subjectTypeDisplayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: typeColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (subject.isElective)
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subject.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subject.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  subject.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.stars,
                    label: '${subject.credits} Credits',
                  ),
                  const SizedBox(width: 8),
                  if (subject.hoursPerWeek != null)
                    _InfoChip(
                      icon: Icons.access_time,
                      label: '${subject.hoursPerWeek}h/week',
                    ),
                  const SizedBox(width: 8),
                  if (subject.area != null)
                    _InfoChip(
                      icon: Icons.category,
                      label: subject.area!,
                    ),
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
