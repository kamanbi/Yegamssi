import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';

class BirthPickerResult {
  const BirthPickerResult({required this.birthDate, required this.birthHour});

  final DateTime birthDate;
  final int birthHour;
}

class BirthPickerSheet {
  BirthPickerSheet._();

  static const int minBirthYear = 1900;
  static const double wheelItemExtent = 48;
  static const double sheetPickerHeight = 220;

  static Future<DateTime?> pickBirthDate(
    BuildContext context, {
    required DateTime initialDate,
  }) async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    var selectedDate = _normalizeDate(
      initialDate.isAfter(now) ? now : initialDate,
    );

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _SheetScaffold(
          title: l10n.birthDate,
          onConfirm: () => Navigator.of(sheetContext).pop(selectedDate),
          child: CupertinoTheme(
            data: const CupertinoThemeData(
              brightness: Brightness.dark,
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            child: SizedBox(
              height: sheetPickerHeight,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selectedDate,
                minimumYear: minBirthYear,
                maximumDate: now,
                onDateTimeChanged: (value) {
                  selectedDate = _normalizeDate(value);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<int?> pickBirthHour(
    BuildContext context, {
    required int initialHour,
  }) async {
    final l10n = AppLocalizations.of(context);
    final options = _hourOptions;
    final normalizedHour = options.contains(initialHour)
        ? initialHour
        : UserProfile.unknownBirthHour;
    var selectedIndex = options.indexOf(normalizedHour);

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _SheetScaffold(
          title: l10n.birthHour,
          onConfirm: () =>
              Navigator.of(sheetContext).pop(options[selectedIndex]),
          child: CupertinoTheme(
            data: const CupertinoThemeData(
              brightness: Brightness.dark,
              textTheme: CupertinoTextThemeData(
                pickerTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            child: SizedBox(
              height: sheetPickerHeight,
              child: CupertinoPicker(
                itemExtent: wheelItemExtent,
                magnification: 1.15,
                useMagnifier: true,
                squeeze: 1.1,
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
                children: options
                    .map(
                      (hour) => Center(
                        child: Text(
                          _hourLabel(l10n, hour),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<BirthPickerResult?> editBirthProfile(
    BuildContext context, {
    required BirthPickerResult initialValue,
  }) async {
    final pickedDate = await pickBirthDate(
      context,
      initialDate: initialValue.birthDate,
    );
    if (pickedDate == null || !context.mounted) {
      return null;
    }

    final pickedHour = await pickBirthHour(
      context,
      initialHour: initialValue.birthHour,
    );
    if (pickedHour == null) {
      return null;
    }

    return BirthPickerResult(birthDate: pickedDate, birthHour: pickedHour);
  }

  static DateTime _normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static List<int> get _hourOptions => [
    UserProfile.unknownBirthHour,
    ...List.generate(
      24,
      (hour) => hour,
    ).where((hour) => hour != UserProfile.unknownBirthHour),
  ];

  static String _hourLabel(AppLocalizations l10n, int hour) {
    if (hour == UserProfile.unknownBirthHour) {
      return l10n.birthUnknownNoonShort;
    }
    return l10n.hourLabel(hour);
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.child,
    required this.onConfirm,
  });

  final String title;
  final Widget child;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withAlpha(238),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: onConfirm,
                  child: Text(
                    l10n.confirm,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
