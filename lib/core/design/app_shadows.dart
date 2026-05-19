import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> surface(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        const BoxShadow(
          color: Color(0x38000000),
          blurRadius: 28,
          offset: Offset(0, 14),
        ),
      ];
    }

    return [
      const BoxShadow(
        color: Color(0x10244A7B),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ];
  }

  static List<BoxShadow> hero(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        const BoxShadow(
          color: Color(0x4C000000),
          blurRadius: 36,
          offset: Offset(0, 18),
        ),
        const BoxShadow(
          color: Color(0x4D4A78FF),
          blurRadius: 28,
          offset: Offset(0, 10),
        ),
      ];
    }

    return [
      const BoxShadow(
        color: Color(0x1A325BFF),
        blurRadius: 32,
        offset: Offset(0, 18),
      ),
      const BoxShadow(
        color: Color(0x144E78D9),
        blurRadius: 22,
        offset: Offset(0, 10),
      ),
    ];
  }
}
