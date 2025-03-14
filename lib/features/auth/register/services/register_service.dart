import 'package:dio/dio.dart';
import 'package:lets_vhandar/core/api/api_services.dart';
import 'package:lets_vhandar/core/constants/api_endpoints.dart';
import 'package:lets_vhandar/core/modals/generic_response_modal.dart';

class RegisterServices {
  final ApiService _apiService;

  RegisterServices(this._apiService);

  /// **Send OTP**
  Future<GenericResponseModal> sendOtp(String phoneNumber, String? phoneCode) async {
    try {
      final response = await _apiService.dio.post(
        ApiUrl.sendOTP,
        data: {
          'phoneNumber': phoneNumber,
          'phoneCode': phoneCode ?? "+977",
        },
      );

      return GenericResponseModal.fromMap(addResponseStatus(response));
    } on DioException catch (e) {
      return GenericResponseModal(
        statusCode: e.response?.statusCode ?? 500,
        success: "false",
        message: e.response?.data?['message'] ?? "Network error occurred",
      );
    } catch (e) {
      return GenericResponseModal(
        statusCode: 501,
        success: "false",
        message: "An unexpected error occurred",
      );
    }
  }

  /// **Register User**
  Future<GenericResponseModal> register({
    required String phoneNumber,
    String? phoneCode,
    required String otp,
    required String password,
    required String confirmPassword,
    required String name,
    String? referalCode,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiUrl.register,
        data: {
          'phoneNumber': phoneNumber,
          'phoneCode': phoneCode ?? '+977',
          'otp': otp,
          'password': password,
          'confirmPassword': confirmPassword,
          'name': name,
          'referalCode': referalCode ?? '',
        },
      );

      return GenericResponseModal.fromMap(addResponseStatus(response));
    } on DioException catch (e) {
      return GenericResponseModal(
        statusCode: e.response?.statusCode ?? 500,
        success: "false",
        message: e.response?.data?["message"] ?? "Network error occurred",
      );
    } catch (e) {
      return GenericResponseModal(
        statusCode: 501,
        success: "false",
        message: "An unexpected error occurred",
      );
    }
  }
}
