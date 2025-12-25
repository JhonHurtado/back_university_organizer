import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../models/notification.dart';

/// Notifications screen showing all user notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  NotificationCategory? _filterCategory;
  bool? _filterRead; // null = all, true = read, false = unread

  // Mock notifications data
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load notifications from API
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _notifications = [
          AppNotification(
            id: 'notif-1',
            userId: 'user-1',
            title: 'New Grade Posted',
            message: 'Your grade for Data Structures midterm has been posted.',
            type: NotificationType.info,
            category: NotificationCategory.grade,
            isRead: false,
            actionUrl: '/subjects/sub-1/grades',
            actionLabel: 'View Grade',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          AppNotification(
            id: 'notif-2',
            userId: 'user-1',
            title: 'Schedule Change',
            message: 'Your Algorithms class has been moved to Room 305.',
            type: NotificationType.warning,
            category: NotificationCategory.schedule,
            isRead: false,
            actionUrl: '/schedule',
            actionLabel: 'View Schedule',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          AppNotification(
            id: 'notif-3',
            userId: 'user-1',
            title: 'Assignment Reminder',
            message: 'Database Systems assignment is due tomorrow.',
            type: NotificationType.warning,
            category: NotificationCategory.reminder,
            isRead: true,
            readAt: DateTime.now().subtract(const Duration(hours: 1)),
            actionUrl: '/subjects/sub-3',
            actionLabel: 'View Subject',
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          AppNotification(
            id: 'notif-4',
            userId: 'user-1',
            title: 'Payment Confirmation',
            message: 'Your semester payment has been processed successfully.',
            type: NotificationType.success,
            category: NotificationCategory.payment,
            isRead: true,
            readAt: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          AppNotification(
            id: 'notif-5',
            userId: 'user-1',
            title: 'Exam Schedule',
            message: 'Final exam schedule has been published.',
            type: NotificationType.info,
            category: NotificationCategory.academic,
            isRead: true,
            readAt: DateTime.now().subtract(const Duration(days: 3)),
            actionUrl: '/schedule',
            actionLabel: 'View Schedule',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          AppNotification(
            id: 'notif-6',
            userId: 'user-1',
            title: 'System Maintenance',
            message: 'The system will be under maintenance on Sunday 2:00 AM - 4:00 AM.',
            type: NotificationType.warning,
            category: NotificationCategory.system,
            isRead: false,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<AppNotification> get _filteredNotifications {
    return _notifications.where((notification) {
      // Filter by category
      if (_filterCategory != null && notification.category != _filterCategory) {
        return false;
      }

      // Filter by read status
      if (_filterRead != null && notification.isRead != _filterRead) {
        return false;
      }

      return true;
    }).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.grade:
        return Icons.grade;
      case NotificationCategory.schedule:
        return Icons.schedule;
      case NotificationCategory.academic:
        return Icons.school;
      case NotificationCategory.payment:
        return Icons.payment;
      case NotificationCategory.subscription:
        return Icons.card_membership;
      case NotificationCategory.reminder:
        return Icons.notifications_active;
      case NotificationCategory.system:
        return Icons.info_outline;
    }
  }

  String _getCategoryDisplayName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.grade:
        return 'Grade';
      case NotificationCategory.schedule:
        return 'Schedule';
      case NotificationCategory.academic:
        return 'Academic';
      case NotificationCategory.payment:
        return 'Payment';
      case NotificationCategory.subscription:
        return 'Subscription';
      case NotificationCategory.reminder:
        return 'Reminder';
      case NotificationCategory.system:
        return 'System';
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    // TODO: Mark notification as read via API
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    });
  }

  Future<void> _markAsUnread(AppNotification notification) async {
    // TODO: Mark notification as unread via API
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(
          isRead: false,
          readAt: null,
        );
      }
    });
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    // TODO: Delete notification via API
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    // TODO: Mark all notifications as read via API
    setState(() {
      _notifications = _notifications.map((n) {
        if (!n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _clearAllRead() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Read Notifications'),
        content: const Text(
          'Are you sure you want to delete all read notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Clear all read notifications via API
              setState(() {
                _notifications.removeWhere((n) => n.isRead);
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Read notifications cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        NotificationCategory? tempCategory = _filterCategory;
        bool? tempRead = _filterRead;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Notifications'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: tempCategory == null,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempCategory = null;
                            });
                          },
                        ),
                        ...NotificationCategory.values.map((category) {
                          return FilterChip(
                            label: Text(_getCategoryDisplayName(category)),
                            selected: tempCategory == category,
                            onSelected: (selected) {
                              setDialogState(() {
                                tempCategory = selected ? category : null;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: tempRead == null,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempRead = null;
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Unread'),
                          selected: tempRead == false,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempRead = selected ? false : null;
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Read'),
                          selected: tempRead == true,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempRead = selected ? true : null;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filterCategory = tempCategory;
                      _filterRead = tempRead;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _filterCategory != null || _filterRead != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount unread',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filter',
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              if (_unreadCount > 0)
                const PopupMenuItem<String>(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20),
                      SizedBox(width: 12),
                      Text('Mark All as Read'),
                    ],
                  ),
                ),
              const PopupMenuItem<String>(
                value: 'clear_read',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 12),
                    Text('Clear Read'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'clear_read':
                  _clearAllRead();
                  break;
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return _NotificationCard(
                          notification: notification,
                          typeColor: _getTypeColor(notification.type),
                          categoryIcon: _getCategoryIcon(notification.category),
                          onTap: () async {
                            if (!notification.isRead) {
                              await _markAsRead(notification);
                            }
                            if (notification.hasAction && notification.actionUrl != null) {
                              context.push(notification.actionUrl!);
                            }
                          },
                          onMarkAsRead: () => _markAsRead(notification),
                          onMarkAsUnread: () => _markAsUnread(notification),
                          onDelete: () => _deleteNotification(notification),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    if (hasActiveFilters) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notifications match filters',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterCategory = null;
                  _filterRead = null;
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  bool get hasActiveFilters => _filterCategory != null || _filterRead != null;
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final Color typeColor;
  final IconData categoryIcon;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnread;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.typeColor,
    required this.categoryIcon,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onMarkAsUnread,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: notification.isRead
            ? null
            : Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.blue[50],
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: typeColor, width: 4),
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
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(categoryIcon, size: 20, color: typeColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.timeAgo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          if (!notification.isRead)
                            const PopupMenuItem<String>(
                              value: 'mark_read',
                              child: Row(
                                children: [
                                  Icon(Icons.done, size: 20),
                                  SizedBox(width: 12),
                                  Text('Mark as Read'),
                                ],
                              ),
                            )
                          else
                            const PopupMenuItem<String>(
                              value: 'mark_unread',
                              child: Row(
                                children: [
                                  Icon(Icons.mark_email_unread, size: 20),
                                  SizedBox(width: 12),
                                  Text('Mark as Unread'),
                                ],
                              ),
                            ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: AppColors.error),
                                SizedBox(width: 12),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'mark_read':
                              onMarkAsRead();
                              break;
                            case 'mark_unread':
                              onMarkAsUnread();
                              break;
                            case 'delete':
                              onDelete();
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                  if (notification.hasAction) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: Text(notification.actionLabel!),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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
      ),
    );
  }
}
