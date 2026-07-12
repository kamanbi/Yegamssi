import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'api_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create({
    required String baseUrl,
    Duration connectTimeout = const Duration(
      seconds: 10,
    ), // ignore: avoid_redundant_argument_values
    Duration receiveTimeout = const Duration(
      seconds: 15,
    ), // ignore: avoid_redundant_argument_values
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(ApiInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(logPrint: (obj) => Logger().d(obj)));
    }

    return dio;
  }
}
