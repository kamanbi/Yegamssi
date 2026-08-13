import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundRefreshPermissionService {
  BackgroundRefreshPermissionService._();

  static const MethodChannel _channel = MethodChannel('yegamssi/app_control');
  static const _openCountKey = 'battery_exception_prompt_open_count';
  static const _suppressedKey = 'battery_exception_prompt_suppressed';
  static const _policyVersionKey = 'battery_exception_prompt_policy_version';
  static const _policyVersion = 2;
  static const _promptInterval = 5;

  static Future<bool> isBatteryOptimizationIgnored() async {
    try {
      return await _channel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> requestBatteryOptimizationException() async {
    try {
      return await _channel.invokeMethod<bool>(
            'requestIgnoreBatteryOptimizations',
          ) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> shouldShowBatteryOptimizationReminder() async {
    if (await isBatteryOptimizationIgnored()) return false;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_policyVersionKey) != _policyVersion) {
      await prefs.remove(_suppressedKey);
      await prefs.remove(_openCountKey);
      await prefs.setInt(_policyVersionKey, _policyVersion);
    }

    final nextCount = (prefs.getInt(_openCountKey) ?? 0) + 1;
    await prefs.setInt(_openCountKey, nextCount);
    return nextCount == 1 || nextCount % _promptInterval == 0;
  }
}
