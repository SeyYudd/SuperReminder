import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/reminder_model.dart';
import '../../../core/repositories/reminder_repository.dart';
import '../../../core/utils/app_logger.dart';
import 'reminder_event.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository repository;

  ReminderBloc(this.repository) : super(ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<DeleteReminder>(_onDeleteReminder);
    on<ToggleReminderCompletion>(_onToggleCompletion);
    on<ToggleNotification>(_onToggleNotification);
    on<SnoozeReminder>(_onSnoozeReminder);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      AppLogger.info('Loading reminders...');
      emit(ReminderLoading());
      final reminders = await repository.getAllReminders();
      AppLogger.info('Loaded ${reminders.length} reminders');
      emit(ReminderLoaded(reminders));
    } catch (e, stackTrace) {
      AppLogger.error('Error loading reminders', e, stackTrace);
      emit(const ReminderError('Failed to load reminders'));
    }
  }

  Future<void> _onAddReminder(
    AddReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      AppLogger.info('Adding reminder: ${event.reminder.id}');
      await repository.insertReminder(event.reminder);
      add(LoadReminders());
    } catch (e, stackTrace) {
      AppLogger.error('Error adding reminder', e, stackTrace);
      emit(const ReminderError('Failed to add reminder'));
    }
  }

  Future<void> _onUpdateReminder(
    UpdateReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      AppLogger.info('Updating reminder: ${event.reminder.id}');
      await repository.updateReminder(event.reminder);
      add(LoadReminders());
    } catch (e, stackTrace) {
      AppLogger.error('Error updating reminder', e, stackTrace);
      emit(const ReminderError('Failed to update reminder'));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      AppLogger.info('Deleting reminder: ${event.id}');
      await repository.deleteReminder(event.id);
      add(LoadReminders());
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting reminder', e, stackTrace);
      emit(const ReminderError('Failed to delete reminder'));
    }
  }

  Future<void> _onToggleCompletion(
    ToggleReminderCompletion event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      AppLogger.debug('Toggling completion for reminder: ${event.id}');
      final reminder = await repository.getReminderById(event.id);
      if (reminder != null) {
        final updatedReminder = reminder.copyWith(
          status: reminder.status.copyWith(
            isCompleted: !reminder.status.isCompleted,
          ),
        );
        await repository.updateReminder(updatedReminder);
        add(LoadReminders());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error toggling completion', e, stackTrace);
      emit(const ReminderError('Failed to toggle completion'));
    }
  }

  Future<void> _onToggleNotification(
    ToggleNotification event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      AppLogger.debug('Toggling notification for reminder: ${event.id}');
      final reminder = await repository.getReminderById(event.id);
      if (reminder != null) {
        final updatedReminder = reminder.copyWith(
          status: reminder.status.copyWith(
            isNotificationEnabled: !reminder.status.isNotificationEnabled,
          ),
        );
        await repository.updateReminder(updatedReminder);
        add(LoadReminders());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error toggling notification', e, stackTrace);
      emit(const ReminderError('Failed to toggle notification'));
    }
  }

  Future<void> _onSnoozeReminder(
    SnoozeReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      AppLogger.debug(
        'Snoozing reminder: ${event.id} for ${event.minutes} minutes',
      );
      final reminder = await repository.getReminderById(event.id);
      if (reminder != null) {
        final newTargetTime = DateTime.now().add(
          Duration(minutes: event.minutes),
        );
        final updatedScheduling = ReminderScheduling(
          mode: reminder.scheduling.mode,
          frequency: reminder.scheduling.frequency,
          targetTimestamp: newTargetTime,
          repeatDays: reminder.scheduling.repeatDays,
          reminderWindow: reminder.scheduling.reminderWindow,
        );
        final updatedReminder = reminder.copyWith(
          scheduling: updatedScheduling,
          status: reminder.status.copyWith(isSnoozed: true),
        );
        await repository.updateReminder(updatedReminder);
        add(LoadReminders());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error snoozing reminder', e, stackTrace);
      emit(const ReminderError('Failed to snooze reminder'));
    }
  }
}
