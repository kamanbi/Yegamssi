import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'in_app_update_manager.dart';

/// 앱 시작 시 구글 플레이 업데이트 확인
/// 루트 위젯 아래에 배치하여 BuildContext를 통해 다이얼로그 표시
class UpdateCheckerWidget extends ConsumerStatefulWidget {
  const UpdateCheckerWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<UpdateCheckerWidget> createState() => _UpdateCheckerWidgetState();
}

class _UpdateCheckerWidgetState extends ConsumerState<UpdateCheckerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    if (!mounted) return;
    final updateManager = InAppUpdateManager();
    await updateManager.checkForUpdate(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
