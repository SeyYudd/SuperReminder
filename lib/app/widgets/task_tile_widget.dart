import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/task_model.dart';

class TaskTileWidget extends StatefulWidget {
  final Task task;
  final ValueChanged<Task>? onTaskChanged;

  const TaskTileWidget({super.key, required this.task, this.onTaskChanged});

  @override
  _TaskTileWidgetState createState() => _TaskTileWidgetState();
}

class _TaskTileWidgetState extends State<TaskTileWidget> {
  void _toggleSubtask(int index, bool? value) {
    if (value == null) return;
    setState(() {
      widget.task.toggleSubTask(index, value);
    });
    widget.onTaskChanged?.call(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    final bool allDone = widget.task.isDone;
    final Color doneButtonColor = widget.task.doneButtonColor;

    final priorityIndex = ((widget.task.priority - 1).clamp(
      0,
      AppConstants.priorityColors.length - 1,
    )).toInt();
    final priorityColor = AppConstants.priorityColors[priorityIndex];

    final titleStyle = AppConstants.titleStyle.copyWith(
      decoration: allDone ? TextDecoration.lineThrough : TextDecoration.none,
      color: allDone ? AppConstants.pending : AppConstants.primary,
    );

    final subItemStyle = AppConstants.bodyStyle.copyWith(
      decoration: allDone ? TextDecoration.lineThrough : TextDecoration.none,
      color: allDone ? AppConstants.pending : AppConstants.bodyStyle.color,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: AppConstants.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Material(
          color: AppConstants.cardBackground,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority indicator
                    Container(
                      width: 10,
                      height: 44,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.task.title, style: titleStyle),
                          const SizedBox(height: 6),
                          if (widget.task.description.isNotEmpty)
                            Text(
                              widget.task.description,
                              style: AppConstants.bodyStyle,
                            ),
                        ],
                      ),
                    ),
                    // Done button
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          // Toggle all subtasks
                          setState(() {
                            final makeDone = !allDone;
                            for (var s in widget.task.subTasks) {
                              s.isDone = makeDone;
                            }
                          });
                          widget.onTaskChanged?.call(widget.task);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: doneButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                        child: Icon(
                          allDone ? Icons.check : Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Subtasks list inside the card
                if (widget.task.subTasks.isNotEmpty)
                  Column(
                    children: List.generate(widget.task.subTasks.length, (i) {
                      final sub = widget.task.subTasks[i];
                      return Row(
                        children: [
                          Checkbox(
                            value: sub.isDone,
                            onChanged: (bool? v) {
                              _toggleSubtask(i, v);
                            },
                          ),
                          Expanded(child: Text(sub.title, style: subItemStyle)),
                        ],
                      );
                    }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
