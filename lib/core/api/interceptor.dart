import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:lets_vhandar/core/constants/r_session.dart';
import 'package:lets_vhandar/core/local/shared_preferences_services.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/di/service_locator.dart';

class ApiInterceptor extends Interceptor {
  // Debounce flag so a burst of 401s only triggers one logout.
  bool _loggingOut = false;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.putIfAbsent('Content-Type', () => 'application/json');
    options.headers.putIfAbsent('Accept', () => 'application/json');

    final token = Rsession.token;
    if (token != null) {
      options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
    }

    if (kDebugMode) {
      log('→ ${options.method.toUpperCase()} ${options.baseUrl}${options.path}');
      if (options.queryParameters.isNotEmpty) {
        log('  query: ${options.queryParameters}');
      }
      if (options.data != null) {
        log('  body: ${options.data}');
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log('← ${response.statusCode} ${response.requestOptions.path}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log('✗ ${err.response?.statusCode} ${err.requestOptions.path} — ${err.message}');
    }

    // Some endpoints (e.g. user search) return 401 for "not found" rather than
    // session expiry — opt them out of auto-logout via extra['skipAutoLogout'].
    final skip = err.requestOptions.extra['skipAutoLogout'] == true;
    if (err.response?.statusCode == 401 && !_loggingOut && !skip) {
      _loggingOut = true;
      scheduleMicrotask(() async {
        try {
          Rsession.token = null;
          await SessionPreferences().clearSession();
          locator<LVGoRouter>().goRoute.go(LVRoute.loginScreen.route);
        } finally {
          _loggingOut = false;
        }
      });
    }

    super.onError(err, handler);
  }
}
