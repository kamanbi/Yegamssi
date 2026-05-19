import 'package:flutter/widgets.dart';

class AppRadius {
  AppRadius._();

  static const Radius medium = Radius.circular(16);
  static const Radius large = Radius.circular(24);
  static const Radius hero = Radius.circular(32);
  static const Radius pill = Radius.circular(999);

  static const BorderRadius card = BorderRadius.all(large);
  static const BorderRadius heroCard = BorderRadius.all(hero);
  static const BorderRadius button = BorderRadius.all(medium);
  static const BorderRadius chip = BorderRadius.all(pill);
}
