import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';

/// Schedule weekly view screen showing weekly class schedule
class ScheduleWeeklyView extends StatefulWidget {
  const ScheduleWeeklyView({super.key});

  @override
  State<ScheduleWeeklyView> createState() => _ScheduleWeeklyViewState();
}

class _ScheduleWeeklyViewState extends State<ScheduleWeeklyView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _isLoading = false;

  // Mock schedule data
  final Map<int, List<Map<String, dynamic>>> _weekSchedule = {
    1: [ // Monday
      {
        'id': 'sch-1',
        'subject': 'Data Structures',
        'code': 'CS301',
        'startTime': '08:00',
        'endTime': '10:00',
        'room': 'Room 101',
        'building': 'Engineering Building',
        'type': 'CLASS',
        'color': '#3B82F6',
      },
      {
        'id': 'sch-2',
        'subject': 'Algorithms',
        'code': 'CS302',
        'startTime': '14:00',
        'endTime': '16:00',
        'room': 'Room 205',
        'building': 'Engineering Building',
        'type': 'CLASS',
        'color': '#10B981',
      },
    ],
    2: [ // Tuesday
      {
        'id': 'sch-3',
        'subject': 'Database Systems',
        'code': 'CS201',
        'startTime': '10:00',
        'endTime': '12:00',
        'room': 'Lab 3',
        'building': 'Computer Lab',
        'type': 'LAB',
        'color': '#F59E0B',
      },
    ],
    3: [ // Wednesday
      {
        'id': 'sch-4',
        'subject': 'Data Structures',
        'code': 'CS301',
        'startTime': '08:00',
        'endTime': '10:00',
        'room': 'Room 101',
        'building': 'Engineering Building',
        'type': 'CLASS',
        'color': '#3B82F6',
      },
      {
        'id': 'sch-5',
        'subject': 'Web Development',
        'code': 'CS203',
        'startTime': '16:00',
        'endTime': '18:00',
        'room': 'Room 303',
        'building': 'Engineering Building',
        'type': 'CLASS',
        'color': '#8B5CF6',
      },
    ],
    4: [ // Thursday
      {
        'id': 'sch-6',
        'subject': 'Database Systems',
        'code': 'CS201',
        'startTime': '10:00',
        'endTime': '12:00',
        'room': 'Lab 3',
        'building': 'Computer Lab',
        'type': 'LAB',
        'color': '#F59E0B',
      },
      {
        'id': 'sch-7',
        'subject': 'Algorithms',
        'code': 'CS302',
        'startTime': '14:00',
        'endTime': '16:00',
        'room': 'Room 205',
        'building': 'Engineering Building',
        'type': 'CLASS',
        'color': '#10B981',
      },
    ],
    5: [ // Friday
      {
        'id': 'sch-8',
        'subject': 'Web Development',
        'code': 'CS203',
        'startTime': '16:00',
        'endTime': '18:00',
        'room': 'Room 303',
        'building': 'Engineering Building',
        'type': 'CLASS',
        'color': '#8B5CF6',
      },
    ],
  };

  List<Map<String, dynamic>> get _todaySchedule {
    final dayOfWeek = _selectedDay.weekday;
    return _weekSchedule[dayOfWeek] ?? [];
  }

  bool get _hasScheduleToday => _todaySchedule.isNotEmpty;

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'CLASS':
        return 'Class';
      case 'LAB':
        return 'Laboratory';
      case 'TUTORIAL':
        return 'Tutorial';
      case 'OFFICE_HOURS':
        return 'Office Hours';
      case 'EXAM':
        return 'Exam';
      default:
        return 'Other';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'CLASS':
        return Icons.school;
      case 'LAB':
        return Icons.science;
      case 'TUTORIAL':
        return Icons.people;
      case 'OFFICE_HOURS':
        return Icons.schedule;
      case 'EXAM':
        return Icons.quiz;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: Icon(
              _calendarFormat == CalendarFormat.week
                  ? Icons.calendar_view_month
                  : Icons.calendar_view_week,
            ),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.week
                    ? CalendarFormat.month
                    : CalendarFormat.week;
              });
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'today',
                child: Row(
                  children: [
                    Icon(Icons.today, size: 20),
                    SizedBox(width: 12),
                    Text('Go to Today'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 12),
                    Text('Add Schedule'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'today':
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                  });
                  break;
                case 'add':
                  // TODO: Navigate to add schedule
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              // Show markers for days with schedule
              final dayOfWeek = day.weekday;
              final hasSchedule = _weekSchedule.containsKey(dayOfWeek) &&
                  _weekSchedule[dayOfWeek]!.isNotEmpty;
              return hasSchedule ? [''] : [];
            },
          ),

          const Divider(height: 1),

          // Selected Day Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.grey[100],
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_hasScheduleToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_todaySchedule.length} ${_todaySchedule.length == 1 ? 'class' : 'classes'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Schedule List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasScheduleToday
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No classes scheduled',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enjoy your free day!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _todaySchedule.length,
                        itemBuilder: (context, index) {
                          final schedule = _todaySchedule[index];
                          final color = _parseColor(schedule['color']);

                          return _ScheduleCard(
                            subject: schedule['subject'],
                            code: schedule['code'],
                            startTime: schedule['startTime'],
                            endTime: schedule['endTime'],
                            room: schedule['room'],
                            building: schedule['building'],
                            type: _getTypeDisplayName(schedule['type']),
                            typeIcon: _getTypeIcon(schedule['type']),
                            color: color,
                            onTap: () {
                              // TODO: Navigate to schedule detail
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add schedule
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String subject;
  final String code;
  final String startTime;
  final String endTime;
  final String? room;
  final String? building;
  final String type;
  final IconData typeIcon;
  final Color color;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.subject,
    required this.code,
    required this.startTime,
    required this.endTime,
    this.room,
    this.building,
    required this.type,
    required this.typeIcon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(typeIcon, size: 20, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                code,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  type,
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
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '$startTime - $endTime',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 24),
                    if (room != null) ...[
                      Icon(Icons.room, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          room!,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (building != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          building!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
      ),
    );
  }
}
