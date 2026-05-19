import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../refresh/app_refresh_controller.dart';

class HeaderRefreshButton extends ConsumerStatefulWidget {
  const HeaderRefreshButton({super.key});

  @override
  ConsumerState<HeaderRefreshButton> createState() =>
      _HeaderRefreshButtonState();
}

class _HeaderRefreshButtonState extends ConsumerState<HeaderRefreshButton> {
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    if (_isRefreshing) {
      return;
    }

    setState(() => _isRefreshing = true);
    try {
      await ref.read(appRefreshControllerProvider).refreshSignals();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('새로고침에 실패했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _refresh,
      tooltip: '새로고침',
      icon: _isRefreshing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh_rounded),
    );
  }
}
