import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/address/domain/models/address_model.dart';
import 'package:lets_vhandar/features/address/domain/models/address_response.dart';

class AddressRepository {
  final ApiClient _apiClient;

  AddressRepository(this._apiClient);

  Future<Result<AddressResponse, Failure>> getAddresses(String userId) async {
    try {
      final result = await _apiClient.get(ApiUrl.userAddresses(userId));
      switch (result) {
        case Success(value: final data):
          return Success(AddressResponse.fromMap(data));
        case Error(failure: final failure):
          throw failure;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<bool, Failure>> addAddress({
    required String userId,
    required double lat,
    required double long,
    required String description,
    required String addressType,
    String? name,
    String? landMark,
    String? locality,
    String? floor,
    String? phoneNumber,
    String? houseNumber,
  }) async {
    try {
      final result = await _apiClient.post(
        ApiUrl.addresses,
        data: {
          'userId': userId,
          'lat': lat,
          'long': long,
          'description': description,
          'addressType': addressType,
          if (name != null) 'name': name,
          if (landMark != null) 'landMark': landMark,
          if (locality != null) 'locality': locality,
          if (floor != null) 'floor': floor,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (houseNumber != null) 'houseNumber': houseNumber,
        },
      );
      switch (result) {
        case Success():
          return const Success(true);
        case Error(failure: final failure):
          throw failure;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<AddressModel, Failure>> updateAddress({
    required String addressId,
    required double lat,
    required double long,
    required String description,
    required String addressType,
    String? name,
    String? landMark,
    String? locality,
    String? floor,
    String? phoneNumber,
    String? houseNumber,
  }) async {
    try {
      final result = await _apiClient.patch(
        '${ApiUrl.addresses}/$addressId',
        data: {
          'lat': lat,
          'long': long,
          'description': description,
          'addressType': addressType,
          if (name != null) 'name': name,
          if (landMark != null) 'landMark': landMark,
          if (locality != null) 'locality': locality,
          if (floor != null) 'floor': floor,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (houseNumber != null) 'houseNumber': houseNumber,
        },
      );
      switch (result) {
        case Success(value: final data):
          return Success(AddressModel.fromMap(data['data']));
        case Error(failure: final failure):
          throw failure;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
