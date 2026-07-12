import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/fortune_tone.dart';

const fortuneToneStorageKey = 'selected_fortune_tone';

final fortuneToneProvider =
    StateNotifierProvider<FortuneToneNotifier, FortuneTone>(
      (ref) => FortuneToneNotifier(),
    );

class FortuneToneNotifier extends StateNotifier<FortuneTone> {
  FortuneToneNotifier() : super(FortuneTone.base) {
    _loadSavedTone();
  }

  final Logger _logger = Logger();

  Future<void> _loadSavedTone() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString(fortuneToneStorageKey);
    final savedTone = FortuneTone.fromStorage(savedValue);
    if (savedValue != null && savedTone == FortuneTone.base) {
      final isKnownBaseValue =
          savedValue == FortuneTone.base.storageValue || savedValue == 'base';
      if (!isKnownBaseValue) {
        _logger.w('알 수 없는 운세 멘트 선택값입니다. 기본값으로 복구합니다: $savedValue');
      }
    }
    state = savedTone;
  }

  Future<void> setTone(FortuneTone tone) async {
    // 저장을 먼저 완료해야 상태 변경으로 재계산되는 쪽(dailyFortune 등)이
    // 옛 저장값을 읽는 레이스가 없다.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(fortuneToneStorageKey, tone.storageValue);
    state = tone;
  }
}
