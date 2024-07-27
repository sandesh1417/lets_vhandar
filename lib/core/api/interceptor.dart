import 'dart:developer';

// import 'package:celestria/core/constants/r_session.dart';
import 'package:dio/dio.dart';
import 'package:lets_vhandar/core/constants/r_session.dart';

// import 'package:shared_preferences/shared_preferences.dart';

class ApiInterceptor extends Interceptor {
  String red = '\u001b[31m';
  String white = '\u001b[37;1m';
  String cyan = '\u001b[36;1m';
  String reset = '\u001b[36;1m';

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    log("$white=======================================================================================================================================");
    log("$white${options.method.isNotEmpty ? options.method.toUpperCase() : 'METHOD'} ${"${options.baseUrl}${options.path}"}");
    options.headers.putIfAbsent("Content-Type", () => 'application/json');
    // options.headers.putIfAbsent(
    //   "Content-Type",
    //   () => 'application/x-www-form-urlencoded',
    // );
    options.headers.putIfAbsent("Accept", () => 'application/json');

    var token = Rsession.token;

    if (token != null) {
      options.headers.putIfAbsent("Authorization", () => "Bearer $token");
    }

    log("$white Headers:");
    options.headers.forEach((k, v) => log('$white $k: $v'));
    if (options.queryParameters.isNotEmpty) {
      log("$white queryParameters:");
      options.queryParameters.forEach((k, v) => log('$k: $v'));
    }
    if (options.data != null) {
      log("$white Body: ${options.data}");
    }
    log("$white END ${options.method.isNotEmpty ? options.method.toUpperCase() : 'METHOD'}");
    log("$white=======================================================================================================================================");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // log("$cyan=======================================================================================================================================");
    // log("$cyan${response.statusCode} ${(response.data != null ? (response.requestOptions.baseUrl + response.requestOptions.path) : 'URL')}");
    // log("{$cyan}Headers:");
    // response.headers.forEach((k, v) => log('$cyan$k: $v'));
    log("${cyan}Response: ${response.data}");
    // log("${cyan}END HTTP");
    // log("$cyan=======================================================================================================================================");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log("$red=======================================================================================================================================");
    log("$red${err.message} ${(err.response?.data != null ? "" : 'URL')}");
    // if (err.requestOptions.baseUrl == Endpoints.baseUrl){
    //   if (err.response?.statusCode == 401) {
    //     // AppRouter.pushThisRemoveRest(
    //     //     context: navigatorKey.currentContext!,
    //     //     pageName: AppRouter.loginScreen);
    //     // CustomSnackbar.showSnackbar(
    //     //     message: "Login Session Expired !", toastLength: Toast.LENGTH_SHORT);
    //   }
    // }
    log("$red${err.response != null ? err.response?.data : 'Unknown Error'}");
    log("${red}End error");
    log("$red${err.response?.statusCode}");
    log("$red${err.response.toString()}");
    log("$red=======================================================================================================================================");
    super.onError(err, handler);
  }
}
