import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUseCase {
  const LogoutUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}