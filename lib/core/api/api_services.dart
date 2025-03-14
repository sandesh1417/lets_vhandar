import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import 'interceptor.dart';

late Dio _dio;

class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiUrl.baseUrl,
        connectTimeout: const Duration(seconds: 60),
      ),
    );
    dio.interceptors.add(ApiInterceptor());
  }

  Dio get dio => _dio;
}

dynamic addResponseStatus(Response response) {
  try {
    Map<String, dynamic> result = {};
    result = response.data;
    if (result['statusCode'] == null) {
      result['statusCode'] = response.statusCode;
    }
    return result;
  } catch (e) {
    return {
      "status": response.statusCode,
    };
  }
  // return null;
}

parseErrorMessage(DioException e) {
  return e.response?.data["message"] ?? "Something went wrong";
}
