import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/modals/generic_response_modal.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/auth/login/models/login_response_modal.dart';

class AuthRepositoryImpl {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  Future<Result<LoginResponseModal, Failure>> login(
      String phoneNumber, String password) async {
    try {
      final result = await _apiClient.post(
        ApiUrl.login,
        data: {
          'phoneNumber': phoneNumber,
          'phoneCode': '+977',
          'password': password,
        },
      );
      switch (result) {
        case Success(value: final data):
          return Success(LoginResponseModal.fromMap(data));
        case Error(failure: final failure):
          throw failure;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<GenericResponseModal, Failure>> sendOtp(
      String phoneNumber, String? phoneCode) async {
    try {
      final result = await _apiClient.post(
        ApiUrl.sendOTP,
        data: {
          'phoneNumber': phoneNumber,
          'phoneCode': phoneCode ?? '+977',
        },
      );
      final parsed = _handleResult(result);
      return Success(parsed);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

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
      final result = await _apiClient.post(
        ApiUrl.register,
        data: data,
      );
      final parsed = _handleResult(result);
      return Success(parsed);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

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
        "lat": lat ?? 27.5074407,
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
      final result = await _apiClient.post(
        ApiUrl.register,
        data: data,
      );
      final parsed = _handleResult(result);
      return Success(parsed);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  GenericResponseModal _handleResult(Result<dynamic, Failure> result) {
    switch (result) {
      case Success(value: final data):
        return GenericResponseModal.fromMap(data);
      case Error(failure: final failure):
        throw failure;
    }
  }
}
