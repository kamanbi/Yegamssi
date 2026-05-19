import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'in_app_update_manager.dart';

part 'in_app_update_provider.g.dart';

@riverpod
InAppUpdateManager inAppUpdateManager(Ref ref) {
  return InAppUpdateManager();
}

/// 앱 시작 시 업데이트 확인
@riverpod
Future<void> checkForAppUpdate(Ref ref, BuildContext context) async {
  final updateManager = ref.watch(inAppUpdateManagerProvider);
  await updateManager.checkForUpdate(context);
}
