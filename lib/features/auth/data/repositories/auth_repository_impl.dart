import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/modals/generic_response_modal.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lets_vhandar/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<GenericResponseModal, Failure>> login(
      String phoneNumber, String password) async {
    try {
      final result = await _remoteDataSource.login(phoneNumber, password);
      return Success(result);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<GenericResponseModal, Failure>> sendOtp(
      String phoneNumber, String? phoneCode) async {
    try {
      final result = await _remoteDataSource.sendOtp(phoneNumber, phoneCode);
      return Success(result);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<GenericResponseModal, Failure>> register({
    required String phoneNumber,
    String? phoneCode,
    required String otp,
    required String password,
    required String confirmPassword,
    required String name,
    String? referalCode,
  }) async {
    try {
      final data = {
        'phoneNumber': phoneNumber,
        'phoneCode': phoneCode ?? '+977',
        'otp': otp,
        'password': password,
        'confirmPassword': confirmPassword,
        'name': name,
        'referalCode': referalCode ?? '',
      };
      final result = await _remoteDataSource.register(data);
      return Success(result);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final data = {
        "phoneNumber": phoneNumber,
        "password": password,
        "confirmPassword": confirmPassword,
        "lat": lat ?? 27.5074407, // Keeping hardcoded values for now if null
        "long": long ?? 85.9804331,
        "businessName": businessName,
        "businessCategory": businessCategory,
        "phoneCode": phoneCode ?? "+977",
        "panNumber": panNumber,
        "vatNumber": vatNumber,
        "email": email,
        "otp": otp,
        "addressName": address ?? "GX4J+X5 Dadhuwa"
      };
      final result = await _remoteDataSource.registerBusiness(data);
      return Success(result);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
