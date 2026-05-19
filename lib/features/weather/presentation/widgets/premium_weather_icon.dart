import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entities/weather_entity.dart';
import 'weather_icon_mapper.dart';

/// 16종 날씨 SVG 아이콘 표시 (야간 4종 추가 지원).
///
/// assets/icons/weather/*.svg 를 사용.
class PremiumWeatherIcon extends StatelessWidget {
  const PremiumWeatherIcon({
    super.key,
    required this.condition,
    this.isNight = false,
    this.size = 56,
  });

  final WeatherCondition condition;
  final bool isNight;
  final double size;

  @override
  Widget build(BuildContext context) {
    final assetPath = WeatherIconMapper.assetFor(condition, isNight: isNight);
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(assetPath),
    );
  }
}
