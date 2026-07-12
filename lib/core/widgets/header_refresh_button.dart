import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
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
      await ref.read(appRefreshControllerProvider).refreshSignals(force: true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.refreshFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      onPressed: _refresh,
      tooltip: l10n.refresh,
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
