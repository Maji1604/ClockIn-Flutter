import 'package:equatable/equatable.dart';
import '../../data/models/holiday_model.dart';

// Events
abstract class HolidayEvent extends Equatable {
  const HolidayEvent();

  @override
  List<Object?> get props => [];
}

class FetchHolidaysEvent extends HolidayEvent {
  final String token;
  final String? year;

  const FetchHolidaysEvent({required this.token, this.year});

  @override
  List<Object?> get props => [token, year];
}

class CreateHolidayEvent extends HolidayEvent {
  final String token;
  final String title;
  final String date;
  final String? description;
  final bool isRecurring;

  const CreateHolidayEvent({
    required this.token,
    required this.title,
    required this.date,
    this.description,
    this.isRecurring = false,
  });

  @override
  List<Object?> get props => [token, title, date, description, isRecurring];
}

class UpdateHolidayEvent extends HolidayEvent {
  final String token;
  final String id;
  final String? title;
  final String? date;
  final String? description;
  final bool? isRecurring;

  const UpdateHolidayEvent({
    required this.token,
    required this.id,
    this.title,
    this.date,
    this.description,
    this.isRecurring,
  });

  @override
  List<Object?> get props => [token, id, title, date, description, isRecurring];
}

class DeleteHolidayEvent extends HolidayEvent {
  final String token;
  final String id;

  const DeleteHolidayEvent({required this.token, required this.id});

  @override
  List<Object?> get props => [token, id];
}

// States
abstract class HolidayState extends Equatable {
  const HolidayState();

  @override
  List<Object?> get props => [];
}

class HolidayInitial extends HolidayState {}

class HolidayLoading extends HolidayState {}

class HolidaysLoadSuccess extends HolidayState {
  final List<HolidayModel> holidays;

  const HolidaysLoadSuccess({required this.holidays});

  @override
  List<Object?> get props => [holidays];
}

class HolidayActionSuccess extends HolidayState {
  final HolidayModel? holiday;
  final String message;

  const HolidayActionSuccess({this.holiday, required this.message});

  @override
  List<Object?> get props => [holiday, message];
}

class HolidayError extends HolidayState {
  final String message;

  const HolidayError({required this.message});

  @override
  List<Object?> get props => [message];
}
