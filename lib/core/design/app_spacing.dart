import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double x1 = 8;
  static const double x2 = 16;
  static const double x3 = 24;
  static const double x4 = 32;

  static const EdgeInsets screen = EdgeInsets.fromLTRB(x2, x1, x2, x4);
  static const EdgeInsets card = EdgeInsets.all(x2);
  static const EdgeInsets hero = EdgeInsets.all(x3);
  static const EdgeInsets pill =
      EdgeInsets.symmetric(horizontal: x2, vertical: x1);
}
