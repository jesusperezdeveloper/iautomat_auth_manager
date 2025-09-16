import 'package:flutter_test/flutter_test.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';

void main() {
  group('Result', () {
    test('should create success result', () {
      const result = Result<String, String>.success('test value');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, equals('test value'));
      expect(result.errorOrNull, isNull);
    });

    test('should create failure result', () {
      const result = Result<String, String>.failure('test error');

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, equals('test error'));
    });

    test('should map success value', () {
      const result = Result<int, String>.success(5);
      final mapped = result.map((value) => value * 2);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.valueOrNull, equals(10));
    });

    test('should not map failure value', () {
      const result = Result<int, String>.failure('error');
      final mapped = result.map((value) => value * 2);

      expect(mapped.isFailure, isTrue);
      expect(mapped.errorOrNull, equals('error'));
    });

    test('should fold correctly', () {
      const successResult = Result<int, String>.success(5);
      const failureResult = Result<int, String>.failure('error');

      final successFolded = successResult.fold(
        (value) => 'Success: $value',
        (error) => 'Error: $error',
      );

      final failureFolded = failureResult.fold(
        (value) => 'Success: $value',
        (error) => 'Error: $error',
      );

      expect(successFolded, equals('Success: 5'));
      expect(failureFolded, equals('Error: error'));
    });
  });

  group('UserModel', () {
    test('should create user model with required fields', () {
      const user = UserModel(uid: 'test-uid');

      expect(user.uid, equals('test-uid'));
      expect(user.email, isNull);
      expect(user.displayName, isNull);
      expect(user.photoURL, isNull);
      expect(user.emailVerified, isFalse);
    });

    test('should create user model with all fields', () {
      const user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: true,
      );

      expect(user.uid, equals('test-uid'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.photoURL, equals('https://example.com/photo.jpg'));
      expect(user.emailVerified, isTrue);
    });

    test('should copy user with modified fields', () {
      const user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
      );

      final copiedUser = user.copyWith(
        displayName: 'Updated Name',
        emailVerified: true,
      );

      expect(copiedUser.uid, equals('test-uid'));
      expect(copiedUser.email, equals('test@example.com'));
      expect(copiedUser.displayName, equals('Updated Name'));
      expect(copiedUser.emailVerified, isTrue);
    });

    test('should convert to and from map', () {
      const user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: true,
      );

      final map = user.toMap();
      final fromMap = UserModel.fromMap(map);

      expect(fromMap, equals(user));
    });

    test('should compare users correctly', () {
      const user1 = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
      );

      const user2 = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
      );

      const user3 = UserModel(
        uid: 'different-uid',
        email: 'test@example.com',
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });

  group('AuthExceptions', () {
    test('should create InvalidCredentialsException', () {
      const exception = InvalidCredentialsException('invalid-credential');

      expect(exception.message, equals('Credenciales inválidas'));
      expect(exception.code, equals('invalid-credential'));
      expect(exception.toString(), equals('[invalid-credential] Credenciales inválidas'));
    });

    test('should create UserNotFoundException', () {
      const exception = UserNotFoundException();

      expect(exception.message, equals('Usuario no encontrado'));
      expect(exception.code, isNull);
      expect(exception.toString(), equals('Usuario no encontrado'));
    });

    test('should create EmailAlreadyInUseException', () {
      const exception = EmailAlreadyInUseException('email-already-in-use');

      expect(exception.message, equals('El email ya está en uso'));
      expect(exception.code, equals('email-already-in-use'));
    });

    test('should create GenericAuthException', () {
      const exception = GenericAuthException('Custom error', 'custom-code');

      expect(exception.message, equals('Custom error'));
      expect(exception.code, equals('custom-code'));
      expect(exception.toString(), equals('[custom-code] Custom error'));
    });
  });
}
