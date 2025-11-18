import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile(String empId, String token);
  Future<Profile> updateProfile({
    required String empId,
    required String token,
    String? mobileNumber,
    String? address,
  });
}
