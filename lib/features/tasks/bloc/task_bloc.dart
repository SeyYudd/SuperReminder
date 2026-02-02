import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/task_repository.dart';
import '../../../core/utils/app_logger.dart';
import 'task_event.dart';

export 'task_event.dart';

/// Task BLoC for managing task state
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc({required this.repository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleSubTask>(_onToggleSubTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      AppLogger.info('Loading tasks...');
      emit(TaskLoading());

      final tasks = await repository.getAllTasks();
      AppLogger.info('Loaded ${tasks.length} tasks');

      emit(TaskLoaded(tasks));
    } catch (e, stack) {
      AppLogger.error('Failed to load tasks', e, stack);
      emit(TaskError('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      AppLogger.info('Adding task: ${event.task.title}');
      await repository.insertTask(event.task);

      // Reload tasks
      add(LoadTasks());
    } catch (e, stack) {
      AppLogger.error('Failed to add task', e, stack);
      emit(TaskError('Failed to add task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      AppLogger.info('Updating task: ${event.task.title}');
      await repository.updateTask(event.task);

      // Reload tasks
      add(LoadTasks());
    } catch (e, stack) {
      AppLogger.error('Failed to update task', e, stack);
      emit(TaskError('Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      AppLogger.info('Deleting task: ${event.taskId}');
      await repository.deleteTask(event.taskId);

      // Reload tasks
      add(LoadTasks());
    } catch (e, stack) {
      AppLogger.error('Failed to delete task', e, stack);
      emit(TaskError('Failed to delete task: ${e.toString()}'));
    }
  }

  Future<void> _onToggleSubTask(
    ToggleSubTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      AppLogger.debug('Toggling subtask: ${event.subTaskId}');
      await repository.toggleSubTask(event.taskId, event.subTaskId);

      // Reload tasks
      add(LoadTasks());
    } catch (e, stack) {
      AppLogger.error('Failed to toggle subtask', e, stack);
      emit(TaskError('Failed to toggle subtask: ${e.toString()}'));
    }
  }
}
