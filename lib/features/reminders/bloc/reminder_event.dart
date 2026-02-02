import 'package:equatable/equatable.dart';
import '../../../core/models/reminder_model.dart';

// Events
abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {}

class AddReminder extends ReminderEvent {
  final ReminderModel reminder;

  const AddReminder(this.reminder);

  @override
  List<Object> get props => [reminder];
}

class UpdateReminder extends ReminderEvent {
  final ReminderModel reminder;

  const UpdateReminder(this.reminder);

  @override
  List<Object> get props => [reminder];
}

class DeleteReminder extends ReminderEvent {
  final String id;

  const DeleteReminder(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleReminderCompletion extends ReminderEvent {
  final String id;

  const ToggleReminderCompletion(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleNotification extends ReminderEvent {
  final String id;

  const ToggleNotification(this.id);

  @override
  List<Object> get props => [id];
}

class SnoozeReminder extends ReminderEvent {
  final String id;
  final int minutes;

  const SnoozeReminder(this.id, this.minutes);

  @override
  List<Object> get props => [id, minutes];
}

// States
abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object> get props => [];
}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<ReminderModel> reminders;

  const ReminderLoaded(this.reminders);

  @override
  List<Object> get props => [reminders];
}

class ReminderError extends ReminderState {
  final String message;

  const ReminderError(this.message);

  @override
  List<Object> get props => [message];
}
