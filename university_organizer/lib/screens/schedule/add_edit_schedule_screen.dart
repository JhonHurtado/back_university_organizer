import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';

/// Add/Edit schedule screen for creating or updating schedule entries
class AddEditScheduleScreen extends StatefulWidget {
  final String? scheduleId;
  final Schedule? schedule;
  final String? subjectId;

  const AddEditScheduleScreen({
    super.key,
    this.scheduleId,
    this.schedule,
    this.subjectId,
  });

  bool get isEditMode => scheduleId != null || schedule != null;

  @override
  State<AddEditScheduleScreen> createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Form controllers
  late TextEditingController _roomController;
  late TextEditingController _buildingController;
  late TextEditingController _notesController;

  // Form values
  String? _selectedSubjectId;
  int _dayOfWeek = 1; // Monday
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  ScheduleType _scheduleType = ScheduleType.classType;
  String _selectedColor = '#3B82F6';
  bool _isRecurring = true;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _availableColors = [
    '#3B82F6', // Blue
    '#10B981', // Green
    '#F59E0B', // Orange
    '#EF4444', // Red
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#14B8A6', // Teal
    '#F97316', // Deep Orange
  ];

  final Map<int, String> _daysOfWeek = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  @override
  void initState() {
    super.initState();

    _roomController = TextEditingController(text: widget.schedule?.room ?? '');
    _buildingController = TextEditingController(text: widget.schedule?.building ?? '');
    _notesController = TextEditingController(text: widget.schedule?.notes ?? '');

    if (widget.schedule != null) {
      _dayOfWeek = widget.schedule!.dayOfWeek;
      _startTime = _parseTimeString(widget.schedule!.startTime);
      _endTime = _parseTimeString(widget.schedule!.endTime);
      _scheduleType = widget.schedule!.type;
      _selectedColor = widget.schedule!.color ?? '#3B82F6';
      _isRecurring = widget.schedule!.isRecurring;
      _startDate = widget.schedule!.startDate;
      _endDate = widget.schedule!.endDate;
    }

    _selectedSubjectId = widget.subjectId;

    _roomController.addListener(_onFieldChanged);
    _buildingController.addListener(_onFieldChanged);
    _notesController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _roomController.dispose();
    _buildingController.dispose();
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

  TimeOfDay _parseTimeString(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduleService = context.read<ScheduleService>();

      // Convert TimeOfDay to String format (HH:mm)
      final startTimeStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

      // Prepare location string
      final location = _roomController.text.isNotEmpty && _buildingController.text.isNotEmpty
          ? '${_roomController.text}, ${_buildingController.text}'
          : _roomController.text.isNotEmpty
              ? _roomController.text
              : _buildingController.text.isNotEmpty
                  ? _buildingController.text
                  : null;

      // Convert ScheduleType enum to string
      String scheduleTypeStr;
      switch (_scheduleType) {
        case ScheduleType.classType:
          scheduleTypeStr = 'CLASS';
          break;
        case ScheduleType.lab:
          scheduleTypeStr = 'LAB';
          break;
        case ScheduleType.tutorial:
          scheduleTypeStr = 'TUTORIAL';
          break;
        case ScheduleType.officeHours:
          scheduleTypeStr = 'OFFICE_HOURS';
          break;
        case ScheduleType.exam:
          scheduleTypeStr = 'EXAM';
          break;
        case ScheduleType.other:
          scheduleTypeStr = 'OTHER';
          break;
      }

      if (widget.isEditMode && widget.scheduleId != null) {
        // Update existing schedule
        await scheduleService.updateSchedule(
          widget.scheduleId!,
          dayOfWeek: _dayOfWeek,
          startTime: startTimeStr,
          endTime: endTimeStr,
          location: location,
          scheduleType: scheduleTypeStr,
          isRecurring: _isRecurring,
        );
      } else {
        // Create new schedule
        if (_selectedSubjectId == null) {
          throw Exception('Please select a subject');
        }

        await scheduleService.createSchedule(
          enrollmentId: _selectedSubjectId!,
          dayOfWeek: _dayOfWeek,
          startTime: startTimeStr,
          endTime: endTimeStr,
          location: location,
          scheduleType: scheduleTypeStr,
          isRecurring: _isRecurring,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Schedule updated successfully'
                : 'Schedule added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save schedule: $e'),
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

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
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
          title: Text(widget.isEditMode ? 'Edit Schedule' : 'Add Schedule'),
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
                onPressed: _saveSchedule,
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
                // Subject Selection
                _SectionHeader(title: 'SUBJECT'),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(_selectedSubjectId != null
                        ? 'Selected Subject'
                        : 'Select Subject'),
                    subtitle: const Text('Tap to select a subject'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to subject selector
                      setState(() {
                        _selectedSubjectId = 'subject-1';
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Time & Day Section
                _SectionHeader(title: 'TIME & DAY'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: _dayOfWeek,
                          decoration: const InputDecoration(
                            labelText: 'Day of Week',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          items: _daysOfWeek.entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _dayOfWeek = value;
                                _hasUnsavedChanges = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _selectStartTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Start Time',
                                    prefixIcon: Icon(Icons.access_time),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _startTime.format(context),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _selectEndTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'End Time',
                                    prefixIcon: Icon(Icons.access_time),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _endTime.format(context),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Location Section
                _SectionHeader(title: 'LOCATION'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _roomController,
                          decoration: const InputDecoration(
                            labelText: 'Room',
                            hintText: 'e.g., Room 101, Lab 3',
                            prefixIcon: Icon(Icons.room),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _buildingController,
                          decoration: const InputDecoration(
                            labelText: 'Building',
                            hintText: 'e.g., Engineering Building',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Type & Color Section
                _SectionHeader(title: 'TYPE & APPEARANCE'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<ScheduleType>(
                          value: _scheduleType,
                          decoration: const InputDecoration(
                            labelText: 'Schedule Type',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          items: ScheduleType.values.map((type) {
                            return DropdownMenuItem<ScheduleType>(
                              value: type,
                              child: Text(_getTypeDisplayName(type)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _scheduleType = value;
                                _hasUnsavedChanges = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Color',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _availableColors.map((color) {
                            final isSelected = _selectedColor == color;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                  _hasUnsavedChanges = true;
                                });
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _parseColor(color),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Recurrence Section
                _SectionHeader(title: 'RECURRENCE'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Recurring Schedule'),
                          subtitle: const Text('Repeat weekly'),
                          value: _isRecurring,
                          onChanged: (value) {
                            setState(() {
                              _isRecurring = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        if (_isRecurring) ...[
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _selectStartDate,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Start Date',
                                      prefixIcon: Icon(Icons.event),
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      _startDate != null
                                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                          : 'Select date',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectEndDate,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'End Date (Optional)',
                                      prefixIcon: Icon(Icons.event),
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      _endDate != null
                                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                          : 'No end date',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Notes Section
                _SectionHeader(title: 'NOTES'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Additional notes or comments',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
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
                        onPressed: _isLoading ? null : _saveSchedule,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.isEditMode ? 'Update Schedule' : 'Add Schedule'),
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

  String _getTypeDisplayName(ScheduleType type) {
    switch (type) {
      case ScheduleType.classType:
        return 'Class';
      case ScheduleType.lab:
        return 'Laboratory';
      case ScheduleType.tutorial:
        return 'Tutorial';
      case ScheduleType.officeHours:
        return 'Office Hours';
      case ScheduleType.exam:
        return 'Exam';
      case ScheduleType.other:
        return 'Other';
    }
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
