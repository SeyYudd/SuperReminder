import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../core/models/task_model.dart';
import '../bloc/task_bloc.dart';
import '../../../core/utils/app_logger.dart';

class TodoDetailScreen extends StatefulWidget {
  final TaskModel? task;

  const TodoDetailScreen({super.key, this.task});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<SubTask> _subTasks;
  late int _priority;
  late DateTime _createdAt;
  late DateTime _updatedAt;
  bool _isModified = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _subTasks =
        widget.task?.subTasks
            .map((s) => SubTask(id: s.id, title: s.title, isDone: s.isDone))
            .toList() ??
        [];
    _createdAt = widget.task?.createdAt ?? DateTime.now();
    _updatedAt = widget.task?.updatedAt ?? DateTime.now();
    _priority = widget.task?.priority ?? 3;

    _titleController.addListener(_onContentChanged);
    _descriptionController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    }
    _autoSave();
  }

  void _autoSave() {
    // Cancel previous timer if it exists
    _debounceTimer?.cancel();

    // Start new timer for auto-save with 500ms debounce
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && _hasContent()) {
        _saveTask(silent: true);
      }
    });
  }

  bool _hasContent() {
    return _titleController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _subTasks.any((s) => s.title.trim().isNotEmpty);
  }

  void _saveTask({bool silent = false}) {
    if (!_hasContent()) {
      if (!silent) {
        AppLogger.debug('No content to save, skipping');
      }
      return;
    }

    _updatedAt = DateTime.now();

    final task = TaskModel(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim().isEmpty
          ? (_descriptionController.text.trim().isEmpty
                ? (_subTasks.isNotEmpty ? _subTasks.first.title : 'Untitled')
                : _descriptionController.text.trim())
          : _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? ''
          : _descriptionController.text.trim(),
      subTasks: _subTasks.where((s) => s.title.trim().isNotEmpty).toList(),
      priority: _priority,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
    );

    if (widget.task == null) {
      context.read<TaskBloc>().add(AddTask(task));
      AppLogger.info('New task created: ${task.id}');
    } else {
      context.read<TaskBloc>().add(UpdateTask(task));
      AppLogger.info('Task updated: ${task.id}');
    }

    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _handleBack() {
    if (!_hasContent() && widget.task != null) {
      // Delete if empty and was an existing task
      context.read<TaskBloc>().add(DeleteTask(widget.task!.id));
      AppLogger.info('Empty task deleted: ${widget.task!.id}');
    } else if (_hasContent()) {
      _saveTask();
    }
    Navigator.pop(context);
  }

  void _addSubTask() {
    setState(() {
      _subTasks.add(
        SubTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          isDone: false,
        ),
      );
      _isModified = true;
    });
    // Don't auto-save empty subtask, let user type first
  }

  void _removeSubTask(int index) {
    setState(() {
      _subTasks.removeAt(index);
      _isModified = true;
      _autoSave();
    });
  }

  void _toggleSubTask(int index) {
    setState(() {
      _subTasks[index] = SubTask(
        id: _subTasks[index].id,
        title: _subTasks[index].title,
        isDone: !_subTasks[index].isDone,
      );
      _isModified = true;
      _autoSave();
    });
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0A0A0A)),
            onPressed: _handleBack,
          ),
          actions: [
            // Priority selector
            PopupMenuButton<int>(
              icon: Icon(Icons.flag, color: _getPriorityColor(_priority)),
              onSelected: (value) {
                setState(() {
                  _priority = value;
                  _isModified = true;
                  _autoSave();
                });
              },
              itemBuilder: (context) => List.generate(5, (index) {
                final priority = index + 1;
                return PopupMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: _getPriorityColor(priority)),
                      const SizedBox(width: 12),
                      Text('Priority $priority'),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0A0A),
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),

              const SizedBox(height: 16),

              // Date display
              Text(
                'Created: ${dateFormat.format(_createdAt)}  ·  Updated: ${dateFormat.format(_updatedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const Divider(height: 24),

              // Description input
              TextField(
                controller: _descriptionController,
                style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),

              const SizedBox(height: 24),

              // Subtasks section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sub Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: const Color(0xFF0A0A0A),
                    onPressed: _addSubTask,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Subtasks list
              Expanded(
                child: ListView.builder(
                  itemCount: _subTasks.length,
                  itemBuilder: (context, index) {
                    return _SubTaskItem(
                      subTask: _subTasks[index],
                      onToggle: () => _toggleSubTask(index),
                      onDelete: () => _removeSubTask(index),
                      onChanged: (value) {
                        setState(() {
                          _subTasks[index] = SubTask(
                            id: _subTasks[index].id,
                            title: value,
                            isDone: _subTasks[index].isDone,
                          );
                          _isModified = true;
                          _autoSave();
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _SubTaskItem extends StatelessWidget {
  final SubTask subTask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<String> onChanged;

  const _SubTaskItem({
    required this.subTask,
    required this.onToggle,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              subTask.isDone ? Icons.check_box : Icons.check_box_outline_blank,
              color: subTask.isDone ? Colors.green : Colors.grey,
            ),
            onPressed: onToggle,
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: subTask.title)
                ..selection = TextSelection.collapsed(
                  offset: subTask.title.length,
                ),
              onChanged: onChanged,
              style: TextStyle(
                decoration: subTask.isDone ? TextDecoration.lineThrough : null,
                color: subTask.isDone ? Colors.grey : const Color(0xFF0A0A0A),
              ),
              decoration: const InputDecoration(
                hintText: 'Subtask',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
