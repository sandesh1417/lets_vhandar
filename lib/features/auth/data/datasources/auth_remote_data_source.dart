import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/modals/generic_response_modal.dart';
import 'package:lets_vhandar/core/utils/result.dart';

abstract class AuthRemoteDataSource {
  Future<GenericResponseModal> login(String phoneNumber, String password);
  Future<GenericResponseModal> sendOtp(String phoneNumber, String? phoneCode);
  Future<GenericResponseModal> register(Map<String, dynamic> data);
  Future<GenericResponseModal> registerBusiness(Map<String, dynamic> data);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<GenericResponseModal> login(
      String phoneNumber, String password) async {
    // TODO: Implement login endpoint when available.
    // For now assuming it's similar to others
    throw UnimplementedError("Login API endpoint not defined yet");
  }

  @override
  Future<GenericResponseModal> sendOtp(
      String phoneNumber, String? phoneCode) async {
    final result = await _apiClient.post(
      ApiUrl.sendOTP,
      data: {
        'phoneNumber': phoneNumber,
        'phoneCode': phoneCode ?? "+977",
      },
    );

    return _handleResult(result);
  }

  @override
  Future<GenericResponseModal> register(Map<String, dynamic> data) async {
    final result = await _apiClient.post(
      ApiUrl.register,
      data: data,
    );
    return _handleResult(result);
  }

  @override
  Future<GenericResponseModal> registerBusiness(
      Map<String, dynamic> data) async {
    final result = await _apiClient.post(
      ApiUrl.register, // Assuming same endpoint for now as per previous service
      data: data,
    );
    return _handleResult(result);
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
