import 'package:flutter/material.dart';

import '../../../../core/design/app_spacing.dart';

class ActivityResultActions extends StatelessWidget {
  const ActivityResultActions({
    super.key,
    required this.onEditConditions,
    required this.onRecalculate,
    required this.onSaveAsNew,
    required this.onDelete,
    this.isCalculating = false,
  });

  static const double buttonHeight = 70;
  static const double iconSize = 38;
  static const double labelSize = 12;

  final VoidCallback onEditConditions;
  final VoidCallback? onRecalculate;
  final VoidCallback onSaveAsNew;
  final VoidCallback onDelete;
  final bool isCalculating;

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionItem>[
      _ActionItem(
        asset: 'assets/icons/activity/edit_conditions.png',
        label: '조건 변경',
        onPressed: onEditConditions,
      ),
      _ActionItem(
        asset: 'assets/icons/activity/recalculate.png',
        label: isCalculating ? '계산 중' : '다시 계산',
        onPressed: isCalculating ? null : onRecalculate,
      ),
      _ActionItem(
        asset: 'assets/icons/activity/save_new.png',
        label: '저장',
        onPressed: onSaveAsNew,
      ),
      _ActionItem(
        asset: 'assets/icons/activity/delete_judgment.png',
        label: '삭제',
        onPressed: onDelete,
      ),
    ];

    return SizedBox(
      height: buttonHeight * 2 + AppSpacing.x1,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: buttonHeight,
          mainAxisSpacing: AppSpacing.x1,
          crossAxisSpacing: AppSpacing.x1,
        ),
        itemCount: actions.length,
        itemBuilder: (_, index) => _ActionCommand(item: actions[index]),
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.asset,
    required this.label,
    required this.onPressed,
  });

  final String asset;
  final String label;
  final VoidCallback? onPressed;
}

class _ActionCommand extends StatelessWidget {
  const _ActionCommand({required this.item});

  final _ActionItem item;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      enabled: item.onPressed != null,
      label: item.label,
      onTap: item.onPressed,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: item.onPressed == null ? 0.38 : 1,
                    child: Image.asset(
                      item.asset,
                      width: ActivityResultActions.iconSize,
                      height: ActivityResultActions.iconSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: item.onPressed == null
                              ? foregroundColor.withAlpha(97)
                              : foregroundColor,
                          fontSize: ActivityResultActions.labelSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
