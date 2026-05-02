import 'package:dio/dio.dart';
import 'package:lets_vhandar/core/api/dio_client.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';

class ApiClient {
  final DioClient _dioClient;

  ApiClient(this._dioClient);

  Future<Result<dynamic, Failure>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(_addStatusToData(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(NetworkFailure(e.toString()));
    }
  }

  Future<Result<dynamic, Failure>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(_addStatusToData(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(NetworkFailure(e.toString()));
    }
  }

  Future<Result<dynamic, Failure>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(_addStatusToData(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(NetworkFailure(e.toString()));
    }
  }

  Future<Result<dynamic, Failure>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(_addStatusToData(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(NetworkFailure(e.toString()));
    }
  }

  Future<Result<dynamic, Failure>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(_addStatusToData(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(NetworkFailure(e.toString()));
    }
  }

  dynamic _addStatusToData(Response response) {
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data = Map.from(response.data);
      if (data['statusCode'] == null) {
        data['statusCode'] = response.statusCode;
      }
      return data;
    }
    return response.data;
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure("Connection timed out");
      case DioExceptionType.badResponse:
        final message =
            error.response?.data['message'] ?? "Unknown Server Error";
        return ServerFailure(message, statusCode: error.response?.statusCode);
      case DioExceptionType.cancel:
        return const NetworkFailure("Request cancelled");
      default:
        return const NetworkFailure("Something went wrong");
    }
  }
}
