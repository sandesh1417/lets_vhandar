import 'package:dio/dio.dart';
import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/modals/generic_response_modal.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/auth/login/models/login_response_modal.dart';
import 'package:lets_vhandar/features/auth/login/models/user_profile_response.dart';

class AuthRepositoryImpl {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  Future<Result<UserProfileResponse, Failure>> getUserProfile(String id) async {
    try {
      final result = await _apiClient.get(ApiUrl.userProfile(id));
      switch (result) {
        case Success(value: final data):
          return Success(UserProfileResponse.fromMap(data));
        case Error(failure: final failure):
          throw failure;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

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

  Future<Result<GenericResponseModal, Failure>> sendOtpForgetPassword(
      String phoneNumber, String? phoneCode) async {
    try {
      final result = await _apiClient.post(
        ApiUrl.forgetPasswordSendOTP,
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

  Future<Result<GenericResponseModal, Failure>> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? phoneCode,
  }) async {
    try {
      final result = await _apiClient.post(
        ApiUrl.verifyOTP,
        data: {
          'phoneNumber': phoneNumber,
          // 'phoneCode': phoneCode ?? '+977',
          'otp': otp,
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

  Future<Result<GenericResponseModal, Failure>> resetPassword({
    required String phoneNumber,
    required String otp,
    required String password,
    required String confirmPassword,
    String? phoneCode,
  }) async {
    try {
      final data = {
        'phoneNumber': phoneNumber,
        'phoneCode': phoneCode ?? '+977',
        'otp': otp,
        'password': password,
        'confirmPassword': confirmPassword,
      };
      final result = await _apiClient.post(
        ApiUrl.resetPassword,
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

  Future<Result<GenericResponseModal, Failure>> changePassword({
    required String userId,
    required String oldPassword,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final data = {
        'authorizedUser': {
          'userId': userId,
        },
        'oldPassword': oldPassword,
        'password': password,
        'confirmPassword': confirmPassword,
      };
      final result = await _apiClient.patch(
        ApiUrl.changePassword,
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

  Future<Result<GenericResponseModal, Failure>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final result = await _apiClient.patch(ApiUrl.updateProfile, data: data);
      final parsed = _handleResult(result);
      return Success(parsed);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  // ── Family Members ────────────────────────────────────────────────────────

  Future<Result<Map<String, dynamic>?, Failure>> searchUserByPhone(
      String phoneNumber) async {
    try {
      final result = await _apiClient.get(
        ApiUrl.searchUsers,
        queryParameters: {'phoneNumber': phoneNumber},
        // 401 here means "not found", not session expiry — skip auto-logout.
        options: Options(extra: {'skipAutoLogout': true}),
      );
      switch (result) {
        case Success(value: final data):
          final payload = data['data'];
          // Paginated: { data: { data: [user, ...], pagination: {} } }
          if (payload is Map<String, dynamic> && payload['data'] is List) {
            final list = payload['data'] as List;
            if (list.isNotEmpty && list.first is Map<String, dynamic>) {
              return Success(Map<String, dynamic>.from(list.first));
            }
            return const Success(null);
          }
          // Direct user object: { data: { _id: ..., name: ... } }
          if (payload is Map<String, dynamic> &&
              payload.containsKey('_id')) {
            return Success(payload);
          }
          // Array: { data: [user] }
          if (payload is List && payload.isNotEmpty &&
              payload.first is Map<String, dynamic>) {
            return Success(Map<String, dynamic>.from(payload.first));
          }
          // Unknown shape — log in debug so we can see what the backend returns
          assert(() {
            // ignore: avoid_print
            print('[searchUserByPhone] unexpected payload type: '
                '${payload.runtimeType} — $payload');
            return true;
          }());
          return const Success(null);
        case Error(failure: final f):
          final code = f is ServerFailure ? f.statusCode : null;
          // 404 → user not found
          if (code == 404) return const Success(null);
          // 403 → endpoint is restricted for regular users; surface a clear message
          if (code == 403) {
            return const Error(ServerFailure(
              'This phone number is not registered on Vhandar.',
            ));
          }
          throw f;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<List<Map<String, dynamic>>, Failure>> getFamilyMembers(
      String userId) async {
    try {
      final result =
          await _apiClient.get(ApiUrl.familyMembersForUser(userId));
      switch (result) {
        case Success(value: final data):
          return Success(_extractList(data['data']));
        case Error(failure: final failure):
          throw failure;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<List<Map<String, dynamic>>, Failure>> getPendingFamilyRequests(
      String userId) async {
    try {
      final result =
          await _apiClient.get(ApiUrl.familyMemberRequests(userId));
      switch (result) {
        case Success(value: final data):
          return Success(_extractList(data['data']));
        case Error(failure: final failure):
          throw failure;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  /// Handles both flat `[...]` and paginated `{data:[...], pagination:{}}` shapes.
  List<Map<String, dynamic>> _extractList(dynamic payload) {
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final inner = payload['data'];
      if (inner is List) {
        return inner.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }

  Future<Result<GenericResponseModal, Failure>> sendFamilyRequest({
    required String memberId,
    required List<String> familyIds,
    required String requestedBy,
    required String relation,
  }) async {
    try {
      final result = await _apiClient.post(
        ApiUrl.familyMembers,
        data: {
          'memberId': memberId,
          'familyIds': familyIds,
          'requestedBy': requestedBy,
          'relation': relation,
          'requestAccepted': false,
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

  Future<Result<GenericResponseModal, Failure>> acceptFamilyRequest(
      String requestId, String relation) async {
    try {
      final result = await _apiClient.patch(
        ApiUrl.familyMemberAccept(requestId),
        data: {'relation': relation},
      );
      final parsed = _handleResult(result);
      return Success(parsed);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<GenericResponseModal, Failure>> removeFamilyMember(
      String requestId) async {
    try {
      final result = await _apiClient.delete(
        ApiUrl.familyMembersForUser(requestId),
      );
      final parsed = _handleResult(result);
      return Success(parsed);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<GenericResponseModal, Failure>> deleteAccount() async {
    try {
      final result = await _apiClient.patch(
        ApiUrl.updateProfile,
        data: {'deleteRequest': true},
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
