import 'package:dio/dio.dart';
import 'package:lets_vhandar/core/api/interceptor.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiUrl.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(ApiInterceptor());
  }

  Dio get dio => _dio;
}
