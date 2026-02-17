import 'package:flutter_test/flutter_test.dart';
import 'package:lets_vhandar/core/utils/validation.dart';

void main() {
  group('Password Validation Tests', () {
    test('validatePassword should return null for valid password', () {
      const validPassword = 'Test123!';
      final result = TFValidators.validatePassword(validPassword);
      expect(result, isNull);
    });

    test('validatePassword should return error for empty password', () {
      const emptyPassword = '';
      final result = TFValidators.validatePassword(emptyPassword);
      expect(result, equals('Password is required'));
    });

    test('validatePassword should return error for short password', () {
      const shortPassword = '123';
      final result = TFValidators.validatePassword(shortPassword);
      expect(result, equals('Password must be at least 6 characters'));
    });

    test('validateConfirmPassword should return null for matching passwords', () {
      const password = 'Test123!';
      const confirmPassword = 'Test123!';
      final result = TFValidators.validateConfirmPassword(confirmPassword, password);
      expect(result, isNull);
    });

    test('validateConfirmPassword should return error for non-matching passwords', () {
      const password = 'Test123!';
      const confirmPassword = 'Test456!';
      final result = TFValidators.validateConfirmPassword(confirmPassword, password);
      expect(result, equals('Passwords do not match'));
    });

    test('validateConfirmPassword should return error for empty confirm password', () {
      const password = 'Test123!';
      const confirmPassword = '';
      final result = TFValidators.validateConfirmPassword(confirmPassword, password);
      expect(result, equals('Confirm Password is required'));
    });

    test('validateConfirmPassword should return error for null confirm password', () {
      const password = 'Test123!';
      const confirmPassword = null;
      final result = TFValidators.validateConfirmPassword(confirmPassword, password);
      expect(result, equals('Confirm Password is required'));
    });
  });

  group('Password Extension Tests', () {
    test('isPasswordValid should return true for strong password', () {
      const strongPassword = 'StrongPass123!';
      expect(strongPassword.isPasswordValid, isTrue);
    });

    test('isPasswordValid should return false for weak password', () {
      const weakPassword = 'weak';
      expect(weakPassword.isPasswordValid, isFalse);
    });

    test('isPasswordValid should return false for password without uppercase', () {
      const noUppercase = 'lowercase123!';
      expect(noUppercase.isPasswordValid, isFalse);
    });

    test('isPasswordValid should return false for password without lowercase', () {
      const noLowercase = 'UPPERCASE123!';
      expect(noLowercase.isPasswordValid, isFalse);
    });

    test('isPasswordValid should return false for password without number', () {
      const noNumber = 'NoNumber!';
      expect(noNumber.isPasswordValid, isFalse);
    });

    test('isPasswordValid should return false for password without special character', () {
      const noSpecial = 'NoSpecial123';
      expect(noSpecial.isPasswordValid, isFalse);
    });
  });
}
