import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/modals/generic_response_modal.dart';
import 'package:lets_vhandar/core/utils/result.dart';

abstract class AuthRepository {
  Future<Result<GenericResponseModal, Failure>> login(
      String phoneNumber, String password);
  Future<Result<GenericResponseModal, Failure>> sendOtp(
      String phoneNumber, String? phoneCode);
  Future<Result<GenericResponseModal, Failure>> register({
    required String phoneNumber,
    String? phoneCode,
    required String otp,
    required String password,
    required String confirmPassword,
    required String name,
    String? referalCode,
  });
  Future<Result<GenericResponseModal, Failure>> registerBusiness({
    required String phoneNumber,
    String? phoneCode,
    required String otp,
    required String email,
    required String password,
    required String confirmPassword,
    required String businessName,
    required String businessCategory,
    required String name,
    required String panNumber,
    required String vatNumber,
    String? referalCode,
    String? lat,
    String? long,
    String? address,
  });
}
