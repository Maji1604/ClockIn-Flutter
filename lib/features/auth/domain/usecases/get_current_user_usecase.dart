import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting current user
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, User?>> call() async {
    return await repository.getCurrentUser();
  }
}
