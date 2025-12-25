import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Grade calculator screen - utility to calculate required grades
class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});

  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {
  final _maxGradeController = TextEditingController(text: '5.0');
  final _targetGradeController = TextEditingController(text: '4.0');

  List<GradeItem> _completedGrades = [];
  List<GradeItem> _remainingGrades = [];

  double? _requiredGrade;
  bool _isAchievable = true;

  @override
  void initState() {
    super.initState();
    // Add initial items
    _completedGrades.add(GradeItem(
      name: 'Midterm 1',
      weight: 25.0,
      grade: 4.5,
    ));
    _remainingGrades.add(GradeItem(
      name: 'Final Exam',
      weight: 35.0,
    ));
  }

  @override
  void dispose() {
    _maxGradeController.dispose();
    _targetGradeController.dispose();
    super.dispose();
  }

  void _calculate() {
    final maxGrade = double.tryParse(_maxGradeController.text) ?? 5.0;
    final targetGrade = double.tryParse(_targetGradeController.text) ?? 4.0;

    // Calculate current weighted sum
    double completedWeightedSum = 0;
    double completedWeightSum = 0;

    for (var item in _completedGrades) {
      if (item.grade != null) {
        completedWeightedSum += (item.grade! * item.weight) / 100;
        completedWeightSum += item.weight;
      }
    }

    // Calculate remaining weight
    double remainingWeightSum = 0;
    for (var item in _remainingGrades) {
      remainingWeightSum += item.weight;
    }

    // Calculate total weight
    final totalWeight = completedWeightSum + remainingWeightSum;

    if (totalWeight != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total weight must be 100% (currently: ${totalWeight.toStringAsFixed(1)}%)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Calculate required grade on remaining items
    // targetGrade = completedWeightedSum + (requiredGrade * remainingWeightSum / 100)
    // requiredGrade = (targetGrade - completedWeightedSum) * 100 / remainingWeightSum

    if (remainingWeightSum > 0) {
      final required = (targetGrade - completedWeightedSum) * 100 / remainingWeightSum;

      setState(() {
        _requiredGrade = required;
        _isAchievable = required >= 0 && required <= maxGrade;
      });
    } else {
      // No remaining grades
      setState(() {
        _requiredGrade = null;
        _isAchievable = completedWeightedSum >= targetGrade;
      });
    }
  }

  void _addCompletedGrade() {
    setState(() {
      _completedGrades.add(GradeItem(
        name: 'Grade ${_completedGrades.length + 1}',
        weight: 0,
        grade: 0,
      ));
    });
  }

  void _addRemainingGrade() {
    setState(() {
      _remainingGrades.add(GradeItem(
        name: 'Assignment ${_remainingGrades.length + 1}',
        weight: 0,
      ));
    });
  }

  void _removeCompletedGrade(int index) {
    setState(() {
      _completedGrades.removeAt(index);
    });
  }

  void _removeRemainingGrade(int index) {
    setState(() {
      _remainingGrades.removeAt(index);
    });
  }

  Color _getResultColor() {
    if (_requiredGrade == null) {
      return _isAchievable ? Colors.green : Colors.red;
    }

    final maxGrade = double.tryParse(_maxGradeController.text) ?? 5.0;
    final percentage = (_requiredGrade! / maxGrade) * 100;

    if (!_isAchievable) return Colors.red;
    if (percentage >= 85) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: () {
              setState(() {
                _completedGrades.clear();
                _remainingGrades.clear();
                _requiredGrade = null;
                _maxGradeController.text = '5.0';
                _targetGradeController.text = '4.0';
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Calculate the grade you need on remaining assignments to achieve your target grade',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Settings Section
            _SectionHeader(title: 'SETTINGS'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _maxGradeController,
                        decoration: const InputDecoration(
                          labelText: 'Max Grade',
                          hintText: '5.0',
                          prefixIcon: Icon(Icons.trending_up),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _targetGradeController,
                        decoration: const InputDecoration(
                          labelText: 'Target Grade',
                          hintText: '4.0',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Completed Grades Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionHeader(title: 'COMPLETED GRADES'),
                TextButton.icon(
                  onPressed: _addCompletedGrade,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_completedGrades.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.grade_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No completed grades added',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._completedGrades.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _GradeItemCard(
                  item: item,
                  isCompleted: true,
                  onDelete: () => _removeCompletedGrade(index),
                  onChanged: () => setState(() {}),
                );
              }),

            const SizedBox(height: 24),

            // Remaining Grades Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionHeader(title: 'REMAINING GRADES'),
                TextButton.icon(
                  onPressed: _addRemainingGrade,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_remainingGrades.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.pending_actions, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No remaining grades added',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._remainingGrades.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _GradeItemCard(
                  item: item,
                  isCompleted: false,
                  onDelete: () => _removeRemainingGrade(index),
                  onChanged: () => setState(() {}),
                );
              }),

            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Required Grade'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Result Section
            if (_requiredGrade != null) ...[
              _SectionHeader(title: 'RESULT'),
              const SizedBox(height: 12),
              Card(
                color: _getResultColor().withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        _isAchievable ? Icons.check_circle : Icons.error,
                        size: 64,
                        color: _getResultColor(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isAchievable
                            ? 'You need to score'
                            : 'Target not achievable',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isAchievable) ...[
                        Text(
                          _requiredGrade!.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getResultColor(),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'out of ${_maxGradeController.text}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'on remaining assignments',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getResultColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${((_requiredGrade! / (double.tryParse(_maxGradeController.text) ?? 5.0)) * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getResultColor(),
                            ),
                          ),
                        ),
                      ] else
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'The required grade (${_requiredGrade!.toStringAsFixed(2)}) exceeds the maximum possible grade. Consider revising your target or improving existing grades.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

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

class _GradeItemCard extends StatelessWidget {
  final GradeItem item;
  final bool isCompleted;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _GradeItemCard({
    required this.item,
    required this.isCompleted,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'e.g., Midterm 1',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    controller: TextEditingController(text: item.name),
                    onChanged: (value) {
                      item.name = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Weight (%)',
                      hintText: '25',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: TextEditingController(
                      text: item.weight > 0 ? item.weight.toString() : '',
                    ),
                    onChanged: (value) {
                      item.weight = double.tryParse(value) ?? 0;
                      onChanged();
                    },
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        hintText: '4.5',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: TextEditingController(
                        text: item.grade != null && item.grade! > 0
                            ? item.grade.toString()
                            : '',
                      ),
                      onChanged: (value) {
                        item.grade = double.tryParse(value);
                        onChanged();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GradeItem {
  String name;
  double weight;
  double? grade;

  GradeItem({
    required this.name,
    required this.weight,
    this.grade,
  });
}
