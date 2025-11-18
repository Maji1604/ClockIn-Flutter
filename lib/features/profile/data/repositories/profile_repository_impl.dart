import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Profile> getProfile(String empId, String token) async {
    return await remoteDataSource.getProfile(empId, token);
  }

  @override
  Future<Profile> updateProfile({
    required String empId,
    required String token,
    String? mobileNumber,
    String? address,
  }) async {
    return await remoteDataSource.updateProfile(
      empId: empId,
      token: token,
      mobileNumber: mobileNumber,
      address: address,
    );
  }
}
