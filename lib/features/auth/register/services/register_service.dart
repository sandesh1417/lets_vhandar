// lib/core/features/auth/services/register_services.dart

import 'package:dio/dio.dart';
import 'package:lets_vhandar/core/api/api_services.dart';
import 'package:lets_vhandar/core/constants/api_endpoints.dart';
import 'package:lets_vhandar/core/modals/generic_response_modal.dart';

class RegisterServices {
  final ApiService _apiService;

  RegisterServices(this._apiService);

  Future<GenericResponseModal> sendOtp(String phoneNumber, String phoneCode) async {
    try {
      final response = await _apiService.dio.post(
        ApiUrl.sendOTP,
        data: {
          'phoneNumber': phoneNumber,
          'phoneCode': phoneCode,
        },
      );

      // Parse the response to GenericResponseModal model
      return GenericResponseModal.fromMap(response.data);
    } catch (e) {
      if (e is DioException) {
        // Handle Dio specific errors
        return GenericResponseModal(
          status: e.response?.statusCode.toString() ?? "500",
          message: e.message ?? "Something went wrong",
          success: "false",
        );
      }
      // Handle general errors
      return GenericResponseModal(
        status: "500",
        message: "An unexpected error occurred",
        success: "false",
      );
    }
  }

  // Future<GenericResponseModal> verifyOtp(String phoneNumber, String phoneCode, String otp) async {
  //   try {
  //     final response = await _apiService.dio.post(
  //       ApiUrl.verifyOtp,
  //       data: {
  //         'phoneNumber': phoneNumber,
  //         'phoneCode': phoneCode,
  //         'otp': otp,
  //       },
  //     );

  //     // Parse the response to GenericResponseModal model
  //     return GenericResponseModal.fromMap(response.data);
  //   } catch (e) {
  //     if (e is DioException) {
  //       // Handle Dio specific errors
  //       return GenericResponseModal(
  //         status: e.response?.statusCode.toString() ?? "500",
  //         message: e.message ?? "Something went wrong",
  //         success: "false",
  //       );
  //     }
  //     // Handle general errors
  //     return GenericResponseModal(
  //       status: "500",
  //       message: "An unexpected error occurred",
  //       success: "false",
  //     );
  //   }
  // }

  // Check if user exists (optional method that might be useful)
  // Future<GenericResponseModal> checkUserExists(String phoneNumber, String phoneCode) async {
  //   try {
  //     final response = await _apiService.dio.post(
  //       ApiUrl.checkUser,
  //       data: {
  //         'phoneNumber': phoneNumber,
  //         'phoneCode': phoneCode,
  //       },
  //     );

  //     // Parse the response to GenericResponseModal
  //     return GenericResponseModal.fromMap(response.data);
  //   } catch (e) {
  //     if (e is DioException) {
  //       // Handle Dio specific errors
  //       return GenericResponseModal(
  //         status: e.response?.statusCode.toString() ?? "500",
  //         message: e.message ?? "Something went wrong",
  //         success: "false",
  //       );
  //     }
  //     // Handle general errors
  //     return GenericResponseModal(
  //       status: "500",
  //       message: "An unexpected error occurred",
  //       success: "false",
  //     );
  //   }
  // }
}
