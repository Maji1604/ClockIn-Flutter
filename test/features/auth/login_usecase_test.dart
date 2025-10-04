import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creoleap_hrms/features/auth/domain/entities/login_request.dart';
import 'package:creoleap_hrms/features/auth/domain/entities/login_response.dart';
import 'package:creoleap_hrms/features/auth/domain/entities/user.dart';
import 'package:creoleap_hrms/features/auth/domain/entities/company_membership.dart';
import 'package:creoleap_hrms/features/auth/domain/repositories/auth_repository.dart';
import 'package:creoleap_hrms/features/auth/domain/usecases/login_usecase.dart';
import 'package:creoleap_hrms/core/core.dart';

/// A tiny fake repository implementation used for testing LoginUseCase.
class FakeAuthRepository implements AuthRepository {
  final Either<Failure, LoginResponse> loginResult;

  String? lastStoredToken;
  User? lastStoredUser;

  FakeAuthRepository({required this.loginResult});

  @override
  Future<Either<Failure, LoginResponse>> login(LoginRequest request) async {
    return loginResult;
  }

  @override
  Future<void> storeToken(String token) async {
    lastStoredToken = token;
  }

  @override
  Future<void> storeUser(User user) async {
    lastStoredUser = user;
  }

  // The rest of the methods are not needed for these tests. Provide
  // simple implementations to satisfy the interface.
  @override
  Future<Either<Failure, void>> changePassword(String userId, dynamic request) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<String?> getToken() async => lastStoredToken;

  @override
  Future<void> clearStoredData() async {
    lastStoredToken = null;
    lastStoredUser = null;
  }

  @override
  Future<User?> getStoredUser() async => lastStoredUser;
}

void main() {
  group('LoginUseCase', () {
    final request = LoginRequest(
      email: 'alice@example.com',
      password: 'pass123',
    );

    test(
      'stores token and user when API returns token (single membership)',
      () async {
        final user = User(
          id: 'u1',
          email: 'alice@example.com',
          firstName: 'Alice',
          lastName: 'Smith',
          role: 'admin',
          mustChangePassword: false,
          isFirstLogin: false,
        );
        final response = LoginResponse(
          user: user,
          token: 'tok-123',
          requiresPasswordChange: false,
          memberships: null,
        );

        final repo = FakeAuthRepository(loginResult: Right(response));
        final usecase = LoginUseCase(repo);

        final result = await usecase.call(request);

        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Expected success'), (r) {
          expect(r.token, 'tok-123');
          expect(r.user.email, equals('alice@example.com'));
        });

        // storeToken and storeUser should have been called
        expect(repo.lastStoredToken, 'tok-123');
        expect(repo.lastStoredUser, isNotNull);
        expect(repo.lastStoredUser!.email, 'alice@example.com');
      },
    );

    test(
      'does not store token but stores user when API returns memberships only',
      () async {
        final user = User(
          id: 'u2',
          email: 'bob@example.com',
          firstName: 'Bob',
          lastName: 'Jones',
          role: 'employee',
          mustChangePassword: false,
          isFirstLogin: false,
        );
        final membership = CompanyMembership(
          companyId: 'c1',
          companyName: 'Acme',
          companySlug: 'acme',
          role: 'member',
        );
        final response = LoginResponse(
          user: user,
          token: null,
          requiresPasswordChange: false,
          memberships: [membership],
        );

        final repo = FakeAuthRepository(loginResult: Right(response));
        final usecase = LoginUseCase(repo);

        final result = await usecase.call(request);

        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Expected success'), (r) {
          expect(r.token, isNull);
          expect(r.memberships, isNotNull);
          expect(r.memberships!.length, 1);
        });

        // storeToken should NOT have been called, but storeUser should have
        expect(repo.lastStoredToken, isNull);
        expect(repo.lastStoredUser, isNotNull);
        expect(repo.lastStoredUser!.email, 'bob@example.com');
      },
    );

    test(
      'returns failure when repository returns ServerFailure (e.g., 403 NO_COMPANY)',
      () async {
        final failure = ServerFailure(
          message: 'No company membership',
          statusCode: 403,
        );
        final repo = FakeAuthRepository(loginResult: Left(failure));
        final usecase = LoginUseCase(repo);

        final result = await usecase.call(request);

        expect(result.isLeft(), isTrue);
        result.fold((l) {
          expect(l, isA<ServerFailure>());
          expect((l as ServerFailure).statusCode, 403);
        }, (r) => fail('Expected failure'));

        // storeUser/storeToken should not have been called
        expect(repo.lastStoredToken, isNull);
        expect(repo.lastStoredUser, isNull);
      },
    );
  });
}
