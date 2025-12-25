import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Preferences screen for academic and notification settings
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Notification Preferences
  bool _enableNotifications = true;
  bool _gradeNotifications = true;
  bool _scheduleReminders = true;
  bool _assignmentReminders = true;
  bool _examReminders = true;
  int _reminderMinutesBefore = 30;

  // Display Preferences
  String _gradeScale = 'FIVE';
  bool _showGPA = true;
  String _weekStartDay = 'Monday';
  bool _use24HourFormat = false;

  // Academic Preferences
  bool _autoCalculateGrades = true;
  bool _showPercentages = true;
  bool _highlightPassingGrades = true;
  double _passingGrade = 3.0; // Used when saving preferences to backend

  bool _hasChanges = false;

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _savePreferences() async {
    // TODO: Save preferences to backend
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences saved successfully'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => _hasChanges = false);
  }

  void _showReminderTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('15 minutes before'),
              value: 15,
              groupValue: _reminderMinutesBefore,
              onChanged: (value) {
                setState(() => _reminderMinutesBefore = value!);
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('30 minutes before'),
              value: 30,
              groupValue: _reminderMinutesBefore,
              onChanged: (value) {
                setState(() => _reminderMinutesBefore = value!);
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('1 hour before'),
              value: 60,
              groupValue: _reminderMinutesBefore,
              onChanged: (value) {
                setState(() => _reminderMinutesBefore = value!);
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('1 day before'),
              value: 1440,
              groupValue: _reminderMinutesBefore,
              onChanged: (value) {
                setState(() => _reminderMinutesBefore = value!);
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGradeScaleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grade Scale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('0-5 (Colombian)'),
              value: 'FIVE',
              groupValue: _gradeScale,
              onChanged: (value) {
                setState(() {
                  _gradeScale = value!;
                  _passingGrade = 3.0;
                });
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('0-10 (Mexican)'),
              value: 'TEN',
              groupValue: _gradeScale,
              onChanged: (value) {
                setState(() {
                  _gradeScale = value!;
                  _passingGrade = 6.0;
                });
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('0-100 (Percentage)'),
              value: 'HUNDRED',
              groupValue: _gradeScale,
              onChanged: (value) {
                setState(() {
                  _gradeScale = value!;
                  _passingGrade = 60.0;
                });
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('0-4 GPA'),
              value: 'FOUR_GPA',
              groupValue: _gradeScale,
              onChanged: (value) {
                setState(() {
                  _gradeScale = value!;
                  _passingGrade = 2.0;
                });
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWeekStartDayDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Week Start Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Monday'),
              value: 'Monday',
              groupValue: _weekStartDay,
              onChanged: (value) {
                setState(() => _weekStartDay = value!);
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Sunday'),
              value: 'Sunday',
              groupValue: _weekStartDay,
              onChanged: (value) {
                setState(() => _weekStartDay = value!);
                _markAsChanged();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getReminderTimeText() {
    if (_reminderMinutesBefore < 60) {
      return '$_reminderMinutesBefore minutes before';
    } else if (_reminderMinutesBefore == 60) {
      return '1 hour before';
    } else {
      return '${_reminderMinutesBefore ~/ 60} hours before';
    }
  }

  String _getGradeScaleText() {
    switch (_gradeScale) {
      case 'FIVE':
        return '0-5 (Colombian)';
      case 'TEN':
        return '0-10 (Mexican)';
      case 'HUNDRED':
        return '0-100 (Percentage)';
      case 'FOUR_GPA':
        return '0-4 GPA';
      default:
        return '0-5';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text('You have unsaved changes. Do you want to discard them?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Preferences'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _savePreferences,
                child: const Text('Save'),
              ),
          ],
        ),
        body: ListView(
          children: [
            // Notifications Section
            const _SectionHeader(title: 'NOTIFICATIONS'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active),
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive all notifications'),
                    value: _enableNotifications,
                    onChanged: (value) {
                      setState(() => _enableNotifications = value);
                      _markAsChanged();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.grade),
                    title: const Text('Grade Notifications'),
                    subtitle: const Text('Get notified when grades are posted'),
                    value: _gradeNotifications,
                    onChanged: _enableNotifications
                        ? (value) {
                            setState(() => _gradeNotifications = value);
                            _markAsChanged();
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.calendar_today),
                    title: const Text('Schedule Reminders'),
                    subtitle: const Text('Remind me about upcoming classes'),
                    value: _scheduleReminders,
                    onChanged: _enableNotifications
                        ? (value) {
                            setState(() => _scheduleReminders = value);
                            _markAsChanged();
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.assignment),
                    title: const Text('Assignment Reminders'),
                    subtitle: const Text('Remind me about assignments'),
                    value: _assignmentReminders,
                    onChanged: _enableNotifications
                        ? (value) {
                            setState(() => _assignmentReminders = value);
                            _markAsChanged();
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.quiz),
                    title: const Text('Exam Reminders'),
                    subtitle: const Text('Remind me about exams'),
                    value: _examReminders,
                    onChanged: _enableNotifications
                        ? (value) {
                            setState(() => _examReminders = value);
                            _markAsChanged();
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Reminder Time'),
                    subtitle: Text(_getReminderTimeText()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _enableNotifications ? _showReminderTimeDialog : null,
                    enabled: _enableNotifications,
                  ),
                ],
              ),
            ),

            // Academic Preferences Section
            const _SectionHeader(title: 'ACADEMIC PREFERENCES'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.straighten),
                    title: const Text('Grade Scale'),
                    subtitle: Text(_getGradeScaleText()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showGradeScaleDialog,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.show_chart),
                    title: const Text('Show GPA'),
                    subtitle: const Text('Display GPA in grade views'),
                    value: _showGPA,
                    onChanged: (value) {
                      setState(() => _showGPA = value);
                      _markAsChanged();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.calculate),
                    title: const Text('Auto-Calculate Grades'),
                    subtitle: const Text('Automatically calculate final grades'),
                    value: _autoCalculateGrades,
                    onChanged: (value) {
                      setState(() => _autoCalculateGrades = value);
                      _markAsChanged();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.percent),
                    title: const Text('Show Percentages'),
                    subtitle: const Text('Display grade percentages'),
                    value: _showPercentages,
                    onChanged: (value) {
                      setState(() => _showPercentages = value);
                      _markAsChanged();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.highlight),
                    title: const Text('Highlight Passing Grades'),
                    subtitle: const Text('Highlight grades above passing threshold'),
                    value: _highlightPassingGrades,
                    onChanged: (value) {
                      setState(() => _highlightPassingGrades = value);
                      _markAsChanged();
                    },
                  ),
                ],
              ),
            ),

            // Display Preferences Section
            const _SectionHeader(title: 'DISPLAY PREFERENCES'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Week Starts On'),
                    subtitle: Text(_weekStartDay),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showWeekStartDayDialog,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.access_time),
                    title: const Text('24-Hour Format'),
                    subtitle: const Text('Use 24-hour time format'),
                    value: _use24HourFormat,
                    onChanged: (value) {
                      setState(() => _use24HourFormat = value);
                      _markAsChanged();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Save Button
            if (_hasChanges)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _savePreferences,
                    child: const Text('Save Preferences'),
                  ),
                ),
              ),

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }
}
