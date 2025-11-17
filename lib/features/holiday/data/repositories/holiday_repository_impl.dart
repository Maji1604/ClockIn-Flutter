import '../datasources/holiday_remote_data_source.dart';
import '../models/holiday_model.dart';

class HolidayRepository {
  final HolidayRemoteDataSource remoteDataSource;

  HolidayRepository({required this.remoteDataSource});

  Future<List<HolidayModel>> getHolidays(String token, {String? year}) async {
    return await remoteDataSource.getHolidays(token, year: year);
  }

  Future<HolidayModel> getHolidayById(String token, String id) async {
    return await remoteDataSource.getHolidayById(token, id);
  }

  Future<HolidayModel> createHoliday({
    required String token,
    required String title,
    required String date,
    String? description,
    bool isRecurring = false,
  }) async {
    return await remoteDataSource.createHoliday(
      token: token,
      title: title,
      date: date,
      description: description,
      isRecurring: isRecurring,
    );
  }

  Future<HolidayModel> updateHoliday({
    required String token,
    required String id,
    String? title,
    String? date,
    String? description,
    bool? isRecurring,
  }) async {
    return await remoteDataSource.updateHoliday(
      token: token,
      id: id,
      title: title,
      date: date,
      description: description,
      isRecurring: isRecurring,
    );
  }

  Future<void> deleteHoliday(String token, String id) async {
    return await remoteDataSource.deleteHoliday(token, id);
  }
}
