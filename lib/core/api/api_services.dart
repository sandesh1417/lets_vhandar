import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import 'interceptor.dart';

late Dio _dio;

class RestApi {
  RestApi() {
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

class RestApiBaseLess {
  RestApiBaseLess() {
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

dynamic handleResponseDio(Response response) {
  try {
    Map<String, dynamic> result = {};
    result = response.data;
    if (result['status'] == null) {
      result['status'] = response.statusCode;
    }
    return result;
  } catch (e) {
    return {
      "status": response.statusCode,
    };
  }
  // return null;
}
