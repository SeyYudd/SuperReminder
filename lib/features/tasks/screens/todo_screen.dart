import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:async';

import '../../../core/models/task_model.dart';
import '../bloc/task_bloc.dart';
import '../../../core/utils/app_logger.dart';
import 'todo_detail_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  bool _isSelectionMode = false;
  bool _isGridView = true;
  final Set<String> _selectedTasks = {};
  String _searchQuery = '';
  Timer? _searchDebounce;
  final TextEditingController _searchController = TextEditingController();

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedTasks.clear();
    });
  }

  void _toggleTaskSelection(String taskId) {
    setState(() {
      if (_selectedTasks.contains(taskId))
        _selectedTasks.remove(taskId);
      else
        _selectedTasks.add(taskId);
    });
  }

  void _deleteSelectedTasks() {
    for (final id in _selectedTasks) {
      context.read<TaskBloc>().add(DeleteTask(id));
    }
    _toggleSelectionMode();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(seconds: 1), () {
      setState(() => _searchQuery = query.toLowerCase());
    });
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    if (_searchQuery.isEmpty) return tasks;
    return tasks.where((task) {
      final title = task.title.toLowerCase();
      final desc = task.description.toLowerCase();
      final sub = task.subTasks.map((s) => s.title.toLowerCase()).join(' ');
      return title.contains(_searchQuery) ||
          desc.contains(_searchQuery) ||
          sub.contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
                '${_selectedTasks.length} selected',
                style: const TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const Text(
                'Notes',
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
            if (_isSelectionMode)
              _toggleSelectionMode();
            else
              Navigator.pop(context);
          },
        ),
        actions: [
          if (!_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF0A0A0A)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Search'),
                    content: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search notes...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                color: const Color(0xFF0A0A0A),
              ),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _selectedTasks.isEmpty ? null : _deleteSelectedTasks,
            ),
          ],
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is TaskError) {
            AppLogger.error('TodoScreen error: ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TaskBloc>().add(LoadTasks()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TaskLoaded) {
            final filtered = _filterTasks(state.tasks);
            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_add_outlined,
                      size: 100,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No notes yet'
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
                          ? 'Tap + to create a note'
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
              child: _isGridView
                  ? GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];
                        final isSelected = _selectedTasks.contains(task.id);
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: _KeepStyleCard(
                                task: task,
                                isSelectionMode: _isSelectionMode,
                                isSelected: isSelected,
                                onTap: () {
                                  if (_isSelectionMode)
                                    _toggleTaskSelection(task.id);
                                  else
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<TaskBloc>(),
                                          child: TodoDetailScreen(task: task),
                                        ),
                                      ),
                                    );
                                },
                                onLongPress: () {
                                  if (!_isSelectionMode) {
                                    setState(() {
                                      _isSelectionMode = true;
                                      _selectedTasks.add(task.id);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];
                        final isSelected = _selectedTasks.contains(task.id);
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _KeepStyleCard(
                                task: task,
                                isSelectionMode: _isSelectionMode,
                                isSelected: isSelected,
                                onTap: () {
                                  if (_isSelectionMode)
                                    _toggleTaskSelection(task.id);
                                  else
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<TaskBloc>(),
                                          child: TodoDetailScreen(task: task),
                                        ),
                                      ),
                                    );
                                },
                                onLongPress: () {
                                  if (!_isSelectionMode) {
                                    setState(() {
                                      _isSelectionMode = true;
                                      _selectedTasks.add(task.id);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<TaskBloc>(),
                      child: const TodoDetailScreen(),
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFF0A0A0A),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}

class _KeepStyleCard extends StatelessWidget {
  final TaskModel task;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _KeepStyleCard({
    required this.task,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case 1:
        return const Color(0xFFFFDAD6);
      case 2:
        return const Color(0xFFFEF7C2);
      case 3:
        return const Color(0xFFD3E3FD);
      case 4:
        return const Color(0xFFD7EFCD);
      case 5:
        return const Color(0xFFF2D8F5);
      default:
        return Colors.white;
    }
  }

  String _getPreviewText() {
    if (task.title.isNotEmpty)
      return task.title.length > 50
          ? '${task.title.substring(0, 50)}...'
          : task.title;
    if (task.description.isNotEmpty)
      return task.description.length > 50
          ? '${task.description.substring(0, 50)}...'
          : task.description;
    if (task.subTasks.isNotEmpty) return task.subTasks.first.title;
    return 'Empty note';
  }

  @override
  Widget build(BuildContext context) {
    final completedSubtasks = task.subTasks.where((s) => s.isDone).length;
    final totalSubtasks = task.subTasks.length;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _getPriorityColor(),
          borderRadius: BorderRadius.circular(12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPreviewText(),
                    maxLines: task.subTasks.isEmpty ? 6 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: const Color(0xFF0A0A0A),
                      fontWeight: FontWeight.w500,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.subTasks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...task.subTasks
                        .take(3)
                        .map(
                          (subtask) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  subtask.isDone
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 18,
                                  color: subtask.isDone
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    subtask.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subtask.isDone
                                          ? Colors.grey.shade600
                                          : const Color(0xFF0A0A0A),
                                      decoration: subtask.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (totalSubtasks > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${totalSubtasks - 3} more',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                  const Spacer(),
                  if (totalSubtasks > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$completedSubtasks/$totalSubtasks',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
