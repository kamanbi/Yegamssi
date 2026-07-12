import 'package:dio/dio.dart';

import '../config/app_config.dart';

enum WeatherProxyProvider { kma, airKorea, openWeather, airNow }

class WeatherProxyDio {
  WeatherProxyDio._();

  static Dio create(WeatherProxyProvider provider) {
    final proxyUrl = AppConfig.weatherProxyUrl;
    const anonKey = AppConfig.supabaseAnonKey;
    if (proxyUrl.isEmpty || anonKey.isEmpty) {
      throw StateError('Weather proxy configuration is missing.');
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: proxyUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      ),
    );
    dio.interceptors.add(_WeatherProxyInterceptor(provider));
    return dio;
  }
}

class _WeatherProxyInterceptor extends Interceptor {
  _WeatherProxyInterceptor(this.provider);

  final WeatherProxyProvider provider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final upstreamPath = options.path;
    options.path = '';
    options.queryParameters = {
      'provider': provider.name,
      'path': upstreamPath,
      ...options.queryParameters,
    };
    handler.next(options);
  }
}
