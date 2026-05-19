import '../entities/oheng.dart';
import '../../../weather/domain/entities/weather_entity.dart';

/// 날씨 조건 → 오행 매핑
class WeatherOhengMapper {
  WeatherOhengMapper._();

  static Oheng? toOheng(WeatherCondition condition) {
    return switch (condition) {
      // 火: 해·뜨거움
      WeatherCondition.sunny => Oheng.hwa,
      WeatherCondition.hot => Oheng.hwa,
      // 土: 구름·안개 (대기의 정체)
      WeatherCondition.partlyCloudy => Oheng.to,
      WeatherCondition.cloudy => Oheng.to,
      WeatherCondition.hazy => Oheng.to,
      // 木: 바람·천둥 (동적 기운)
      WeatherCondition.windy => Oheng.mok,
      WeatherCondition.thunderstorm => Oheng.mok,
      WeatherCondition.rainThunder => Oheng.mok,
      // 水: 비·눈·진눈깨비
      WeatherCondition.slightRain => Oheng.su,
      WeatherCondition.rainy => Oheng.su,
      WeatherCondition.heavyRain => Oheng.su,
      WeatherCondition.lightSnow => Oheng.su,
      WeatherCondition.snowy => Oheng.su,
      WeatherCondition.sleet => Oheng.su,
      // 金: 한파 (차가운 금속성)
      WeatherCondition.coldWave => Oheng.geum,
      WeatherCondition.unknown => null,
    };
  }
}
