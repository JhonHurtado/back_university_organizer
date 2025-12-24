import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/career_provider.dart';
import '../../models/career.dart';

/// Screen for creating a new career
class CreateCareerScreen extends StatefulWidget {
  const CreateCareerScreen({super.key});

  @override
  State<CreateCareerScreen> createState() => _CreateCareerScreenState();
}

class _CreateCareerScreenState extends State<CreateCareerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  final _campusController = TextEditingController();
  final _totalCreditsController = TextEditingController();
  final _totalSemestersController = TextEditingController();

  GradeScale _gradeScale = GradeScale.five;
  DateTime _startDate = DateTime.now();
  DateTime? _expectedEndDate;
  String _selectedColor = '#3B82F6';
  bool _isLoading = false;

  final List<String> _availableColors = [
    '#3B82F6', // Blue
    '#10B981', // Green
    '#F59E0B', // Orange
    '#EF4444', // Red
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#14B8A6', // Teal
    '#F97316', // Orange
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _campusController.dispose();
    _totalCreditsController.dispose();
    _totalSemestersController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<CareerProvider>().createCareer(
            name: _nameController.text,
            university: _universityController.text,
            totalCredits: int.parse(_totalCreditsController.text),
            totalSemesters: int.parse(_totalSemestersController.text),
            startDate: _startDate,
            code: _codeController.text.isNotEmpty ? _codeController.text : null,
            faculty:
                _facultyController.text.isNotEmpty ? _facultyController.text : null,
            campus:
                _campusController.text.isNotEmpty ? _campusController.text : null,
            gradeScale: _gradeScale,
            expectedEndDate: _expectedEndDate,
            color: _selectedColor,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Career created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create career: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Career'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Career Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Career Name *',
                  hintText: 'e.g., Computer Science',
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter career name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // University
              TextFormField(
                controller: _universityController,
                decoration: const InputDecoration(
                  labelText: 'University *',
                  hintText: 'e.g., National University',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter university name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Career Code
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Career Code (Optional)',
                  hintText: 'e.g., CS-2024',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 16),

              // Faculty
              TextFormField(
                controller: _facultyController,
                decoration: const InputDecoration(
                  labelText: 'Faculty (Optional)',
                  hintText: 'e.g., Engineering',
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 16),

              // Campus
              TextFormField(
                controller: _campusController,
                decoration: const InputDecoration(
                  labelText: 'Campus (Optional)',
                  hintText: 'e.g., Main Campus',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 16),

              // Total Credits
              TextFormField(
                controller: _totalCreditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Credits *',
                  hintText: 'e.g., 180',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total credits';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Total Semesters
              TextFormField(
                controller: _totalSemestersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Semesters *',
                  hintText: 'e.g., 10',
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total semesters';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Grade Scale
              DropdownButtonFormField<GradeScale>(
                initialValue: _gradeScale,
                decoration: const InputDecoration(
                  labelText: 'Grade Scale',
                  prefixIcon: Icon(Icons.grade),
                ),
                items: GradeScale.values.map((scale) {
                  String label;
                  switch (scale) {
                    case GradeScale.five:
                      label = '0-5 (Colombia, México)';
                      break;
                    case GradeScale.ten:
                      label = '0-10 (Argentina, España)';
                      break;
                    case GradeScale.hundred:
                      label = '0-100 (USA Percentage)';
                      break;
                    case GradeScale.fourGPA:
                      label = '0-4 GPA (USA)';
                      break;
                    case GradeScale.seven:
                      label = '1-7 (Chile)';
                      break;
                  }
                  return DropdownMenuItem(
                    value: scale,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _gradeScale = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Start Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Start Date'),
                subtitle: Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() => _startDate = date);
                  }
                },
              ),
              const Divider(),

              // Expected End Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available),
                title: const Text('Expected End Date (Optional)'),
                subtitle: Text(
                  _expectedEndDate != null
                      ? '${_expectedEndDate!.day}/${_expectedEndDate!.month}/${_expectedEndDate!.year}'
                      : 'Not set',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _expectedEndDate ?? _startDate,
                    firstDate: _startDate,
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() => _expectedEndDate = date);
                  }
                },
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Color Picker
              const Text(
                'Career Color',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Create Career'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
