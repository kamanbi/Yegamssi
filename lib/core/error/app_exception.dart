sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred']);
}

class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

class LocationException extends AppException {
  const LocationException([super.message = 'Location unavailable']);
}

class ParseException extends AppException {
  const ParseException([super.message = 'Failed to parse data']);
}

class FortuneNoProfileException extends AppException {
  const FortuneNoProfileException() : super('생년월일이 입력되지 않았습니다');
}
