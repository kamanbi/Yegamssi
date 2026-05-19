import 'package:dio/dio.dart';

import '../error/app_exception.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        const NetworkException('요청 시간이 초과되었습니다.'),
      DioExceptionType.connectionError =>
        const NetworkException('인터넷 연결을 확인해주세요.'),
      DioExceptionType.badResponse => ServerException(
          'HTTP ${err.response?.statusCode}',
          statusCode: err.response?.statusCode,
        ),
      _ => const NetworkException(),
    };

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        message: exception.message,
      ),
    );
  }
}
