import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/grade.dart';

/// Add/Edit grade screen for creating or updating grades
class AddEditGradeScreen extends StatefulWidget {
  final String subjectId;
  final String? gradeId;
  final Grade? grade;

  const AddEditGradeScreen({
    super.key,
    required this.subjectId,
    this.gradeId,
    this.grade,
  });

  bool get isEditMode => gradeId != null || grade != null;

  @override
  State<AddEditGradeScreen> createState() => _AddEditGradeScreenState();
}

class _AddEditGradeScreenState extends State<AddEditGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Form controllers
  late TextEditingController _cutNumberController;
  late TextEditingController _cutNameController;
  late TextEditingController _gradeController;
  late TextEditingController _maxGradeController;
  late TextEditingController _weightController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;

  DateTime _gradedAt = DateTime.now();

  @override
  void initState() {
    super.initState();

    _cutNumberController = TextEditingController(
      text: widget.grade?.cutNumber.toString() ?? '',
    );
    _cutNameController = TextEditingController(
      text: widget.grade?.cutName ?? '',
    );
    _gradeController = TextEditingController(
      text: widget.grade?.grade.toString() ?? '',
    );
    _maxGradeController = TextEditingController(
      text: widget.grade?.maxGrade.toString() ?? '5.0',
    );
    _weightController = TextEditingController(
      text: widget.grade?.weight.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.grade?.description ?? '',
    );
    _notesController = TextEditingController(
      text: widget.grade?.notes ?? '',
    );

    if (widget.grade != null) {
      _gradedAt = widget.grade!.gradedAt;
    }

    // Add listeners for unsaved changes detection
    _cutNumberController.addListener(_onFieldChanged);
    _cutNameController.addListener(_onFieldChanged);
    _gradeController.addListener(_onFieldChanged);
    _maxGradeController.addListener(_onFieldChanged);
    _weightController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _notesController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _cutNumberController.dispose();
    _cutNameController.dispose();
    _gradeController.dispose();
    _maxGradeController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _gradedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _gradedAt) {
      setState(() {
        _gradedAt = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveGrade() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Save grade via API
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Grade updated successfully'
                : 'Grade added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save grade: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditMode ? 'Edit Grade' : 'Add Grade'),
          actions: [
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _saveGrade,
                child: const Text('Save'),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cut Information Section
                _SectionHeader(title: 'CUT INFORMATION'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _cutNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Cut Number',
                            hintText: 'e.g., 1, 2, 3',
                            prefixIcon: Icon(Icons.numbers),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter cut number';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number < 1) {
                              return 'Please enter a valid cut number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cutNameController,
                          decoration: const InputDecoration(
                            labelText: 'Cut Name (Optional)',
                            hintText: 'e.g., First Cut, Midterm',
                            prefixIcon: Icon(Icons.label),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Grade Details Section
                _SectionHeader(title: 'GRADE DETAILS'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _gradeController,
                                decoration: const InputDecoration(
                                  labelText: 'Grade',
                                  hintText: '0.0 - 5.0',
                                  prefixIcon: Icon(Icons.grade),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final grade = double.tryParse(value);
                                  if (grade == null) {
                                    return 'Invalid';
                                  }
                                  final maxGrade = double.tryParse(_maxGradeController.text) ?? 5.0;
                                  if (grade < 0 || grade > maxGrade) {
                                    return '0-$maxGrade';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _maxGradeController,
                                decoration: const InputDecoration(
                                  labelText: 'Max',
                                  hintText: '5.0',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final maxGrade = double.tryParse(value);
                                  if (maxGrade == null || maxGrade <= 0) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight (%)',
                            hintText: 'e.g., 30, 35, 40',
                            prefixIcon: Icon(Icons.percent),
                            border: OutlineInputBorder(),
                            helperText: 'Contribution to final grade',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter weight';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight < 0 || weight > 100) {
                              return 'Weight must be between 0 and 100';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(4),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Graded Date',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy').format(_gradedAt),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Additional Information Section
                _SectionHeader(title: 'ADDITIONAL INFORMATION'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'Brief description of this grade',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'Additional notes or comments',
                            prefixIcon: Icon(Icons.note),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Grade Preview Card
                if (_gradeController.text.isNotEmpty &&
                    _maxGradeController.text.isNotEmpty &&
                    _weightController.text.isNotEmpty)
                  _GradePreviewCard(
                    grade: double.tryParse(_gradeController.text) ?? 0.0,
                    maxGrade: double.tryParse(_maxGradeController.text) ?? 5.0,
                    weight: double.tryParse(_weightController.text) ?? 0.0,
                  ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveGrade,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.isEditMode ? 'Update Grade' : 'Add Grade'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
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

class _GradePreviewCard extends StatelessWidget {
  final double grade;
  final double maxGrade;
  final double weight;

  const _GradePreviewCard({
    required this.grade,
    required this.maxGrade,
    required this.weight,
  });

  Color get gradeColor {
    final percentage = (grade / maxGrade) * 100;
    if (percentage >= 85) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = ((grade / maxGrade) * 100).toStringAsFixed(1);
    final contribution = ((grade * weight) / 100).toStringAsFixed(2);

    return Card(
      color: gradeColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, size: 20, color: gradeColor),
                const SizedBox(width: 8),
                const Text(
                  'Grade Preview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PreviewItem(
                  label: 'Grade',
                  value: '${grade.toStringAsFixed(1)}/${maxGrade.toStringAsFixed(1)}',
                  color: gradeColor,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _PreviewItem(
                  label: 'Percentage',
                  value: '$percentage%',
                  color: gradeColor,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _PreviewItem(
                  label: 'Contribution',
                  value: '$contribution pts',
                  color: gradeColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PreviewItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
