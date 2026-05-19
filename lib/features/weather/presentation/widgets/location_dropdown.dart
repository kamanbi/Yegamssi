import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/saved_location.dart';
import '../weather_location_provider.dart';

class LocationDropdown extends ConsumerWidget {
  const LocationDropdown({super.key});

  static const double _menuTopOffset = 92;
  static const double _menuMaxWidth = 320;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(weatherLocationNotifierProvider);
    final selectedLocation = locationState.location;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showTopLocationMenu(context, ref),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              selectedLocation?.name ?? '현재 위치',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.expand_more_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }

  void _showTopLocationMenu(BuildContext context, WidgetRef ref) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '위치 선택 닫기',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (dialogContext, _, __) {
        return _TopLocationMenu(
          onClose: () => Navigator.of(dialogContext).pop(),
          onAddFavorite: () {
            Navigator.of(dialogContext).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                _showAddFavoriteDialog(context, ref);
              }
            });
          },
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.03),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  void _showAddFavoriteDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => _AddFavoriteDialog(
        onAdd: (location) async {
          final success =
              await ref.read(favoriteLocationsProvider.notifier).add(location);
          if (!context.mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? '${location.name} 추가되었습니다'
                    : '최대 5개까지 추가 가능합니다',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

class _TopLocationMenu extends ConsumerWidget {
  const _TopLocationMenu({
    required this.onClose,
    required this.onAddFavorite,
  });

  final VoidCallback onClose;
  final VoidCallback onAddFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(weatherLocationNotifierProvider);
    final favoritesAsync = ref.watch(favoriteLocationsProvider);
    final favorites = favoritesAsync.valueOrNull ?? [];
    final selectedLocation = locationState.location;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            LocationDropdown._menuTopOffset,
            16,
            0,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LocationDropdown._menuMaxWidth,
            ),
            child: Material(
              color: const Color(0xFF17223D),
              elevation: 18,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LocationMenuTile(
                      icon: Icons.my_location_rounded,
                      label: '현재 위치',
                      selected: selectedLocation == null,
                      onTap: () {
                        ref
                            .read(weatherLocationNotifierProvider.notifier)
                            .reset();
                        onClose();
                      },
                    ),
                    if (favorites.isNotEmpty) const _MenuDivider(),
                    for (final favorite in favorites)
                      _LocationMenuTile(
                        icon: Icons.star_rounded,
                        iconColor: selectedLocation?.name == favorite.name
                            ? const Color(0xFFFFD76A)
                            : AppColors.textMuted,
                        label: favorite.name,
                        selected: selectedLocation?.name == favorite.name,
                        trailing: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => ref
                              .read(favoriteLocationsProvider.notifier)
                              .remove(favorite),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                            size: 16,
                          ),
                        ),
                        onTap: () {
                          ref
                              .read(weatherLocationNotifierProvider.notifier)
                              .select(favorite);
                          onClose();
                        },
                      ),
                    const _MenuDivider(),
                    _LocationMenuTile(
                      icon: Icons.add_rounded,
                      label: favorites.length >= 5 ? '즐겨찾기 가득 참' : '즐겨찾기 추가',
                      enabled: favorites.length < 5,
                      onTap: favorites.length < 5 ? onAddFavorite : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationMenuTile extends StatelessWidget {
  const _LocationMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.trailing,
    this.selected = false,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Widget? trailing;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled
        ? (selected ? const Color(0xFF7EB8FF) : AppColors.textSecondary)
        : AppColors.textMuted;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor ?? effectiveColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: Color(0xFF7EB8FF),
              ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withAlpha(18),
    );
  }
}

class _AddFavoriteDialog extends ConsumerStatefulWidget {
  const _AddFavoriteDialog({required this.onAdd});

  final Future<void> Function(SavedLocation) onAdd;

  @override
  ConsumerState<_AddFavoriteDialog> createState() => _AddFavoriteDialogState();
}

class _AddFavoriteDialogState extends ConsumerState<_AddFavoriteDialog> {
  final _controller = TextEditingController();
  List<SavedLocation> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final keyword = query.trim();
    if (keyword.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _searching = true);
    final results = await ref.read(searchLocationProvider(keyword).future);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2640),
      title: const Text(
        '지역 검색',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 서울, 부산, Tokyo',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: Colors.white.withAlpha(15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF7EB8FF)),
                ),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : null,
              ),
              onSubmitted: _search,
            ),
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final location = _results[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.place_rounded,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      title: Text(
                        location.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${location.lat.toStringAsFixed(3)}, ${location.lon.toStringAsFixed(3)}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      dense: true,
                      onTap: () => widget.onAdd(location),
                    );
                  },
                ),
              ),
            ] else if (!_searching && _controller.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '검색 결과가 없습니다',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
        TextButton(
          onPressed: () => _search(_controller.text),
          child: const Text('검색'),
        ),
      ],
    );
  }
}
