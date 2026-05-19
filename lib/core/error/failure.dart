sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '네트워크 연결을 확인해주세요.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = '서버 오류가 발생했습니다.']);
  final int? statusCode = null;
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = '위치 정보를 가져올 수 없습니다.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = '저장된 데이터를 불러올 수 없습니다.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '알 수 없는 오류가 발생했습니다.']);
}
