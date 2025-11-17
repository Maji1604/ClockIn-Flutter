import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/holiday_repository_impl.dart';
import 'holiday_event.dart';

export 'holiday_event.dart';

class HolidayBloc extends Bloc<HolidayEvent, HolidayState> {
  final HolidayRepository repository;

  HolidayBloc({required this.repository}) : super(HolidayInitial()) {
    on<FetchHolidaysEvent>(_onFetchHolidays);
    on<CreateHolidayEvent>(_onCreateHoliday);
    on<UpdateHolidayEvent>(_onUpdateHoliday);
    on<DeleteHolidayEvent>(_onDeleteHoliday);
  }

  Future<void> _onFetchHolidays(
    FetchHolidaysEvent event,
    Emitter<HolidayState> emit,
  ) async {
    emit(HolidayLoading());
    try {
      final holidays = await repository.getHolidays(event.token, year: event.year);
      emit(HolidaysLoadSuccess(holidays: holidays));
    } catch (e) {
      emit(HolidayError(message: e.toString()));
    }
  }

  Future<void> _onCreateHoliday(
    CreateHolidayEvent event,
    Emitter<HolidayState> emit,
  ) async {
    emit(HolidayLoading());
    try {
      final holiday = await repository.createHoliday(
        token: event.token,
        title: event.title,
        date: event.date,
        description: event.description,
        isRecurring: event.isRecurring,
      );
      emit(
        HolidayActionSuccess(
          holiday: holiday,
          message: 'Holiday created successfully',
        ),
      );

      // Refresh the list
      add(FetchHolidaysEvent(token: event.token));
    } catch (e) {
      emit(HolidayError(message: e.toString()));
    }
  }

  Future<void> _onUpdateHoliday(
    UpdateHolidayEvent event,
    Emitter<HolidayState> emit,
  ) async {
    emit(HolidayLoading());
    try {
      final holiday = await repository.updateHoliday(
        token: event.token,
        id: event.id,
        title: event.title,
        date: event.date,
        description: event.description,
        isRecurring: event.isRecurring,
      );
      emit(
        HolidayActionSuccess(
          holiday: holiday,
          message: 'Holiday updated successfully',
        ),
      );

      // Refresh the list
      add(FetchHolidaysEvent(token: event.token));
    } catch (e) {
      emit(HolidayError(message: e.toString()));
    }
  }

  Future<void> _onDeleteHoliday(
    DeleteHolidayEvent event,
    Emitter<HolidayState> emit,
  ) async {
    emit(HolidayLoading());
    try {
      await repository.deleteHoliday(event.token, event.id);
      emit(const HolidayActionSuccess(message: 'Holiday deleted successfully'));

      // Refresh the list
      add(FetchHolidaysEvent(token: event.token));
    } catch (e) {
      emit(HolidayError(message: e.toString()));
    }
  }
}
