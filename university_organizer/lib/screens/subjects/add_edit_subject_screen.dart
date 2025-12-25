import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/subject.dart';

/// Add/Edit subject screen for creating or updating subjects
class AddEditSubjectScreen extends StatefulWidget {
  final String careerId;
  final String? subjectId;
  final Subject? subject;

  const AddEditSubjectScreen({
    super.key,
    required this.careerId,
    this.subjectId,
    this.subject,
  });

  bool get isEditMode => subjectId != null || subject != null;

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Form controllers
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _creditsController;
  late TextEditingController _hoursPerWeekController;
  late TextEditingController _areaController;
  late TextEditingController _totalCutsController;

  SubjectType _subjectType = SubjectType.required;
  bool _isElective = false;
  Map<String, double> _gradeWeights = {};
  bool _showGradeWeights = false;

  @override
  void initState() {
    super.initState();

    _codeController = TextEditingController(
      text: widget.subject?.code ?? '',
    );
    _nameController = TextEditingController(
      text: widget.subject?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.subject?.description ?? '',
    );
    _creditsController = TextEditingController(
      text: widget.subject?.credits.toString() ?? '',
    );
    _hoursPerWeekController = TextEditingController(
      text: widget.subject?.hoursPerWeek?.toString() ?? '',
    );
    _areaController = TextEditingController(
      text: widget.subject?.area ?? '',
    );
    _totalCutsController = TextEditingController(
      text: widget.subject?.totalCuts.toString() ?? '3',
    );

    if (widget.subject != null) {
      _subjectType = widget.subject!.subjectType;
      _isElective = widget.subject!.isElective;
      _gradeWeights = Map.from(widget.subject!.gradeWeights ?? {});
      _showGradeWeights = _gradeWeights.isNotEmpty;
    }

    // Add listeners
    _codeController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _creditsController.addListener(_onFieldChanged);
    _hoursPerWeekController.addListener(_onFieldChanged);
    _areaController.addListener(_onFieldChanged);
    _totalCutsController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _creditsController.dispose();
    _hoursPerWeekController.dispose();
    _areaController.dispose();
    _totalCutsController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate grade weights if enabled
    if (_showGradeWeights) {
      final totalWeight = _gradeWeights.values.fold<double>(0, (sum, weight) => sum + weight);
      if (totalWeight != 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grade weights must sum to 100%'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Save subject via API
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Subject updated successfully'
                : 'Subject added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save subject: $e'),
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

  void _addGradeWeight() {
    final nameController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Grade Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., midterm1, finalExam',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (%)',
                hintText: 'e.g., 25, 30, 40',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && weightController.text.isNotEmpty) {
                final weight = double.tryParse(weightController.text);
                if (weight != null && weight > 0) {
                  setState(() {
                    _gradeWeights[nameController.text] = weight;
                    _hasUnsavedChanges = true;
                  });
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeGradeWeight(String key) {
    setState(() {
      _gradeWeights.remove(key);
      _hasUnsavedChanges = true;
    });
  }

  String _formatWeightName(String name) {
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final totalWeight = _gradeWeights.values.fold<double>(0, (sum, weight) => sum + weight);

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
          title: Text(widget.isEditMode ? 'Edit Subject' : 'Add Subject'),
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
                onPressed: _saveSubject,
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
                // Basic Information Section
                _SectionHeader(title: 'BASIC INFORMATION'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'Subject Code',
                            hintText: 'e.g., CS301, MATH201',
                            prefixIcon: Icon(Icons.tag),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter subject code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Subject Name',
                            hintText: 'e.g., Data Structures',
                            prefixIcon: Icon(Icons.book),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter subject name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'Brief description of the subject',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Academic Information Section
                _SectionHeader(title: 'ACADEMIC INFORMATION'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _creditsController,
                                decoration: const InputDecoration(
                                  labelText: 'Credits',
                                  hintText: '3',
                                  prefixIcon: Icon(Icons.stars),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final credits = int.tryParse(value);
                                  if (credits == null || credits < 1) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _hoursPerWeekController,
                                decoration: const InputDecoration(
                                  labelText: 'Hours/Week',
                                  hintText: '4',
                                  prefixIcon: Icon(Icons.access_time),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _areaController,
                          decoration: const InputDecoration(
                            labelText: 'Area (Optional)',
                            hintText: 'e.g., Programming, Mathematics',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _totalCutsController,
                          decoration: const InputDecoration(
                            labelText: 'Total Cuts',
                            hintText: '3',
                            prefixIcon: Icon(Icons.format_list_numbered),
                            border: OutlineInputBorder(),
                            helperText: 'Number of grading periods',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter total cuts';
                            }
                            final cuts = int.tryParse(value);
                            if (cuts == null || cuts < 1) {
                              return 'Must be at least 1';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Subject Type Section
                _SectionHeader(title: 'SUBJECT TYPE'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        RadioListTile<SubjectType>(
                          title: const Text('Required'),
                          subtitle: const Text('Mandatory subject'),
                          value: SubjectType.required,
                          groupValue: _subjectType,
                          onChanged: (value) {
                            setState(() {
                              _subjectType = value!;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        RadioListTile<SubjectType>(
                          title: const Text('Elective'),
                          subtitle: const Text('Optional subject'),
                          value: SubjectType.elective,
                          groupValue: _subjectType,
                          onChanged: (value) {
                            setState(() {
                              _subjectType = value!;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        RadioListTile<SubjectType>(
                          title: const Text('Free Elective'),
                          subtitle: const Text('Free choice subject'),
                          value: SubjectType.freeElective,
                          groupValue: _subjectType,
                          onChanged: (value) {
                            setState(() {
                              _subjectType = value!;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        RadioListTile<SubjectType>(
                          title: const Text('Complementary'),
                          subtitle: const Text('Complementary subject'),
                          value: SubjectType.complementary,
                          groupValue: _subjectType,
                          onChanged: (value) {
                            setState(() {
                              _subjectType = value!;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Is Elective'),
                          subtitle: const Text('Mark as elective course'),
                          value: _isElective,
                          onChanged: (value) {
                            setState(() {
                              _isElective = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Grade Weights Section
                _SectionHeader(title: 'GRADE WEIGHTS'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: const Text('Enable Grade Weights'),
                          subtitle: const Text('Define how grades are calculated'),
                          value: _showGradeWeights,
                          onChanged: (value) {
                            setState(() {
                              _showGradeWeights = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        if (_showGradeWeights) ...[
                          const Divider(),
                          if (_gradeWeights.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(Icons.scale, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No grade weights defined',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: _addGradeWeight,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Weight'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _gradeWeights.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final entry = _gradeWeights.entries.elementAt(index);
                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.percent, color: AppColors.primary),
                                  ),
                                  title: Text(_formatWeightName(entry.key)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${entry.value}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: AppColors.error),
                                        onPressed: () => _removeGradeWeight(entry.key),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Total: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${totalWeight.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: totalWeight == 100 ? Colors.green : AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton.icon(
                                    onPressed: _addGradeWeight,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Weight'),
                                  ),
                                ],
                              ),
                            ),
                            if (totalWeight != 100)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Grade weights must sum to 100%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ],
                    ),
                  ),
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
                        onPressed: _isLoading ? null : _saveSubject,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.isEditMode ? 'Update Subject' : 'Add Subject'),
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
