import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../core/models/reminder_model.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_event.dart';
import '../../../core/utils/app_logger.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedReminders = {};
  String _searchQuery = '';
  Timer? _searchDebounce;

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedReminders.clear();
      }
    });
  }

  void _toggleReminderSelection(String reminderId) {
    setState(() {
      if (_selectedReminders.contains(reminderId)) {
        _selectedReminders.remove(reminderId);
      } else {
        _selectedReminders.add(reminderId);
      }
    });
  }

  void _deleteSelectedReminders() {
    for (final reminderId in _selectedReminders) {
      context.read<ReminderBloc>().add(DeleteReminder(reminderId));
    }
    _toggleSelectionMode();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
    });
  }

  List<ReminderModel> _filterReminders(List<ReminderModel> reminders) {
    if (_searchQuery.isEmpty) return reminders;

    return reminders.where((reminder) {
      final titleMatch = reminder.title.toLowerCase().contains(_searchQuery);
      final descMatch = reminder.description.toLowerCase().contains(
        _searchQuery,
      );
      final categoryMatch = reminder.category.tag.toLowerCase().contains(
        _searchQuery,
      );
      return titleMatch || descMatch || categoryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSelectionMode
            ? Text(
                '${_selectedReminders.length} selected',
                style: const TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const Text(
                'Reminders',
                style: TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
        leading: IconButton(
          icon: Icon(
            _isSelectionMode ? Icons.close : Icons.menu,
            color: const Color(0xFF0A0A0A),
          ),
          onPressed: () {
            if (_isSelectionMode) {
              _toggleSelectionMode();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (!_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF0A0A0A)),
              onPressed: () {
                // TODO: Implement search dialog
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFF0A0A0A)),
              onPressed: () {
                // TODO: Show filter options
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _selectedReminders.isEmpty
                  ? null
                  : _deleteSelectedReminders,
            ),
          ],
        ],
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReminderError) {
            AppLogger.error('ReminderScreen error: ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReminderBloc>().add(LoadReminders());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ReminderLoaded) {
            final filteredReminders = _filterReminders(state.reminders);

            if (filteredReminders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 100,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No reminders yet'
                          : 'No results found',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Tap + to create a reminder'
                          : 'Try a different search',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredReminders.length,
                itemBuilder: (context, index) {
                  final reminder = filteredReminders[index];
                  final isSelected = _selectedReminders.contains(reminder.id);

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _ReminderCard(
                          reminder: reminder,
                          isSelectionMode: _isSelectionMode,
                          isSelected: isSelected,
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleReminderSelection(reminder.id);
                            } else {
                              // TODO: Navigate to ReminderDetailScreen
                            }
                          },
                          onLongPress: () {
                            if (!_isSelectionMode) {
                              setState(() {
                                _isSelectionMode = true;
                                _selectedReminders.add(reminder.id);
                              });
                            }
                          },
                          onToggle: (value) {
                            context.read<ReminderBloc>().add(
                              ToggleReminderCompletion(reminder.id),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                // TODO: Navigate to create reminder screen
              },
              backgroundColor: const Color(0xFF0A0A0A),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}

class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onToggle;

  const _ReminderCard({
    required this.reminder,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onToggle,
  });

  Color _getPriorityColor() {
    switch (reminder.priority.level) {
      case 1:
        return const Color(0xFFFFDAD6); // Red pastel
      case 2:
        return const Color(0xFFFEF7C2); // Yellow pastel
      case 3:
        return const Color(0xFFD3E3FD); // Blue pastel
      case 4:
        return const Color(0xFFD7EFCD); // Green pastel
      case 5:
        return const Color(0xFFF2D8F5); // Purple pastel
      default:
        return Colors.white;
    }
  }

  IconData _getCategoryIcon() {
    // Map icon name to Flutter icon
    switch (reminder.category.icon.toLowerCase()) {
      case 'work':
        return Icons.work_outline;
      case 'home':
        return Icons.home_outlined;
      case 'health':
        return Icons.favorite_border;
      case 'shopping':
        return Icons.shopping_cart_outlined;
      case 'event':
        return Icons.event_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy · HH:mm');
    final scheduledTime = reminder.scheduling.targetTimestamp;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _getPriorityColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon & checkbox
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(),
                          size: 24,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Checkbox(
                        value: reminder.status.isCompleted,
                        onChanged: (value) => onToggle(value ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          reminder.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0A0A0A),
                            decoration: reminder.status.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (reminder.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            reminder.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reminder.category.tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Scheduled time
                        if (scheduledTime != null)
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(scheduledTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),

                        // Spam indicator
                        if (reminder.spamConfiguration.isSpamEnabled) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_active,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Spam: ${reminder.spamConfiguration.intensity.intervalSeconds}s',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Notification status
                  Icon(
                    reminder.status.isNotificationEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: reminder.status.isNotificationEnabled
                        ? Colors.green
                        : Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),

            // Selection checkbox
            if (isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isSelected ? Icons.check : null,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
